
#!/bin/bash

# ================================================================
# HEALTHBANE vs MedDefense
# Task 8: Unified Attack Timeline
# ================================================================
# Combines:
#   T5 - Stages 1-2 reconstruction
#   T6 - Stage 3 reconstruction
#   T7 - Stage 4 reconstruction
#
# Produces:
#   * Chronological event list
#   * Temporal metrics where timestamps are available
#   * Timeline gaps and sequencing uncertainties
#   * Evidence-source and confidence summaries
#
# This script extracts candidate events. Verify timestamps,
# timezones, duplicate events and source independence before
# treating the output as the definitive timeline.
# ================================================================

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OUTPUT_DIR="$BASE_DIR/task8_output"
OUTPUT_FILE="$OUTPUT_DIR/unified_timeline.txt"
EVENT_FILE="$OUTPUT_DIR/timeline_events.tsv"

# Accept common alternative names for earlier task outputs.
find_report() {
    local result=""
    local candidate

    for candidate in "$@"; do
        if [[ -f "$candidate" ]]; then
            result="$candidate"
            break
        fi
    done

    printf '%s' "$result"
}

STAGE12="$(find_report \
    "$BASE_DIR/task5_output/stages_1_2_reconstruction.txt" \
    "$BASE_DIR/task5_output/stage_1_2_reconstruction.txt" \
    "$BASE_DIR/5-stages_1_2_reconstruction.txt")"

STAGE3="$(find_report \
    "$BASE_DIR/task6_output/stage_3_reconstruction.txt" \
    "$BASE_DIR/task6_output/stages_3_reconstruction.txt" \
    "$BASE_DIR/task6_output/stage_3.txt")"

STAGE4="$(find_report \
    "$BASE_DIR/task7_output/stage_4_reconstruction.txt" \
    "$BASE_DIR/task7_output/stage_4.txt")"

HUNT="$BASE_DIR/previous_findings/4x04_hunting_report.txt"
IR_NOTES="$BASE_DIR/ir_evidence/ir_team_notes.txt"

mkdir -p "$OUTPUT_DIR"
: > "$EVENT_FILE"
: > "$OUTPUT_FILE"

section() {
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

check_source() {
    local name="$1"
    local file="$2"

    if [[ -n "$file" && -f "$file" ]]; then
        printf '[AVAILABLE] %s: %s\n' "$name" "$file"
    else
        printf '[MISSING] %s: %s\n' "$name" "${file:-not found}"
    fi
}

# ------------------------------------------------
# 1. Locate source reports
# ------------------------------------------------

{
    section "UNIFIED ATTACK TIMELINE - HEALTHBANE vs MedDefense"
    echo "Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo
    echo "SOURCE REPORTS"
    check_source "T5 Stage 1-2" "$STAGE12"
    check_source "T6 Stage 3" "$STAGE3"
    check_source "T7 Stage 4" "$STAGE4"
    check_source "4x04 Hunt" "$HUNT"
    check_source "IR Notes" "$IR_NOTES"

    echo
    echo "NOTE: Missing reports reduce timeline completeness."
    echo "No example timestamp is treated as an actual finding."
} | tee -a "$OUTPUT_FILE"

# ------------------------------------------------
# 2. Extract timestamped candidate events
# ------------------------------------------------
#
# Normalized TSV format:
# timestamp | event description | host/account | ATT&CK |
# source | confidence
#
# Supports ISO-like timestamps and common YYYY-MM-DD HH:MM:SS
# formats. It does not infer missing years or timezone offsets.
# ------------------------------------------------

extract_events() {
    local file="$1"
    local label="$2"

    [[ -n "$file" && -f "$file" ]] || return 0

    awk -v label="$label" '
    {
        line = $0

        # Extract a date with optional time and timezone.
        if (match(line, /20[0-9][0-9][-\/][01]?[0-9][-\/][0-3]?[0-9][ T]+[0-2]?[0-9]:[0-5][0-9](:[0-5][0-9])?([.][0-9]+)?[[:space:]]*(UTC|GMT|Z|CET|CEST|[+-][0-9][0-9]:?[0-9][0-9])?/)) {
            timestamp = substr(line, RSTART, RLENGTH)
        } else if (match(line, /20[0-9][0-9]-[01][0-9]-[0-3][0-9]/)) {
            timestamp = substr(line, RSTART, RLENGTH)
        } else {
            next
        }

        # Avoid reporting every dated line from a source.
        # Keep lines that look like attack events or analysis findings.
        if (line !~ /phish|click|credential|C2|beacon|malware|payload|PsExec|WMI|PSRemoting|lateral|LSASS|staging|archive|\.zip|contain|isolat|detect|scheduled task|persistence|exfil|logon|pivot/i) {
            next
        }

        technique = "---"
        if (line ~ /T1566[.]001/) technique = "T1566.001"
        else if (line ~ /T1078/) technique = "T1078"
        else if (line ~ /T1071[.]001/) technique = "T1071.001"
        else if (line ~ /T1573[.]001/) technique = "T1573.001"
        else if (line ~ /T1568/) technique = "T1568"
        else if (line ~ /T1003[.]001/) technique = "T1003.001"
        else if (line ~ /T1021[.]002/) technique = "T1021.002"
        else if (line ~ /T1047/) technique = "T1047"
        else if (line ~ /T1021[.]006/) technique = "T1021.006"
        else if (line ~ /T1053[.]005/) technique = "T1053.005"
        else if (line ~ /T1074[.]001/) technique = "T1074.001"
        else if (line ~ /T1560[.]001/) technique = "T1560.001"
        else if (line ~ /T1005/) technique = "T1005"

        confidence = "REVIEW"
        if (line ~ /CONFIRMED|CONVERGED/) confidence = "REVIEW-CONVERGED"
        else if (line ~ /PROBABLE/) confidence = "REVIEW-PROBABLE"
        else if (line ~ /POSSIBLE/) confidence = "REVIEW-POSSIBLE"

        # Sanitize tabs/newlines in fields.
        gsub(/\t/, " ", line)
        gsub(/\r/, "", line)

        print timestamp "\t" line "\t" "See source record" "\t" technique "\t" label "\t" confidence
    }
    ' "$file" >> "$EVENT_FILE"
}

extract_events "$STAGE12" "T5"
extract_events "$STAGE3" "T6"
extract_events "$STAGE4" "T7"

# ------------------------------------------------
# 3. Display candidate timeline
# ------------------------------------------------

{
    section "CHRONOLOGICAL SEQUENCE"

    if [[ -s "$EVENT_FILE" ]]; then
        printf '%-28s | %-13s | %-19s | %-20s | %s\n' \
            "TIMESTAMP AS REPORTED" "ATT&CK" "SOURCE" "CONFIDENCE" "EVENT"
        printf '%s\n' \
            "----------------------------+---------------+---------------------+----------------------+------------------------------"

        sort -t "$(printf '\t')" -k1,1 "$EVENT_FILE" |
        awk -F '\t' '
        {
            event = $2
            if (length(event) > 110) event = substr(event, 1, 107) "..."

            printf "%-28s | %-13s | %-19s | %-20s | %s\n",
                   $1, $4, $5, $6, event
        }'
    else
        echo "No timestamped candidate events were extracted."
        echo "Check the earlier stage reports and their timestamp formats."
    fi

    echo
    echo "IMPORTANT:"
    echo "This is a candidate sequence, not yet a deduplicated final timeline."
    echo "Review repeated events appearing in multiple stage reports."
    echo "Verify timezone offsets and source independence."
} | tee -a "$OUTPUT_FILE"

# ------------------------------------------------
# 4. Temporal metrics
# ------------------------------------------------
#
# Metrics are calculated only from explicit, parseable timestamps.
# Use UTC timestamps for reliable calculations.
# ------------------------------------------------

{
    section "TEMPORAL METRICS"

    echo "The stage reports may contain local time, UTC, or dates without"
    echo "a timezone. Do not calculate exact durations until timestamps"
    echo "are normalized to a common timezone."

    echo
    echo "Candidate event dates:"
    if [[ -s "$EVENT_FILE" ]]; then
        cut -f1 "$EVENT_FILE" | sort -u
    else
        echo "No candidate dates available."
    fi

    echo
    echo "Metrics requiring verified UTC timestamps:"
    echo "  Total dwell time: first confirmed access to containment."
    echo "  Breakout time: initial access to first confirmed lateral movement."
    echo "  Time to persistence: initial access to confirmed persistence."
    echo "  Time to data staging: initial access to first confirmed staging event."
    echo "  Detection-to-containment: hunt detection to actual IR isolation."
    echo "  Operational tempo: intervals between verified attack phases."

    echo
    echo "Exact duration calculations are withheld unless the source events"
    echo "can be reliably identified and normalized."
} | tee -a "$OUTPUT_FILE"

# ------------------------------------------------
# 5. Timeline gaps and uncertainties
# ------------------------------------------------

{
    section "TIMELINE GAPS"

    echo "A gap means the evidence does not establish what happened"
    echo "during a period. It does not prove the attacker was inactive."
    echo
    echo "Review:"
    echo "  * Periods between confirmed events with no relevant telemetry."
    echo "  * Time periods outside PCAP collection coverage."
    echo "  * Events recorded by only one source."
    echo "  * Missing host, account, or timezone details."
    echo "  * Firewall sessions that cannot be attributed to an attack."
    echo
    echo "Source coverage notes:"
    grep -Ein 'gap|missing|coverage|48 hours|14 days|clock skew|timezone|unknown|limitation' \
        "$STAGE12" "$STAGE3" "$STAGE4" "$HUNT" "$IR_NOTES" \
        2>/dev/null || true

    section "SEQUENCING UNCERTAINTIES"

    echo "Review candidate events where:"
    echo "  * Two sources report different timestamps for the same event."
    echo "  * Timezones or host clock offsets are unknown."
    echo "  * A stage report contains an event without a direct source citation."
    echo "  * Event ordering depends on an assumed, rather than measured, delay."
    echo
    echo "No clock-skew adjustment is applied automatically."
    echo "Document the original timestamp, corrected timestamp, offset,"
    echo "reason for adjustment, and supporting evidence."
} | tee -a "$OUTPUT_FILE"

# ------------------------------------------------
# 6. Summary counts
# ------------------------------------------------

{
    section "TIMELINE SUMMARY"

    if [[ -s "$EVENT_FILE" ]]; then
        TOTAL="$(wc -l < "$EVENT_FILE" | tr -d ' ')"
        echo "Candidate timestamped records: $TOTAL"
        echo "These are records, not necessarily unique attack events."
        echo "Deduplicate only after matching event time, host, action,"
        echo "and supporting evidence across stage reports."
    else
        echo "Candidate timestamped records: 0"
    fi

    echo
    echo "Output files:"
    echo "  Timeline report: $OUTPUT_FILE"
    echo "  Candidate events: $EVENT_FILE"

    echo
    echo "Next step:"
    echo "Verify and normalize timestamps, merge duplicate events,"
    echo "calculate metrics, and document gaps before final reporting."
    echo "================================================================"
} | tee -a "$OUTPUT_FILE"
