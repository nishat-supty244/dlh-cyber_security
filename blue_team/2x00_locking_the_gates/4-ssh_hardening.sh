#!/bin/bash
# Defensive bash practices
set -euo pipefail

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with root privileges (sudo)." >&2
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_CONFIG="/etc/ssh/sshd_config.bak"
BANNER_FILE="/etc/issue.net"

echo "[*] Backing up $SSHD_CONFIG to $BACKUP_CONFIG"
cp -f "$SSHD_CONFIG" "$BACKUP_CONFIG"

echo "[*] Creating warning banner at $BANNER_FILE"
cat << 'EOF' > "$BANNER_FILE"
***************************************************************************
*                             NOTICE TO USERS                             *
*                                                                         *
* This system is restricted to authorized MedDefense personnel only.      *
* Unauthorized access or use may lead to disciplinary action, civil       *
* penalties, and/or criminal prosecution. All activities are monitored.   *
***************************************************************************
EOF

echo "[*] Applying SSH hardening settings..."

# Helper function to update or append configuration settings safely with threat references
set_sshd_param() {
    local param="$1"
    local value="$2"
    local comment="$3"
    
    echo "    $param $value"
    
    # Check if parameter exists (even if commented out)
    if grep -qE "^\s*#?\s*${param}\s+" "$SSHD_CONFIG"; then
        sed -i -E "s/^\s*#?\s*(${param}\s+).*/\1${value} # [Threat Mitigation: ${comment}]/g" "$SSHD_CONFIG"
    else
        echo "${param} ${value} # [Threat Mitigation: ${comment}]" >> "$SSHD_CONFIG"
    fi
}

# Apply parameters matching project requirements
set_sshd_param "PermitRootLogin" "no" "Prevent root compromise and administrative lateral movement"
set_sshd_param "PasswordAuthentication" "no" "Eliminate brute-force attacks and harvested password abuse"
set_sshd_param "PermitEmptyPasswords" "no" "Disallow blank authentication risks"
set_sshd_param "X11Forwarding" "no" "Reduce attack surface via graphical forwarding channels"
set_sshd_param "MaxAuthTries" "3" "Limit brute-force attempts per connection session"
set_sshd_param "ClientAliveInterval" "300" "Terminate stale idle interactive sessions"
set_sshd_param "ClientAliveCountMax" "2" "Define idle timeout threshold limit (10 min total)"
set_sshd_param "AllowUsers" "medadmin sysadmin" "Enforce strict least-privilege user access boundary"
set_sshd_param "Protocol" "2" "Disable legacy insecure cryptographic protocol standards"
set_sshd_param "LoginGraceTime" "60" "Mitigate unauthenticated connection exhaustion DoS"
set_sshd_param "Banner" "$BANNER_FILE" "Display authorized legal warning notice prior to login"

echo "[*] Validating SSH configuration..."
if sshd -t; then
    echo "    sshd -t: OK"
    
    echo "[*] Restarting SSH service..."
    if systemctl restart ssh || systemctl restart sshd; then
        # Determine service status name dynamically
        SERVICE_NAME=$(systemctl list-units --type=service --state=running | grep -oE 'ssh(d)?\.service' | head -n 1)
        echo "    ${SERVICE_NAME:-ssh.service}: active (running)"
        echo "Settings applied: 11"
    else
        echo "Error: Failed to restart SSH service." >&2
        exit 1
    fi
else
    echo "Error: sshd -t validation failed! Restoring backup config..." >&2
    cp -f "$BACKUP_CONFIG" "$SSHD_CONFIG"
    exit 1
fi
