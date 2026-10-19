
#!/usr/bin/env bash

# MedDefense - Task 2: Verify All Artifacts
# Case: LH-2026-0414-01
# Incident: IR-2026-0414-01
# Investigator: Steve, Cybersecurity Engineer
#
# First run: Establish SHA-256 baselines.
# Later runs: Verify all artifacts against baselines.
# Every attempt is logged with a UTC timestamp.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

BASELINE_FILE="$SCRIPT_DIR/hashes.txt"
LOG_FILE="$SCRIPT_DIR/verification_log.txt"
ACTOR="${FORENSIC_ACTOR:-Steve}"

ARTIFACT_IDS=("ART-001" "ART-002" "ART-003")
ARTIFACT_NAMES=(
    "wst-ws-031.dd"
    "wst-ws-031.mem"
    "wst-ws-017.mem"
)

# Evidence files can be stored in a separate directory.
EVIDENCE_DIR="${EVIDENCE_DIR:-$SCRIPT_DIR}"

timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log_event() {
    local id="$1"
    local result="$2"
    local expected="$3"
    local computed="$4"

    printf '%s | actor=%s | artifact=%s | result=%s | expected=%s | computed=%s\n' \
        "$(timestamp)" "$ACTOR" "$id" "$result" \
        "$expected" "$computed" >> "$LOG_FILE"
}

calculate_hash() {
    local file="$1"
    local output

    output=$(sha256sum -- "$file") || return 1
    printf '%s\n' "${output:0:64}"
}

# Check required tool.
if ! command -v sha256sum >/dev/null 2>&1; then
    echo "[ERROR] sha256sum is not installed."
    exit 1
fi

# Prevent concurrent runs from changing baseline/log state.
if command -v flock >/dev/null 2>&1; then
    exec 9>"$SCRIPT_DIR/.verification.lock"
    flock -x 9 || exit 1
fi

# --------------------------------------------------
# FIRST RUN: Establish baseline
# --------------------------------------------------

if [[ ! -e "$BASELINE_FILE" ]]; then
    echo "No existing baseline found."
    echo "Establishing first-access SHA-256 baseline..."
    echo

    # Do not create a partial baseline.
    hashes=()
    failed=0

    for i in "${!ARTIFACT_NAMES[@]}"; do
        id="${ARTIFACT_IDS[$i]}"
        name="${ARTIFACT_NAMES[$i]}"
        path="$EVIDENCE_DIR/$name"

        if [[ ! -f "$path" || ! -r "$path" ]]; then
            echo "[ERROR] $id $name missing or unreadable"
            log_event "$id" "ERROR" "NONE" "UNAVAILABLE"
            failed=1
            continue
        fi

        if computed=$(calculate_hash "$path"); then
            hashes[$i]="$computed"
            echo "[BASELINE_SET] $id $name sha256=$computed"
        else
            echo "[ERROR] $id $name hashing failed"
            log_event "$id" "ERROR" "NONE" "HASH_ERROR"
            failed=1
        fi
    done

    if (( failed != 0 )); then
        echo
        echo "BASELINE NOT ESTABLISHED"
        exit 1
    fi

    # Restrict baseline file permissions.
    umask 077

    temp_file=$(mktemp "$SCRIPT_DIR/.hashes.XXXXXX") || exit 1

    for i in "${!ARTIFACT_NAMES[@]}"; do
        printf '%s %s %s\n' \
            "${ARTIFACT_IDS[$i]}" \
            "${ARTIFACT_NAMES[$i]}" \
            "${hashes[$i]}" >> "$temp_file"
    done

    # Avoid overwriting an existing baseline.
    if ! ln "$temp_file" "$BASELINE_FILE"; then
        rm -f "$temp_file"
        echo "[ERROR] Could not safely create hashes.txt"
        exit 1
    fi

    rm -f "$temp_file"

    for i in "${!ARTIFACT_NAMES[@]}"; do
        log_event "${ARTIFACT_IDS[$i]}" \
            "BASELINE_SET" "NONE" "${hashes[$i]}"
    done

    echo
    echo "Baseline written to hashes.txt. Run again to verify."
    exit 0
fi

# --------------------------------------------------
# SUBSEQUENT RUNS: Verify against baseline
# --------------------------------------------------

echo "Verifying forensic artifacts..."
echo

overall_status=0

# Read the baseline into arrays without executing its contents.
baseline_ids=()
baseline_names=()
baseline_hashes=()

while read -r id name hash extra; do
    [[ -z "${id:-}" ]] && continue

    baseline_ids+=("$id")
    baseline_names+=("$name")
    baseline_hashes+=("$hash")

    if [[ -n "${extra:-}" ]]; then
        echo "[ERROR] Invalid baseline file format."
        exit 1
    fi
done < "$BASELINE_FILE"

# Require exactly the three expected artifacts.
if (( ${#baseline_ids[@]} != 3 )); then
    echo "[ERROR] Baseline must contain exactly three artifacts."
    exit 1
fi

for i in "${!ARTIFACT_NAMES[@]}"; do
    id="${ARTIFACT_IDS[$i]}"
    name="${ARTIFACT_NAMES[$i]}"
    path="$EVIDENCE_DIR/$name"

    expected="${baseline_hashes[$i]}"

    # Validate baseline identity and hash format.
    if [[ "${baseline_ids[$i]}" != "$id" ||
          "${baseline_names[$i]}" != "$name" ||
          ! "$expected" =~ ^[a-fA-F0-9]{64}$ ]]; then
        echo "[FAIL] $id $name invalid baseline entry"
        log_event "$id" "FAIL" "$expected" "INVALID_BASELINE"
        overall_status=1
        continue
    fi

    if [[ ! -f "$path" || ! -r "$path" ]]; then
        echo "[FAIL] $id $name"
        echo "       expected=$expected"
        echo "       computed=UNAVAILABLE"

        log_event "$id" "FAIL" "$expected" "UNAVAILABLE"
        overall_status=1
        continue
    fi

    if ! computed=$(calculate_hash "$path"); then
        echo "[FAIL] $id $name"
        echo "       expected=$expected"
        echo "       computed=HASH_ERROR"

        log_event "$id" "FAIL" "$expected" "HASH_ERROR"
        overall_status=1
        continue
    fi

    if [[ "$computed" == "$expected" ]]; then
        echo "[PASS] $id $name expected=$expected computed=$computed"
        log_event "$id" "PASS" "$expected" "$computed"
    else
        echo "[FAIL] $id $name expected=$expected computed=$computed"
        log_event "$id" "FAIL" "$expected" "$computed"
        overall_status=1
    fi
done

echo

if (( overall_status == 0 )); then
    echo "ALL ARTIFACTS VERIFIED"
    exit 0
else
    echo "VERIFICATION FAILED - DO NOT BEGIN ANALYSIS"
    echo "DEVIATION: Investigate mismatches and document them in chain_of_custody.md."
    exit 1
fi
