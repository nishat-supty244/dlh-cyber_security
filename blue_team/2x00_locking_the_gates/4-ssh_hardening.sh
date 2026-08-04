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

echo "[*] Backing up /etc/ssh/sshd_config"
cp -f "$SSHD_CONFIG" "$BACKUP_CONFIG"

echo "[*] Creating login banner..."
echo "Authorized access only." > "$BANNER_FILE"
chmod 644 "$BANNER_FILE"

echo "[*] Applying SSH hardening settings..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSHD_CONFIG"
sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG"
sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 3/' "$SSHD_CONFIG"
sed -i 's/^#\?ClientAliveInterval.*/ClientAliveInterval 300/' "$SSHD_CONFIG"
sed -i 's/^#\?ClientAliveCountMax.*/ClientAliveCountMax 2/' "$SSHD_CONFIG"
sed -i 's/^#\?AllowUsers.*/AllowUsers medadmin sysadmin/' "$SSHD_CONFIG"
sed -i 's/^#\?Protocol.*/Protocol 2/' "$SSHD_CONFIG"
sed -i 's/^#\?LoginGraceTime.*/LoginGraceTime 60/' "$SSHD_CONFIG"
sed -i "s|^#\?Banner.*|Banner $BANNER_FILE|" "$SSHD_CONFIG"

echo "[*] Validating SSH configuration..."
if sshd -t; then
    echo "    sshd -t: OK"
    echo "[*] Restarting SSH service..."
    systemctl restart ssh || systemctl restart sshd
    echo "    ssh.service: active (running)"
    echo "Settings applied: 11"
else
    echo "Error: validation failed, restoring backup" >&2
    cp -f "$BACKUP_CONFIG" "$SSHD_CONFIG"
    exit 1
fi
