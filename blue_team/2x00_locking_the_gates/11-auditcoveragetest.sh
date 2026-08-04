#!/bin/bash
# ==============================================================================
# Audit Telemetry Coverage Test
# MedDefense Security Validation
# Purpose: Verify that auditd rules deployed in Task 10 capture security events.
# ==============================================================================

set -euo pipefail

# Must be run as root to trigger and verify audit logs
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with root privileges (sudo)." >&2
    exit 1
fi

REPORT="audit_validation.json"
TEST_DIR="/tmp/meddefense_audit_test"
mkdir -p "$TEST_DIR"

echo "[*] Running audit telemetry coverage tests..."

# Initialize JSON report structure
echo "{" > "$REPORT"
echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> "$REPORT"
echo "  \"tests\": [" >> "$REPORT"

tests_executed=0
captured_count=0
missed_count=0

# Helper function to run a test and check audit logs via ausearch
run_audit_test() {
    local test_num="$1"
    local test_name="$2"
    local expected_key="$3"
    local test_cmd="$4"

    tests_executed=$((tests_executed + 1))
    
    # Trigger the controlled action
    eval "$test_cmd" >/dev/null 2>&1 || true
    
    # Give the kernel audit subsystem a moment to log the event
    sleep 1

    # Check if auditd captured the event using ausearch by key
    local event_count=0
    if command -v ausearch &>/dev/null; then
        event_count=$(ausearch -k "$expected_key" --start recent -i 2>/dev/null | grep -c "type=" || true)
    fi

    local status="MISSED"
    if [ "$event_count" -gt 0 ]; then
        status="CAPTURED"
        captured_count=$((captured_count + 1))
    else
        missed_count=$((missed_count + 1))
    fi

    printf "[%d/6] %-32s [%s]\n" "$test_num" "$test_name" "$status"

    # Append to JSON report
    if [ "$test_num" -gt 1 ]; then
        echo "," >> "$REPORT"
    fi
    cat <<EOF >> "$REPORT"
    {
      "test_number": $test_num,
      "test_name": "$test_name",
      "expected_audit_key": "$expected_key",
      "command_executed": "$test_cmd",
      "capture_status": "$status",
      "matching_event_count": $event_count
    }
EOF
}

# Execute the 6 required controlled events
run_audit_test 1 "sudo execution" "privileged" "sudo id"
run_audit_test 2 "shadow access" "shadow" "cat /etc/shadow >/dev/null 2>&1 || true"
run_audit_test 3 "suspicious download tool" "download" "wget --version"
run_audit_test 4 "sshd config read" "config_modification" "stat /etc/ssh/sshd_config"
run_audit_test 5 "monitored test file write" "restricted_file" "touch $TEST_DIR/test_file.txt"
run_audit_test 6 "cron configuration check" "cron_action" "ls -la /etc/cron.d"

# Close JSON report array and add summary statistics
echo "" >> "$REPORT"
echo "  ]," >> "$REPORT"
echo "  \"summary\": {" >> "$REPORT"
echo "    \"tests_executed\": $tests_executed," >> "$REPORT"
echo "    \"captured\": $captured_count," >> "$REPORT"
echo "    \"missed\": $missed_count" >> "$REPORT"
echo "  }" >> "$REPORT"
echo "}" >> "$REPORT"

echo "[*] Cleaning test artifacts..."
rm -rf "$TEST_DIR"

echo "Tests executed: $tests_executed"
echo "Captured: $captured_count"
echo "Missed: $missed_count"
echo "Report saved to: $REPORT"
