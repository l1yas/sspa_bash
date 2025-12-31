#!/bin/bash

#################################
# SSPA - Security Hardening Tool #
#################################

###############
# VARIABLES   #
###############

LOG_FILE="/var/log/sspa_secharden.log"
DRY_RUN=false

###############
# USAGE       #
###############

usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --dry-run        Affiche les actions sans modifier le système"
    echo "  -h, --help       Affiche cette aide"
    exit 1
}

###############
# CHECK ROOT  #
###############

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être exécuté en tant que root"
    exit 1
fi

###############
# LOGGING     #
###############

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

###############
# PARSING     #
###############

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            usage
            ;;
    esac
done

###############
# FONCTIONS   #
###############

# Correction permissions dangereuses
fix_permissions() {
    log "[INFO] Correction des permissions dangereuses"

    find / -xdev \
        \( -path /proc -o -path /sys -o -path /dev \) -prune -o \
        -type f \( -perm 0777 -o -perm 0666 \) -print | while read file; do

        if [ "$DRY_RUN" = true ]; then
            log "[DRY] chmod 644 $file"
        else
            chmod 644 "$file"
            log "[FIX] Permissions corrigées : $file"
        fi
    done
}

# Désactivation services inutiles
disable_services() {
    log "[INFO] Désactivation des services inutiles"

    SERVICES=("avahi-daemon" "cups" "bluetooth" "rpcbind")

    for svc in "${SERVICES[@]}"; do
        if systemctl list-unit-files | grep -q "^$svc"; then
            if [ "$DRY_RUN" = true ]; then
                log "[DRY] Désactivation service $svc"
            else
                systemctl disable --now "$svc" 2>/dev/null
                log "[FIX] Service désactivé : $svc"
            fi
        fi
    done
}

# Sécurisation SSH
secure_ssh() {
    SSH_CONF="/etc/ssh/sshd_config"

    log "[INFO] Sécurisation de SSH"

    if [ ! -f "$SSH_CONF" ]; then
        log "[ERROR] sshd_config introuvable"
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        log "[DRY] Modification de $SSH_CONF"
        return
    fi

    cp "$SSH_CONF" "$SSH_CONF.bak.$(date +%F_%H%M)"
    log "[INFO] Backup SSH créé"

    set_conf() {
        key="$1"
        value="$2"
        if grep -qE "^\s*$key" "$SSH_CONF"; then
            sed -i "s|^\s*$key.*|$key $value|" "$SSH_CONF"
        else
            echo "$key $value" >> "$SSH_CONF"
        fi
    }

    set_conf "PermitRootLogin" "no"
    set_conf "PasswordAuthentication" "no"
    set_conf "Protocol" "2"

    systemctl reload ssh
    log "[FIX] Configuration SSH durcie"
}

# Configuration pare-feu (UFW)
configure_firewall() {
    log "[INFO] Configuration du pare-feu"

    if ! command -v ufw >/dev/null; then
        log "[ERROR] UFW non installé"
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        log "[DRY] Configuration UFW"
        return
    fi

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable

    log "[FIX] Pare-feu configuré avec succès"
}

###############
# MAIN        #
###############

main() {
    touch "$LOG_FILE"
    log "=== DÉMARRAGE SSPA SECHARDEN ==="

    fix_permissions
    disable_services
    secure_ssh
    configure_firewall

    log "=== HARDENING TERMINÉ ==="
}

main
