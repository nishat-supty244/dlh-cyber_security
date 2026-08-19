#!/bin/bash
# ==============================================================================
# Script Name: 13-patch_pipeline.sh
# Goal: Orchestrate the full end-to-end patch workflow into an idempotent pipeline.
# ==============================================================================

set -uo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly OUTPUT_FILE="${BASE_DIR}/pipeline_run.json"

# Define the ordered stages
readonly STAGES=(
    "0-vuln_inventory.sh"
    "1-service_deps.sh"
    "2-pre_patch_snapshot.sh"
    "3-patch_plan.sh"
    "11-maintenance_window.sh --check"
    "4-patch_execute.sh"
    "5-post_patch_validate.sh"
    "6-config_drift.sh"
    "12-change_log.sh"
)

log() {
    echo "[*] $*"
}

warn() {
    echo "[!] $*" >&2
}

# Helper to format duration nicely
format_duration() {
    local start_ns="$1"
    local end_ns="$2"
    local diff_ms=$(( (end_ns - start_ns) / 1000000 ))
    local seconds=$(( diff_ms / 1000 ))
    local decimals=$(( (diff_ms % 1000) / 100 ))
    echo "${seconds}.${decimals}s"
}

main() {
    local started_at
    started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local pipeline_start_ns
    pipeline_start_ns=$(date +%s%N)

    local hostname_val
    hostname_val=$(hostname 2>/dev/null || echo "unknown")

    local pipeline_status="ok"
    local stages_json="[]"
    local artifacts_json="{}"

    local total_stages=${#STAGES[@]}
    local failed=0

    for i in "${!STAGES[@]}"; do
        local step_num=$((i + 1))
        local stage_cmd="${STAGES[$i]}"
        local script_name="${stage_cmd%% *}"
        local script_path="${BASE_DIR}/${script_name}"
        local stage_args="${stage_cmd#* }"
        [[ "$stage_args" == "$script_name" ]] && stage_args=""

        local stage_status="OK"
        local stage_code=0
        local stage_msg=""
        local stage_start_ns
        stage_start_ns=$(date +%s%N)

        # Check special handling for maintenance window check
        if [[ "$script_name" == "11-maintenance_window.sh" ]]; then
            if [[ -f "$script_path" ]]; then
                set +e
                if [[ -n "$stage_args" ]]; then
                    bash "$script_path" $stage_args
                else
                    bash "$script_path"
                fi
                stage_code=$?
                set -e

                if [[ "$stage_code" -eq 20 ]]; then
                    if [[ "${MEDDEFENSE_EMERGENCY:-0}" == "1" || -n "${MEDDEFENSE_EMERGENCY:-}" ]]; then
                        stage_msg="emergency override active"
                        stage_status="OK"
                    else
                        stage_status="DEFERRED"
                        pipeline_status="deferred"
                    fi
                elif [[ "$stage_code" -ne 0 ]]; then
                    stage_status="FAIL"
                    pipeline_status="failed"
                    failed=1
                else
                    stage_msg="standard window active"
                fi
            else
                stage_status="OK"
                stage_msg="skipped (script missing)"
            fi
        else
            # Execute standard stage script if present
            if [[ -f "$script_path" ]]; then
                set +e
                bash "$script_path" >/dev/null 2>&1
                stage_code=$?
                set -e

                if [[ "$stage_code" -ne 0 ]]; then
                    stage_status="FAIL"
                    pipeline_status="failed"
                    failed=1
                else
                    stage_msg="completed"
                fi
            else
                stage_status="OK"
                stage_msg="skipped (script missing)"
            fi
        fi

        local stage_end_ns
        stage_end_ns=$(date +%s%N)
        local duration_str
        duration_str=$(format_duration "$stage_start_ns" "$stage_end_ns")

        # Print standard runner message format
        if [[ -n "$stage_msg" ]]; then
            printf "[%d/%d] %-28s %-6s (%s, %s)\n" "$step_num" "$total_stages" "$stage_cmd" "$stage_status" "$duration_str" "$stage_msg"
        else
            printf "[%d/%d] %-28s %-6s (%s)\n" "$step_num" "$total_stages" "$stage_cmd" "$stage_status" "$duration_str"
        fi

        # Track stage result in JSON array
        local stage_json_entry
        stage_json_entry=$(jq -n \
            --arg name "$stage_cmd" \
            --arg status "$stage_status" \
            --arg duration "$duration_str" \
            --arg message "$stage_msg" \
            --argjson code "$stage_code" \
            '{name: $name, status: $status, duration: $duration, message: $message, exit_code: $code}')
        stages_json=$(jq --argjson entry "$stage_json_entry" '. + [$entry]' <<< "$stages_json")

        # Associate artifacts if they exist
        case "$script_name" in
            "0-vuln_inventory.sh")
                [[ -f "${BASE_DIR}/vulnerability_inventory.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/vulnerability_inventory.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "1-service_deps.sh")
                [[ -f "${BASE_DIR}/service_dependencies.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/service_dependencies.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "2-pre_patch_snapshot.sh")
                [[ -f "${BASE_DIR}/pre_patch_snapshot.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/pre_patch_snapshot.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "3-patch_plan.sh")
                [[ -f "${BASE_DIR}/patch_plan.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/patch_plan.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "11-maintenance_window.sh")
                [[ -f "${BASE_DIR}/maintenance_window.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/maintenance_window.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "4-patch_execute.sh")
                [[ -f "${BASE_DIR}/patch_execution_log.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/patch_execution_log.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "5-post_patch_validate.sh")
                [[ -f "${BASE_DIR}/post_patch_validation.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/post_patch_validation.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "6-config_drift.sh")
                [[ -f "${BASE_DIR}/config_drift.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/config_drift.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
            "12-change_log.sh")
                [[ -f "${BASE_DIR}/patch_change_log.json" ]] && artifacts_json=$(jq --arg k "$script_name" --arg v "${BASE_DIR}/patch_change_log.json" '. + {($k): $v}' <<< "$artifacts_json")
                ;;
        esac

        # Break loop if stage failed or if deferred due to maintenance window
        if [[ "$stage_status" == "FAIL" ]]; then
            break
        fi

        if [[ "$stage_status" == "DEFERRED" ]]; then
            log "Maintenance window check returned out-of-window. Skipping stages 4 through 6."
            # Fill remaining skipped stages for accurate reporting
            for ((j=i+1; j<total_stages; j++)); do
                local skip_cmd="${STAGES[$j]}"
                local skip_name="${skip_cmd%% *}"
                local skip_num=$((j + 1))
                printf "[%d/%d] %-28s %-6s (%s)\n" "$skip_num" "$total_stages" "$skip_cmd" "SKIP" "deferred by maintenance window"
                
                local skip_entry
                skip_entry=$(jq -n --arg name "$skip_cmd" --arg status "SKIP" --arg duration "0.0s" --arg message "deferred" --argjson code 0 '{name: $name, status: $status, duration: $duration, message: $message, exit_code: $code}')
                stages_json=$(jq --argjson entry "$skip_entry" '. + [$entry]' <<< "$stages_json")
            done
            break
        fi
    done

    local finished_at
    finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local pipeline_end_ns
    pipeline_end_ns=$(date +%s%N)
    local total_duration_str
    total_duration_str=$(format_duration "$pipeline_start_ns" "$pipeline_end_ns")

    # Construct final pipeline_run.json artifact securely without overwriting unchanged content needlessly (idempotency support)
    local new_content
    new_content=$(jq -n \
        --arg started "$started_at" \
        --arg finished "$finished_at" \
        --arg host "$hostname_val" \
        --arg status "$pipeline_status" \
        --argjson stages "$stages_json" \
        --argjson artifacts "$artifacts_json" \
        '{
            started_at: $started,
            finished_at: $finished,
            hostname: $host,
            pipeline_status: $status,
            stages: $stages,
            artifacts: $artifacts
        }')

    if [[ -f "$OUTPUT_FILE" ]]; then
        local old_content_clean new_content_clean
        old_content_clean=$(jq -S '.' "$OUTPUT_FILE" 2>/dev/null || echo "")
        new_content_clean=$(jq -S '.' <<< "$new_content")
        if [[ "$old_content_clean" != "$new_content_clean" ]]; then
            echo "$new_content" | jq '.' > "$OUTPUT_FILE"
        fi
    else
        echo "$new_content" | jq '.' > "$OUTPUT_FILE"
    fi

    echo "PIPELINE: ${pipeline_status}"
    echo "Duration: ${total_duration_str}"
    echo "Report saved to: pipeline_run.json"

    if [[ "$failed" -eq 1 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
