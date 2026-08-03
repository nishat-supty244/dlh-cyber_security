#!/bin/bash

# ==============================================================================
# Script Name: 0-baseline_snapshot.sh
# Description: Captures the complete security baseline of a Linux system.
# Addresses: Establishment of initial security posture metrics (Delta tracking).
# ==============================================================================

# Ensure script is run as root for complete visibility
if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: This script must be run as root (sudo)." >&2
  exit 1
fi

OUTPUT_DIR="./baseline_output"
mkdir -p "$OUTPUT_DIR"
JSON_FILE="$OUTPUT_DIR/baseline_snapshot.json"

echo "[*] Capturing system baseline state..."

# 1. System Identification
HOSTNAME_VAL=$(hostname)
OS_VAL=$(grep -oP 'PRETTY_NAME="\K[^"]+' /etc/os-release 2>/dev/null || uname -s)
KERNEL_VAL=$(uname -r)
UPTIME_VAL=$(uptime -p)

# 2. Running Services
RUNNING_SERVICES_COUNT=$(systemctl list-units --type=service --state=running --no-legend | wc -l)

# 3. Open Ports & Listening Sockets
if command -v ss &> /dev/null; then
    OPEN_PORTS_COUNT=$(ss -tuln | tail -n +2 | wc -l)
else
    OPEN_PORTS_COUNT=$(netstat -tuln | tail -n +3 | wc -l)
fi

# 4. SUID and SGID Binaries
SUID_COUNT=$(find / -type f -perm -4000 2>/dev/null | wc -l)
SGID_COUNT=$(find / -type f -perm -2000 2>/dev/null | wc -l)

# 5. World-Writable Files (excluding /proc, /sys, /dev)
WORLD_WRITABLE_COUNT=$(find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -type f -perm -0002 2>/dev/null | wc -l)

# Generate JSON Output structure
cat << EOF > "$JSON_FILE"
{
  "system_identification": {
    "hostname": "$HOSTNAME_VAL",
    "os": "$OS_VAL",
    "kernel": "$KERNEL_VAL",
    "uptime": "$UPTIME_VAL"
  },
  "metrics": {
    "running_services": $RUNNING_SERVICES_COUNT,
    "open_ports": $OPEN_PORTS_COUNT,
    "suid_binaries": $SUID_COUNT,
    "sgid_binaries": $SGID_COUNT,
    "world_writable_files": $WORLD_WRITABLE_COUNT
  }
}
EOF

# Print required human-readable summary matching expected output format
echo "Hostname: $HOSTNAME_VAL"
echo "OS: $OS_VAL"
echo "Running services: $RUNNING_SERVICES_COUNT"
echo "Open ports: $OPEN_PORTS_COUNT"
echo "SUID binaries: $SUID_COUNT"
echo "SGID binaries: $SGID_COUNT"
echo "World-writable files: $WORLD_WRITABLE_COUNT"

echo "[+] Baseline snapshot successfully saved to $JSON_FILE"
