# SSH Intrusion Detection Script (Bash)

Bash script to automatically detect and block failed SSH login attempts on a Linux server.
This script analyzes authentication logs, identifies suspicious IP addresses, and can block them via `iptables` or `ip6tables`.



## Features

* Analyze SSH logs (`/var/log/auth.log` or `journalctl -t sshd`)
* Detect repeated failed login attempts (configurable threshold)
* Extract and filter suspicious IP addresses
* Automatically block IPs via `iptables` and `ip6tables` (optional)
* Manage a whitelist of allowed IPs
* Log incidents to a dedicated file



## Requirements

* Linux with Bash
* Root access to enable IP blocking
* `iptables` and `ip6tables` installed
* SSH logs available (`/var/log/auth.log` or via `journalctl`)



## Installation

Make the script executable:

```bash
chmod +x sspa_intrusions.sh
```

Optional: create a whitelist for allowed IPs:

```bash
sudo touch /var/log/sspa_whitelist.txt
```



## Usage

### Analysis-Only Mode

```bash
./sspa_intrusions.sh -t 5
```

* `-t` : threshold of failed attempts before marking an IP as suspicious (default: 5)
* Displays suspicious IPs and logs them in `/var/log/sspa_intrusions.log`

### Automatic Blocking Mode

```bash
./sspa_intrusions.sh -t 5 -b
```

* `-b` : enables automatic blocking via `iptables` / `ip6tables`

### Other Options

* `-l <logfile>` : Specify a custom log file
* `-w <whitelist>` : Specify a custom whitelist file
* `-o <output>` : Specify a custom output log file
* `-h` : Display help



## Example of Detected Logs

```
192.168.56.42
::1
```



## Generated Files

* `/var/log/sspa_intrusions.log` : logs of suspicious IPs and blocked addresses
* `/var/log/sspa_whitelist.txt` : list of allowed IPs



## Security Notes

* The script must be run as root to enable blocking
* Local IPs (`127.0.0.1` and `::1`) are automatically ignored
* IPs listed in the whitelist will never be blocked
