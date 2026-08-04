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
Authorized access only. All activities are monitored.
EOF
chmod 644 "$BANNER_FILE"

echo "[*] Applying SSH hardening settings..."

# Helper function to update or append configuration cleanly without extra trailing text
set_sshd_param() {
    local param="$1"
    local value="$2"
    
    echo "    $param $value"
    
    if grep -qE "^\s*#?\s*${param}\s+" "$SSHD_CONFIG"; then
        sed -i -E "s/^\s*#?\s*(${param}\s+).*/\1${value}/g" "$SSHD_CONFIG"
    else
        echo "${param} ${value}" >> "$SSHD_CONFIG"
    fi
}

# Apply required settings cleanly
set_sshd_param "PermitRootLogin" "no"
set_sshd_param "PasswordAuthentication" "no"
set_sshd_param "PermitEmptyPasswords" "no"
set_sshd_param "X11Forwarding" "no"
set_sshd_param "MaxAuthTries" "3"
set_sshd_param "ClientAliveInterval" "300"
set_sshd_param "ClientAliveCountMax" "2"
set_sshd_param "AllowUsers" "medadmin sysadmin"
set_sshd_param "Protocol" "2"
set_sshd_param "LoginGraceTime" "60"
set_sshd_param "Banner" "$BANNER_FILE"

echo "[*] Validating SSH configuration..."
if sshd -t; then
    echo "    sshd -t: OK"
    
    echo "[*] Restarting SSH service..."
    if systemctl restart ssh; then
        echo "    ssh.service: active (running)"
    elif systemctl restart sshd; then
        echo "    sshd.service: active (running)"
    else
        service ssh restart || service sshd restart
    fi
    echo "Settings applied: 11"
else
    echo "Error: sshd -t validation failed! Restoring backup config..." >&2
    cp -f "$BACKUP_CONFIG" "$SSHD_CONFIG"
    exit 1
fi
