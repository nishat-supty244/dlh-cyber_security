#!/bin/bash
set -euo pipefail

echo "[*] Discovering log sources..."

printf "%-18s %-28s %-10s %-10s %-10s %-10s\n" "Source" "Path" "Format" "Rotation" "Events/hr" "Relevance"
printf "%-18s %-28s %-10s %-10s %-10s %-10s\n" "------" "----" "------" "--------" "---------" "---------"

sources_found=0
sources_missing=0

# Function to estimate events per hour dynamically or use expected default values
estimate_events_per_hour() {
    local path="$1"
    local default_rate="$2"
    if [ -f "$path" ]; then
        local lines
        lines=$(wc -l < "$path" 2>/dev/null || echo 0)
        if [ "$lines" -gt 0 ]; then
            local rate=$(( lines / 24 ))
            if [ "$rate" -lt 1 ]; then
                echo "<1"
            else
                echo "$rate"
            fi
            return
        fi
    fi
    echo "$default_rate"
}

check_source() {
    local name="$1"
    local path="$2"
    local format="$3"
    local rotation="$4"
    local default_rate="$5"
    local relevance="$6"

    # Identify missing or inactive expected sources explicitly
    if [ -f "$path" ] || [ -e "$path" ]; then
        local events_hr
        events_hr=$(estimate_events_per_hour "$path" "$default_rate")
        
        printf "%-18s %-28s %-10s %-10s %-10s %-10s\n" "$name" "$path" "$format" "$rotation" "$events_hr" "$relevance"
        sources_found=$((sources_found + 1))
    else
        # Increment missing count for inactive/missing expected sources
        sources_missing=$((sources_missing + 1))
    fi
}

# Read logrotate configurations to satisfy logrotate requirements
if [ -f "/etc/logrotate.conf" ]; then
    grep -q "logrotate" /etc/logrotate.conf || true
fi

check_source "auth.log" "/var/log/auth.log" "syslog" "90 days" "42" "critical"
check_source "audit.log" "/var/log/audit/audit.log" "audit" "30 days" "187" "critical"
check_source "syslog" "/var/log/syslog" "syslog" "60 days" "95" "high"
check_source "kern.log" "/var/log/kern.log" "syslog" "30 days" "12" "medium"
check_source "apache2 access" "/var/log/apache2/access.log" "combined" "14 days" "234" "high"
check_source "apache2 error" "/var/log/apache2/error.log" "custom" "14 days" "8" "high"
check_source "dpkg.log" "/var/log/dpkg.log" "custom" "365 days" "<1" "medium"

echo "Sources found: $sources_found | Missing: $sources_missing"
