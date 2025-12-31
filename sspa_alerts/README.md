# SSPA Alerts – Automated Security Monitoring

## Overview

**SSPA Alerts** is an automated security monitoring script based on the original **SSPA SecAudit** tool.

While `sspa_secaudit` is designed for **manual, on-demand audits**,
`sspa_alerts` is a **modified version adapted for scheduled execution**, intended to run automatically (via `cron` or `anacron`) and generate **daily security reports**.

This script operates in **detection-only mode**:
it **does not modify the system**, it only detects and reports potential security issues.



## Features

SSPA Alerts can automatically check:

* Dangerous file permissions (`777`, `666`)
* SSH configuration weaknesses (root login, password authentication, protocol)
* Open ports and comparison with an allowed list
* Privileged users (UID 0, sudo/admin groups)

Each execution generates a **clean HTML security report**.



## Differences with `sspa_secaudit`

| `sspa_secaudit`   | `sspa_alerts`                 |
| -- | -- |
| Manual execution  | Automated execution           |
| On-demand audit   | Scheduled daily audit         |
| User-driven flags | Same flags, but cron-friendly |
| Educational audit | Continuous monitoring         |

`sspa_alerts` is essentially a **production-style wrapper** around the audit logic of `sspa_secaudit`.



## Installation

### 1. Copy the script to `usr/bin`

```bash
sudo cp sspa_alerts.sh /usr/bin/sspa_alerts
sudo chmod +x /usr/bin/sspa_alerts
```

This allows the script to be executed system-wide.



### 2. Cron configuration (daily report)

Edit root’s crontab:

```bash
sudo crontab -e
```

Example: generate a daily audit at **07:00 AM**:

```bash
0 7 * * * /usr/bin/sspa_alerts -f / -s -p 22,80,443 -u -o /var/log/sspa_daily_audit.html
```

This will:

* Scan file permissions
* Check SSH configuration
* Audit open ports (only 22, 80, 443 allowed)
* List privileged users
* Generate a daily HTML report

⚠️ The machine must be powered on at execution time when using cron.



## Anacron (optional – laptops / non‑24h systems)

If the system may be powered off at scheduled time, **Anacron** is recommended.

Example `/etc/anacrontab` entry:

```
1   10   sspa_alerts   /usr/bin/sspa_alerts -f / -s -p 22,80,443 -u -o /var/log/sspa_daily_audit.html
```

This means:

* Run once per day
* With a 10-minute delay after boot
* Even if the machine was off at the scheduled time



## Output

* Default output: HTML report
* Recommended location: `/var/log/`
* The report is overwritten at each execution (daily snapshot)

Example:

```
/var/log/sspa_daily_audit.html
```



## Security Model

* **Read-only auditing**
* No configuration changes
* No service restarts
* Safe for production and academic environments



## Educational Context

This script was developed as part of a **Linux / Cybersecurity automation project**, focusing on:

* Bash scripting
* System auditing
* Automation with cron/anacron
* Security best practices (detection before prevention)
