
#!/bin/bash

set -u

STATE_DIR="/tmp/rtest_state"
LOG_FILE="$(pwd)/recovery_test_log.txt"
RTO_SECONDS=1800

usage() {
    echo 'Usage: ./recovery_timer.sh "Step name" START|PASS|FAIL'
    echo '   or: ./recovery_timer.sh SUMMARY'
    exit 2
}

if [[ "${1:-}" == "SUMMARY" && $# -eq 1 ]]; then
    if [[ ! -f "$STATE_DIR/test_start" ]]; then
        echo "No recovery test has started."
        exit 1
    fi

    now=$(date +%s)
    start=$(cat "$STATE_DIR/test_start")
    elapsed=$((now - start))

    result="PASS"
    if (( elapsed > RTO_SECONDS )); then
        result="FAIL"
    fi

    printf 'Total elapsed time: %dm %02ds\n' \
        "$((elapsed / 60))" "$((elapsed % 60))"
    echo "RTO (30 minutes): $result"
    exit 0
fi

[[ $# -eq 2 ]] || usage

step="$1"
status="$2"

if [[ "$status" != "START" &&
      "$status" != "PASS" &&
      "$status" != "FAIL" ]]; then
    usage
fi

mkdir -p "$STATE_DIR"

if [[ "$status" == "START" ]]; then

    if [[ ! -f "$STATE_DIR/test_start" ]]; then
        date +%s > "$STATE_DIR/test_start"
        : > "$LOG_FILE"
        echo 0 > "$STATE_DIR/count"
    fi

    if [[ -f "$STATE_DIR/active_step" ]]; then
        echo "Finish the active step first:"
        cat "$STATE_DIR/active_step"
        exit 1
    fi

    count=$(cat "$STATE_DIR/count")
    count=$((count + 1))
    echo "$count" > "$STATE_DIR/count"

    printf '%s' "$step" > "$STATE_DIR/active_step"
    date +%s > "$STATE_DIR/active_start"
    date '+%H:%M:%S' > "$STATE_DIR/active_clock"

    printf 'Started step %02d: %s\n' "$count" "$step"

else

    if [[ ! -f "$STATE_DIR/active_step" ]]; then
        echo "No active step."
        exit 1
    fi

    if [[ "$(cat "$STATE_DIR/active_step")" != "$step" ]]; then
        echo "Step name does not match active step."
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

    rm -f "$STATE_DIR/active_step"
    rm -f "$STATE_DIR/active_start"
    rm -f "$STATE_DIR/active_clock"
fi
