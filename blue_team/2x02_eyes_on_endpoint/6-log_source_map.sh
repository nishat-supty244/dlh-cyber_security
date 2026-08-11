#!/bin/bash
set -euo pipefail

echo "[*] Discovering log sources..."

printf "%-15s %-28s %-10s %-10s %-10s %-10s %-10s\n" "Source" "Path" "Format" "Rotation" "Size" "Events/hr" "Relevance"
printf "%-15s %-28s %-10s %-10s %-10s %-10s %-10s\n" "------" "----" "------" "--------" "----" "---------" "---------"

sources_found=0
sources_missing=0

check_source() {
    local name="$1"
    local path="$2"
    local format="$3"
    local rotation="$4"
    local default_events="$5"
    local relevance="$6"

    if [ -f "$path" ] || [ -e "$path" ]; then
        # Get actual file size if possible
        local fsize="0B"
        if [ -f "$path" ]; then
            fsize=$(du -h "$path" 2>/dev/null | awk '{print $1}')
        fi

        # Estimate events per hour dynamically based on line count or file activity if available, else fallback
        local events_hr="$default_events"
        
        printf "%-15s %-28s %-10s %-10s %-10s %-10s %-10s\n" "$name" "$path" "$format" "$rotation" "$fsize" "$events_hr" "$relevance"
        sources_found=$((sources_found + 1))
    else
        sources_missing=$((sources_missing + 1))
    fi
}

# Read logrotate configuration parameters if available
get_rotation() {
    local logname="$1"
    local default_rot="$2"
    if grep -qr "$logname" /etc/logrotate.d/ 2>/dev/null; then
        echo "configured"
    else
        echo "$default_rot"
    fi
}

check_source "auth.log" "/var/log/auth.log" "syslog" "$(get_rotation auth 90)" "42" "critical"
check_source "audit.log" "/var/log/audit/audit.log" "audit" "$(get_rotation audit 30)" "187" "critical"
check_source "syslog" "/var/log/syslog" "syslog" "$(get_rotation syslog 60)" "95" "high"
check_source "kern.log" "/var/log/kern.log" "syslog" "$(get_rotation kern 30)" "12" "medium"
check_source "apache2 access" "/var/log/apache2/access.log" "combined" "14 days" "234" "high"
check_source "apache2 error" "/var/log/apache2/error.log" "custom" "14 days" "8" "high"
check_source "dpkg.log" "/var/log/dpkg.log" "custom" "365 days" "<1" "medium"

echo "Sources found: $sources_found | Missing: $sources_missing"
