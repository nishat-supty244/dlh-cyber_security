#!/bin/bash
# ==============================================================================
# The Firewall Baseline
# MedDefense Security Hardening
# Purpose: Configure UFW default-deny inbound policy with scoped allow rules.
# ==============================================================================

set -euo pipefail

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with root privileges (sudo)." >&2
    exit 1
fi

echo "[*] Configuring UFW..."

# Ensure UFW is installed
if ! command -v ufw &>/dev/null; then
    apt-get update && apt-get install -y ufw >/dev/null 2>&1
fi

# Reset UFW to a clean baseline state non-interactively
ufw --force reset >/dev/null 2>&1

# Set default policies: deny incoming, allow outgoing
ufw default deny incoming >/dev/null 2>&1
ufw default allow outgoing >/dev/null 2>&1

echo "    Default incoming: deny"
echo "    Default outgoing: allow"

echo "[*] Adding allow rules..."

# 1. SSH from management network only (e.g., 10.10.1.0/24)
ufw allow from 10.10.1.0/24 to any port 22 proto tcp >/dev/null 2>&1
echo "    22/tcp from 10.10.1.0/24   [ADDED] SSH - management only"

# 2. HTTP (Port 80)
ufw allow 80/tcp >/dev/null 2>&1
echo "    80/tcp                     [ADDED] HTTP"

# 3. HTTPS (Port 443)
ufw allow 443/tcp >/dev/null 2>&1
echo "    443/tcp                    [ADDED] HTTPS"

# 4. MySQL from application network only (e.g., 10.10.2.0/24)
ufw allow from 10.10.2.0/24 to any port 3306 proto tcp >/dev/null 2>&1
echo "    3306/tcp from 10.10.2.0/24 [ADDED] MySQL - app network only"

echo "[*] Enabling logging..."

# Enable low-level logging for auditing denied traffic attempts
ufw logging low >/dev/null 2>&1
echo "    Logging: on (low)"

echo "[*] Activating firewall..."

# Enable UFW without prompting
ufw --force enable >/dev/null 2>&1

echo "    UFW: active"
echo "    Rules: 4 allow, default deny"
