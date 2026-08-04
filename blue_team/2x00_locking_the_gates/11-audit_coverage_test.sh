#!/bin/bash

# Audit Telemetry Coverage Test
# MedDefense Security Validation
#
# Purpose:
# Verify that auditd rules deployed in Task 10
# capture important security events.

set -euo pipefail


REPORT="audit_validation.json"
TEST_DIR="/tmp/meddefense_audit_test"
RESULTS=()
CAPTURED=0
TOTAL=6


echo "[*] Running audit telemetry coverage tests..."


########################################
# Cleanup function
########################################

cleanup()
{
    echo "[*] Cleaning test artifacts..."

    rm -rf "$TEST_DIR"

    # Remove temporary cron test if created
    rm -f /etc/cron.d/meddefense_audit_test

}

trap cleanup EXIT


mkdir -p "$TEST_DIR"



########################################
# Function to search audit events
########################################

check_audit()
{

NAME="$1"
KEY="$2"
COMMAND="$3"


START_TIME=$(date +"%H:%M:%S")


# Execute test command

eval "$COMMAND" >/dev/null 2>&1 || true


sleep 2


EVENTS=$(ausearch -ts recent -k "$KEY" 2>/dev/null | grep -c "type=" || true)


if [ "$EVENTS" -gt 0 ]; then

    STATUS="CAPTURED"
    CAPTURED=$((CAPTURED+1))

else

    STATUS="MISSED"

fi



echo "$STATUS"


RESULTS+=(
"{\"test\":\"$NAME\",\"key\":\"$KEY\",\"command\":\"$COMMAND\",\"timestamp\":\"$START_TIME\",\"status\":\"$STATUS\",\"events\":$EVENTS}"
)

}



########################################
# 1. Sudo execution test
########################################

echo -n "[1/6] sudo execution                    "

check_audit \
"sudo execution" \
"priv_esc" \
"sudo -n true"



########################################
# 2. Shadow access test
########################################

echo -n "[2/6] shadow access                     "

check_audit \
"shadow access" \
"identity" \
"cat /etc/shadow"



########################################
# 3. wget/curl execution test
########################################

echo -n "[3/6] suspicious download tool          "


if command -v wget >/dev/null 2>&1; then

    TOOL="/usr/bin/wget"

    COMMAND="$TOOL --version"

elif command -v curl >/dev/null 2>&1; then

    TOOL="/usr/bin/curl"

    COMMAND="$TOOL --version"

else

    TOOL="none"
    COMMAND="true"

fi


check_audit \
"suspicious download tool" \
"suspicious_download" \
"$COMMAND"



########################################
# 4. SSH config read test
########################################

echo -n "[4/6] sshd config read                  "


check_audit \
"sshd config read" \
"sshd_config" \
"stat /etc/ssh/sshd_config"



########################################
# 5. Test file write
########################################

echo -n "[5/6] monitored test file write          "


TEST_FILE="$TEST_DIR/testfile"

touch "$TEST_FILE"

check_audit \
"monitored test file write" \
"meddefense_test" \
"echo audit-test > $TEST_FILE"



########################################
# 6. Cron configuration test
########################################

echo -n "[6/6] cron configuration check          "


CRON_TEST="/etc/cron.d/meddefense_audit_test"


echo "# MedDefense audit test" | sudo tee "$CRON_TEST" >/dev/null


check_audit \
"cron configuration check" \
"startup_scripts" \
"stat $CRON_TEST"



########################################
# Create JSON Report
########################################


echo

echo "[*] Creating JSON report..."


cat > "$REPORT" <<EOF
{
    "audit_validation": [
        $(IFS=,; echo "${RESULTS[*]}")
    ]
}
EOF



########################################
# Summary
########################################

MISSED=$((TOTAL-CAPTURED))


echo

echo "Tests executed: $TOTAL"
echo "Captured: $CAPTURED"
echo "Missed: $MISSED"

echo "Report saved to: $REPORT"
