#!/bin/bash

# Audit Engine Script
# MedDefense Security Hardening
# Purpose: Deploy auditd rules for monitoring security-critical events

set -euo pipefail


RULE_FILE="/etc/audit/rules.d/meddefense.rules"


echo "[*] Enabling auditd service..."


########################################
# 1. Install auditd
########################################

if ! command -v auditctl >/dev/null 2>&1; then

    echo "[*] Installing auditd..."

    apt update
    apt install -y auditd audispd-plugins

fi


########################################
# Enable auditd service
########################################

systemctl enable auditd >/dev/null 2>&1
systemctl start auditd


if systemctl is-active --quiet auditd; then
    echo "    auditd.service: active (running)"
else
    echo "    auditd.service: FAILED"
    exit 1
fi


echo


########################################
# 2. Create Audit Rules
########################################

echo "[*] Deploying MedDefense audit rules..."


cat > "$RULE_FILE" <<EOF

# ===============================
# Identity and Authentication Files
# ===============================

-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity


# PAM Configuration Monitoring

-w /etc/pam.d/ -p wa -k pam_config


# SSH Configuration Monitoring

-w /etc/ssh/sshd_config -p wa -k sshd_config


# ===============================
# Privilege Escalation Monitoring
# ===============================

-w /usr/bin/sudo -p x -k priv_esc
-w /usr/bin/su -p x -k priv_esc
-w /etc/sudoers -p wa -k sudoers


# ===============================
# Suspicious Tool Execution
# ===============================

-w /usr/bin/wget -p x -k suspicious_download
-w /usr/bin/curl -p x -k suspicious_download
-w /usr/bin/nc -p x -k suspicious_netcat


# ===============================
# MedDefense Application Monitoring
# ===============================

-w /var/lib/mysql/ -p wa -k meddefense_db

-w /etc/apache2/ -p wa -k meddefense_web

-w /etc/init.d/ -p wa -k startup_scripts


EOF



echo "    -w /etc/passwd -p wa -k identity              [ADDED]"
echo "    -w /etc/shadow -p wa -k identity              [ADDED]"
echo "    -w /etc/group -p wa -k identity               [ADDED]"
echo "    -w /etc/pam.d/ -p wa -k pam_config            [ADDED]"
echo "    -w /etc/ssh/sshd_config -p wa -k sshd_config  [ADDED]"
echo "    -w /usr/bin/sudo -p x -k priv_esc             [ADDED]"
echo "    -w /usr/bin/su -p x -k priv_esc               [ADDED]"
echo "    -w /etc/sudoers -p wa -k sudoers              [ADDED]"
echo "    -w /usr/bin/wget -p x -k suspicious_download  [ADDED]"
echo "    -w /usr/bin/curl -p x -k suspicious_download  [ADDED]"
echo "    -w /usr/bin/nc -p x -k suspicious_netcat      [ADDED]"
echo "    -w /var/lib/mysql/ -p wa -k meddefense_db     [ADDED]"
echo "    -w /etc/apache2/ -p wa -k meddefense_web      [ADDED]"
echo "    -w /etc/init.d/ -p wa -k startup_scripts      [ADDED]"



echo


########################################
# 3. Load Audit Rules
########################################


echo "[*] Loading rules..."

if augenrules --load; then

    echo "    augenrules --load: OK"

else

    echo "    augenrules --load: FAILED"
    exit 1

fi


echo


########################################
# 4. Verify Active Rules
########################################


echo "[*] Verifying..."

RULE_COUNT=$(auditctl -l | grep -c "^")

echo "    auditctl -l: $RULE_COUNT rules loaded"


echo


########################################
# 5. Test Audit Event
########################################


echo "[*] Test: reading /etc/shadow..."


# Trigger an auditable event

cat /etc/shadow >/dev/null 2>&1 || true


sleep 2


EVENT_COUNT=$(ausearch -ts recent -k identity 2>/dev/null | grep -c "type=" || true)



if [ "$EVENT_COUNT" -gt 0 ]; then

    echo "    ausearch -ts recent -k identity: $EVENT_COUNT event found [PASS]"

else

    echo "    ausearch -ts recent -k identity: No event found [FAIL]"

fi


echo

echo "======================================"
echo "Auditd Configuration Completed"
echo "======================================"

echo "Rules deployed:"
echo "14"

echo "Audit logging active: YES"
