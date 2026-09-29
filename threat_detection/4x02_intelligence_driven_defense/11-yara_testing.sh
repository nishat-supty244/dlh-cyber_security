#!/bin/bash

# ============================================================
# 11-YARA TESTING
#
# Purpose:
#   Test all YARA rules from Tasks 9 and 10 against all samples.
#
# Calculates:
#   TP = True Positive
#   TN = True Negative
#   FP = False Positive
#   FN = False Negative
#
# Metrics:
#   Detection Rate = TP / (TP + FN)
#   False Positive Rate = FP / (FP + TN)
#   Precision = TP / (TP + FP)
#
# Output:
#   11-yara_testing.md
#
# Usage:
#   ./11-yara_testing.sh
#
# Optional:
#   ./11-yara_testing.sh \
#       --samples ./samples \
#       --manifest ./samples_manifest.txt \
#       --rules ./9-yara_phishing_pdf.yar ./10-yara_arsenal.yar
# ============================================================

set -uo pipefail

# ------------------------------------------------------------
# Default paths
# ------------------------------------------------------------

SAMPLES_DIR="./samples"
MANIFEST="./samples_manifest.txt"
OUTPUT="11-yara_testing.md"

RULE_FILES=(
    "./9-yara_phishing_pdf.yar"
    "./10-yara_arsenal.yar"
)

# ------------------------------------------------------------
# Parse command-line arguments
# ------------------------------------------------------------

while [[ $# -gt 0 ]]; do

    case "$1" in

        --samples)
            SAMPLES_DIR="$2"
            shift 2
            ;;

        --manifest)
            MANIFEST="$2"
            shift 2
            ;;

        --output)
            OUTPUT="$2"
            shift 2
            ;;

        --rules)
            RULE_FILES=()
            shift

            while [[ $# -gt 0 && "$1" != --* ]]; do
                RULE_FILES+=("$1")
                shift
            done
            ;;

        -h|--help)
            echo "Usage:"
            echo "  ./11-yara_testing.sh"
            echo ""
            echo "Options:"
            echo "  --samples DIR       Samples directory"
            echo "  --manifest FILE     Sample manifest"
            echo "  --rules FILE...     YARA rule files"
            echo "  --output FILE       Markdown output file"
            exit 0
            ;;

        *)
            echo "[ERROR] Unknown argument: $1"
            exit 1
            ;;

    esac

done

# ------------------------------------------------------------
# Check dependencies
# ------------------------------------------------------------

if ! command -v yara >/dev/null 2>&1; then
    echo "[ERROR] YARA is not installed."
    echo "Install it with:"
    echo "  sudo apt install yara"
    exit 1
fi

# ------------------------------------------------------------
# Check required files
# ------------------------------------------------------------

if [[ ! -d "$SAMPLES_DIR" ]]; then
    echo "[ERROR] Samples directory not found: $SAMPLES_DIR"
    exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
    echo "[WARNING] Manifest not found: $MANIFEST"
    echo "[WARNING] Filename-based classification will be used."
fi

for rule_file in "${RULE_FILES[@]}"; do

    if [[ ! -f "$rule_file" ]]; then
        echo "[ERROR] YARA rule file not found: $rule_file"
        exit 1
    fi

done

# ------------------------------------------------------------
# Temporary working directory
# ------------------------------------------------------------

TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# ------------------------------------------------------------
# Arrays
#
# sample_expected[path] = MALICIOUS or BENIGN
# ------------------------------------------------------------

declare -A sample_expected

# ------------------------------------------------------------
# Normalize a path
# ------------------------------------------------------------

normalize_path() {

    local value="$1"

    value="${value%$'\r'}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    echo "$value"
}

# ------------------------------------------------------------
# Classify sample using a text label
# ------------------------------------------------------------

classify_label() {

    local label
    label="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

    # Malicious / positive labels
    if echo "$label" | grep -Eq \
        'phishing|malicious|healthbane|positive|bad|infected|variant|attack|suspicious'; then
        echo "MALICIOUS"
        return
    fi

    # Benign / negative labels
    if echo "$label" | grep -Eq \
        'benign|invoice|newsletter|clean|negative|normal|legitimate|good'; then
        echo "BENIGN"
        return
    fi

    echo "UNKNOWN"
}

# ------------------------------------------------------------
# Load sample expectations from manifest
#
# Supports common formats such as:
#
#   sample.pdf | phishing
#   sample.pdf,phishing
#   sample.pdf    phishing
#   phishing/sample.pdf
#   benign/invoice.pdf
#
# If no usable label is found, filename is inspected later.
# ------------------------------------------------------------

if [[ -f "$MANIFEST" ]]; then

    while IFS= read -r line || [[ -n "$line" ]]; do

        # Remove CRLF
        line="${line%$'\r'}"

        # Ignore blank lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        # Try pipe-separated
        if [[ "$line" == *"|"* ]]; then

            filename="$(echo "$line" | cut -d'|' -f1)"
            label="$(echo "$line" | cut -d'|' -f2-)"

        # Try comma-separated
        elif [[ "$line" == *,* ]]; then

            filename="$(echo "$line" | cut -d',' -f1)"
            label="$(echo "$line" | cut -d',' -f2-)"

        else

            # Try whitespace-separated
            filename="$(echo "$line" | awk '{print $1}')"
            label="$(echo "$line" | cut -d' ' -f2-)"

        fi

        filename="$(normalize_path "$filename")"
        label="$(normalize_path "$label")"

        [[ -z "$filename" ]] && continue

        expected="$(classify_label "$label")"

        # If the label itself is not useful, inspect entire line
        if [[ "$expected" == "UNKNOWN" ]]; then
            expected="$(classify_label "$line")"
        fi

        # Store only useful classifications
        if [[ "$expected" != "UNKNOWN" ]]; then

            # Remove leading ./ from manifest entries
            filename="${filename#./}"

            sample_expected["$filename"]="$expected"

        fi

    done < "$MANIFEST"

fi

# ------------------------------------------------------------
# Discover all samples
# ------------------------------------------------------------

mapfile -d '' SAMPLE_FILES < <(
    find "$SAMPLES_DIR" -type f -print0 | sort -z
)

if [[ ${#SAMPLE_FILES[@]} -eq 0 ]]; then
    echo "[ERROR] No samples found in $SAMPLES_DIR"
    exit 1
fi

# ------------------------------------------------------------
# Determine expected class for each sample
# ------------------------------------------------------------

declare -a VALID_SAMPLES
declare -A EXPECTED_BY_PATH

for sample in "${SAMPLE_FILES[@]}"; do

    relative_path="${sample#"$SAMPLES_DIR"/}"
    filename="$(basename "$sample")"

    expected="UNKNOWN"

    # Try exact relative path from manifest
    if [[ -n "${sample_expected[$relative_path]+x}" ]]; then
        expected="${sample_expected[$relative_path]}"

    # Try basename from manifest
    elif [[ -n "${sample_expected[$filename]+x}" ]]; then
        expected="${sample_expected[$filename]}"

    else

        # ----------------------------------------------------
        # Filename/directory fallback
        # ----------------------------------------------------

        lower_path="$(echo "$sample" | tr '[:upper:]' '[:lower:]')"

        if echo "$lower_path" | grep -Eq \
            'phishing|healthbane|malicious|infected|variant|attack|suspicious'; then

            expected="MALICIOUS"

        elif echo "$lower_path" | grep -Eq \
            'benign|invoice|newsletter|clean|normal|legitimate'; then

            expected="BENIGN"

        fi

    fi

    if [[ "$expected" == "UNKNOWN" ]]; then

        echo "[WARNING] Could not determine expected result for:"
        echo "          $sample"
        echo "          Skipping this sample."
        continue

    fi

    VALID_SAMPLES+=("$sample")
    EXPECTED_BY_PATH["$sample"]="$expected"

done

if [[ ${#VALID_SAMPLES[@]} -eq 0 ]]; then
    echo "[ERROR] No samples could be classified."
    echo "Check samples_manifest.txt."
    exit 1
fi

# ------------------------------------------------------------
# Extract YARA rule names
# ------------------------------------------------------------

declare -a RULE_NAMES
declare -A RULE_TO_FILE

for rule_file in "${RULE_FILES[@]}"; do

    while IFS= read -r rule_name; do

        [[ -z "$rule_name" ]] && continue

        RULE_NAMES+=("$rule_name")
        RULE_TO_FILE["$rule_name"]="$rule_file"

    done < <(
        grep -E '^[[:space:]]*rule[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' "$rule_file" \
        | sed -E 's/^[[:space:]]*rule[[:space:]]+([A-Za-z_][A-Za-z0-9_]*).*/\1/'
    )

done

if [[ ${#RULE_NAMES[@]} -eq 0 ]]; then

    echo "[ERROR] No YARA rules were found."
    exit 1

fi

# ------------------------------------------------------------
# Validate YARA rule files before testing
# ------------------------------------------------------------

echo "=========================================="
echo "       YARA RULE VALIDATION"
echo "=========================================="

for rule_file in "${RULE_FILES[@]}"; do

    echo "[*] Checking: $rule_file"

    if yara -w "$rule_file" /dev/null >/dev/null 2>&1; then
        echo "[OK] Rule file compiles: $rule_file"
    else
        echo "[ERROR] Rule file failed to compile: $rule_file"
        yara -w "$rule_file" /dev/null
        exit 1
    fi

done

# ------------------------------------------------------------
# Start Markdown report
# ------------------------------------------------------------

{
    echo "# 11-YARA Testing: Rule Validation"
    echo
    echo "## 1. Test Overview"
    echo
    echo "This report tests all YARA rules from Tasks 9 and 10 against the provided sample corpus."
    echo
    echo "The test classifies results using:"
    echo
    echo "- **TP (True Positive):** malicious sample matched by the rule"
    echo "- **TN (True Negative):** benign sample not matched by the rule"
    echo "- **FP (False Positive):** benign sample matched by the rule"
    echo "- **FN (False Negative):** malicious sample not matched by the rule"
    echo
    echo "### Metrics"
    echo
    echo "- **Detection Rate:** TP / (TP + FN)"
    echo "- **False Positive Rate:** FP / (FP + TN)"
    echo "- **Precision:** TP / (TP + FP)"
    echo
    echo "## 2. Test Corpus"
    echo
    echo "- Samples directory: \`$SAMPLES_DIR\`"
    echo "- Manifest: \`$MANIFEST\`"
    echo "- Classified samples: ${#VALID_SAMPLES[@]}"
    echo "- YARA rules tested: ${#RULE_NAMES[@]}"
    echo
    echo "### Sample Classification"
    echo
    echo "| Sample | Expected Result |"
    echo "|---|---|"

} > "$OUTPUT"

for sample in "${VALID_SAMPLES[@]}"; do

    relative="${sample#"$SAMPLES_DIR"/}"
    expected="${EXPECTED_BY_PATH[$sample]}"

    echo "| \`$relative\` | $expected |" >> "$OUTPUT"

done

echo >> "$OUTPUT"
echo "## 3. YARA Testing Results" >> "$OUTPUT"
echo >> "$OUTPUT"

# ------------------------------------------------------------
# Global counters
# ------------------------------------------------------------

GLOBAL_TP=0
GLOBAL_TN=0
GLOBAL_FP=0
GLOBAL_FN=0

# ------------------------------------------------------------
# Test every rule against every sample
# ------------------------------------------------------------

for rule_name in "${RULE_NAMES[@]}"; do

    rule_file="${RULE_TO_FILE[$rule_name]}"

    TP=0
    TN=0
    FP=0
    FN=0

    echo
    echo "=========================================="
    echo "Rule: $rule_name"
    echo "File: $rule_file"
    echo "=========================================="

    {
        echo "### Rule: \`$rule_name\`"
        echo
        echo "**Rule file:** \`$rule_file\`"
        echo
        echo "| Sample | Expected | Match | Result |"
        echo "|---|---|---|---|"

    } >> "$OUTPUT"

    for sample in "${VALID_SAMPLES[@]}"; do

        expected="${EXPECTED_BY_PATH[$sample]}"
        relative="${sample#"$SAMPLES_DIR"/}"

        # ----------------------------------------------------
        # Test ONLY the current rule
        #
        # YARA -w -N rule-file sample
        #
        # We use a temporary rule wrapper containing the
        # current rule name and original file.
        # ----------------------------------------------------

        match_output="$(
            yara -w -N "$rule_file" "$sample" 2>/dev/null \
            | awk '{print $1}' \
            | grep -Fx "$rule_name" \
            || true
        )"

        if [[ -n "$match_output" ]]; then
            matched="YES"
        else
            matched="NO"
        fi

        result=""

        if [[ "$expected" == "MALICIOUS" && "$matched" == "YES" ]]; then

            result="TP"
            ((TP+=1))
            ((GLOBAL_TP+=1))

        elif [[ "$expected" == "BENIGN" && "$matched" == "NO" ]]; then

            result="TN"
            ((TN+=1))
            ((GLOBAL_TN+=1))

        elif [[ "$expected" == "BENIGN" && "$matched" == "YES" ]]; then

            result="FP"
            ((FP+=1))
            ((GLOBAL_FP+=1))

        elif [[ "$expected" == "MALICIOUS" && "$matched" == "NO" ]]; then

            result="FN"
            ((FN+=1))
            ((GLOBAL_FN+=1))

        fi

        printf "| \`%s\` | %s | %s | **%s** |\n" \
            "$relative" \
            "$expected" \
            "$matched" \
            "$result" >> "$OUTPUT"

        # ----------------------------------------------------
        # Store details for FP/FN analysis
        # ----------------------------------------------------

        if [[ "$result" == "FP" ]]; then

            {
                echo
                echo "**False Positive:** \`$relative\`"
                echo
                echo "- Expected: **BENIGN**"
                echo "- Actual: **MATCHED**"
                echo "- Likely cause: one or more rule conditions are also present in a legitimate sample."
                echo "- Suggested tuning: strengthen the rule with an additional independent condition, such as a specific string, metadata field, structural feature, or combination of indicators."
                echo "- Safety note: avoid removing the original detection condition unless testing shows it is responsible for excessive false positives."
                echo

            } >> "$OUTPUT"

        elif [[ "$result" == "FN" ]]; then

            {
                echo
                echo "**False Negative:** \`$relative\`"
                echo
                echo "- Expected: **MALICIOUS**"
                echo "- Actual: **NO MATCH**"
                echo "- Likely cause: the sample may use a variant or contain different formatting/strings not covered by the current rule."
                echo "- Suggested modification: inspect the missed sample for stable characteristics shared with other confirmed malicious samples and add a narrowly scoped condition."
                echo "- Validation step: retest the modified rule against both the malicious corpus and all benign samples."
                echo

            } >> "$OUTPUT"

        fi

    done

    # --------------------------------------------------------
    # Calculate metrics
    # --------------------------------------------------------

    if (( TP + FN > 0 )); then
        DETECTION_RATE=$(awk "BEGIN {printf \"%.2f\", ($TP / ($TP + $FN)) * 100}")
    else
        DETECTION_RATE="N/A"
    fi

    if (( FP + TN > 0 )); then
        FALSE_POSITIVE_RATE=$(awk "BEGIN {printf \"%.2f\", ($FP / ($FP + $TN)) * 100}")
    else
        FALSE_POSITIVE_RATE="N/A"
    fi

    if (( TP + FP > 0 )); then
        PRECISION=$(awk "BEGIN {printf \"%.2f\", ($TP / ($TP + $FP)) * 100}")
    else
        PRECISION="N/A"
    fi

    # --------------------------------------------------------
    # Deployment recommendation
    # --------------------------------------------------------

    if [[ "$DETECTION_RATE" != "N/A" && "$FALSE_POSITIVE_RATE" != "N/A" ]]; then

        detection_num="$DETECTION_RATE"
        fp_num="$FALSE_POSITIVE_RATE"

        if (( $(awk "BEGIN {print ($detection_num >= 90)}") )) \
            && (( $(awk "BEGIN {print ($fp_num <= 2)}") )); then

            RECOMMENDATION="DEPLOY"

        elif (( $(awk "BEGIN {print ($detection_num >= 70)}") )) \
            && (( $(awk "BEGIN {print ($fp_num <= 10)}") )); then

            RECOMMENDATION="MONITOR"

        else

            RECOMMENDATION="TUNE"

        fi

    else
        RECOMMENDATION="MONITOR"
    fi

    # --------------------------------------------------------
    # Console output
    # --------------------------------------------------------

    echo "TP: $TP | TN: $TN | FP: $FP | FN: $FN"
    echo "Detection rate: ${DETECTION_RATE}%"
    echo "False positive rate: ${FALSE_POSITIVE_RATE}%"
    echo "Precision: ${PRECISION}%"
    echo "Recommendation: $RECOMMENDATION"

    # --------------------------------------------------------
    # Markdown summary
    # --------------------------------------------------------

    {
        echo
        echo "#### Rule Summary"
        echo
        echo "| Metric | Value |"
        echo "|---|---:|"
        echo "| True Positives (TP) | $TP |"
        echo "| True Negatives (TN) | $TN |"
        echo "| False Positives (FP) | $FP |"
        echo "| False Negatives (FN) | $FN |"
        echo "| Detection Rate | ${DETECTION_RATE}% |"
        echo "| False Positive Rate | ${FALSE_POSITIVE_RATE}% |"
        echo "| Precision | ${PRECISION}% |"
        echo "| Recommendation | **$RECOMMENDATION** |"
        echo

        echo "#### Interpretation"
        echo

        if [[ "$FN" -gt 0 ]]; then
            echo "- The rule produced **$FN false negative(s)**. The rule should be reviewed for coverage gaps or sample variation."
        else
            echo "- No false negatives were observed in the tested malicious samples."
        fi

        if [[ "$FP" -gt 0 ]]; then
            echo "- The rule produced **$FP false positive(s)**. Additional tuning is recommended before production deployment."
        else
            echo "- No false positives were observed in the tested benign samples."
        fi

        if [[ "$RECOMMENDATION" == "DEPLOY" ]]; then
            echo "- **DEPLOY:** Current test results show strong detection with low false-positive impact."
        elif [[ "$RECOMMENDATION" == "TUNE" ]]; then
            echo "- **TUNE:** Detection or false-positive performance needs improvement before deployment."
        else
            echo "- **MONITOR:** Results are promising but additional validation or a larger sample set is recommended."
        fi

        echo

    } >> "$OUTPUT"

done

# ------------------------------------------------------------
# Overall test summary
# ------------------------------------------------------------

{
    echo
    echo "## 4. Overall Testing Summary"
    echo
    echo "| Metric | Total |"
    echo "|---|---:|"
    echo "| True Positives | $GLOBAL_TP |"
    echo "| True Negatives | $GLOBAL_TN |"
    echo "| False Positives | $GLOBAL_FP |"
    echo "| False Negatives | $GLOBAL_FN |"
    echo

    echo "## 5. Testing Limitations"
    echo
    echo "- Results depend on the expected classifications in \`samples_manifest.txt\`."
    echo "- A limited test corpus cannot prove that a YARA rule will detect every future variant."
    echo "- False-negative explanations identify likely coverage gaps; the missed sample should be manually inspected before changing a rule."
    echo "- False-positive tuning should preserve the original detection objective and must be retested against the complete corpus."
    echo

    echo "## 6. Deployment Decision"
    echo
    echo "A YARA rule should only be deployed after confirming that detection performance remains acceptable on both malicious and benign samples."
    echo
    echo "Recommended process:"
    echo
    echo "1. Test the original rule."
    echo "2. Investigate every false positive and false negative."
    echo "3. Tune the rule carefully."
    echo "4. Re-run the complete corpus."
    echo "5. Deploy only after the revised results are acceptable."
    echo

} >> "$OUTPUT"

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo
echo "=========================================="
echo "       YARA TESTING COMPLETE"
echo "=========================================="
echo
echo "Report written to:"
echo "  $OUTPUT"
echo
echo "Overall:"
echo "  TP: $GLOBAL_TP"
echo "  TN: $GLOBAL_TN"
echo "  FP: $GLOBAL_FP"
echo "  FN: $GLOBAL_FN"
echo
