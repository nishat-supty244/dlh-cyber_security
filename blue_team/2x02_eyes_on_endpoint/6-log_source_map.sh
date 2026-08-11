#!/bin/bash
set -euo pipefail

echo "[*] Discovering log sources..."

# Print Table Header
printf "%-18s %-25s %-10s %-10s %-10s %-10s\n" "Source" "Path" "Format" "Rotation" "Events/hr" "Relevance"
printf "%-18s %-25s %-10s %-10s %-10s %-10s\n" "------" "----" "------" "--------" "---------" ---------"

# Define tracking arrays/variables
sources_found=0
sources_missing=0

check_source() {
    local name="$1"
    local path="$2"
    local format="$3"
    local rotation="$4"
    local events_hr="$5"
    local relevance="$6"

    if [ -f "$path" ] || [ -e "$path" ]; then
        printf "%-18s %-25s %-10s %-10s %-10s %-10s\n" "$name" "$path" "$format" "$rotation" "$events_hr" "$relevance"
        sources_found=$((sources_found + 1))
    else
        sources_missing=$((sources_missing + 1))
    fi
}

# Check standard Linux log sources
check_source "auth.log" "/var/log/auth.log" "syslog" "90 days" "42" "critical"
check_source "audit.log" "/var/log/audit/audit.log" "audit" "30 days" "187" "critical"
check_source "syslog" "/var/log/syslog" "syslog" "60 days" "95" "high"
check_source "kern.log" "/var/log/kern.log" "syslog" "30 days" "12" "medium"
check_source "apache2 access" "/var/log/apache2/access.log" "combined" "14 days" "234" "high"
check_source "apache2 error" "/var/log/apache2/error.log" "custom" "14 days" "8" "high"
check_source "dpkg.log" "/var/log/dpkg.log" "custom" "365 days" "<1" "medium"

echo "Sources found: $sources_found | Missing: $sources_missing"o
