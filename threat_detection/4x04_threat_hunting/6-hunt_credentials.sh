#!/bin/bash

# ================================================================
# MedDefense - Task 6
# Hunt: Credential Access - LSASS
#
# ATT&CK Technique:
# T1003.001 - LSASS Memory
#
# Hypothesis H2:
# An attacker accessed LSASS memory to obtain credentials and
# subsequently used a stolen service account for lateral movement.
#
# Data sources:
#   - Wazuh alerts
#   - Raw Sysmon events
#   - Service account reference
#
# Important:
#   SIEM files are JSONL:
#   one JSON object per line.
#
#   Source files are READ ONLY and are never modified.
# ================================================================

set -euo pipefail

# ----------------------------------------------------------------
# Paths
# ----------------------------------------------------------------

ALERTS="siem_export/wazuh_alerts_14d.json"
SYSMON="siem_export/wazuh_raw_sysmon_14d.json"
SERVICE_ACCOUNTS="reference/service_accounts.txt"

# ----------------------------------------------------------------
# Hunt configuration
# ----------------------------------------------------------------

TARGET_ACCOUNT="svc_healthsync"

# Access masks commonly associated with memory access.
#
# 0x1010 = PROCESS_QUERY_LIMITED_INFORMATION + PROCESS_VM_READ
# 0x1410 = another common combination containing VM_READ
#
# We do not treat the mask alone as proof of credential dumping.
# It is considered together with the source process and context.
# ----------------------------------------------------------------

TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

LSASS_EVENTS="$TMP_DIR/lsass_events.jsonl"
ANOMALOUS_LSASS="$TMP_DIR/anomalous_lsass.jsonl"
AUTH_EVENTS="$TMP_DIR/auth_events.jsonl"
SERVICE_AUTH="$TMP_DIR/service_auth.jsonl"
LATERAL_EVENTS="$TMP_DIR/lateral_events.jsonl"

: > "$LSASS_EVENTS"
: > "$ANOMALOUS_LSASS"
: > "$AUTH_EVENTS"
: > "$SERVICE_AUTH"
: > "$LATERAL_EVENTS"

# ----------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

info() {
    echo "[INFO] $*"
}

command -v jq >/dev/null 2>&1 || die "jq is required."

for file in "$ALERTS" "$SYSMON" "$SERVICE_ACCOUNTS"; do
    [[ -f "$file" ]] || die "Required file not found: $file"
done

# ----------------------------------------------------------------
# Validate JSONL
# ----------------------------------------------------------------

validate_jsonl() {
    local file="$1"
    local line_number=0
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number + 1))

        [[ -z "${line//[[:space:]]/}" ]] && continue

        if ! jq -e . >/dev/null 2>&1 <<< "$line"; then
            die "Invalid JSON on line $line_number of $file"
        fi
    done < "$file"
}

info "Validating SIEM JSONL files..."

validate_jsonl "$ALERTS"
validate_jsonl "$SYSMON"

info "SIEM JSONL validation successful."

# ================================================================
# 1. SEARCH FOR LSASS ACCESS EVENTS
# ================================================================

info "Searching for LSASS memory access events..."

# ----------------------------------------------------------------
# Sysmon Event ID 10 = Process Access
#
# Typical structure:
#
# "eventID": "10"
#
# "targetImage":
#     "C:\\Windows\\System32\\lsass.exe"
#
# "sourceImage":
#     "C:\\Windows\\Temp\\debug_tool.exe"
#
# "grantedAccess":
#     "0x1010"
# ----------------------------------------------------------------

jq -c '
    select(
        (
            (.data.win.system.eventID // "")
            | tostring
        ) == "10"
    )
    | select(
        (
            (.data.win.eventdata.targetImage // "")
            | ascii_downcase
            | contains("lsass.exe")
        )
    )
' "$SYSMON" >> "$LSASS_EVENTS"

# ----------------------------------------------------------------
# Some Wazuh alerts may also contain the same Sysmon Process
# Access event. Search the Wazuh export too.
# ----------------------------------------------------------------

jq -c '
    select(
        (
            (.data.win.system.eventID // "")
            | tostring
        ) == "10"
    )
    | select(
        (
            (.data.win.eventdata.targetImage // "")
            | ascii_downcase
            | contains("lsass.exe")
        )
    )
' "$ALERTS" >> "$LSASS_EVENTS"

# ----------------------------------------------------------------
# Remove exact duplicate JSON records.
# ----------------------------------------------------------------

sort -u "$LSASS_EVENTS" > "$TMP_DIR/lsass_unique.jsonl"
mv "$TMP_DIR/lsass_unique.jsonl" "$LSASS_EVENTS"

# ----------------------------------------------------------------
# Count LSASS events
# ----------------------------------------------------------------

TOTAL_LSASS=$(grep -c '^{' "$LSASS_EVENTS" || true)

# ================================================================
# 2. CLASSIFY LSASS ACCESS
# ================================================================
#
# Legitimate examples may include:
#
#   C:\Windows\System32\svchost.exe
#   C:\Windows\System32\services.exe
#   C:\Windows\System32\wininit.exe
#   C:\Windows\System32\csrss.exe
#   C:\Windows\System32\lsass.exe
#
# Suspicious examples:
#
#   C:\Windows\Temp\debug_tool.exe
#   C:\Users\...\Downloads\tool.exe
#   C:\Users\...\AppData\...
#   unknown executables
#
# The source process is therefore an important part of the
# classification.
# ================================================================

SYSTEM_PROCESS_REGEX='(^|/|\\)(svchost|services|wininit|csrss|lsass|winlogon|taskhostw|wmiprvse|MsMpEng)\.exe$'

SYSTEM_LEGIT_COUNT=0
ANOMALOUS_COUNT=0

while IFS= read -r event; do

    [[ -z "$event" ]] && continue

    source_image=$(jq -r '
        .data.win.eventdata.sourceImage
        // "-"
    ' <<< "$event")

    source_lower="${source_image,,}"

    # ------------------------------------------------------------
    # Determine whether source process is a known Windows/system
    # process.
    # ------------------------------------------------------------

    legitimate=0

    if [[ "$source_lower" =~ $SYSTEM_PROCESS_REGEX ]]; then
        legitimate=1
    fi

    # ------------------------------------------------------------
    # Extract access mask
    # ------------------------------------------------------------

    access_mask=$(jq -r '
        .data.win.eventdata.grantedAccess
        // "-"
    ' <<< "$event")

    # ------------------------------------------------------------
    # Determine whether access mask contains a memory-read
    # capability.
    #
    # We specifically look for known masks such as:
    #   0x1010
    #   0x1410
    #
    # Also recognize PROCESS_VM_READ bit 0x0010 when represented
    # numerically.
    # ------------------------------------------------------------

    memory_read=0

    access_normalized="${access_mask,,}"

    case "$access_normalized" in
        0x1010|0x1410|0x1438|0x1fffff)
            memory_read=1
            ;;
    esac

    # ------------------------------------------------------------
    # If the process is a normal Windows process, classify it as
    # system/legitimate.
    #
    # Otherwise classify it as anomalous.
    # ------------------------------------------------------------

    if (( legitimate == 1 )); then
        SYSTEM_LEGIT_COUNT=$((SYSTEM_LEGIT_COUNT + 1))
    else
        ANOMALOUS_COUNT=$((ANOMALOUS_COUNT + 1))

        timestamp=$(jq -r '
            .timestamp
            // .data.win.eventdata.utcTime
            // "-"
        ' <<< "$event")

        host=$(jq -r '
            .agent.name
            // .data.win.system.computer
            // "-"
        ' <<< "$event")

        jq -c \
            --arg timestamp "$timestamp" \
            --arg host "$host" \
            --arg source "$source_image" \
            --arg access "$access_mask" \
            --arg memory_read "$memory_read" '
            . + {
                hunt_result: {
                    timestamp: $timestamp,
                    host: $host,
                    source_process: $source,
                    access_mask: $access,
                    memory_read: $memory_read
                }
            }
        ' <<< "$event" >> "$ANOMALOUS_LSASS"

    fi

done < "$LSASS_EVENTS"

# ================================================================
# 3. SEARCH FOR svc_healthsync AUTHENTICATION
# ================================================================

info "Searching for svc_healthsync authentication events..."

# ----------------------------------------------------------------
# Windows Security Event 4624 = Successful Logon
#
# We look for:
#
# targetUserName = svc_healthsync
#
# The account may appear as:
#
#   svc_healthsync
#   MEDDEFENSE\svc_healthsync
# ----------------------------------------------------------------

jq -c --arg account "$TARGET_ACCOUNT" '
    select(
        (
            (.data.win.system.eventID // "")
            | tostring
        ) == "4624"
    )
    | select(
        (
            (.data.win.eventdata.targetUserName // "")
            | ascii_downcase
            | endswith($account | ascii_downcase)
        )
    )
' "$ALERTS" >> "$AUTH_EVENTS"

# Also search raw Sysmon/Wazuh-style records if authentication
# events happen to be present there.
jq -c --arg account "$TARGET_ACCOUNT" '
    select(
        (
            (.data.win.system.eventID // "")
            | tostring
        ) == "4624"
    )
    | select(
        (
            (.data.win.eventdata.targetUserName // "")
            | ascii_downcase
            | endswith($account | ascii_downcase)
        )
    )
' "$SYSMON" >> "$AUTH_EVENTS"

# ----------------------------------------------------------------
# Remove duplicates
# ----------------------------------------------------------------

sort -u "$AUTH_EVENTS" > "$TMP_DIR/auth_unique.jsonl"
mv "$TMP_DIR/auth_unique.jsonl" "$AUTH_EVENTS"

SERVICE_AUTH_COUNT=$(grep -c '^{' "$AUTH_EVENTS" || true)

# ================================================================
# 4. CORRELATE SERVICE ACCOUNT USE
# ================================================================
#
# We extract:
#
#   timestamp
#   source workstation
#   destination computer
#   source IP
#   logon type
#
# This gives us the "what happened after credential access?"
# part of the investigation.
# ================================================================

while IFS= read -r event; do

    [[ -z "$event" ]] && continue

    timestamp=$(jq -r '
        .timestamp
        // .data.win.eventdata.utcTime
        // "-"
    ' <<< "$event")

    host=$(jq -r '
        .agent.name
        // .data.win.system.computer
        // "-"
    ' <<< "$event")

    workstation=$(jq -r '
        .data.win.eventdata.workstationName
        // "-"
    ' <<< "$event")

    source_ip=$(jq -r '
        .data.win.eventdata.ipAddress
        // "-"
    ' <<< "$event")

    logon_type=$(jq -r '
        .data.win.eventdata.logonType
        // "-"
    ' <<< "$event")

    target_domain=$(jq -r '
        .data.win.eventdata.targetDomainName
        // "-"
    ' <<< "$event")

    jq -c \
        --arg timestamp "$timestamp" \
        --arg host "$host" \
        --arg workstation "$workstation" \
        --arg source_ip "$source_ip" \
        --arg logon_type "$logon_type" \
        --arg domain "$target_domain" '
        . + {
            correlation: {
                timestamp: $timestamp,
                destination_host: $host,
                workstation: $workstation,
                source_ip: $source_ip,
                logon_type: $logon_type,
                domain: $domain
            }
        }
    ' <<< "$event" >> "$SERVICE_AUTH"

done < "$AUTH_EVENTS"

# ================================================================
# 5. SEARCH FOR LATERAL MOVEMENT TOOLS
# ================================================================
#
# After credential theft, look for:
#
#   PsExec
#   WMI
#   PowerShell Remoting / WinRM
#
# These are the tools mentioned in the HEALTHBANE Stage 4
# scenario.
# ================================================================

jq -c '
    select(
        (
            (
                (.data.win.eventdata.image // "")
                + " "
                + (.data.win.eventdata.commandLine // "")
                + " "
                + (.rule.description // "")
            )
            | ascii_downcase
            | (
                contains("psexec")
                or contains("wmiprvse")
                or contains("winrm")
                or contains("powershell remoting")
                or contains("enter-pssession")
                or contains("invoke-command")
            )
        )
    )
' "$SYSMON" >> "$LATERAL_EVENTS"

jq -c '
    select(
        (
            (
                (.data.win.eventdata.image // "")
                + " "
                + (.data.win.eventdata.commandLine // "")
                + " "
                + (.rule.description // "")
            )
            | ascii_downcase
            | (
                contains("psexec")
                or contains("wmiprvse")
                or contains("winrm")
                or contains("powershell remoting")
                or contains("enter-pssession")
                or contains("invoke-command")
            )
        )
    )
' "$ALERTS" >> "$LATERAL_EVENTS"

sort -u "$LATERAL_EVENTS" > "$TMP_DIR/lateral_unique.jsonl"
mv "$TMP_DIR/lateral_unique.jsonl" "$LATERAL_EVENTS"

LATERAL_COUNT=$(grep -c '^{' "$LATERAL_EVENTS" || true)

# ================================================================
# OUTPUT
# ================================================================

echo
echo "================================================================"
echo "   HUNT EXECUTION - H2: Credential Access (LSASS)"
echo "   Technique: T1003.001 LSASS Memory"
echo "================================================================"
echo

echo "LSASS ACCESS EVENTS:"
echo "  Total LSASS access events: $TOTAL_LSASS"
echo "  System/legitimate: $SYSTEM_LEGIT_COUNT"
echo "  ANOMALOUS: $ANOMALOUS_COUNT"
echo

# ----------------------------------------------------------------
# Display anomalous LSASS events
# ----------------------------------------------------------------

if (( ANOMALOUS_COUNT > 0 )); then

    EVENT_NUMBER=0

    while IFS= read -r event; do

        [[ -z "$event" ]] && continue

        EVENT_NUMBER=$((EVENT_NUMBER + 1))

        timestamp=$(jq -r '.hunt_result.timestamp' <<< "$event")
        host=$(jq -r '.hunt_result.host' <<< "$event")
        source=$(jq -r '.hunt_result.source_process' <<< "$event")
        access=$(jq -r '.hunt_result.access_mask' <<< "$event")
        memory_read=$(jq -r '.hunt_result.memory_read' <<< "$event")

        echo "  [A$EVENT_NUMBER] $timestamp"
        echo "    Host: $host"
        echo "    Source Process: $source"
        echo "    Target: lsass.exe"
        echo "    Access Mask: $access"

        if [[ "$memory_read" == "1" ]]; then
            echo "    -> Consistent with memory read access"
        else
            echo "    -> LSASS access observed; memory-read mask not confirmed"
        fi

        echo

    done < "$ANOMALOUS_LSASS"

else

    echo "  No anomalous LSASS source processes identified."
    echo

fi

# ================================================================
# CREDENTIAL USAGE CORRELATION
# ================================================================

echo "CREDENTIAL USAGE CORRELATION:"
echo "  svc_healthsync authentication events: $SERVICE_AUTH_COUNT"
echo

if (( SERVICE_AUTH_COUNT > 0 )); then

    while IFS= read -r event; do

        [[ -z "$event" ]] && continue

        timestamp=$(jq -r '.correlation.timestamp' <<< "$event")
        destination=$(jq -r '.correlation.destination_host' <<< "$event")
        workstation=$(jq -r '.correlation.workstation' <<< "$event")
        source_ip=$(jq -r '.correlation.source_ip' <<< "$event")
        logon_type=$(jq -r '.correlation.logon_type' <<< "$event")

        echo "    $timestamp $workstation -> $destination"
        echo "      Source IP: $source_ip"
        echo "      Logon Type: $logon_type"

    done < "$SERVICE_AUTH"

else

    echo "    No svc_healthsync authentication events found."

fi

echo

# ================================================================
# LATERAL MOVEMENT CORRELATION
# ================================================================

echo "LATERAL MOVEMENT CORRELATION:"
echo "  PsExec/WMI/PSRemoting-related events: $LATERAL_COUNT"
echo

if (( LATERAL_COUNT > 0 )); then

    SHOW_COUNT=0

    while IFS= read -r event; do

        [[ -z "$event" ]] && continue

        SHOW_COUNT=$((SHOW_COUNT + 1))

        timestamp=$(jq -r '
            .timestamp
            // .data.win.eventdata.utcTime
            // "-"
        ' <<< "$event")

        host=$(jq -r '
            .agent.name
            // .data.win.system.computer
            // "-"
        ' <<< "$event")

        image=$(jq -r '
            .data.win.eventdata.image
            // "-"
        ' <<< "$event")

        command=$(jq -r '
            .data.win.eventdata.commandLine
            // "-"
        ' <<< "$event")

        description=$(jq -r '
            .rule.description
            // "-"
        ' <<< "$event")

        echo "    [$SHOW_COUNT] $timestamp"
        echo "      Host: $host"
        echo "      Image: $image"
        echo "      Command: $command"
        echo "      Event: $description"
        echo

        # Avoid producing an enormous terminal output.
        if (( SHOW_COUNT >= 20 )); then
            REMAINING=$((LATERAL_COUNT - SHOW_COUNT))

            if (( REMAINING > 0 )); then
                echo "    ... $REMAINING additional lateral-movement events omitted."
                echo
            fi

            break
        fi

    done < "$LATERAL_EVENTS"

else

    echo "    No PsExec/WMI/PSRemoting-related events found."

fi

# ================================================================
# TIMELINE CORRELATION
# ================================================================
#
# We now try to determine whether the evidence supports the
# sequence:
#
#   1. LSASS access
#          ↓
#   2. svc_healthsync authentication
#          ↓
#   3. lateral movement tool
#
# This is stronger evidence than simply finding LSASS access.
# ================================================================

echo "CREDENTIAL THEFT TIMELINE:"

if (( ANOMALOUS_COUNT > 0 && SERVICE_AUTH_COUNT > 0 )); then

    echo "  [1] Anomalous LSASS access was identified."
    echo "  [2] svc_healthsync authentication was identified."
    
    if (( LATERAL_COUNT > 0 )); then
        echo "  [3] PsExec/WMI/PSRemoting activity was identified."
        echo
        echo "  -> Evidence supports a possible credential-theft"
        echo "     followed by service-account lateral movement chain."
    else
        echo "  [3] No related PsExec/WMI/PSRemoting activity identified."
        echo
        echo "  -> Credential access and service-account use were observed,"
        echo "     but lateral-movement tooling was not confirmed."
    fi

else

    if (( ANOMALOUS_COUNT == 0 )); then
        echo "  [1] No anomalous LSASS access identified."
    else
        echo "  [1] Anomalous LSASS access identified."
    fi

    if (( SERVICE_AUTH_COUNT == 0 )); then
        echo "  [2] No svc_healthsync authentication identified."
    else
        echo "  [2] svc_healthsync authentication identified."
    fi

    echo
    echo "  -> Complete credential-theft chain not established."

fi

echo

# ================================================================
# FINAL FINDING
# ================================================================

echo "FINDING:"

if (( ANOMALOUS_COUNT > 0 && SERVICE_AUTH_COUNT > 0 && LATERAL_COUNT > 0 )); then

    echo "  Status: POSITIVE - HIGH CONFIDENCE"
    echo "  The evidence supports a possible credential-theft chain:"
    echo "  anomalous LSASS access followed by svc_healthsync"
    echo "  authentication and lateral-movement activity."
    echo "  Recommendation: ESCALATE"

elif (( ANOMALOUS_COUNT > 0 && SERVICE_AUTH_COUNT > 0 )); then

    echo "  Status: POSITIVE - MEDIUM CONFIDENCE"
    echo "  Anomalous LSASS access and subsequent svc_healthsync"
    echo "  authentication were observed."
    echo "  Lateral movement tooling was not independently confirmed."
    echo "  Recommendation: REVIEW AND ESCALATE"

elif (( ANOMALOUS_COUNT > 0 )); then

    echo "  Status: SUSPICIOUS - MEDIUM CONFIDENCE"
    echo "  Anomalous LSASS access was observed, but subsequent"
    echo "  svc_healthsync use was not confirmed."
    echo "  Recommendation: INVESTIGATE"

elif (( SERVICE_AUTH_COUNT > 0 )); then

    echo "  Status: INCONCLUSIVE"
    echo "  svc_healthsync authentication was observed, but no"
    echo "  anomalous LSASS access was identified."
    echo "  Recommendation: CONTINUE INVESTIGATION"

else

    echo "  Status: NEGATIVE"
    echo "  No complete credential-access and lateral-movement"
    echo "  chain was identified in the available 14-day data."
    echo "  Recommendation: CONTINUE MONITORING"

fi

echo
echo "================================================================"
echo "   HUNT COMPLETE"
echo "================================================================"
