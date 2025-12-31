#!/bin/bash

##################
# DEFAULT VALUES #
##################

TARGET=""
PORTS_ALLOWED=""
REPORT="audit.html"
REPORT_DIR="/var/log/sspa_alerts/reports"
DATE=$(date +"%Y-%m-%d")
REPORT="$REPORT_DIR/audit_$DATE.html"


DO_PERMS=false
DO_SSH=false
DO_PORTS=false
DO_USERS=false

PERMS_RESULT="<p class='na'>Non audité</p>"
CONF_RESULT="<p class='na'>Non audité</p>"
PORTS_RESULT="<p class='na'>Non audité</p>"
USERS_RESULT="<p class='na'>Non audité</p>"

#########
# USAGE #
#########

usage(){
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -f <path>     Audit permissions dangereuses"
    echo "  -s            Audit configuration SSH (détection)"
    echo "  -p <ports>    Audit ports ouverts (ex: 22,80 ou -)"
    echo "  -u            Audit utilisateurs privilégiés"
    echo "  -o <file>     Rapport HTML (défaut: audit.html)"
    echo "  -h            Aide"
    exit 1
}

###########
# CHECKS #
###########

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Exécuter en root"
    exit 1
fi

###########
# FONCTIONS AUDIT
###########

get_dangerous_perms(){
    find "$TARGET" -type f \( -perm 0777 -o -perm 0666 \) 2>/dev/null
}

check_ssh_rdp(){
    SSH_CONF="/etc/ssh/sshd_config"

    echo "=== Audit SSH ==="

    ROOT_LOGIN=$(grep -Ei "^\s*PermitRootLogin" "$SSH_CONF" | tail -n1 | awk '{print $2}')
    PASS_AUTH=$(grep -Ei "^\s*PasswordAuthentication" "$SSH_CONF" | tail -n1 | awk '{print $2}')
    PROTOCOL=$(grep -Ei "^\s*Protocol" "$SSH_CONF" | tail -n1 | awk '{print $2}')

    [ "$ROOT_LOGIN" != "no" ] && echo "[RISK] PermitRootLogin = $ROOT_LOGIN" || echo "[OK] PermitRootLogin sécurisé"
    [ "$PASS_AUTH" != "no" ] && echo "[RISK] PasswordAuthentication activé" || echo "[OK] PasswordAuthentication désactivé"
    [ "$PROTOCOL" = "1" ] && echo "[CRITICAL] SSH Protocol 1 détecté" || echo "[OK] SSH Protocol sécurisé"
}

audit_open_ports(){
    echo "=== Audit ports ouverts ==="

    OPEN_PORTS=$(ss -tuln | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort -n | uniq)

    if [ "$PORTS_ALLOWED" = "-" ]; then
        echo "[INFO] Tous les ports sont autorisés"
        echo "$OPEN_PORTS"
        return
    fi

    IFS=',' read -ra ALLOWED <<< "$PORTS_ALLOWED"

    for port in $OPEN_PORTS; do
        if [[ ! " ${ALLOWED[*]} " =~ " $port " ]]; then
            echo "[RISK] Port non autorisé : $port"
        else
            echo "[OK] Port autorisé : $port"
        fi
    done
}

find_root_users(){
    echo "=== Audit utilisateurs privilégiés ==="

    awk -F: '$3 == 0 {print "[UID 0] " $1}' /etc/passwd

    for grp in sudo wheel admin; do
        getent group "$grp" >/dev/null && \
        echo "[GROUP $grp] $(getent group "$grp" | cut -d: -f4)"
    done
}

###########
# ADAPTATION HTML
###########

audit_perms(){
    res=$(get_dangerous_perms)
    if [ -z "$res" ]; then
        PERMS_RESULT="<p class='ok'>Aucune permission dangereuse</p>"
    else
        PERMS_RESULT="<ul>"
        while read -r f; do
            PERMS_RESULT+="<li class='alert'>$f</li>"
        done <<< "$res"
        PERMS_RESULT+="</ul>"
    fi
}

audit_ssh(){
    CONF_RESULT="<pre>$(check_ssh_rdp)</pre>"
}

audit_ports_html(){
    PORTS_RESULT="<pre>$(audit_open_ports)</pre>"
}

audit_users(){
    USERS_RESULT="<pre>$(find_root_users)</pre>"
}

###########
# HTML REPORT
###########

rapport_html(){
cat <<EOF > "$REPORT"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>SSPA – Rapport de Sécurité</title>
<style>
/* ===== Reset & Base ===== */
body {
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f4f6f8;
    color: #222;
    margin: 0;
    padding: 20px 50px;
}

/* ===== Titres ===== */
h1 {
    color: #0d47a1;
    font-size: 2em;
    margin-bottom: 5px;
}
.subtitle {
    color: #555;
    margin-bottom: 25px;
    font-size: 1.1em;
}

/* ===== Cards ===== */
.card {
    background: #ffffff;
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 25px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.08);
}
.card h2 {
    margin-top: 0;
    color: #1565c0;
}

/* ===== Metadata ===== */
.meta {
    font-size: 0.95em;
    color: #555;
}

/* ===== Preformatted text ===== */
pre {
    background: #f1f3f4;
    padding: 15px;
    border-radius: 6px;
    overflow-x: auto;
    font-family: Consolas, monospace;
    font-size: 0.9em;
}

/* ===== Alerts & statuses ===== */
.ok {
    color: #2e7d32;
    font-weight: bold;
}
.alert {
    color: #c62828;
    font-weight: bold;
}
.na {
    color: #777;
    font-style: italic;
}

/* ===== Lists ===== */
ul {
    padding-left: 20px;
}

/* ===== Footer ===== */
.footer {
    text-align: center;
    font-size: 0.85em;
    color: #888;
    margin-top: 40px;
    border-top: 1px solid #ddd;
    padding-top: 15px;
}
</style>
</head>
<body>

<h1>SSPA – Daily Security Report</h1>
<div class="subtitle">System & Security Posture Analysis</div>

<div class="card meta">
<b>Date :</b> $(date +"%Y-%m-%d %H:%M:%S")<br>
<b>Cible :</b> ${TARGET:-Non spécifiée}<br>
<b>Mode :</b> Surveillance quotidienne
</div>

<div class="card">
<h2> 1 - Permissions dangereuses</h2>
$PERMS_RESULT
</div>

<div class="card">
<h2> 2 - Configuration SSH / RDP</h2>
$CONF_RESULT
</div>

<div class="card">
<h2> 3 - Ports ouverts</h2>
$PORTS_RESULT
</div>

<div class="card">
<h2> 4 - Utilisateurs privilégiés</h2>
$USERS_RESULT
</div>

<div class="footer">
Rapport généré automatiquement par <b>SSPA</b> – Script d’audit en lecture seule
</div>

</body>
</html>
EOF
}



#########
# FLAGS #
#########

while getopts ":f:sp:uo:h" opt; do
    case "$opt" in
        f) TARGET="$OPTARG"; DO_PERMS=true ;;
        s) DO_SSH=true ;;
        p) PORTS_ALLOWED="$OPTARG"; DO_PORTS=true ;;
        u) DO_USERS=true ;;
        o) REPORT="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[ "$DO_PERMS" = true ] && [ ! -e "$TARGET" ] && echo "[ERREUR] Cible inexistante" && exit 1

###########
# MAIN #
###########

main(){
    mkdir -p "$REPORT_DIR"
    $DO_PERMS && audit_perms
    $DO_SSH && audit_ssh
    $DO_PORTS && audit_ports_html
    $DO_USERS && audit_users

    rapport_html
    echo "[OK] Rapport généré : $REPORT"
}

main
