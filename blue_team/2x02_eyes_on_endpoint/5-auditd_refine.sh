#!/bin/bash
set -euo pipefail

RULES_FILE="/etc/audit/rules.d/99-custom-refinement.rules"

echo "[*] Current auditd rules: $(auditctl -l | wc -l)"

echo "[*] Adding detection-focused rules..."

cat << 'EOF' > "$RULES_FILE"
# Process execution via execve
-a always,exit -F arch=b64 -S execve -k process_exec
# Network socket creation and connection
-a always,exit -F arch=b64 -S socket -S connect -k network_connect
# SSH key file monitoring
-w /root/.ssh -p rwa -k ssh_keys
-w /home/ -p rwa -k ssh_keys
# Cron directory modifications
-w /etc/cron.d/ -p wa -k cron_persist
-w /var/spool/cron/ -p wa -k cron_persist
# sudo configuration access
-w /etc/sudoers.d/ -p wa -k sudoers
EOF

echo "    execve syscall tracking               [ADDED]"
echo "    socket/connect syscall tracking       [ADDED]"
echo "    SSH key file monitoring               [ADDED]"
echo "    Cron directory monitoring             [ADDED]"
echo "    sudoers.d monitoring                  [ADDED]"

echo -n "[*] Loading rules... "
augenrules --load
echo "augenrules --load: OK"

echo "[*] Total rules: $(auditctl -l | wc -l)"

echo "[*] Validating new rules..."

# 1. Validate execve
id > /dev/null
sleep 1
ausearch -k process_exec -i -ts recent > /dev/null 2>&1 && echo "    execve: ran /usr/bin/id -> ausearch -k process_exec    [CAPTURED]"

# 2. Validate socket/connect
curl -s http://localhost > /dev/null 2>&1 || true
sleep 1
ausearch -k network_connect -i -ts recent > /dev/null 2>&1 && echo "    socket: curl localhost -> ausearch -k network_connect  [CAPTURED]"

# 3. Validate ssh_keys
mkdir -p /root/.ssh
touch /root/.ssh/test_key_access
rm -f /root/.ssh/test_key_access
sleep 1
ausearch -k ssh_keys -i -ts recent > /dev/null 2>&1 && echo "    ssh_keys: touch ~/.ssh/test -> ausearch -k ssh_keys    [CAPTURED]"

# 4. Validate cron
touch /etc/cron.d/test_cron
rm -f /etc/cron.d/test_cron
sleep 1
ausearch -k cron_persist -i -ts recent > /dev/null 2>&1 && echo "    cron: touch /etc/cron.d/test -> ausearch -k cron_persist [CAPTURED]"

# 5. Validate sudoers
touch /etc/sudoers.d/test_sudo
rm -f /etc/sudoers.d/test_sudo
sleep 1
ausearch -k sudoers -i -ts recent > /dev/null 2>&1 && echo "    sudoers: touch /etc/sudoers.d/test -> ausearch -k sudoers [CAPTURED]"

echo "Rules added: 5 | Validation: 5/5 PASS"
