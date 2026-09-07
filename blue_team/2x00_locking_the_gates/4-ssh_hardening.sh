#!/bin/bash

# SSH Hardening Script for MedDefense billing-srv-01
# Purpose: Reduce SSH attack surface and prevent credential-based attacks

set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak"
BANNER="/etc/issue.net"

echo "[+] Starting SSH hardening..."

# Backup existing SSH configuration
echo "[+] Creating SSH configuration backup..."
cp "$SSHD_CONFIG" "$BACKUP"

# Apply SSH hardening settings
echo "[+] Applying SSH security controls..."

cat >> "$SSHD_CONFIG" <<EOF

# Threat: Prevents attackers from gaining full root access through SSH
PermitRootLogin no

# Threat: Blocks brute-force attacks using stolen or guessed passwords
PasswordAuthentication no

# Threat: Prevents login attempts with empty passwords
PermitEmptyPasswords no

# Threat: Reduces unnecessary remote attack features
X11Forwarding no

# Threat: Limits brute-force authentication attempts
MaxAuthTries 3

# Threat: Disconnects inactive sessions to reduce session hijacking risk
ClientAliveInterval 300
ClientAliveCountMax 2

# Threat: Restricts SSH access to authorized administrators only
AllowUsers medadmin sysadmin

# Threat: Ensures secure SSH protocol version
Protocol 2

# Threat: Reduces time available for attackers during login attempts
LoginGraceTime 60

# Threat: Displays security warning to unauthorized users
Banner /etc/issue.net

EOF

# Create SSH warning banner
echo "[+] Creating SSH warning banner..."

cat > "$BANNER" <<EOF
************************************************************************
WARNING: Authorized access only.
All activities are monitored and logged.
Unauthorized access attempts will be investigated.
************************************************************************
EOF

# Validate SSH configuration
echo "[+] Validating SSH configuration..."

if sshd -t; then

    echo "[+] SSH configuration valid. Restarting SSH service..."

    systemctl restart sshd

    echo "[+] SSH hardening completed successfully."

else

    echo "[!] SSH configuration validation failed!"
    echo "[!] Restoring previous configuration..."

    cp "$BACKUP" "$SSHD_CONFIG"

    systemctl restart sshd

    echo "[+] Backup restored. SSH remains unchanged."

    exit 1

fi
