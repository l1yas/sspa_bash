# SSPA – System & Security Posture Analysis

**SSPA** is a Bash security auditing script for Linux systems. It allows you to analyze dangerous file permissions, SSH configuration, open ports, and privileged users. The script generates a clear and structured HTML report for easy reading and risk tracking.



## Purpose

The main goal of **SSPA** is to provide a quick and comprehensive overview of a system’s security posture, by detecting:

* Files and directories with overly permissive permissions.
* Potentially risky SSH configurations.
* Open and unauthorized ports.
* Users with elevated privileges (root or sudoers).

All of this is done **without modifying the system** or impacting its functionality.



## Key Features

1. **Dangerous Permissions Audit**
   Searches for files with `0666` or `0777` permissions, which allow any user to read or modify the content.

2. **SSH Configuration Audit**
   Checks:

   * `PermitRootLogin` – prevents direct root login.
   * `PasswordAuthentication` – disables password authentication if needed.
   * `Protocol` – detects usage of SSH1, which is obsolete and insecure.

3. **Open Ports Audit**
   Compares the system’s open ports with the allowed list. Unauthorized ports are flagged as potential risks.

4. **Privileged Users Audit**
   Lists all root accounts and members of administrative groups (`sudo`, `wheel`, `admin`) to identify users capable of critical actions.

5. **HTML Report Generation**

   * Clear, structured report with separate cards for each audit type.
   * Color-coded: green for secure, red for risk, gray for not audited.
   * Includes generation date, audited target, and other metadata.



## Usage

```bash
sudo ./sspa_secaudit.sh [options]
```

### Available Options

| Option       | Description                                           |
|  | -- |
| `-f <path>`  | Audit dangerous permissions in the specified path     |
| `-s`         | Audit SSH configuration                               |
| `-p <ports>` | Audit open ports (e.g., `22,80` or `-` for all ports) |
| `-u`         | Audit privileged users                                |
| `-o <file>`  | Name of the HTML report (default: `audit.html`)       |
| `-h`         | Display help and available options                    |

> The script must be run as root to properly analyze all elements.



## Practical Examples

1. **Full system audit using all modules:**

```bash
sudo ./sspa_secaudit.sh -f / -s -p 22,80 -u -o full_report.html
```

2. **Audit only dangerous permissions in `/var/www`:**

```bash
sudo ./sspa_secaudit.sh -f /var/www -o perms_report.html
```

3. **Audit open ports without restrictions:**

```bash
sudo ./sspa_secaudit.sh -p - -o ports_report.html
```



## Internal Workflow

1. **Dangerous Permissions:** Uses `find` to list all files with `-perm 0777` or `-perm 0666`.
2. **SSH Configuration:** Parses `/etc/ssh/sshd_config` to detect risky parameters.
3. **Open Ports:** Retrieves open TCP/UDP ports via `ss -tuln` and compares them to allowed ports.
4. **Privileged Users:** Checks `/etc/passwd` for root accounts and `getent group` for administrative group members.
5. **HTML Report:** Generates a structured page with sections for each audit, including formatting and color coding.



## Security and Limitations

* **Read-Only:** SSPA does not modify the system.
* **Scope:** Only detects system-level configuration issues, not application vulnerabilities.
* **Root Privileges Required:** Needed to audit all files and users.
* **Static HTML:** The report provides a snapshot audit and does not offer real-time alerts.



## Best Practices

* Schedule regular audits (e.g., weekly or monthly) to detect misconfigurations early.
* Complement SSPA with tools like `Lynis`, `Nmap`, or `Fail2ban` for deeper analysis.
* Keep HTML reports to maintain a history of system security posture over time.



## HTML Report Structure

The report includes the following sections:

* **Date and audited target**
* **Dangerous Permissions:** List of files or a message saying “No dangerous permissions found”
* **SSH Configuration:** Status of each critical parameter
* **Open Ports:** Complete list with risk indication
* **Privileged Users:** Root accounts and members of administrative groups

Color coding for quick reference:

* Green: Secure
* Red: Risk detected
* Gray: Not audited



## Resources & References

* [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
* [Linux File Permissions](https://www.gnu.org/software/coreutils/manual/html_node/File-permissions.html)
* [SSH Hardening](https://www.ssh.com/ssh/hardening/)
* [ss command (Linux)](https://man7.org/linux/man-pages/man8/ss.8.html)



This script is ideal for system administrators, penetration testers in the reconnaissance phase, or anyone wanting a quick and safe overview of a Linux server’s security posture.
