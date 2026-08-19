#!/bin/bash
# ==============================================================================
# Script Name: 14-pipeline_test.sh
# Goal: Execute an end-to-end pipeline test against a simulated CVE advisory.
# ==============================================================================

set -uo pipefail

readonly BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly CVE_FEED="${BASE_DIR}/cve_feed.json"
readonly CVE_BAK="${BASE_DIR}/cve_feed.json.bak"
readonly SIMULATED_FEED="${BASE_DIR}/cve_feed.simulated.json"
readonly EXPECTED_PLAN="${BASE_DIR}/patch_plan.expected.json"
readonly PRODUCED_PLAN="${BASE_DIR}/patch_plan.json"
readonly PIPELINE_RUN="${BASE_DIR}/pipeline_run.json"
readonly TEST_RESULTS_FILE="${BASE_DIR}/pipeline_test_results.json"

log() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }

cleanup() {
    if [[ -f "$CVE_BAK" ]]; then
        mv "$CVE_BAK" "$CVE_FEED"
        log "Restoring cve_feed.json...                OK"
    fi
}

trap cleanup EXIT

main() {
    local started_at
    started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    log "Scenario: simulated CVE advisory"

    log "Backing up cve_feed.json...              OK"
    if [[ -f "$CVE_FEED" ]]; then
        cp "$CVE_FEED" "$CVE_BAK"
    else
        echo "{}" > "$CVE_BAK"
    fi

    log "Injecting cve_feed.simulated.json...     OK"
    if [[ -f "$SIMULATED_FEED" ]]; then
        cp "$SIMULATED_FEED" "$CVE_FEED"
    else
        warn "Simulated feed not found, using empty structure."
        echo "{}" > "$CVE_FEED"
    fi

    log "Running pipeline (PIPELINE_TEST=1)..."
    export PIPELINE_TEST=1
    
    local pipeline_exit=0
    if [[ -f "${BASE_DIR}/13-patch_pipeline.sh" ]]; then
        bash "${BASE_DIR}/13-patch_pipeline.sh" || pipeline_exit=$?
    else
        warn "13-patch_pipeline.sh not found!"
        pipeline_exit=1
    fi

    log "Comparing patch_plan.json to expected..."
    local plan_matches=false
    local diff_array="[]"

    if [[ -f "$PRODUCED_PLAN" && -f "$EXPECTED_PLAN" ]]; then
        local norm_produced norm_expected
        norm_produced=$(jq 'walk(if type == "string" then sub("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:\\.\\d+)?(?:Z|[+-]\\d{2}:\\d{2})?"; "TIMESTAMP") else . end)' "$PRODUCED_PLAN" 2>/dev/null || cat "$PRODUCED_PLAN")
        norm_expected=$(jq 'walk(if type == "string" then sub("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:\\.\\d+)?(?:Z|[+-]\\d{2}:\\d{2})?"; "TIMESTAMP") else . end)' "$EXPECTED_PLAN" 2>/dev/null || cat "$EXPECTED_PLAN")

        if [[ "$norm_produced" == "$norm_expected" ]]; then
            plan_matches=true
            echo " match"
        else
            echo " mismatch"
            local diff_output
            diff_output=$(diff -u <(echo "$norm_expected") <(echo "$norm_produced") || true)
            diff_array=$(jq -R -s 'split("\n") | map(select(length > 0))' <<< "$diff_output")
        fi
    else
        warn "Missing produced or expected plan files for comparison."
    fi

    # Validate that every stage emitted a non-empty JSON artifact if pipeline_run exists
    local artifacts_valid=true
    if [[ -f "$PIPELINE_RUN" ]]; then
        local art_paths
        art_paths=$(jq -r '.artifacts // {} | to_entries[].value' "$PIPELINE_RUN")
        for p in $art_paths; do
            if [[ ! -f "$p" ]] || [[ ! -s "$p" ]]; then
                artifacts_valid=false
                break
            fi
        done
    else
        artifacts_valid=false
    fi

    # Restore cve_feed right away
    if [[ -f "$CVE_BAK" ]]; then
        mv "$CVE_BAK" "$CVE_FEED"
        log "Restoring cve_feed.json...                OK"
    fi
    trap - EXIT

    local verdict="pass"
    if [[ "$pipeline_exit" -ne 0 ]] || [[ "$plan_matches" != "true" ]] || [[ "$artifacts_valid" != "true" ]]; then
        verdict="fail"
    fi

    local finished_at
    finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Construct complete pipeline_test_results.json matching all expected schema fields
    jq -n \
        --arg scenario "simulated CVE advisory" \
        --arg started "$started_at" \
        --arg finished "$finished_at" \
        --argjson stages_ok $( [[ "$pipeline_exit" -eq 0 ]] && echo "true" || echo "false" ) \
        --argjson match "$plan_matches" \
        --argjson diff "$diff_array" \
        --arg verdict "$verdict" \
        '{
            scenario: $scenario,
            started_at: $started,
            finished_at: $finished,
            stages_ok: $stages_ok,
            plan_matches_expected: $match,
            diff: $diff,
            verdict: $verdict
        }' > "$TEST_RESULTS_FILE"

    echo "VERDICT: ${verdict}"
    echo "Report saved to: pipeline_test_results.json"

    if [[ "$verdict" == "pass" ]]; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
