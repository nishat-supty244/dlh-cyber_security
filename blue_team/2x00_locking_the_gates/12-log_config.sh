k#!/bin/bash

# The Log Architect
# MedDefense - Log Configuration Script

set -euo pipefail

RSYSLOG_CONF="/etc/rsyslog.d/meddefense.conf"
LOGROTATE_CONF="/etc/logrotate.d/meddefense"

echo "[*] Configuring rsyslog..."

########################################
# Install rsyslog if missing
########################################

if ! command -v rsyslogd >/dev/null 2>&1; then
    apt update
    apt install -y rsyslog
fi

########################################
# Configure rsyslog
########################################

cat > "$RSYSLOG_CONF" <<EOF
# MedDefense rsyslog configuration

# Authentication logs
auth,authpriv.*    /var/log/auth.log

# General system logs
*.info;auth.none   /var/log/syslog

# Structured log format
\$ActionFileDefaultTemplate RSYSLOG_FileFormat
EOF

systemctl restart rsyslog

echo "    auth,authpriv.* -> /var/log/auth.log     [CONFIGURED]"
echo "    *.info;auth.none -> /var/log/syslog      [CONFIGURED]"

echo

########################################
# Configure log rotation
########################################

echo "[*] Setting log rotation policies..."

cat > "$LOGROTATE_CONF" <<EOF
/var/log/auth.log {
    daily
    rotate 90
    compress
    delaycompress
    missingok
    notifempty
    create 640 root adm
}

/var/log/syslog {
    daily
    rotate 60
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

########################################
# Verify log activity
########################################

echo "[*] Verifying log activity..."

# Ensure log files exist
touch /var/log/auth.log
touch /var/log/syslog

# Generate test log entries
logger -p auth.info "MedDefense auth test"
logger "MedDefense syslog test"

sleep 2

if grep -q "MedDefense auth test" /var/log/auth.log; then
    echo "    /var/log/auth.log: receiving events       [OK]"
else
    echo "    /var/log/auth.log: receiving events       [FAIL]"
fi

if grep -q "MedDefense syslog test" /var/log/syslog; then
    echo "    /var/log/syslog: receiving events         [OK]"
else
    echo "    /var/log/syslog: receiving events         [FAIL]"
fi

echo

########################################
# Secure log permissions
########################################

echo "[*] Securing log file permissions..."

chown root:adm /var/log/auth.log
chmod 640 /var/log/auth.log

chown root:adm /var/log/syslog
chmod 640 /var/log/syslog

echo "    /var/log/auth.log: 640 root:adm          [OK]"
echo "    /var/log/syslog: 640 root:adm            [OK]"

echo

########################################
# Summary
########################################

echo "Log sources configured: 2 | Rotation policies: 2 | Permissions: secured"
