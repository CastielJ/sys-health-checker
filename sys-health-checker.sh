#!/bin/bash

# sys-health-checker.sh
# A system health checker
# Created by CastielJ, 2025

SERVICES=(ssh apache2 nginx mysql)

print_banner() {
  echo "======================================="
  echo "  SYSTEM HEALTH CHECK by CastielJ"
  echo "======================================="
}

run_neofetch() {
  echo "[+] Basic system information:"
  if command -v neofetch &>/dev/null; then
    neofetch --stdout
  else
    echo "  [✘] Neofetch is not installed."
  fi
}

check_uptime_load() {
  echo "[+] Uptime and Load Average:"
  uptime
}

check_network() {
  echo "[+] Network Interfaces and IPs:"
  ip -brief addr | grep -v "lo"
}

check_internet() {
  echo "[+] Internet Connectivity:"
  if ping -c 1 1.1.1.1 &>/dev/null; then
    echo "  [✔] Internet is reachable"
  else
    echo "  [✘] No internet access"
  fi
}

check_services() {
  echo "[+] Service activity check:"
  for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
      echo "  [✔] $service is Active"
    else
      echo "  [✘] $service is NOT Active"
    fi
  done
}

check_failed_services() {
  echo "[+] Failed systemd services:"
  failed=$(systemctl --failed --no-legend)
  if [ -n "$failed" ]; then
    echo "$failed"
  else
    echo "  [✔] No failed services"
  fi
}

handle_failed_services() {
  echo "[+] Handling Failed Services:"
  failed_services=$(systemctl --failed --no-legend | awk '{print $1}')
  
  if [ -z "$failed_services" ]; then
    echo "  [✔] No failed services to handle."
    return
  fi

  echo "  Detected failed services:"
  echo "$failed_services" | sed 's/^/  - /'

  echo
  read -p "  ↪ Would you like to attempt to restart them? [y/N]: " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    for service in $failed_services; do
      echo "  ↻ Restarting $service..."
      sudo systemctl restart "$service"
      sleep 0.5
      if systemctl is-active --quiet "$service"; then
        echo "    [✔] $service restarted successfully."
      else
        echo "    [✘] Failed to restart $service."
      fi
    done
  else
    echo "  [ℹ] Skipping restart of failed services."
  fi
}


check_cpu_ram() {
  echo "[+] CPU and RAM load:"
  cpu_busy=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
  echo "  CPU: $cpu_busy is busy"
  echo "  RAM: $(free -h | awk '/Mem:/ {print $3" / "$2}')"
}

check_swap() {
  echo "[+] Swap Usage:"
  free -h | awk '/Swap:/ {print "  Used: "$3" / "$2}'
}

check_disks() {
  echo "[+] Disk Availability:"
  df -h --output=source,fstype,size,used,avail,pcent,target -x tmpfs -x devtmpfs | column -t
}

check_updates() {
  echo "[+] Package Updates:"
  if command -v apt &>/dev/null; then
    updates=$(apt list --upgradeable 2>/dev/null | grep -v "Listing..." | wc -l)
    echo "  [$updates] packages can be upgraded"
  elif command -v dnf &>/dev/null; then
    updates=$(dnf check-update 2>/dev/null | grep -c "^[a-zA-Z0-9]")
    echo "  [$updates] packages can be upgraded"
  else
    echo "  [!] Package manager not supported"
  fi
}

check_firewall() {
  echo "[+] Firewall Status:"
  if command -v ufw &>/dev/null; then
    ufw status
  elif command -v firewall-cmd &>/dev/null; then
    firewall-cmd --state
  else
    echo "  [!] No known firewall tool detected"
  fi
}

check_users() {
  echo "[+] Logged-in Users:"
  who
}

top_memory_processes() {
  echo "[+] Top 5 Memory-Hungry Processes:"
  ps aux --sort=-%mem | awk 'NR<=6{printf "  PID: %s | USER: %s | MEM: %s%% | CMD: %s\n", $2, $1, $4, $11}'
}

check_rootkits() {
  echo "[+] Rootkit Scan:"
  if command -v chkrootkit &>/dev/null; then
    chkrootkit | grep -v "not found"
  else
    echo "  [!] chkrootkit is not installed"
  fi
}

main() {
  print_banner
  run_neofetch
  echo
  check_uptime_load
  echo
  check_network
  echo
  check_internet
  echo
  check_services
  echo
  check_failed_services
  echo
  handle_failed_services
  echo
  check_cpu_ram
  echo
  check_swap
  echo
  check_disks
  echo
  check_updates
  echo
  check_firewall
  echo
  check_users
  echo
  top_memory_processes
  echo
  check_rootkits
  echo
  echo "✔ System health check complete."
}

main
