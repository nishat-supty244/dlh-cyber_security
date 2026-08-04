#!/bin/bash

# Production Hardening Orchestrator
# MedDefense Linux Security Hardening

set -euo pipefail


########################################
# Configuration
########################################

LOG_FILE="hardening_run.json"
IMPROVEMENT_FILE="hardening_improvement.json"

STEPS=(
    "0-baseline_snapshot.sh"
    "2-lynis_parse.sh"
    "4-ssh_hardening.sh"
    "5-sysctl_hardening.sh"
    "6-filesystem_hardening.sh"
    "7-service_minimization.sh"
    "8-pam_hardening.sh"
    "9-apparmor_config.sh"
    "10-auditd_config.sh"
    "11-audit_coverage_test.sh"
    "12-log_config.sh"
    "13-firewall_baseline.sh"
    "15-validation.sh"
)


RUN_RESULTS=()

FAILED=0
COMPLETED=0



########################################
# Root check
########################################

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run as root"
    exit 1
fi



########################################
# Pre-check scripts
########################################

echo "[*] Running pre-checks..."

for script in "${STEPS[@]}"; do

    if [ ! -f "$script" ]; then
        echo "[FAIL] Missing script: $script"
        exit 1
    fi

done


echo "Pre-checks: PASS"
echo "Steps scheduled: ${#STEPS[@]}"



########################################
# Capture Lynis score
########################################

get_lynis_score(){

    if command -v lynis >/dev/null 2>&1; then

        lynis audit system --quick >/tmp/lynis_output.txt 2>/dev/null || true

        SCORE=$(grep "Hardening index" /tmp/lynis_output.txt \
        | awk '{print $4}' \
        | tr -d '%' || echo "0")

        echo "$SCORE"

    else

        echo "0"

    fi

}



echo "[*] Capturing baseline Lynis score..."

BEFORE_SCORE=$(get_lynis_score)



########################################
# Execute hardening steps
########################################

echo

echo "[*] Starting hardening workflow..."



for script in "${STEPS[@]}"; do


    echo
    echo "[+] Running $script"


    START_TIME=$(date +%s)


    if bash "./$script"; then

        STATUS="SUCCESS"
        EXIT_CODE=0

        COMPLETED=$((COMPLETED+1))


    else

        STATUS="FAILED"
        EXIT_CODE=$?

        FAILED=$((FAILED+1))

        echo "[!] $script failed"
        break

    fi



    END_TIME=$(date +%s)

    DURATION=$((END_TIME-START_TIME))


    RUN_RESULTS+=(
    "{\"script\":\"$script\",\"status\":\"$STATUS\",\"exit_code\":$EXIT_CODE,\"duration\":\"${DURATION}s\"}"
    )


done



########################################
# Capture final Lynis score
########################################

echo

echo "[*] Capturing final Lynis score..."

AFTER_SCORE=$(get_lynis_score)



DELTA=$((AFTER_SCORE-BEFORE_SCORE))



########################################
# Generate hardening_run.json
########################################


echo "{"

echo "\"steps_completed\":$COMPLETED,"
echo "\"steps_failed\":$FAILED,"
echo "\"results\":["


printf "%s\n" "${RUN_RESULTS[@]}" | paste -sd "," -


echo "]"

echo "}" > "$LOG_FILE"



########################################
# Generate improvement report
########################################


cat > "$IMPROVEMENT_FILE" <<EOF
{
    "before_lynis_score": $BEFORE_SCORE,
    "after_lynis_score": $AFTER_SCORE,
    "improvement_delta": $DELTA
}
EOF



########################################
# Final report
########################################


echo

echo "=================================="
echo "Hardening Completed"
echo "=================================="

echo "Steps scheduled: ${#STEPS[@]}"
echo "Steps completed: $COMPLETED"
echo "Steps failed: $FAILED"

echo "Before Lynis score: $BEFORE_SCORE"
echo "After Lynis score: $AFTER_SCORE"
echo "Delta: $DELTA"

echo

echo "Run log saved to: $LOG_FILE"
echo "Improvement saved to: $IMPROVEMENT_FILE"


if [ "$FAILED" -ne 0 ]; then
    exit 1
fi

exit 0
