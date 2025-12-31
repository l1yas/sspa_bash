# SSPA – Security Hardening Script (`sspa_secharden.sh`)

## Overview

`sspa_secharden.sh` is a **Linux security hardening script** designed to **apply system security recommendations in a controlled and auditable way**.

The script focuses on:

* Reducing attack surface
* Enforcing basic security policies
* Logging every modification
* Providing a **dry-run mode** for safe validation

It is intended for **educational, lab, and defensive security use**.



## Features

### 🔐 System Hardening

* Fix non-compliant file permissions
* Disable unnecessary or insecure services
* Apply predefined firewall rules (UFW)
* Harden SSH configuration (secure defaults)

### 🧪 Dry-Run Mode

* Simulates all actions
* No system changes applied
* Ideal for testing and validation

### 📝 Full Logging

* Every action is logged with timestamps
* Clear distinction between applied and simulated actions



## Requirements

* Linux system
* Root privileges
* `ufw` installed (for firewall configuration)



## Installation

```bash
chmod +x sspa_secharden.sh
```



## Usage

### Dry-Run (Recommended)

```bash
sudo ./sspa_secharden.sh --dry-run
```

This mode:

* Shows what **would** be changed
* Applies **no modifications**
* Is safe to run on any system



### Apply Hardening

```bash
sudo ./sspa_secharden.sh
```

This will:

* Apply permission fixes
* Disable unnecessary services
* Configure firewall rules
* Apply SSH hardening
* Log all changes



## What the Script Does

### Permissions

* Corrects overly permissive files (e.g. 777 / 666)
* Applies safer defaults

### Services

* Detects and disables unused or insecure services
* Keeps essential services running

### Firewall

* Enables UFW
* Applies a predefined allow/deny policy
* Blocks unnecessary incoming traffic

### SSH

* Enforces secure SSH settings
* Does **not** modify SSH in dry-run mode



## Logs

All actions are documented in log files, including:

* Action type
* Target
* Timestamp
* Dry-run or applied status

Logs are essential for traceability and auditing.



## Security Philosophy

* **Explicit actions**
* **No silent changes**
* **Auditability first**
* **Fail-safe defaults**
* **Dry-run before enforcement**



## Disclaimer

This script is provided for **educational and defensive purposes only**

Always:

* Review the code
* Test in a lab environment
* Use dry-run before applying changes on production systems
