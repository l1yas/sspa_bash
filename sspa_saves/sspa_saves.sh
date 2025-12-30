#!/bin/bash

##################
# DEFAULT_VALUES #
##################

BACKUP_DIR="/var/backups/sspa"
ROTATION_DAYS=7
ALERT_LOG="/var/log/sspa_saves.log"

#########
# USAGE #
#########

usage(){
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -s <source> <dest>          Sauvegarder un fichier critique"
    echo "  -a <folder> <archive> <pw> Compresser + chiffrer un dossier"
    echo "  -c <file1> <file2>         Vérifier l'intégrité (SHA-256)"
    echo "  -h                         Aide"
    exit 1
}

###########
# CHECKS #
###########

[ "$EUID" -ne 0 ] && echo "[ERREUR] Exécuter en root" && exit 1
mkdir -p "$BACKUP_DIR"
touch "$ALERT_LOG"

###########
# FONCTIONS
###########

make_save_file(){
    local SRC="$1"
    local DEST="$2"

    if [ ! -f "$SRC" ]; then
        echo "[ERREUR] Fichier source inexistant : $SRC" >> "$ALERT_LOG"
        exit 1
    fi

    mkdir -p "$(dirname "$DEST")"
    cp "$SRC" "$DEST"

    if [ $? -eq 0 ]; then
        echo "[INFO] Sauvegarde OK : $SRC → $DEST" >> "$ALERT_LOG"
    else
        echo "[ERREUR] Échec sauvegarde : $SRC" >> "$ALERT_LOG"
        exit 1
    fi
}

make_archive(){
    local FOLDER="$1"
    local ARCHIVE="$2"
    local PASS="$3"

    if [ ! -d "$FOLDER" ]; then
        echo "[ERREUR] Dossier inexistant : $FOLDER" >> "$ALERT_LOG"
        exit 1
    fi

    mkdir -p "$(dirname "$ARCHIVE")"
    zip -r -P "$PASS" "$ARCHIVE" "$FOLDER" >> "$ALERT_LOG" 2>&1

    if [ $? -eq 0 ]; then
        echo "[INFO] Archive chiffrée créée : $ARCHIVE" >> "$ALERT_LOG"
    else
        echo "[ERREUR] Échec archive : $ARCHIVE" >> "$ALERT_LOG"
        exit 1
    fi
}

check_checksum(){
    local FILE1="$1"
    local FILE2="$2"

    [ ! -f "$FILE1" ] || [ ! -f "$FILE2" ] && \
        echo "[ERREUR] Fichier manquant pour checksum" >> "$ALERT_LOG" && exit 1

    local SUM1=$(sha256sum "$FILE1" | awk '{print $1}')
    local SUM2=$(sha256sum "$FILE2" | awk '{print $1}')

    if [ "$SUM1" = "$SUM2" ]; then
        echo "[INFO] Intégrité OK : $FILE1 == $FILE2" >> "$ALERT_LOG"
    else
        echo "[ALERTE] Intégrité KO : $FILE1 ≠ $FILE2" >> "$ALERT_LOG"
        exit 1
    fi
}

#########
# FLAGS #
#########

case "$1" in
    -s)
        [ $# -ne 3 ] && usage
        make_save_file "$2" "$3"
        ;;
    -a)
        [ $# -ne 4 ] && usage
        make_archive "$2" "$3" "$4"
        ;;
    -c)
        [ $# -ne 3 ] && usage
        check_checksum "$2" "$3"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        ;;
esac

exit 0
       
