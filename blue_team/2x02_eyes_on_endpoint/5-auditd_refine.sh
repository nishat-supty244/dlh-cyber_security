#!/bin/bash

# 5-auditd_refine.sh
# Goal: Refine auditd rules, load them, and validate each rule using trigger actions and ausearch.

RULES_FILE="/etc/audit/rules.d/refinement.rules"

echo "[*] Current auditd rules: $(auditctl -l | wc -l)"

echo "[*] Adding detection-focused rules..."

# Create or overwrite the refinement rules file in rules.d
cat << 'EOF' > "$RULES_FILE"
# Process execution via execve
-a always,exit -F arch=b64 -S execve -k process_exec
# Network socket creation and connection
-a always,exit -F arch=b64 -S socket -S connect -k network_connect
# SSH key file access
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

# Load updated rules using augenrules
echo -n "[*] Loading rules... "
if augenrules --load; then
    echo "augenrules --load: OK"
else
    echo "augenrules --load: FAILED"
    exit 1
fi

echo "[*] Total rules: $(auditctl -l | wc -l)"

echo "[*] Validating new rules..."

# 1. Validate execve
id > /dev/null
sleep 1
if ausearch -k process_exec -i -ts recent > /dev/null 2>&1; then
    echo "    execve: ran /usr/bin/id -> ausearch -k process_exec    [CAPTURED]"
    execve_pass=1
else
    echo "    execve: ran /usr/bin/id -> ausearch -k process_exec    [FAILED]"
    execve_pass=0
fi

# 2. Validate socket/connect
curl -s http://localhost > /dev/null 2>&1
sleep 1
if ausearch -k network_connect -i -ts recent > /dev/null 2>&1; then
    echo "    socket: curl localhost -> ausearch -k network_connect  [CAPTURED]"
    socket_pass=1
else
    echo "    socket: curl localhost -> ausearch -k network_connect  [FAILED]"
    socket_pass=0
fi

# 3. Validate ssh_keys (ensure a test user or root home .ssh exists)
mkdir -p /root/.ssh
touch /root/.ssh/test_key_access
sleep 1
if ausearch -k ssh_keys -i -ts recent > /dev/null 2>&1; then
    echo "    ssh_keys: touch ~/.ssh/test -> ausearch -k ssh_keys    [CAPTURED]"
    ssh_pass=1
else
    echo "    ssh_keys: touch ~/.ssh/test -> ausearch -k ssh_keys    [FAILED]"
    ssh_pass=0
fi

# 4. Validate cron
mkdir -p /etc/cron.d
touch /etc/cron.d/test_cron
rm -f /etc/cron.d/test_cron
sleep 1
if ausearch -k cron_persist -i -ts recent > /dev/null 2>&1; then
    echo "    cron: touch /etc/cron.d/test -> ausearch -k cron_persist [CAPTURED]"
    cron_pass=1
else
    echo "    cron: touch /etc/cron.d/test -> ausearch -k cron_persist [FAILED]"
    cron_pass=0
fi

# 5. Validate sudoers
mkdir -p /etc/sudoers.d
touch /etc/sudoers.d/test_sudo
rm -f /etc/sudoers.d/test_sudo
sleep 1
if ausearch -k sudoers -i -ts recent > /dev/null 2>&1; then
    echo "    sudoers: touch /etc/sudoers.d/test -> ausearch -k sudoers [CAPTURED]"
    sudo_pass=1
else
    echo "    sudoers: touch /etc/sudoers.d/test -> ausearch -k sudoers [FAILED]"
    sudo_pass=0
fi

total_pass=$((execve_pass + socket_pass + ssh_pass + cron_pass + sudo_pass))
echo "Rules added: 5 | Validation: $total_pass/5 PASS"
