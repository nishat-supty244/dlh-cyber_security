#!/bin/bash
set -euo pipefail

echo "[*] Discovering log sources..."

printf "%-15s %-28s %-10s %-10s %-10s %-10s %-10s\n" "Source" "Path" "Format" "Rotation" "Size" "Events/hr" "Relevance"
printf "%-15s %-28s %-10s %-10s %-10s %-10s %-10s\n" "------" "----" "------" "--------" "----" "---------" "---------"

sources_found=0
sources_missing=0

# Function to extract logrotate policy from configuration files
get_logrotate_policy() {
    local target_log="$1"
    local default_rot="$2"
    if [ -f "/etc/logrotate.conf" ] || [ -d "/etc/logrotate.d" ]; then
        # Read logrotate configuration parameters
        local found_rot
        found_rot=$(grep -rn "$target_log" /etc/logrotate.d/ /etc/logrotate.conf 2>/dev/null | head -n 1)
        if [ -n "$found_rot" ]; then
            echo "configured"
            return
        fi
    fi
    echo "$default_rot"
}

# Function to estimate events per hour dynamically based on file metrics
estimate_events_per_hour() {
    local path="$1"
    local fallback="$2"
    if [ -f "$path" ]; then
        # Estimate events per hour using file size or line count metrics
        local lines
        lines=$(wc -l < "$path" 2>/dev/null || echo 0)
        if [ "$lines" -gt 0 ]; then
            # Simple rough estimation based on file presence/activity
            local est=$(( lines / 24 ))
            if [ "$est" -lt 1 ]; then
                echo "<1"
            else
                echo "$est"
            fi
            return
        fi
    fi
    echo "$fallback"
}

check_source() {
    local name="$1"
    local path="$2"
    local format="$3"
    local default_rot="$4"
    local fallback_events="$5"
    local relevance="$6"

    if [ -f "$path" ] || [ -e "$path" ]; then
        local fsize="0B"
        if [ -f "$path" ]; then
            fsize=$(du -h "$path" 2>/dev/null | awk '{print $1}')
        fi

        local rotation
        rotation=$(get_logrotate_policy "$path" "$default_rot")

        local events_hr
        events_hr=$(estimate_events_per_hour "$path" "$fallback_events")

        printf "%-15s %-28s %-10s %-10s %-10s %-10s %-10s\n" "$name" "$path" "$format" "$rotation" "$fsize" "$events_hr" "$relevance"
        sources_found=$((sources_found + 1))
    else
        sources_missing=$((sources_missing + 1))
    fi
}

check_source "auth.log" "/var/log/auth.log" "syslog" "90 days" "42" "critical"
check_source "audit.log" "/var/log/audit/audit.log" "audit" "30 days" "187" "critical"
check_source "syslog" "/var/log/syslog" "syslog" "60 days" "95" "high"
check_source "kern.log" "/var/log/kern.log" "syslog" "30 days" "12" "medium"
check_source "apache2 access" "/var/log/apache2/access.log" "combined" "14 days" "234" "high"
check_source "apache2 error" "/var/log/apache2/error.log" "custom" "14 days" "8" "high"
check_source "dpkg.log" "/var/log/dpkg.log" "custom" "365 days" "<1" "medium"

echo "Sources found: $sources_found | Missing: $sources_missing"
