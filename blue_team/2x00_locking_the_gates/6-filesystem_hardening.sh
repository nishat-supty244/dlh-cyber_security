#!/bin/bash

# Permission Sweep - Filesystem Hardening Script
# MedDefense Security Hardening
# Purpose: Prevent privilege escalation through dangerous permissions

set -euo pipefail

SUID_FIXED=0
SGID_FIXED=0
WORLD_FIXED=0

SYSCTL_BACKUP="/etc/sysctl.conf.bak"

echo "[*] Starting filesystem permission hardening..."
echo


##############################
# 1. SUID Binary Audit
##############################

echo "[*] Checking SUID binaries..."

# Known safe Ubuntu 22.04 SUID binaries
SUID_WHITELIST=(
    "/usr/bin/passwd"
    "/usr/bin/sudo"
    "/usr/bin/su"
    "/usr/bin/chfn"
    "/usr/bin/chsh"
    "/usr/bin/gpasswd"
    "/usr/bin/newgrp"
    "/usr/bin/mount"
    "/usr/bin/umount"
    "/usr/bin/pkexec"
)

SUID_FILES=$(find / -xdev -type f -perm -4000 2>/dev/null || true)

SUID_COUNT=$(echo "$SUID_FILES" | grep -c "/" || true)

echo "Found $SUID_COUNT SUID binaries"

WHITELIST_COUNT=0
NON_WHITELIST_COUNT=0


while read -r file; do

    [[ -z "$file" ]] && continue

    if printf '%s\n' "${SUID_WHITELIST[@]}" | grep -qx "$file"; then
        WHITELIST_COUNT=$((WHITELIST_COUNT+1))

    else
        NON_WHITELIST_COUNT=$((NON_WHITELIST_COUNT+1))

        echo "  $file [SUID REMOVED]"

        chmod u-s "$file"

        SUID_FIXED=$((SUID_FIXED+1))
    fi

done <<< "$SUID_FILES"


echo "Whitelisted: $WHITELIST_COUNT"
echo "Non-whitelisted: $NON_WHITELIST_COUNT"

echo


##############################
# 2. SGID Binary Audit
##############################

echo "[*] Checking SGID binaries..."

SGID_WHITELIST=(
    "/usr/bin/wall"
    "/usr/bin/write"
    "/usr/bin/crontab"
    "/usr/bin/ssh-agent"
)

SGID_FILES=$(find / -xdev -type f -perm -2000 2>/dev/null || true)

SGID_COUNT=$(echo "$SGID_FILES" | grep -c "/" || true)

echo "Found $SGID_COUNT SGID binaries"

SGID_SAFE=0
SGID_UNSAFE=0


while read -r file; do

    [[ -z "$file" ]] && continue

    if printf '%s\n' "${SGID_WHITELIST[@]}" | grep -qx "$file"; then

        SGID_SAFE=$((SGID_SAFE+1))

    else

        SGID_UNSAFE=$((SGID_UNSAFE+1))

        echo "  $file [SGID REMOVED]"

        chmod g-s "$file"

        SGID_FIXED=$((SGID_FIXED+1))

    fi

done <<< "$SGID_FILES"


echo "Whitelisted: $SGID_SAFE"
echo "Non-whitelisted: $SGID_UNSAFE"

echo


##############################
# 3. World Writable Files
##############################

echo "[*] Checking world-writable files..."

WORLD_FILES=$(find / \
    -xdev \
    -type f \
    -perm -002 \
    ! -path "/proc/*" \
    ! -path "/sys/*" \
    ! -path "/dev/*" \
    2>/dev/null || true)


while read -r file; do

    [[ -z "$file" ]] && continue

    echo "  $file [FIXED]"

    chmod o-w "$file"

    WORLD_FIXED=$((WORLD_FIXED+1))

done <<< "$WORLD_FILES"


echo


##############################
# 4. Secure Temporary Mounts
##############################

echo "[*] Checking temporary directories..."

secure_mount()
{
    DIR=$1

    if mount | grep -q "$DIR"; then

        OPTIONS=$(mount | grep "$DIR" | awk '{print $6}')

        if [[ "$OPTIONS" == *"noexec"* &&
              "$OPTIONS" == *"nosuid"* &&
              "$OPTIONS" == *"nodev"* ]]; then

            echo "$DIR: noexec,nosuid,nodev [OK]"

        else

            echo "$DIR: missing security options [WARNING]"

        fi

    else

        echo "$DIR: not separately mounted [MANUAL REVIEW]"

    fi
}


secure_mount "/tmp"
secure_mount "/var/tmp"
secure_mount "/dev/shm"


echo


##############################
# 5. Restrict Cron Access
##############################

echo "[*] Restricting cron access..."

cat > /etc/cron.allow <<EOF
root
medadmin
sysadmin
EOF

chmod 600 /etc/cron.allow

echo "/etc/cron.allow configured"


echo


##############################
# Final Summary
##############################

echo "================================="
echo "Filesystem Hardening Summary"
echo "================================="

echo "SUID remediated: $SUID_FIXED"
echo "SGID remediated: $SGID_FIXED"
echo "World-writable fixed: $WORLD_FIXED"

echo
echo "[+] Permission sweep completed."
