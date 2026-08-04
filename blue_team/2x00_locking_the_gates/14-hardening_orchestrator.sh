#!/bin/bash

# 14-hardening_orchestrator.sh
# MedDefense Production Hardening Workflow

set -euo pipefail


RUN_LOG="hardening_run.json"
IMPROVEMENT_LOG="hardening_improvement.json"


########################################
# Required hardening scripts
########################################

SCRIPTS=(
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


########################################
# Verify scripts exist
########################################

echo "[*] Checking required scripts..."

for script in "${SCRIPTS[@]}"
do
    if [ ! -f "$script" ]; then
        echo "[FAIL] Missing: $script"
        exit 1
    fi
done

echo "Pre-checks: PASS"
echo "Steps scheduled: ${#SCRIPTS[@]}"


########################################
# Capture Lynis score
########################################

get_lynis_score()
{
    if command -v lynis >/dev/null 2>&1
    then
        lynis audit system --quick > lynis_output.txt 2>/dev/null || true

        grep "Hardening index" lynis_output.txt | \
        awk '{print $4}' | tr -d '%'
    else
        echo "0"
    fi
}


########################################
# Before score
########################################

echo "[*] Capturing pre-hardening Lynis score..."

BEFORE_SCORE=$(get_lynis_score)



########################################
# Create JSON log header
########################################

echo "{" > "$RUN_LOG"
echo "\"steps\":[" >> "$RUN_LOG"


FIRST=true
COMPLETED=0
FAILED=0



########################################
# Run workflow
########################################

for script in "${SCRIPTS[@]}"
do

    echo "[*] Running $script"

    START=$(date +%s)


    if bash "./$script"
    then

        RESULT="SUCCESS"
        EXIT_CODE=0
        COMPLETED=$((COMPLETED+1))


    else

        RESULT="FAILED"
        EXIT_CODE=$?
        FAILED=$((FAILED+1))


        echo "[FAIL] $script failed"
        echo "Stopping workflow."

        break

    fi


    END=$(date +%s)

    TIME=$((END-START))


    if [ "$FIRST" = true ]
    then
        FIRST=false
    else
        echo "," >> "$RUN_LOG"
    fi


    echo "{\"script\":\"$script\",\"status\":\"$RESULT\",\"exit_code\":$EXIT_CODE,\"duration\":\"${TIME}s\"}" >> "$RUN_LOG"


done


echo "]" >> "$RUN_LOG"
echo "}" >> "$RUN_LOG"



########################################
# After score
########################################

echo "[*] Capturing post-hardening Lynis score..."

AFTER_SCORE=$(get_lynis_score)



DELTA=$((AFTER_SCORE-BEFORE_SCORE))



########################################
# Improvement JSON
########################################

cat > "$IMPROVEMENT_LOG" <<EOF
{
    "before_lynis_score": $BEFORE_SCORE,
    "after_lynis_score": $AFTER_SCORE,
    "delta": $DELTA
}
EOF



########################################
# Final output
########################################

echo
echo "Pre-checks: PASS"
echo "Steps completed: $COMPLETED"
echo "Steps failed: $FAILED"

echo "Before Lynis score: $BEFORE_SCORE"
echo "After Lynis score: $AFTER_SCORE"
echo "Delta: +$DELTA"

echo "Run log saved to: hardening_run.json"
echo "Improvement saved to: hardening_improvement.json"



if [ "$FAILED" -gt 0 ]
then
    exit 1
fi

exit 0
