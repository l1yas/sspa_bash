# SSPA ProMon

**Script de Surveillance des Processus et Services (Bash)**

## Description

**SSPA ProMon** est un script Bash de supervision système destiné aux environnements Linux.
Il permet de surveiller l’utilisation des ressources (CPU et mémoire), de détecter des processus suspects, de vérifier l’état de services critiques et d’appliquer des actions correctives automatiques en cas de défaillance.

Ce script a été conçu dans une optique **sécurité / administration système**, avec une logique proche d’un agent de monitoring ou d’un mini EDR.

## Fonctionnalités

* Surveillance de l’utilisation CPU des processus
* Surveillance de l’utilisation mémoire des processus
* Détection de processus non autorisés ou suspects (blacklist)
* Vérification de l’état des services critiques (SSH, Apache/Nginx, MySQL, etc.)
* Redémarrage automatique des services défaillants
* Alertes en cas de consommation anormale de ressources
* Journalisation des événements de sécurité


## Prérequis

* Système Linux
* Bash
* Accès à `ps`, `awk`, `pgrep`, `systemctl`
* Droits suffisants pour vérifier/redémarrer les services (root recommandé)


## Installation

1. Cloner le dépôt :

   ```
   git clone https://github.com/l1yas/sspa_bash
   ```
2. Rendre le script exécutable :

   ```
   chmod +x sspa_promon.sh
   ```

## Utilisation

### Lancer une surveillance CPU

* Valeur par défaut :

  ```
  ./sspa_promon.sh -c
  ```
* Seuil personnalisé :

  ```
  ./sspa_promon.sh -c 50
  ```

### Lancer une surveillance mémoire

* Valeur par défaut :

  ```
  ./sspa_promon.sh -m
  ```
* Seuil personnalisé :

  ```
  ./sspa_promon.sh -m 60
  ```

### Combiner CPU et mémoire

```
./sspa_promon.sh -c -m
./sspa_promon.sh -c 50 -m 60
```

### Vérifier un service

```
./sspa_promon.sh -s ssh
```

### Vérifier et redémarrer automatiquement un service

```
./sspa_promon.sh -s ssh -r
```

## Alertes et logs

Les alertes sont :

* affichées dans le terminal
* enregistrées dans un fichier de log dédié

Chaque événement inclut :

* la date et l’heure
* le type d’alerte
* le processus ou service concerné
* la consommation CPU/mémoire si applicable
* 
## Processus suspects

Le script inclut une liste de processus considérés comme suspects (ex. outils réseau offensifs).
Si l’un d’eux est détecté en cours d’exécution, une alerte est générée et journalisée.

Cette liste pourra être externalisée ou remplacée par une whitelist dans les versions futures.

## Cas d’usage

* Surveillance basique d’un serveur Linux
* Détection de comportements anormaux
* Outil pédagogique pour comprendre le monitoring système
* Base pour un projet sécurité / cybersécurité
* Mini agent de supervision personnalisé

## Limitations actuelles

* Seuils statiques
* Pas de mode daemon
* Pas d’export JSON
* Blacklist codée en dur

Ces limitations sont volontaires afin de privilégier la compréhension du fonctionnement interne.
