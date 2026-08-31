#!/bin/bash
#
# SYNOPSIS
#   Runs the Lynis audit helper and persists the baseline score.

set -euo pipefail

SCRIPT_NAME=$(basename "$0")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CAPSTONE_DIR="${SCRIPT_DIR}/capstone"
BASELINE_DIR="${CAPSTONE_DIR}/baseline"
LOG_FILE="${BASELINE_DIR}/lynis_baseline.log"
JSON_FILE="${BASELINE_DIR}/baseline_linux.json"

write_info_log() {
    local message="$1"
    echo "[${SCRIPT_NAME}][INFO] ${message}"
}

write_error_log() {
    local message="$1"
    # ANSI color code for red text
    echo -e "\e[31m[${SCRIPT_NAME}][ERROR] ${message}\e[0m" >&2
}

validate_environment() {
    write_info_log "Validating execution environment..."

    if [[ $EUID -ne 0 ]]; then
        write_error_log "This script requires root privileges"
        exit 2
    fi

    if ! command -v lynis &> /dev/null; then
        write_error_log "Audit helper not found: lynis is not installed in PATH"
        exit 2
    fi

    write_info_log "Environment validation complete"
}

ensure_directories() {
    write_info_log "Creating baseline directory structure..."

    if [[ ! -d "${BASELINE_DIR}" ]]; then
        if ! mkdir -p "${BASELINE_DIR}" > /dev/null 2>&1; then
            write_error_log "Failed to create baseline directory: ${BASELINE_DIR}"
            exit 2
        fi
    fi

    write_info_log "Directory ready: ${BASELINE_DIR}"
}

run_baseline_audit() {
    write_info_log "Running lynis audit system (quick mode)..."

    # Temporarily disable exit-on-error as lynis may return non-zero if warnings exist
    set +e
    lynis audit system --quick --no-colors > "${LOG_FILE}" 2>&1
    set -e

    if [[ ! -s "${LOG_FILE}" ]]; then
        write_error_log "lynis produced no output"
        exit 1
    fi

    write_info_log "Raw log persisted: ${LOG_FILE}"
}

write_baseline_record() {
    write_info_log "Parsing audit results and writing baseline_linux.json..."

    local hostname=$(hostname)
    local lynis_version=$(lynis show version 2>/dev/null || echo "unknown")

    local hardening_index=$(grep "Hardening index" "${LOG_FILE}" | grep -o '[0-9]\+' | head -n 1 || true)
    local warnings_count=$(grep "Warnings (found)" "${LOG_FILE}" | grep -o '[0-9]\+' | head -n 1 || true)
    local suggestions_count=$(grep "Suggestions (found)" "${LOG_FILE}" | grep -o '[0-9]\+' | head -n 1 || true)

    # Apply defaults if grep fails to find a value
    hardening_index=${hardening_index:-0}
    warnings_count=${warnings_count:-0}
    suggestions_count=${suggestions_count:-0}

    if ! cat <<EOF > "${JSON_FILE}"
{
  "timestamp": "${TIMESTAMP}",
  "hostname": "${hostname}",
  "lynis_version": "${lynis_version}",
  "hardening_index": ${hardening_index},
  "warnings_count": ${warnings_count},
  "suggestions_count": ${suggestions_count},
  "log_path": "${LOG_FILE}"
}
EOF
    then
        write_error_log "Failed to write JSON file: ${JSON_FILE}"
        exit 1
    fi

    local hash=$(sha256sum "${JSON_FILE}" | awk '{print $1}')
    write_info_log "Baseline record written: ${JSON_FILE}"
    write_info_log "Metrics: Hardening Index ${hardening_index}, Warnings ${warnings_count}, Suggestions ${suggestions_count}"
    write_info_log "Record hash: ${hash}"
}

main() {
    write_info_log "Starting capstone baseline snapshot for Hawthorne Linux endpoint..."
    write_info_log "Timestamp: ${TIMESTAMP}"

    validate_environment
    ensure_directories
    run_baseline_audit
    write_baseline_record

    write_info_log "Capstone baseline snapshot completed successfully"
    exit 0
}

main
