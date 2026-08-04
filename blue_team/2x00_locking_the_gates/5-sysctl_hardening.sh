#!/bin/bash
# Defensive bash practices
set -euo pipefail

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with root privileges (sudo)." >&2
    exit 1
fi

SYSCTL_CONF="/etc/sysctl.conf"
BACKUP_CONF="/etc/sysctl.conf.bak"

echo "[*] Backing up $SYSCTL_CONF"
cp -f "$SYSCTL_CONF" "$BACKUP_CONF"

echo "[*] Applying kernel hardening parameters..."

# Define parameters and expected values
declare -A params=(
    ["net.ipv4.ip_forward"]="0"
    ["net.ipv4.conf.all.accept_redirects"]="0"
    ["net.ipv4.conf.default.accept_redirects"]="0"
    ["net.ipv4.conf.all.send_redirects"]="0"
    ["net.ipv4.conf.all.accept_source_route"]="0"
    ["net.ipv4.conf.all.log_martians"]="1"
    ["net.ipv4.tcp_syncookies"]="1"
    ["net.ipv4.icmp_echo_ignore_broadcasts"]="1"
    ["net.ipv6.conf.all.disable_ipv6"]="1"
    ["net.ipv6.conf.default.disable_ipv6"]="1"
    ["kernel.randomize_va_space"]="2"
    ["fs.suid_dumpable"]="0"
    ["kernel.dmesg_restrict"]="1"
    ["kernel.kptr_restrict"]="2"
)

applied_count=0
pass_count=0
fail_count=0

# Ensure file ends with newline before appending
[ -f "$SYSCTL_CONF" ] && sed -i -e '$a\' "$SYSCTL_CONF"

for key in "${!params[@]}"; do
    val="${params[$key]}"
    
    # Remove existing definitions to avoid duplicates
    sed -i "/^#\?\s*${key}\s*=/d" "$SYSCTL_CONF"
    
    # Append new setting
    echo "${key} = ${val}" >> "$SYSCTL_CONF"
    applied_count=$((applied_count + 1))
done

# Apply immediately
sysctl -p > /dev/null 2>&1 || true

# Verify each setting via /proc/sys/
for key in "${!params[@]}"; do
    expected="${params[$key]}"
    # Convert dot-notation to file path under /proc/sys/
    proc_path="/proc/sys/$(echo "$key" | tr '.' '/')"
    
    status="[FAIL]"
    if [ -f "$proc_path" ]; then
        current=$(cat "$proc_path" | tr -d '[:space:]')
        if [ "$current" = "$expected" ]; then
            status="[PASS]"
            pass_count=$((pass_count + 1))
        else
            fail_count=$((fail_count + 1))
        fi
    else
        fail_count=$((fail_count + 1))
    fi
    
    # Print formatted output matching expectations
    printf "%-42s %s\n" "${key} = ${expected}" "$status"
done

echo "Parameters applied: ${applied_count}"
echo "Verified PASS: ${pass_count}"
echo "Verified FAIL: ${fail_count}"
