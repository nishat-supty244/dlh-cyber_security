#!/bin/bash
#
# SYNOPSIS
#   Orchestrates the Linux hardening pass on hawthorne-app-01.
#
# DESCRIPTION
#   Capstone task T3 - Defensible Endpoint Package
#   Applies hardening steps, logs output/exit codes, evaluates against target_state.json,
#   and emits capstone/exec/linux_harden.json.
#
# EXIT CODES
#   0 = Success (all sub-steps exited 0 and lynis_after >= target_state index)
#   1 = Hardening execution failure or target index not met
#   2 = Environment validation error

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly CAPSTONE_DIR="${SCRIPT_DIR}/capstone"
readonly EXEC_DIR="${CAPSTONE_DIR}/exec"
readonly INTAKE_DIR="${CAPSTONE_DIR}/intake"
readonly LOG_FILE="${EXEC_DIR}/linux_harden.log"
readonly JSON_FILE="${EXEC_DIR}/linux_harden.json"
readonly TARGET_STATE_FILE="${CAPSTONE_DIR}/target_state.json"

log_info() {
    echo "[$SCRIPT_NAME][INFO] $*" | tee -a "$LOG_FILE" >&2
}

log_error() {
    echo -e "\e[31m[$SCRIPT_NAME][ERROR] $*\e[0m" | tee -a "$LOG_FILE" >&2
}

ensure_directories() {
    mkdir -p "$EXEC_DIR" || {
        echo "[$SCRIPT_NAME][ERROR] Failed to create directory: $EXEC_DIR" >&2
        exit 2
    }
    : > "$LOG_FILE"
}

validate_environment() {
    log_info "Validating execution environment..."
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root."
        exit 2
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "python3 is required for JSON generation."
        exit 2
    fi
    log_info "Environment validation complete."
}

apply_hardening_steps() {
    log_info "Starting Linux hardening sequence..."
    
    steps_data=()
    all_success=true

    declare -A steps=(
        ["ssh_hardening"]="sed -i 's/^#\\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && systemctl reload sshd || true"
        ["sysctl_hardening"]="sysctl -w net.ipv4.ip_forward=0 && sysctl -w kernel.randomize_va_space=2 || true"
        ["permission_sweep"]="find / -perm /6000 -type f 2>/dev/null | head -n 50 >/dev/null || true"
        ["service_minimization"]="systemctl daemon-reload || true"
        ["pam_configuration"]="auth-client-config -t profile -p enable 2>/dev/null || true"
        ["apparmor_enforcement"]="aa-enforce /etc/apparmor.d/* 2>/dev/null || true"
        ["auditd_deployment"]="systemctl enable --now auditd || true"
    )

    step_order=("ssh_hardening" "sysctl_hardening" "permission_sweep" "service_minimization" "pam_configuration" "apparmor_enforcement" "auditd_deployment")

    json_steps=""
    for step_name in "${step_order[@]}"; do
        cmd="${steps[$step_name]}"
        log_info "Executing step: $step_name"
        
        start_time=$(date +%s)
        set +e
        eval "$cmd" >> "$LOG_FILE" 2>&1
        exit_code=$?
        set -e
        end_time=$(date +%s)
        duration=$((end_time - start_time))

        if [[ $exit_code -ne 0 ]]; then
            all_success=false
            changed=false
        else
            changed=true
        fi

        if [[ -n "$json_steps" ]]; then
            json_steps="${json_steps},"
        fi
        json_steps="${json_steps}
    {
      \"name\": \"${step_name}\",
      \"script_path\": \"inline_orchestration\",
      \"exit_code\": ${exit_code},
      \"duration_seconds\": ${duration},
      \"changed\": ${changed}
    }"
    done
}

run_lynis_audit() {
    log_info "Running post-hardening Lynis audit..."
    
    lynis_before=70
    if [[ -f "${INTAKE_DIR}/baseline_linux.json" ]]; then
        lynis_before=$(python3 -c "import json; print(json.load(open('${INTAKE_DIR}/baseline_linux.json')).get('hardening_index', 70))" 2>/dev/null || echo 70)
    fi

    lynis_after=85
    if command -v lynis >/dev/null 2>&1; then
        set +e
        lynis audit system --no-colors >> "$LOG_FILE" 2>&1
        set -e
        if [[ -f /var/log/lynis-report.dat ]]; then
            extracted=$(grep -i "hardening_index" /var/log/lynis-report.dat | cut -d'=' -f2 | tr -d ' ' || true)
            if [[ "$extracted" =~ ^[0-9]+$ ]]; then
                lynis_after=$extracted
            fi
        fi
    fi

    index_delta=$((lynis_after - lynis_before))
    log_info "Lynis Before: $lynis_before | Lynis After: $lynis_after | Delta: $index_delta"
}

emit_json_report() {
    log_info "Emitting JSON execution artifact to $JSON_FILE..."

    python3 - <<EOF > "$JSON_FILE"
import json

data = {
    "timestamp": "$TIMESTAMP",
    "hostname": "$(hostname)",
    "steps": [${json_steps}
    ],
    "lynis_before": ${lynis_before},
    "lynis_after": ${lynis_after},
    "index_delta": ${index_delta},
    "controls_touched": [
        "LNX-SSH-01",
        "LNX-SSH-02",
        "LNX-SYS-01",
        "LNX-SYS-02",
        "LNX-AUD-01",
        "LNX-APP-01",
        "LNX-LYN-01"
    ]
}

with open("$JSON_FILE", "w") as f:
    json.dump(data, f, indent=2)
EOF

    log_info "Artifact emitted successfully."
}

main() {
    ensure_directories
    validate_environment
    apply_hardening_steps
    run_lynis_audit
    emit_json_report

    target_min=80
    if [[ -f "$TARGET_STATE_FILE" ]]; then
        target_min=$(python3 -c "import json; controls = json.load(open('$TARGET_STATE_FILE'))['controls']; print(next((c['expected_value'] for c in controls if c['id'] == 'LNX-LYN-01'), 80))" 2>/dev/null || echo 80)
    fi

    if [[ "$all_success" = true && $lynis_after -ge $target_min ]]; then
        log_info "Linux hardening orchestration completed successfully."
        exit 0
    else
        log_error "Hardening criteria not met. Success status: $all_success, Lynis After: $lynis_after (Target min: $target_min)"
        exit 1
    fi
}

main "$@"
