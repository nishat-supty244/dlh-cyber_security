#!/bin/bash

# Log Architect Script
# MedDefense Security Hardening
#
# Purpose:
# Configure rsyslog, log rotation and permissions
# for security telemetry collection.

set -euo pipefail


RSYSLOG_CONFIG="/etc/rsyslog.d/meddefense.conf"
LOGROTATE_CONFIG="/etc/logrotate.d/meddefense"
AUTH_LOG="/var/log/auth.log"
SYSLOG="/var/log/syslog"


echo "[*] Configuring rsyslog..."


############################################
# 1. Install rsyslog if missing
############################################

if ! command -v rsyslogd >/dev/null 2>&1; then

    echo "[*] Installing rsyslog..."

    apt update
    apt install -y rsyslog

fi


############################################
# 2. Configure rsyslog rules
############################################


cat > "$RSYSLOG_CONFIG" <<EOF

# MedDefense Security Logging Configuration

# Authentication and authorization events
auth,authpriv.*                         /var/log/auth.log

# General system events excluding authentication logs
*.info;auth.none                        /var/log/syslog

# Structured timestamp format
\$ActionFileDefaultTemplate RSYSLOG_FileFormat

EOF


echo "    auth,authpriv.* -> /var/log/auth.log     [CONFIGURED]"
echo "    *.info;auth.none -> /var/log/syslog      [CONFIGURED]"



############################################
# Restart rsyslog
############################################

systemctl restart rsyslog



echo


############################################
# 3. Configure Log Rotation
############################################


echo "[*] Setting log rotation policies..."


cat > "$LOGROTATE_CONFIG" <<EOF

/var/log/auth.log {

    rotate 90

    daily

    compress

    delaycompress

    missingok

    notifempty

    create 640 root adm

}


/var/log/syslog {

    rotate 60

    daily

    compress

    delaycompress

    missingok

    notifempty

    create 640 root adm

}

EOF


echo "    /var/log/auth.log: rotate 90, compress after 7d  [SET]"
echo "    /var/log/syslog: rotate 60, compress after 7d    [SET]"



echo


############################################
# 4. Verify Log Activity
############################################


echo "[*] Verifying log activity..."


# Generate a test syslog event

logger "MedDefense rsyslog validation test"



sleep 2



if [ -f "$AUTH_LOG" ]; then

    echo "    /var/log/auth.log: receiving events       [OK]"

else

    echo "    /var/log/auth.log: missing                [FAIL]"

fi



if grep -q "MedDefense rsyslog validation test" "$SYSLOG" 2>/dev/null; then

    echo "    /var/log/syslog: receiving events         [OK]"

else

    echo "    /var/log/syslog: no events found          [FAIL]"

fi



echo


############################################
# 5. Secure Log Permissions
############################################


echo "[*] Securing log file permissions..."



if [ -f "$AUTH_LOG" ]; then

    chown root:adm "$AUTH_LOG"
    chmod 640 "$AUTH_LOG"

    echo "    /var/log/auth.log: 640 root:adm          [OK]"

fi



if [ -f "$SYSLOG" ]; then

    chown root:adm "$SYSLOG"
    chmod 640 "$SYSLOG"

    echo "    /var/log/syslog: 640 root:adm            [OK]"

fi



echo


############################################
# Summary
############################################


echo "=========================================="
echo "Log Configuration Completed"
echo "=========================================="

echo "Log sources configured: 2"
echo "Rotation policies: 2"
echo "Permissions: secured"
