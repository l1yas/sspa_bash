# SSPA Saves – Secure Backup Script

SSPA Saves is a **Bash script** designed to automate secure backups of critical system files.
It provides basic backup, archive encryption, integrity verification, and logging features.

This project is part of the **SSPA (System Security & Protection Automation)** toolkit.



## Features

* File backup
* Compressed and password-protected archives
* Backup integrity verification (SHA-256)
* Configurable backup directory
* Centralized logging
* Root execution enforcement



## Requirements

* Linux system
* Root privileges
* Installed tools:

  * `zip`
  * `unzip`
  * `sha256sum`



## Usage

```bash
sudo ./sspa_saves.sh [options]
```

### Options

| Option                                 | Description                 |
| -- |  |
| `-s <source> <destination>`            | Backup a file               |
| `-a <folder> <archive.zip> <password>` | Create an encrypted archive |
| `-c <file1> <file2>`                   | Verify file integrity       |
| `-h`                                   | Display help                |



## Examples

Backup a file:

```bash
sudo ./sspa_saves.sh -s /var/log/syslog /var/backups/syslog.bak
```

Create an encrypted archive:

```bash
sudo ./sspa_saves.sh -a ./logs backup.zip password
```

Verify integrity:

```bash
sudo ./sspa_saves.sh -c file1.bak file2.bak
```



## Logs

All actions are logged to:

```
/var/log/sspa_promon.log
```



## Backup Rotation

A rotation policy is supported via configuration variables.
Older backups can be automatically removed based on retention settings.



## Notes

* ZIP encryption is used for simplicity and learning purposes.
* Not intended for production-grade cryptographic security.
* Designed for educational and system administration practice.



## Author

Ilyas
