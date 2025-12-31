# SSPA ProMon

**Process and Service Monitoring Script (Bash)**



## Description

**SSPA ProMon** is a Bash system monitoring script designed for Linux environments.
It monitors resource usage (CPU and memory), detects suspicious processes, checks the status of critical services, and can perform automatic corrective actions if a failure occurs.

This script is intended for **system administration and security purposes**, with a design similar to a lightweight monitoring agent or mini EDR (Endpoint Detection and Response).



## Features

* Monitor CPU usage of processes
* Monitor memory usage of processes
* Detect unauthorized or suspicious processes (blacklist)
* Check the status of critical services (SSH, Apache/Nginx, MySQL, etc.)
* Automatically restart failing services
* Alert on abnormal resource consumption
* Log security-related events



## Requirements

* Linux system
* Bash
* Access to `ps`, `awk`, `pgrep`, `systemctl`
* Sufficient privileges to check/restart services (root recommended)



## Installation

1. Clone the repository:

```bash
git clone https://github.com/l1yas/sspa_bash
```

2. Make the script executable:

```bash
chmod +x sspa_promon.sh
```



## Usage

### Start CPU Monitoring

* Default threshold:

```bash
./sspa_promon.sh -c
```

* Custom threshold:

```bash
./sspa_promon.sh -c 50
```

### Start Memory Monitoring

* Default threshold:

```bash
./sspa_promon.sh -m
```

* Custom threshold:

```bash
./sspa_promon.sh -m 60
```

### Combine CPU and Memory Monitoring

```bash
./sspa_promon.sh -c -m
./sspa_promon.sh -c 50 -m 60
```

### Check a Service

```bash
./sspa_promon.sh -s ssh
```

### Check and Automatically Restart a Service

```bash
./sspa_promon.sh -s ssh -r
```



## Alerts and Logs

Alerts are:

* Displayed in the terminal
* Recorded in a dedicated log file

Each event includes:

* Date and time
* Alert type
* Process or service involved
* CPU/memory usage if applicable



## Suspicious Processes

The script contains a list of processes considered suspicious (e.g., offensive network tools).
If any of these are detected running, an alert is triggered and logged.

In future versions, this list could be externalized or replaced with a whitelist for more flexibility.



## Use Cases

* Basic Linux server monitoring
* Detection of abnormal behavior
* Educational tool for learning system monitoring
* Base for security/cybersecurity projects
* Mini custom monitoring agent
