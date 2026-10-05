#!/bin/bash

set -euo pipefail

# ================================================================
# HEALTHBANE Stage 4 - Threat Hunt Brief
# Task 0
# ================================================================

ADVISORY="reference/hc3_advisory_004.txt"
ATTACK_MAPPING="reference/4x03_attack_mapping.json"
ADMIN_SCHEDULE="reference/admin_schedule.txt"
SERVICE_ACCOUNTS="reference/service_accounts.txt"
NETWORK_TOPOLOGY="reference/network_topology.txt"

ALERTS="siem_export/wazuh_alerts_14d.json"
RAWSYSMON="siem_export/wazuh_raw_sysmon_14d.json"
BASELINE="baseline/robert_kim_activity.json"

# ------------------------------------------------
# Validation
# ------------------------------------------------

required_files=(
    "$ADVISORY"
    "$ATTACK_MAPPING"
    "$ADMIN_SCHEDULE"
    "$SERVICE_ACCOUNTS"
    "$NETWORK_TOPOLOGY"
    "$ALERTS"
    "$RAWSYSMON"
    "$BASELINE"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "[ERROR] Missing required file: $file" >&2
        exit 1
    fi
done

if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq is required but was not found." >&2
    exit 1
fi

# Validate JSON files before processing them.
jq empty "$ATTACK_MAPPING" >/dev/null
jq empty "$ALERTS" >/dev/null
jq empty "$RAWSYSMON" >/dev/null
jq empty "$BASELINE" >/dev/null

# ------------------------------------------------
# Header
# ------------------------------------------------

echo
echo "================================================================"
echo "   THREAT HUNT BRIEF - HEALTHBANE Stage 4"
echo "   LOLBin Lateral Movement"
echo "   Classification: TLP:AMBER"
echo "================================================================"
echo

# ------------------------------------------------
# 1. HC3 Advisory Summary
# ------------------------------------------------

echo "HC3 ADVISORY SUMMARY:"
echo "  Stage 4 TTPs:"

echo "    [*] PsExec for remote command execution on servers"
echo "    [*] WMI for remote process creation and enumeration"
echo "    [*] PowerShell Remoting for interactive access and staging"
echo "    [*] Credential dumping via LSASS memory access"
echo "    [*] Service account abuse for lateral authentication"
echo "    [*] Off-hours operations to avoid detection"
echo

# ------------------------------------------------
# Extract relevant advisory evidence
# ------------------------------------------------

echo "ADVISORY EVIDENCE:"
grep -Ein \
    'PsExec|WMI|PowerShell Remoting|LSASS|service account|off-hours|01:00|05:00' \
    "$ADVISORY" |
    sed 's/^/  /' |
    head -n 20 || true

echo

# ------------------------------------------------
# 2. ATT&CK Coverage Analysis
# ------------------------------------------------

echo "ATT&CK COVERAGE GAP ANALYSIS:"

# Attempt to calculate coverage from common JSON structures.
coverage_info="$(
    jq -r '
        def items:
            if type == "array" then .
            elif type == "object" then
                if (.techniques? | type) == "array" then .techniques
                elif (.mapping? | type) == "array" then .mapping
                elif (.entries? | type) == "array" then .entries
                elif (.data? | type) == "array" then .data
                else
                    [to_entries[] | .value]
                end
            else []
            end;

        [items[] |
            select(type == "object") |
            {
                id: (.id // .technique_id // .technique // .attack_id // ""),
                name: (.name // .technique_name // .title // ""),
                state: (.state // .status // .coverage // "")
            }
        ] |
        map(select(.id != "")) |
        length as $total |
        {
            total: $total,
            observed: ([.[] | select((.state | ascii_upcase) == "OBSERVED")] | length),
            inferred: ([.[] | select((.state | ascii_upcase) == "INFERRED")] | length),
            not_covered: ([.[] | select((.state | ascii_upcase) == "NOT COVERED")] | length)
        }
    ' "$ATTACK_MAPPING"
)"

total="$(jq -r '.total' <<< "$coverage_info")"
observed="$(jq -r '.observed' <<< "$coverage_info")"
inferred="$(jq -r '.inferred' <<< "$coverage_info")"
not_covered="$(jq -r '.not_covered' <<< "$coverage_info")"

if [[ "$total" -gt 0 ]]; then
    echo "  Techniques loaded: $total"
    echo "  OBSERVED:           $observed"
    echo "  INFERRED:           $inferred"
    echo "  NOT COVERED:        $not_covered"
else
    echo "  [!] Could not determine ATT&CK technique count automatically."
fi

echo

# ------------------------------------------------
# Extract lateral movement / credential-access
# techniques and states.
# ------------------------------------------------

echo "  LATERAL MOVEMENT / CREDENTIAL ACCESS:"

jq -r '
    def items:
        if type == "array" then .
        elif type == "object" then
            if (.techniques? | type) == "array" then .techniques
            elif (.mapping? | type) == "array" then .mapping
            elif (.entries? | type) == "array" then .entries
            elif (.data? | type) == "array" then .data
            else [to_entries[] | .value]
            end
        else []
        end;

    items[] |
    select(type == "object") |
    {
        id: (.id // .technique_id // .technique // .attack_id // ""),
        name: (.name // .technique_name // .title // ""),
        state: (.state // .status // .coverage // ""),
        tactic: (.tactic // .tactics // .category // "")
    } |
    select(
        (.id | test(
            "^T1021|^T1047|^T1003|^T1078|^T1569|^T1059";
            "i"
        ))
        or
        (.tactic | tostring | test(
            "lateral|credential";
            "i"
        ))
    ) |
    "\(.id)\t\(.name)\t\(.state)"
' "$ATTACK_MAPPING" |
while IFS=$'\t' read -r id name state; do
    [[ -z "$id" ]] && continue
    printf "    %-12s %-35s %s\n" "$id" "$name" "$state"
done

echo

# ------------------------------------------------
# 3. Advisory techniques in NOT COVERED category
# ------------------------------------------------

echo "STAGE 4 TECHNIQUES IN CURRENT GAP:"

# Known Stage 4 ATT&CK mappings from the project requirements.
# We check the local mapping rather than blindly declaring them uncovered.

stage4_techniques=(
    "T1021.002"
    "T1047"
    "T1021.006"
    "T1003.001"
    "T1078.002"
)

stage4_names=(
    "SMB/Windows Admin Shares"
    "Windows Management Instrumentation"
    "Windows Remote Management"
    "LSASS Memory"
    "Domain Accounts"
)

for i in "${!stage4_techniques[@]}"; do
    technique="${stage4_techniques[$i]}"
    name="${stage4_names[$i]}"

    state="$(
        jq -r --arg id "$technique" '
            def items:
                if type == "array" then .
                elif type == "object" then
                    if (.techniques? | type) == "array" then .techniques
                    elif (.mapping? | type) == "array" then .mapping
                    elif (.entries? | type) == "array" then .entries
                    elif (.data? | type) == "array" then .data
                    else [to_entries[] | .value]
                    end
                else []
                end;

            items[] |
            select(type == "object") |
            select(
                (.id // .technique_id // .technique // .attack_id // "") == $id
            ) |
            (.state // .status // .coverage // "UNKNOWN")
        ' "$ATTACK_MAPPING" |
        head -n 1
    )"

    if [[ -z "$state" ]]; then
        state="UNKNOWN"
    fi

    printf "    %-12s %-35s %s\n" "$technique" "$name" "$state"
done

echo

# ------------------------------------------------
# 4. Hunt Priority
# ------------------------------------------------

echo "HUNT PRIORITY RANKING:"
echo "  P1: T1021.002  PsExec / Windows Admin Shares"
echo "  P2: T1003.001  LSASS Memory"
echo "  P3: T1047      WMI"
echo "  P4: T1021.006  PowerShell Remoting / WinRM"
echo "  P5: T1078.002  Domain Accounts / Service Account Abuse"
echo

# ------------------------------------------------
# 5. Hunt Scope
# ------------------------------------------------

echo "HUNT SCOPE:"
echo "  Scope:        MedDefense Health Systems"
echo "  Time window:  Last 14 days"
echo "  Objective:    Identify HEALTHBANE Stage 4-style lateral movement"
echo "  Focus:        LOLBin abuse, credential access and account misuse"
echo

# ------------------------------------------------
# 6. Data Sources
# ------------------------------------------------

echo "DATA SOURCES:"
echo "  Primary:"
echo "    - $ALERTS"
echo
echo "  Secondary:"
echo "    - $RAWSYSMON"
echo
echo "  Baseline:"
echo "    - $BASELINE"
echo
echo "  Reference:"
echo "    - $ADVISORY"
echo "    - $ATTACK_MAPPING"
echo "    - $ADMIN_SCHEDULE"
echo "    - $SERVICE_ACCOUNTS"
echo "    - $NETWORK_TOPOLOGY"
echo

# ------------------------------------------------
# 7. False-positive controls
# ------------------------------------------------

echo "FALSE-POSITIVE CONTROLS:"
echo "  [1] Robert Kim authorized maintenance schedule"
echo "      $ADMIN_SCHEDULE"
echo
echo "  [2] Service account authorization matrix"
echo "      $SERVICE_ACCOUNTS"
echo
echo "  [3] Network topology and authorized host usage"
echo "      $NETWORK_TOPOLOGY"
echo

# ------------------------------------------------
# 8. Hunt Questions
# ------------------------------------------------

echo "PRIMARY HUNT QUESTIONS:"
echo "  [1] Did PsExec activity occur outside authorized maintenance?"
echo "  [2] Did WMI remote execution or enumeration occur from unusual hosts?"
echo "  [3] Did LSASS memory access indicate possible credential theft?"
echo "  [4] Did PowerShell Remoting occur outside the administrator baseline?"
echo "  [5] Did service accounts authenticate from unauthorized hosts?"
echo "  [6] Did suspicious activity cluster between 01:00 and 05:00?"
echo "  [7] Can separate events be correlated into a Stage 4 attack chain?"
echo

# ------------------------------------------------
# 9. Priority interpretation
# ------------------------------------------------

echo "HUNT INTERPRETATION:"
echo "  Baseline activity:"
echo "    Authorized administrator activity matching schedule, source,"
echo "    target and expected maintenance behavior."
echo
echo "  Anomalous activity:"
echo "    Legitimate administrative tooling used outside the expected"
echo "    account, host, target or time context."
echo
echo "  Confirmed finding:"
echo "    Correlated evidence demonstrating unauthorized activity that"
echo "    cannot be explained by the approved baseline."
echo
echo "  Inferred conclusion:"
echo "    A hypothesis supported by correlated evidence but requiring"
echo "    additional validation before declaring compromise."
echo

# ------------------------------------------------
# End
# ------------------------------------------------

echo "================================================================"
echo "   END OF HUNT BRIEF"
echo "================================================================"
echo
