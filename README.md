#sys-health-checker.sh

A **system health checker script** for Linux
Has features like failed service recovery, network checks, memory usage, package updates, and more.

>  Built by **CastielJ**, 2025

---

##  Features

-  Basic system summary via **Neofetch**
-  CPU & RAM load stats
-  Swap and disk usage
-  Network interfaces & internet connectivity check
-  Active service checker (configurable)
-  Failed services detector + optional auto-restart prompt
-  Package update checker (APT & DNF support)
-  Firewall status check (UFW or firewalld)
-  Logged-in users
-  Top memory-hogging processes
-  Rootkit scan using `chkrootkit` (if installed)

---

## Requirements

| Tool         | Purpose                      | Install with                     |
|--------------|------------------------------|----------------------------------|
| `neofetch`   | System summary               | `sudo apt install neofetch`      |
| `chkrootkit` | Rootkit scanner (optional)   | `sudo apt install chkrootkit`    |

Other commands used (and usually pre-installed): `top`, `free`, `ps`, `df`, `ss`, `who`, `uptime`, `awk`, `sed`, `systemctl`, `ip`, `ping`, etc.

---

##Installation

```bash
git clone https://github.com/CastielJ/sys-health-checker.git
cd sys-health-checker
chmod +x sys-health-checker.sh

```
##USAGE

```bash
./sys-health-checker.sh
```

## CONFIGURATION

You can edit the SERVICES array inside the script to specify which services are critical on your system:
SERVICES=(ssh apache2 nginx mysql)

Security Note
The script reads system info and can restart services using sudo systemctl.

Want it to run automatically?
Add it to a cron job:

```bash
crontab -e
@daily /path/to/sys-health-checker.sh >> /var/log/sys-health.log
```

