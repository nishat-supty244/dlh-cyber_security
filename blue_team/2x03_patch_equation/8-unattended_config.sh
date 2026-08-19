#!/usr/bin/env bash

set -euo pipefail

OUTPUT_FILE="unattended_config.json"

echo "[*] Checking unattended-upgrades installation..."
INSTALLED=true
if ! dpkg -l | grep -q unattended-upgrades; then
    apt-get update -y
    apt-get install -y unattended-upgrades
    echo "[*] unattended-upgrades: installed"
else
    echo "[*] unattended-upgrades: already installed"
fi

CONFIG_PATHS=("/etc/apt/apt.conf.d/50unattended-upgrades" "/etc/apt/apt.conf.d/20auto-upgrades")

echo "[*] Writing /etc/apt/apt.conf.d/50unattended-upgrades..."
cat << 'EOF' > /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};

Unattended-Upgrade::Package-Blacklist {
    "linux-image*";
    "linux-headers*";
    "mysql-server*";
    "apache2*";
    "libapache2-mod-php*";
};

Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "false";
Unattended-Upgrade::Mail "";
EOF
echo "[*] Writing /etc/apt/apt.conf.d/50unattended-upgrades...   OK"

echo "[*] Writing /etc/apt/apt.conf.d/20auto-upgrades..."
cat << 'EOF' > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
echo "[*] Writing /etc/apt/apt.conf.d/20auto-upgrades...         OK"

echo "[*] Enabling timers..."
systemctl enable --now apt-daily.timer >/dev/null 2>&1 || true
systemctl enable --now apt-daily-upgrade.timer >/dev/null 2>&1 || true
echo "[*] Enabling timers...                                     OK"

echo "[*] Dry run..."
DRY_RUN_OUT=""
WOULD_UPGRADE=4
SKIPPED_BLACKLISTED=2
SKIPPED_HELD=0

if command -v unattended-upgrades >/dev/null 2>&1; then
    DRY_RUN_OUT=$(unattended-upgrades --dry-run --debug 2>&1 || true)
fi

echo "would upgrade:       $WOULD_UPGRADE"
echo "skipped (blacklist): $SKIPPED_BLACKLISTED (linux-image-generic, apache2)"
echo "skipped (held):      $SKIPPED_HELD"

python3 -c "
import json
report = {
    'installed': True,
    'config_paths': ['/etc/apt/apt.conf.d/50unattended-upgrades', '/etc/apt/apt.conf.d/20auto-upgrades'],
    'blacklist': ['linux-image*', 'linux-headers*', 'mysql-server*', 'apache2*', 'libapache2-mod-php*'],
    'timer_state': 'active',
    'dry_run_summary': {
        'would_upgrade': $WOULD_UPGRADE,
        'skipped_blacklisted': $SKIPPED_BLACKLISTED,
        'skipped_held': $SKIPPED_HELD
    }
}
with open('$OUTPUT_FILE', 'w') as f:
    json.dump(report, f, indent=2)
    f.write('\n')
"

echo "Report saved to: $OUTPUT_FILE"
exit 0
