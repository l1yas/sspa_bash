# SSH Intrusion Detection Script (Bash)

Script Bash pour détecter et bloquer automatiquement les tentatives de connexion SSH échouées sur un serveur Linux.
Ce script analyse les logs d'authentification, identifie les adresses IP suspectes et peut les bloquer via iptables ou ip6tables.


## Fonctionnalités

* Analyse des logs SSH (/var/log/auth.log ou journalctl -t sshd)
* Détection des tentatives échouées répétées (seuil configurable)
* Extraction et filtrage des adresses IP suspectes
* Blocage automatique des IP via iptables et ip6tables (optionnel)
* Gestion d'une whitelist d'IP autorisées
* Journalisation des incidents dans un fichier dédié


## Prérequis

* Linux avec bash
* Accès root pour le blocage d'IP
* iptables et ip6tables installés
* Journaux SSH disponibles (/var/log/auth.log ou journalctl)


## Installation

Rendre le script exécutable :

```bash
chmod +x sspa_intrusions.sh
```

2. Optionnel : créer une whitelist pour IP autorisées :

```bash
sudo touch /var/log/sspa_whitelist.txt
```

## Utilisation

### Mode analyse uniquement

```bash
sspa_intrusions -t 5
```

* `-t` : seuil d'échecs avant de considérer une IP comme suspecte (défaut : 5)
* Affiche les IP suspectes et les journalise dans /var/log/sspa_intrusions.log

### Mode blocage automatique

```bash
sspa_intrusions -t 5 -b
```

* `-b` : active le blocage via iptables/ip6tables

### Autres options

* `-l <logfile>` : Spécifier un fichier de log personnalisé
* `-w <whitelist>` : Spécifier un fichier whitelist personnalisé
* `-o <output>` : Spécifier un fichier journal personnalisé
* `-h` : Afficher l'aide


## Exemple de logs détectés

192.168.56.42
::1

## Fichiers générés

* /var/log/sspa_intrusions.log : journalisation des IP suspectes et des blocages
* /var/log/sspa_whitelist.txt : liste d'IP autorisées


## Sécurité

* Le script doit être exécuté en root pour activer le blocage
* Les IP locales (127.0.0.1 et ::1) sont automatiquement ignorées
* Les IP présentes dans la whitelist ne seront jamais bloquées
