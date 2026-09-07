#!/bin/bash

# PAM Fortress - Authentication Hardening Script
# MedDefense Security Hardening
# Purpose: Enforce password complexity, account lockout,
#          and password history policies.

set -euo pipefail

echo "[*] Starting PAM hardening..."
echo


########################################
# 1. Install libpam-pwquality
########################################

echo "[*] Checking libpam-pwquality..."

if dpkg -s libpam-pwquality >/dev/null 2>&1; then

    VERSION=$(dpkg -s libpam-pwquality | grep Version | awk '{print $2}')

    echo "    Already installed: libpam-pwquality $VERSION"

else

    echo "    Installing libpam-pwquality..."

    apt update
    apt install -y libpam-pwquality

    echo "    Installation completed"

fi


########################################
# 2. Backup configuration files
########################################

echo

echo "[*] Creating PAM configuration backups..."

cp /etc/security/pwquality.conf \
/etc/security/pwquality.conf.bak 2>/dev/null || true

cp /etc/pam.d/common-password \
/etc/pam.d/common-password.bak 2>/dev/null || true

cp /etc/pam.d/common-auth \
/etc/pam.d/common-auth.bak 2>/dev/null || true


########################################
# 3. Configure password quality
########################################

echo

echo "[*] Configuring password quality (/etc/security/pwquality.conf)..."

PWQUALITY="/etc/security/pwquality.conf"


cat > "$PWQUALITY" <<EOF

# MedDefense Password Quality Policy

# Minimum password length
minlen = 14

# Require at least one digit
dcredit = -1

# Require at least one uppercase letter
ucredit = -1

# Require at least one lowercase letter
lcredit = -1

# Require at least one special character
ocredit = -1

# Prevent repeated characters
maxrepeat = 3

# Reject password containing username
reject_username

EOF


echo "    minlen = 14              [SET]"
echo "    dcredit = -1             [SET]"
echo "    ucredit = -1             [SET]"
echo "    lcredit = -1             [SET]"
echo "    ocredit = -1             [SET]"
echo "    maxrepeat = 3            [SET]"
echo "    reject_username          [SET]"


########################################
# 4. Configure pam_faillock
########################################

echo

echo "[*] Configuring account lockout (pam_faillock)..."

AUTH_FILE="/etc/pam.d/common-auth"

# Add faillock configuration if missing

if ! grep -q "pam_faillock" "$AUTH_FILE"; then

cat >> "$AUTH_FILE" <<EOF

# MedDefense Account Lockout Policy
auth required pam_faillock.so preauth silent deny=5 unlock_time=900 fail_interval=900
auth [default=die] pam_faillock.so authfail deny=5 unlock_time=900 fail_interval=900
account required pam_faillock.so

EOF

fi


echo "    deny = 5                 [SET]"
echo "    unlock_time = 900        [SET]"
echo "    fail_interval = 900      [SET]"


########################################
# 5. Configure password history
########################################

echo

echo "[*] Configuring password history..."

PASSWORD_FILE="/etc/pam.d/common-password"


if ! grep -q "pam_pwhistory" "$PASSWORD_FILE"; then

cat >> "$PASSWORD_FILE" <<EOF

# MedDefense Password History Policy
password required pam_pwhistory.so remember=12 use_authtok

EOF

fi


echo "    remember = 12             [SET]"


########################################
# 6. Validation
########################################

echo

echo "[*] Validating PAM configuration..."

ERRORS=0


# Check password quality

for setting in \
"minlen = 14" \
"dcredit = -1" \
"ucredit = -1" \
"lcredit = -1" \
"ocredit = -1" \
"maxrepeat = 3" \
"reject_username"
do

    if grep -q "$setting" "$PWQUALITY"; then
        echo "    $setting [PASS]"
    else
        echo "    $setting [FAIL]"
        ERRORS=$((ERRORS+1))
    fi

done


# Check faillock

if grep -q "deny=5" "$AUTH_FILE"; then
    echo "    faillock deny=5 [PASS]"
else
    echo "    faillock deny=5 [FAIL]"
    ERRORS=$((ERRORS+1))
fi


if grep -q "unlock_time=900" "$AUTH_FILE"; then
    echo "    faillock unlock_time=900 [PASS]"
else
    echo "    faillock unlock_time=900 [FAIL]"
    ERRORS=$((ERRORS+1))
fi


# Check password history

if grep -q "remember=12" "$PASSWORD_FILE"; then
    echo "    password history remember=12 [PASS]"
else
    echo "    password history remember=12 [FAIL]"
    ERRORS=$((ERRORS+1))
fi


########################################
# Summary
########################################

echo

if [ "$ERRORS" -eq 0 ]; then

    echo "======================================"
    echo "PAM Hardening Completed Successfully"
    echo "======================================"

    echo "Password minimum length: 14"
    echo "Lockout: 5 attempts / 15 min"
    echo "History: 12 passwords"

else

    echo "======================================"
    echo "PAM Hardening Completed With Errors"
    echo "Errors detected: $ERRORS"
    echo "======================================"

fi
