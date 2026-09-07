#!/bin/bash

# Service Minimization Script
# MedDefense - Reduce the attack surface by disabling unnecessary services

set -euo pipefail

echo "[*] Scanning enabled services..."

# Get enabled services
ENABLED_SERVICES=$(systemctl list-unit-files --type=service --state=enabled --no-legend | awk '{print $1}')

BEFORE_COUNT=$(echo "$ENABLED_SERVICES" | wc -l)

echo "    Enabled services found: $BEFORE_COUNT"
echo

echo "[*] Comparing against MedDefense whitelist (9 required services)..."

# ==========================
# Required MedDefense Services
# ==========================

WHITELIST=(
    "ssh.service"                 # Secure remote administration
    "apache2.service"             # Billing web application
    "mysql.service"               # Billing database
    "ufw.service"                 # Host firewall
    "auditd.service"              # Security auditing
    "apparmor.service"            # Mandatory access control
    "cron.service"                # Scheduled maintenance tasks
    "rsyslog.service"             # System logging
    "systemd-timesyncd.service"   # Time synchronization
)

DISABLED_COUNT=0

##################################
# Disable non-whitelisted services
##################################

while read -r SERVICE
do

    [[ -z "$SERVICE" ]] && continue

    KEEP=false

    for REQUIRED in "${WHITELIST[@]}"
    do
        if [[ "$SERVICE" == "$REQUIRED" ]]; then
            KEEP=true
            break
        fi
    done

    if ! $KEEP; then

        systemctl stop "$SERVICE" 2>/dev/null || true
        systemctl disable "$SERVICE" >/dev/null 2>&1 || true

        echo "  $SERVICE     [STOPPED] [DISABLED]"

        DISABLED_COUNT=$((DISABLED_COUNT+1))
    fi

done <<< "$ENABLED_SERVICES"

echo

##################################
# Verify required services
##################################

for SERVICE in "${WHITELIST[@]}"
do

    if systemctl is-active --quiet "$SERVICE"; then

        echo "  $SERVICE     [ACTIVE]"

    else

        echo "  $SERVICE     [NOT RUNNING]"

    fi

done

echo

##################################
# Summary
##################################

AFTER_COUNT=$((BEFORE_COUNT - DISABLED_COUNT))

echo "Before: $BEFORE_COUNT | After: $AFTER_COUNT | Disabled: $DISABLED_COUNT"
