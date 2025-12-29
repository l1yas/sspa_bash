#!/bin/bash



##################
# DEFAULT_VALUES #
##################

CPU_TRESH=60
MEM_TRESH=40
ALERT_LOG="/var/log/sspa_promon.log"

CHECK_CPU=false
CHECK_MEM=false
RESTART_SERVICE=false

#########
# USAGE #
#########


usage(){
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -c [threshold]     Vérifier l'usage du CPU (défaut: 60%)"
    echo "  -m [threshold]     Vérifier l'usage de la mémoire (défaut: 40%)"
    echo "  -s <service>       Vérifier l'état d'un service"
    echo "  -r                 Redémarrer automatiquement le service"
    echo "  -h                 Afficher cette aide"
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




#########
# FLAGS #
#########

for arg in "$@"; do
    if [ "$arg" = "--help" ]; then
        usage
    fi
done

while getopts ":c:m:s:rh" opt; do
    case "$opt" in
        c)
            CHECK_CPU=true
            if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                CPU_THRESH="$OPTARG"
            else
                OPTIND=$((OPTIND - 1))
            fi
            ;;
        m)
            CHECK_MEM=true
            if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                MEM_THRESH="$OPTARG"
            else
                OPTIND=$((OPTIND - 1))
            fi
            ;;
        s)
            CHECK_SERVICE=true
            SERVICE="$OPTARG"
            ;;
        r)
            RESTART_SERVICE=true
            ;;
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done


# FONCTIONS 

check_cpu(){
    ps -eo pid,comm,%cpu --no-headers \
    | awk -v t="$CPU_THRESH" '$3 > t {print $1, $2, $3}'\
    | while read pid name cpu; do
        echo "$(date '+%F %T') | CPU élevé | PID=$pid | PROC=$name | CPU=${cpu}%" >> "$ALERT_LOG"
        echo "[ALERTE] CPU élevé : $name (PID $pid) ${cpu}%"
    done
}

check_mem(){
    ps -eo pid,comm,%mem --no-headers \
    | awk -v t="$MEM_THRESH" '$3 > t {print $1, $2, $3}'\
    | while read pid name mem; do
        echo "$(date '+%F %T') | MEM élevé | PID=$pid | PROC=$name | MEM=${mem}%" >> "$ALERT_LOG"
        echo "[ALERTE] CPU élevé : $name (PID $pid) ${mem}%"
    done
}


check_suspicious_processes() {
    SUSPICIOUS_PROCS=("nc" "ncat" "netcat" "hydra" "john" "tcpdump")
    for proc in "${SUSPICIOUS_PROCS[@]}"; do
        if pgrep -x "$proc" >/dev/null 2>&1; then
            pids=$(pgrep -x "$proc" | tr '\n' ' ')
            echo "$(date '+%F %T') | Processus suspect détecté : $proc | PID=$pids" >> "$ALERT_LOG"
            echo "[ALERTE] Processus suspect : $proc (PID: $pids)"
        fi
    done
}

check_service() {
    if systemctl is-active --quiet "$SERVICE"; then
        echo "[INFO] Service $SERVICE actif"
    else
        echo "$(date '+%F %T') | Service DOWN : $SERVICE" >> "$ALERT_LOG"
        echo "[ALERTE] Service $SERVICE arrêté"

        if [ "$RESTART_SERVICE" = true ]; then
            systemctl restart "$SERVICE"
            if systemctl is-active --quiet "$SERVICE"; then
                echo "$(date '+%F %T') | Service redémarré : $SERVICE" >> "$ALERT_LOG"
                echo "[INFO] Service $SERVICE redémarré avec succès"
            else
                echo "$(date '+%F %T') | ÉCHEC redémarrage : $SERVICE" >> "$ALERT_LOG"
                echo "[ERREUR] Impossible de redémarrer $SERVICE"
            fi
        fi
    fi
}


#####################
# GESTION D'ERREURS #
#####################

# Initialisation des fichiers
touch "$ALERT_LOG"


main() {

    if [ "$CHECK_CPU" = true ]; then
        check_cpu
    fi

    if [ "$CHECK_MEM" = true ]; then
        check_mem
    fi

    check_suspicious_processes

    if [ "$CHECK_SERVICE" = true ]; then
        check_service
    fi
}

main


