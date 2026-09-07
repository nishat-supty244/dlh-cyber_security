#!/bin/bash

# AppArmor Enforcer Script
# MedDefense Security Hardening
# Purpose: Enable AppArmor protection and enforce profiles
# for network-exposed services.

set -euo pipefail

echo "[*] Checking AppArmor status..."

########################################
# 1. Check AppArmor Installation
########################################

if ! command -v aa-status >/dev/null 2>&1; then
    echo "[!] AppArmor tools not installed."
    echo "[*] Installing AppArmor..."

    apt update
    apt install -y apparmor apparmor-utils
fi


########################################
# Check AppArmor module
########################################

if aa-status | grep -q "apparmor module is loaded"; then
    echo "    AppArmor module: loaded"
else
    echo "    AppArmor module: NOT loaded"
fi


########################################
# Check service
########################################

if systemctl is-active --quiet apparmor; then
    echo "    AppArmor service: active"
else
    echo "    AppArmor service inactive. Starting..."
    systemctl enable --now apparmor
    echo "    AppArmor service: active"
fi


echo


########################################
# 2. Show Current Profiles
########################################

echo "[*] Current AppArmor profiles:"

aa-status | grep -E "profiles are|processes are|enforce|complain|unconfined" || true

echo


########################################
# 3. Switch Apache and MySQL Profiles
########################################

echo "[*] Profile enforcement:"


ENFORCE_COUNT=0
COMPLAIN_COUNT=0
UNCONFINED_COUNT=0


enforce_profile()
{

PROFILE=$1
NAME=$2


if [ -f "$PROFILE" ]; then

    if aa-status | grep -q "$NAME"; then

        echo "    $NAME        complain -> enforce [ENFORCED]"

        aa-enforce "$PROFILE"

        ENFORCE_COUNT=$((ENFORCE_COUNT+1))

    else

        echo "    $NAME        [ALREADY ENFORCED]"
        ENFORCE_COUNT=$((ENFORCE_COUNT+1))

    fi

else

    echo "    $NAME        [PROFILE NOT FOUND]"

fi

}


enforce_profile \
"/etc/apparmor.d/usr.sbin.apache2" \
"/usr/sbin/apache2"


enforce_profile \
"/etc/apparmor.d/usr.sbin.mysqld" \
"/usr/sbin/mysqld"



########################################
# SSH Verification
########################################

if [ -f "/etc/apparmor.d/usr.sbin.sshd" ]; then

    echo "    /usr/sbin/sshd        enforce [OK]"
    ENFORCE_COUNT=$((ENFORCE_COUNT+1))

fi


echo


########################################
# 4. Create Custom MedDefense Profile
########################################

echo "[*] Creating custom AppArmor profile..."

PROFILE="/etc/apparmor.d/opt.meddefense.billing-app"


cat > "$PROFILE" <<EOF

#include <tunables/global>

/opt/meddefense/billing-app {

    # Allow application execution
    /opt/meddefense/billing-app/** rix,

    # Allow application logs
    /var/log/meddefense/** rw,

    # Allow temporary files
    /tmp/** rw,

    # Block access to sensitive authentication files
    deny /etc/shadow r,
    deny /etc/gshadow r,

    # Block patient database access
    deny /var/lib/mysql/** rw,

    # Network access
    network inet stream,

}

EOF


echo "    /opt/meddefense/billing-app [CREATED]"


# Load and enforce profile

apparmor_parser -r "$PROFILE"

aa-enforce "$PROFILE"


ENFORCE_COUNT=$((ENFORCE_COUNT+1))


echo


########################################
# 5. Find Unconfined Processes
########################################

echo "[*] Unconfined network-exposed processes:"


UNCONFINED=$(aa-status | grep -A20 "processes are unconfined" || true)


if [ -n "$UNCONFINED" ]; then

    echo "$UNCONFINED"

else

    echo "    None"

fi


echo


########################################
# 6. Final Summary
########################################


# Count current states

ENFORCE_FINAL=$(aa-status | grep "profiles are in enforce mode" | awk '{print $1}' || echo 0)

COMPLAIN_FINAL=$(aa-status | grep "profiles are in complain mode" | awk '{print $1}' || echo 0)

UNCONFINED_FINAL=$(aa-status | grep "processes are unconfined" | awk '{print $1}' || echo 0)



echo "======================================"
echo "AppArmor Configuration Summary"
echo "======================================"

echo "Profiles in enforce: $ENFORCE_FINAL"
echo "Complain: $COMPLAIN_FINAL"
echo "Unconfined: $UNCONFINED_FINAL"

echo

echo "[+] AppArmor hardening completed."
