#!/bin/bash



##################
# DEFAULT_VALUES #
##################

LOG_FILE="/var/log/auth.log"
ALERT_LOG="/var/log/sspa_intrusions.log"
WHITELIST="/var/log/sspa_whitelist.txt"
THRESHOLD=5
BLOCK_MODE=false

#########
# USAGE #
#########


usage(){
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -l <logfile>     Fichier de log à analyser (défaut: /var/log/auth.log)"
    echo "  -w <whitelist>   Fichier whitelist d'IP"
    echo "  -t <threshold>   Seuil d'échecs (défaut: 5)"
    echo "  -o <output>      Nom du fichier en sortie (défaut: /var/log/sspa_intrusions.log)"
    echo "  -b <block>       Blocker les IPs suspectes"
    echo "  -h, --help       Afficher cette aide"

    exit 1
}

###########
# LOGIQUE #
###########


# Check Root
if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté en tant que root"
    exit 1
fi



get_failed_ssh_logins(){
    if [ -f "$LOG_FILE" ]; then
        grep "Failed password" "$LOG_FILE"
    else
        journalctl -t sshd \
        | grep "Failed password"
    fi
}


extract_ips(){
    get_failed_ssh_logins | awk '{for(i=1;i<=NF;i++) if ($i=="from") print $(i+1)}'
}

blacklist() {
    extract_ips \
    | sort \
    | uniq -c \
    | awk -v t="$THRESHOLD" '$1 >= t {print $2}'
}

whitelist(){
    local ips
    ips=$(blacklist)

    for ip in $ips; do
        if [[ "$ip" == "127.0.0.1" ]] || [[ "$ip" == "::1" ]]; then
            continue
        fi
        if [ -f "$WHITELIST" ] && grep -Fxq "$ip" "$WHITELIST"; then
            continue
        fi
        echo "$ip"
    done
}

block_ips(){
    local ips
    ips=$(whitelist)

    [ -z "$ips" ] && return

    for ip in $ips; do
        if [[ "$ip" == *:* ]]; then  # Check IPV6
            if ! ip6tables -C INPUT -s "$ip" -j DROP 2>/dev/null; then
                ip6tables -A INPUT -s "$ip" -j DROP
                echo "$(date '+%F %T') | IPv6 bloquée : $ip" >> "$ALERT_LOG"
            fi
        else                         # Check IPV4
            if ! iptables -C INPUT -s "$ip" -j DROP 2>/dev/null; then
                iptables -A INPUT -s "$ip" -j DROP
                echo "$(date '+%F %T') | IPv4 bloquée : $ip" >> "$ALERT_LOG"
            fi
        fi
    done

}

#########
# FLAGS #
#########

for arg in "$@"; do
    if [ "$arg" = "--help" ]; then
        usage
    fi
done

while getopts ":l:w:t:o:bh" opt; do
    case "$opt" in
        l) LOG_FILE="$OPTARG" ;;
        w) WHITELIST="$OPTARG" ;;
        t) THRESHOLD="$OPTARG" ;;
        o) ALERT_LOG="$OPTARG" ;;
        b) BLOCK_MODE=true ;;
        h) usage ;;
        \?) usage ;;
    esac
done


#####################
# GESTION D'ERREURS #
#####################

# Initialisation des fichiers
touch "$ALERT_LOG"
touch "$WHITELIST"


# Si treshold est pas un nombre
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "[ERREUR] Le seuil doit être un nombre."
    exit 1
fi

# Si rien n'est detecté
main(){
    IPS=$(whitelist)

    [ -z "$IPS" ] && echo "[INFO] Rien à signaler." && exit 0

    for ip in $IPS; do
        echo "$(date '+%F %T') | Tentatives SSH suspectes détectées : $ip" >> "$ALERT_LOG"
    done

    [ "$BLOCK_MODE" = true ] && block_ips || echo "$IPS"
}

main
