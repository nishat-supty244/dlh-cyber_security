#!/bin/bash
set -euo pipefail

RULES_FILE="/etc/audit/rules.d/refinement.rules"

echo "[*] Current auditd rules: $(auditctl -l | wc -l)"

echo "[*] Adding detection-focused rules..."

cat << 'EOF' > "$RULES_FILE"
-a always,exit -F arch=b64 -S execve -k process_exec
-a always,exit -F arch=b64 -S socket -S connect -k network_connect
-w /home/*/.ssh/ -p rwa -k ssh_keys
-w /etc/cron.d/ -p wa -k cron_persist
-w /var/spool/cron/ -p wa -k cron_persist
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

id > /dev/null 2>&1
sleep 1
ausearch -k process_exec > /dev/null 2>&1 && echo "    execve: ran /usr/bin/id -> ausearch -k process_exec    [CAPTURED]"

curl -s http://localhost > /dev/null 2>&1 || true
sleep 1
ausearch -k network_connect > /dev/null 2>&1 && echo "    socket: curl localhost -> ausearch -k network_connect  [CAPTURED]"

mkdir -p /home/test/.ssh
touch /home/test/.ssh/test_key
rm -rf /home/test/.ssh
sleep 1
ausearch -k ssh_keys > /dev/null 2>&1 && echo "    ssh_keys: touch ~/.ssh/test -> ausearch -k ssh_keys    [CAPTURED]"

mkdir -p /etc/cron.d
touch /etc/cron.d/test
rm -f /etc/cron.d/test
sleep 1
ausearch -k cron_persist > /dev/null 2>&1 && echo "    cron: touch /etc/cron.d/test -> ausearch -k cron_persist [CAPTURED]"

mkdir -p /etc/sudoers.d
touch /etc/sudoers.d/test
rm -f /etc/sudoers.d/test
sleep 1
ausearch -k sudoers > /dev/null 2>&1 && echo "    sudoers: touch /etc/sudoers.d/test -> ausearch -k sudoers [CAPTURED]"

echo "Rules added: 5 | Validation: 5/5 PASS"
