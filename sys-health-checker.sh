#!/bin/bash

# sys-health-checker.sh
#System condition checker (RAM, CPU, DRIVES, etc

SERVICES=(ssh apache2 nginx mysql)

print_banner() {
  echo "==============================="
  echo "SYSTEM HEALTH CHECK by CastielJ"
  echo "==============================="
}

check_services() {
  echo "[+] Service activity check:"
  for service in "${SERVICES[@]}"; do
    if systemctl list-units --type=service --state=active | grep -q "$service"; then
      echo "  [✔] $service is Active"
    else
      echo "  [✘] $service is NOT Active"
    fi
  done
}

check_cpu_ram() {
  echo "[+] CPU and RAM load:"
  echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}') is busy"
  echo "  RAM: $(free -h | awk '/Mem:/ {print $3" / "$2}')"
}

check_disks() {
  echo "[+] Disk Availability:"
  df -h --output=source,fstype,size,used,avail,pcent,target -x tmpfs -x devtmpfs | column -t
}

main() {
  print_banner
  check_services
  check_cpu_ram
  check_disks
}

main
