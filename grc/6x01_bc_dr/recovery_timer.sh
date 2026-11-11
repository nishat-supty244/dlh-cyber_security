
#!/bin/bash

set -u

STATE_DIR="/tmp/rtest_state"
LOG_FILE="$STATE_DIR/recovery_test_log.txt"
RTO_SECONDS=1800

usage() {
    echo 'Usage: ./recovery_timer.sh "Step name" START|PASS|FAIL'
    echo '       ./recovery_timer.sh SUMMARY'
    exit 2
}

mkdir -p "$STATE_DIR"

if [[ "${1:-}" == "SUMMARY" && $# -eq 1 ]]; then
    if [[ ! -f "$STATE_DIR/test_start" ]]; then
        echo "ERROR: No test has been recorded."
        exit 1
    fi

    if [[ -f "$STATE_DIR/active_step" ]]; then
        echo "ERROR: A recovery step is still active."
        exit 1
    fi

    if [[ -f "$STATE_DIR/test_end" ]]; then
        end=$(cat "$STATE_DIR/test_end")
    else
        end=$(date +%s)
    fi

    start=$(cat "$STATE_DIR/test_start")
    elapsed=$((end - start))

    failures=0
    if [[ -f "$STATE_DIR/failures" ]]; then
        failures=$(cat "$STATE_DIR/failures")
    fi

    if (( elapsed <= RTO_SECONDS )); then
        rto="PASS"
    else
        rto="FAIL"
    fi

    if (( failures == 0 && elapsed <= RTO_SECONDS )); then
        outcome="PASS"
    else
        outcome="FAIL"
    fi

    {
        echo "Recovery Test Summary"
        printf 'Actual recovery time: %dm %02ds\n' \
            "$((elapsed / 60))" "$((elapsed % 60))"
        echo "Declared RTO: 30 minutes"
        echo "RTO result: $rto"
        echo "Failed steps: $failures"
        echo "Overall timing/step result: $outcome"
    } | tee "$STATE_DIR/summary.txt"

    exit 0
fi

[[ $# -eq 2 ]] || usage

step="$1"
status="$2"

case "$status" in
    START|PASS|FAIL) ;;
    *) usage ;;
esac

if [[ "$status" == "START" ]]; then

    if [[ -f "$STATE_DIR/test_end" ]]; then
        echo "ERROR: Test already completed."
        exit 1
    fi

    if [[ -f "$STATE_DIR/active_step" ]]; then
        echo "ERROR: Finish the active step first."
        exit 1
    fi

    if [[ ! -f "$STATE_DIR/test_start" ]]; then
        date +%s > "$STATE_DIR/test_start"
        date '+%H:%M:%S' > "$STATE_DIR/start_clock"
        echo 0 > "$STATE_DIR/count"
        echo 0 > "$STATE_DIR/failures"
        : > "$LOG_FILE"
    fi

    count=$(cat "$STATE_DIR/count")
    count=$((count + 1))
    echo "$count" > "$STATE_DIR/count"

    echo "$step" > "$STATE_DIR/active_step"
    date +%s > "$STATE_DIR/active_start"
    date '+%H:%M:%S' > "$STATE_DIR/active_clock"

    printf 'Started STEP %02d: %s\n' "$count" "$step"
    exit 0
fi

if [[ ! -f "$STATE_DIR/active_step" ]]; then
    echo "ERROR: No active step."
    exit 1
fi

if [[ "$(cat "$STATE_DIR/active_step")" != "$step" ]]; then
    echo "ERROR: Step name does not match."
    exit 1
fi

end_epoch=$(date +%s)
end_clock=$(date '+%H:%M:%S')
start_epoch=$(cat "$STATE_DIR/active_start")
start_clock=$(cat "$STATE_DIR/active_clock")
count=$(cat "$STATE_DIR/count")

duration=$((end_epoch - start_epoch))

printf '[STEP %02d] %-30s | Start: %s | End: %s | Duration: %dm %02ds | %s\n' \
    "$count" "$step" "$start_clock" "$end_clock" \
    "$((duration / 60))" "$((duration % 60))" "$status" \
    | tee -a "$LOG_FILE"

if [[ "$status" == "FAIL" ]]; then
    failures=$(cat "$STATE_DIR/failures")
    echo $((failures + 1)) > "$STATE_DIR/failures"
fi

rm -f "$STATE_DIR/active_step"
rm -f "$STATE_DIR/active_start"
rm -f "$STATE_DIR/active_clock"

# Final validation is the recovery endpoint.
if [[ "$step" == "Final recovery validation" ]]; then
    echo "$end_epoch" > "$STATE_DIR/test_end"
fi
