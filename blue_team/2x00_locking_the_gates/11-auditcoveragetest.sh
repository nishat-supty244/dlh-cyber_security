#!/bin/bash

# Audit Telemetry Coverage Test
# MedDefense Security Validation

set -euo pipefail


REPORT="audit_validation.json"
TEST_PATH="/tmp/meddefense_audit_test"

CAPTURED=0
MISSED=0
TOTAL=6

RESULTS=()


#################################
# Cleanup Function
#################################

cleanup()
{
    echo "[*] Cleaning test artifacts..."

    rm -rf "$TEST_PATH"

    rm -f /etc/cron.d/meddefense_audit_test
}

trap cleanup EXIT



#################################
# Setup
#################################

mkdir -p "$TEST_PATH"

echo "[*] Running audit telemetry coverage tests..."



#################################
# Audit Check Function
#################################

run_test()
{

NAME="$1"
KEY="$2"
COMMAND="$3"


TIMESTAMP=$(date -Iseconds)


eval "$COMMAND" >/dev/null 2>&1 || true


sleep 2


EVENT_COUNT=$(ausearch -ts recent -k "$KEY" 2>/dev/null | grep -c "type=" || true)



if [ "$EVENT_COUNT" -gt 0 ]; then

    STATUS="CAPTURED"

    CAPTURED=$((CAPTURED+1))

else

    STATUS="MISSED"

    MISSED=$((MISSED+1))

fi



echo "$STATUS"


RESULTS+=(
"{\"test\":\"$NAME\",\"key\":\"$KEY\",\"command\":\"$COMMAND\",\"timestamp\":\"$TIMESTAMP\",\"status\":\"$STATUS\",\"events\":$EVENT_COUNT}"
)

}



#################################
# Test 1 - sudo execution
#################################

echo -n "[1/6] sudo execution                    "

run_test \
"sudo execution" \
"priv_esc" \
"sudo -n id"



#################################
# Test 2 - shadow access
#################################

echo -n "[2/6] shadow access                     "

run_test \
"shadow access" \
"identity" \
"cat /etc/shadow"



#################################
# Test 3 - wget/curl execution
#################################

echo -n "[3/6] suspicious download tool          "


if command -v wget >/dev/null
then

COMMAND="/usr/bin/wget --version"

else

COMMAND="/usr/bin/curl --version"

fi


run_test \
"suspicious download tool" \
"suspicious_download" \
"$COMMAND"



#################################
# Test 4 - SSH config read
#################################

echo -n "[4/6] sshd config read                  "

run_test \
"sshd config read" \
"sshd_config" \
"stat /etc/ssh/sshd_config"



#################################
# Test 5 - Controlled file write
#################################

echo -n "[5/6] monitored test file write          "


TEST_FILE="$TEST_PATH/test.txt"

touch "$TEST_FILE"


run_test \
"monitored test file write" \
"meddefense_test" \
"echo test > $TEST_FILE"



#################################
# Test 6 - Cron configuration
#################################

echo -n "[6/6] cron configuration check          "


echo "# audit test" > /etc/cron.d/meddefense_audit_test


run_test \
"cron configuration check" \
"startup_scripts" \
"cat /etc/cron.d/meddefense_audit_test"



#################################
# JSON Report
#################################

cat > "$REPORT" <<EOF
{
"tests_executed": $TOTAL,
"captured": $CAPTURED,
"missed": $MISSED,
"results":[
$(IFS=,; echo "${RESULTS[*]}")
]
}
EOF



#################################
# Summary
#################################

echo

echo "Tests executed: $TOTAL"
echo "Captured: $CAPTURED"
echo "Missed: $MISSED"

echo "Report saved to: $REPORT"
