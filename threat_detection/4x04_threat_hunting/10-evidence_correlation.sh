#!/bin/bash

# ================================================================
# EVIDENCE CORRELATION - HEALTHBANE Stage 4 Reconstruction
#
# Goal:
#   Correlate evidence from Tasks 4-9 into one chronological
#   attack timeline.
#
# Kill-chain phases:
#   Credential Access
#   Lateral Movement
#   Reconnaissance
#   Staging
#   Expansion
#
# SIEM format:
#   JSONL - one JSON object per line.
#
# Source files are read-only.
# ================================================================

set -u
set -o pipefail

BASE_DIR="."
REFERENCE_DIR="$BASE_DIR/reference"
SIEM_DIR="$BASE_DIR/siem_export"

ALERTS="$SIEM_DIR/wazuh_alerts_14d.json"
SYSMON="$SIEM_DIR/wazuh_raw_sysmon_14d.json"
SERVICE_FILE="$REFERENCE_DIR/service_accounts.txt"

TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

TIMELINE="$TMP_DIR/timeline.tsv"
SERVICE_ACCOUNTS="$TMP_DIR/service_accounts.txt"
AUTHORIZED_MATRIX="$TMP_DIR/service_matrix.tsv"

touch "$TIMELINE"
touch "$SERVICE_ACCOUNTS"
touch "$AUTHORIZED_MATRIX"

# ================================================================
# FUNCTIONS
# ================================================================

die() {
    echo "[ERROR] $1" >&2
    exit 1
}

check_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "$1 is required but not installed."
}

check_file() {
    [ -f "$1" ] ||
        die "Required file not found: $1"
}

lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

normalize_account() {
    local account="$1"

    account="${account##*\\}"
    account="${account##*/}"

    lower "$account"
}

# ---------------------------------------------------------------
# Validate JSONL.
#
# Each line is checked independently.
# ---------------------------------------------------------------

validate_jsonl() {

    local file="$1"
    local line_number=0
    local line

    while IFS= read -r line || [ -n "$line" ]; do

        line_number=$((line_number + 1))

        [ -z "$line" ] && continue

        if ! printf '%s\n' "$line" |
            jq -e '.' >/dev/null 2>&1; then

            die "Invalid JSON on line $line_number of $file"
        fi

    done < "$file"
}

# ================================================================
# REQUIREMENTS
# ================================================================

check_command jq
check_command awk
check_command grep
check_command sort
check_command date

check_file "$ALERTS"
check_file "$SYSMON"
check_file "$SERVICE_FILE"

validate_jsonl "$ALERTS"
validate_jsonl "$SYSMON"

# ================================================================
# HEADER
# ================================================================

echo
echo "================================================================"
echo "   EVIDENCE CORRELATION - HEALTHBANE Stage 4 Reconstruction"
echo "================================================================"
echo

# ================================================================
# 1. LOAD SERVICE ACCOUNTS
# ================================================================

grep -Eio 'svc_[a-zA-Z0-9_.-]+' "$SERVICE_FILE" |
    tr '[:upper:]' '[:lower:]' |
    sort -u > "$SERVICE_ACCOUNTS"

# ================================================================
# 2. LOAD AUTHORIZATION MATRIX
# ================================================================

while IFS= read -r account; do

    while IFS= read -r line; do

        if ! printf '%s\n' "$line" |
            grep -Eiq "(^|[^a-zA-Z0-9_])${account}([^a-zA-Z0-9_]|$)"; then
            continue
        fi

        printf '%s\n' "$line" |
            grep -Eio 'SRV-[A-Za-z0-9_.-]+' |
            tr '[:upper:]' '[:lower:]' |
            sort -u |
            while IFS= read -r host; do

                [ -n "$host" ] || continue

                printf '%s\t%s\n' "$account" "$host" \
                    >> "$AUTHORIZED_MATRIX"

            done

    done < "$SERVICE_FILE"

done < "$SERVICE_ACCOUNTS"

sort -u "$AUTHORIZED_MATRIX" -o "$AUTHORIZED_MATRIX"

# ================================================================
# 3. ADD TIMELINE EVENT
#
# Format:
#
# timestamp
# phase
# source
# action
# account
# target
# tool
# ================================================================

add_event() {

    local timestamp="$1"
    local phase="$2"
    local source="$3"
    local action="$4"
    local account="$5"
    local target="$6"
    local tool="$7"

    [ -n "$timestamp" ] || return

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$timestamp" \
        "$phase" \
        "$source" \
        "$action" \
        "$account" \
        "$target" \
        "$tool" \
        >> "$TIMELINE"
}

# ================================================================
# 4. PROCESS CREDENTIAL ACCESS
#
# Sysmon Event ID 10 = Process Access.
#
# We specifically look for:
#
#   targetImage = lsass.exe
#
# and flag unusual source processes.
# ================================================================

process_credential_access() {

    local file="$1"
    local json

    while IFS= read -r json || [ -n "$json" ]; do

        [ -n "$json" ] || continue

        local event_id

        event_id="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.system.eventID //
                    .data.win.eventdata.eventID //
                    ""
                '
        )"

        [ "$event_id" = "10" ] || continue

        local target_image

        target_image="$(
            printf '%s\n' "$json" |
                jq -r '.data.win.eventdata.targetImage // ""'
        )"

        printf '%s\n' "$target_image" |
            grep -Eiq 'lsass\.exe' || continue

        local source_image
        local timestamp
        local source_host
        local access_mask

        source_image="$(
            printf '%s\n' "$json" |
                jq -r '.data.win.eventdata.sourceImage // ""'
        )"

        timestamp="$(
            printf '%s\n' "$json" |
                jq -r '
                    .timestamp //
                    .data.win.eventdata.utcTime //
                    ""
                '
        )"

        source_host="$(
            printf '%s\n' "$json" |
                jq -r '
                    .hunt_meta.source_host //
                    .agent.name //
                    .data.win.system.computer //
                    ""
                '
        )"

        access_mask="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.eventdata.grantedAccess //
                    .data.win.eventdata.accessMask //
                    ""
                '
        )"

        # -------------------------------------------------------
        # Ignore common Windows/system processes.
        # -------------------------------------------------------

        if printf '%s\n' "$source_image" |
            grep -Eiq \
            'svchost|services\.exe|wininit|csrss|lsass|winlogon|taskhostw|wmiprvse|MsMpEng'; then

            continue
        fi

        local action="LSASS memory access"

        if [ -n "$access_mask" ]; then
            action="$action (access $access_mask)"
        fi

        add_event \
            "$timestamp" \
            "CREDENTIAL ACCESS" \
            "$source_host" \
            "$action by $source_image" \
            "" \
            "" \
            "LSASS"

    done < "$file"
}

process_credential_access "$SYSMON"
process_credential_access "$ALERTS"

# ================================================================
# 5. PROCESS SERVICE ACCOUNT AUTHENTICATION
#
# Event ID 4624.
#
# Only unauthorized service-account use is added to the attack
# timeline.
# ================================================================

process_service_auth() {

    local file="$1"
    local json

    while IFS= read -r json || [ -n "$json" ]; do

        [ -n "$json" ] || continue

        local event_id

        event_id="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.system.eventID //
                    .data.win.eventdata.eventID //
                    ""
                '
        )"

        [ "$event_id" = "4624" ] || continue

        local raw_account
        local account

        raw_account="$(
            printf '%s\n' "$json" |
                jq -r '.data.win.eventdata.targetUserName // ""'
        )"

        [ -n "$raw_account" ] || continue

        account="$(normalize_account "$raw_account")"

        # Only service accounts.
        grep -Fxqi "$account" "$SERVICE_ACCOUNTS" ||
            continue

        local timestamp
        local source_host
        local destination
        local logon_type
        local auth_package

        timestamp="$(
            printf '%s\n' "$json" |
                jq -r '
                    .timestamp //
                    .data.win.eventdata.utcTime //
                    ""
                '
        )"

        source_host="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.eventdata.workstationName //
                    .data.win.eventdata.workstation //
                    .hunt_meta.source_host //
                    .agent.name //
                    ""
                '
        )"

        destination="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.system.computer //
                    .data.win.eventdata.computer //
                    .agent.name //
                    ""
                '
        )"

        logon_type="$(
            printf '%s\n' "$json" |
                jq -r '.data.win.eventdata.logonType // ""'
        )"

        auth_package="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.eventdata.authenticationPackageName //
                    ""
                '
        )"

        # -------------------------------------------------------
        # Determine authorized host.
        # -------------------------------------------------------

        authorized_hosts="$(
            awk -F '\t' -v a="$account" '
                $1 == a {
                    if (result != "") {
                        result = result ","
                    }
                    result = result $2
                }
                END {
                    print result
                }
            ' "$AUTHORIZED_MATRIX"
        )"

        local source_lower
        source_lower="$(lower "$source_host")"

        local authorized="false"

        if [ -n "$authorized_hosts" ]; then

            IFS=',' read -r -a allowed_array <<< "$authorized_hosts"

            for allowed in "${allowed_array[@]}"; do

                if [ "$source_lower" = "$allowed" ]; then
                    authorized="true"
                    break
                fi

            done
        fi

        # -------------------------------------------------------
        # Workstation detection.
        # -------------------------------------------------------

        local workstation="false"

        if printf '%s\n' "$source_host" |
            grep -Eiq '(^|[-_])(WS|WKSTN|WORKSTATION)([-_]|$)'; then

            workstation="true"
        fi

        # -------------------------------------------------------
        # Interactive logon.
        # -------------------------------------------------------

        local interactive="false"

        case "$logon_type" in
            2|10|11)
                interactive="true"
                ;;
        esac

        # -------------------------------------------------------
        # Only add suspicious/unauthorized service account use.
        # -------------------------------------------------------

        if [ "$authorized" = "false" ] ||
           [ "$workstation" = "true" ] ||
           [ "$interactive" = "true" ]; then

            local action="Unauthorized service-account authentication"

            if [ "$workstation" = "true" ]; then
                action="$action from workstation"
            fi

            if [ "$interactive" = "true" ]; then
                action="$action (interactive logon type $logon_type)"
            fi

            if printf '%s\n' "$auth_package" |
                grep -Eiq 'NTLM'; then

                action="$action using NTLM"
            fi

            add_event \
                "$timestamp" \
                "LATERAL MOVEMENT" \
                "$source_host" \
                "$action" \
                "$account" \
                "$destination" \
                "Service Account"

        fi

    done < "$file"
}

process_service_auth "$ALERTS"
process_service_auth "$SYSMON"

# ================================================================
# 6. PROCESS PSEXEC / WMI / PSREMOTING
# ================================================================

process_lateral_tools() {

    local file="$1"
    local json

    while IFS= read -r json || [ -n "$json" ]; do

        [ -n "$json" ] || continue

        local event_text

        event_text="$(
            printf '%s\n' "$json" |
                jq -r '
                    [
                        .data.win.eventdata.image,
                        .data.win.eventdata.commandLine,
                        .data.win.eventdata.parentImage,
                        .data.win.eventdata.processName,
                        .data.win.eventdata.destinationHostname,
                        .data.win.eventdata.targetFilename,
                        .hunt_meta.tool,
                        .hunt_meta.category,
                        .rule.description
                    ]
                    | map(select(. != null))
                    | join(" ")
                '
        )"

        # -------------------------------------------------------
        # PsExec
        # -------------------------------------------------------

        if printf '%s\n' "$event_text" |
            grep -Eiq 'psexec'; then

            local timestamp
            local source
            local target
            local command_line

            timestamp="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .timestamp //
                        .data.win.eventdata.utcTime //
                        ""
                    '
            )"

            source="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.source_host //
                        .agent.name //
                        .data.win.system.computer //
                        ""
                    '
            )"

            target="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.target_host //
                        .data.win.eventdata.destinationHostname //
                        ""
                    '
            )"

            command_line="$(
                printf '%s\n' "$json" |
                    jq -r '.data.win.eventdata.commandLine // ""'
            )"

            add_event \
                "$timestamp" \
                "LATERAL MOVEMENT" \
                "$source" \
                "PsExec execution: $command_line" \
                "" \
                "$target" \
                "PsExec"

            continue
        fi

        # -------------------------------------------------------
        # WMI
        # -------------------------------------------------------

        if printf '%s\n' "$event_text" |
            grep -Eiq 'wmic|wmiprvse|wmi'; then

            timestamp="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .timestamp //
                        .data.win.eventdata.utcTime //
                        ""
                    '
            )"

            source="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.source_host //
                        .agent.name //
                        .data.win.system.computer //
                        ""
                    '
            )"

            target="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.target_host //
                        .data.win.eventdata.destinationHostname //
                        ""
                    '
            )"

            add_event \
                "$timestamp" \
                "RECONNAISSANCE" \
                "$source" \
                "WMI activity" \
                "" \
                "$target" \
                "WMI"

            continue
        fi

        # -------------------------------------------------------
        # PowerShell Remoting / WinRM
        # -------------------------------------------------------

        if printf '%s\n' "$event_text" |
            grep -Eiq \
            'winrm|winrs|enter-pssession|invoke-command|powershell.*-computername|powershell.*-session'; then

            timestamp="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .timestamp //
                        .data.win.eventdata.utcTime //
                        ""
                    '
            )"

            source="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.source_host //
                        .agent.name //
                        .data.win.system.computer //
                        ""
                    '
            )"

            target="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.target_host //
                        .data.win.eventdata.destinationHostname //
                        ""
                    '
            )"

            add_event \
                "$timestamp" \
                "STAGING" \
                "$source" \
                "PowerShell Remoting / WinRM activity" \
                "" \
                "$target" \
                "PSRemoting"

        fi

    done < "$file"
}

process_lateral_tools "$ALERTS"
process_lateral_tools "$SYSMON"

# ================================================================
# 7. FILE STAGING / COPY-ITEM
# ================================================================

process_staging() {

    local file="$1"
    local json

    while IFS= read -r json || [ -n "$json" ]; do

        [ -n "$json" ] || continue

        local event_text

        event_text="$(
            printf '%s\n' "$json" |
                jq -r '
                    [
                        .data.win.eventdata.image,
                        .data.win.eventdata.commandLine,
                        .data.win.eventdata.targetFilename,
                        .rule.description
                    ]
                    | map(select(. != null))
                    | join(" ")
                '
        )"

        if printf '%s\n' "$event_text" |
            grep -Eiq \
            'copy-item|copy-item|robocopy|xcopy|copy .*\\\\|targetFilename.*Temp'; then

            local timestamp
            local source
            local target
            local command

            timestamp="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .timestamp //
                        .data.win.eventdata.utcTime //
                        ""
                    '
            )"

            source="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.source_host //
                        .agent.name //
                        .data.win.system.computer //
                        ""
                    '
            )"

            target="$(
                printf '%s\n' "$json" |
                    jq -r '
                        .hunt_meta.target_host //
                        .data.win.eventdata.destinationHostname //
                        ""
                    '
            )"

            command="$(
                printf '%s\n' "$json" |
                    jq -r '.data.win.eventdata.commandLine // ""'
            )"

            add_event \
                "$timestamp" \
                "STAGING" \
                "$source" \
                "File staging/copy activity: $command" \
                "" \
                "$target" \
                "File Staging"

        fi

    done < "$file"
}

process_staging "$ALERTS"
process_staging "$SYSMON"

# ================================================================
# 8. REMOVE DUPLICATES
# ================================================================

sort -u "$TIMELINE" -o "$TIMELINE"

# ================================================================
# 9. DETERMINE BASIC ATTACK FACTS
# ================================================================

# Pivot host:
# Prefer a workstation that appears in suspicious activity.

PIVOT_HOST="$(
    awk -F '\t' '
        $3 ~ /^WS-|^ws-/ {
            print $3
        }
    ' "$TIMELINE" |
        sort |
        uniq -c |
        sort -nr |
        awk 'NR == 1 {print $2}'
)"

# If no WS-* host found, use the most common source.
if [ -z "$PIVOT_HOST" ]; then

    PIVOT_HOST="$(
        awk -F '\t' '
            $3 != "" {
                print $3
            }
        ' "$TIMELINE" |
            sort |
            uniq -c |
            sort -nr |
            awk 'NR == 1 {print $2}'
    )"

fi

# ================================================================
# 10. STOLEN / ABUSED ACCOUNT
# ================================================================

STOLEN_ACCOUNT="$(
    awk -F '\t' '
        $5 ~ /^svc_/ {
            print $5
        }
    ' "$TIMELINE" |
        sort |
        uniq -c |
        sort -nr |
        awk 'NR == 1 {print $2}'
)"

# ================================================================
# 11. TARGETS
# ================================================================

TARGETS="$(
    awk -F '\t' '
        $6 != "" {
            print $6
        }
    ' "$TIMELINE" |
        grep -E '^SRV-|^srv-' |
        sort -u |
        paste -sd ', ' -
)"

# ================================================================
# 12. TOOLS
# ================================================================

TOOLS="$(
    awk -F '\t' '
        $7 != "" {
            print $7
        }
    ' "$TIMELINE" |
        sort -u |
        paste -sd ', ' -
)"

# ================================================================
# 13. DWELL TIME
#
# Calculate:
#
# last observed suspicious event
# minus
# first observed suspicious event
# ================================================================

FIRST_TIMESTAMP="$(
    awk -F '\t' '
        $1 != "" {
            print $1
        }
    ' "$TIMELINE" |
        sort |
        head -n 1
)"

LAST_TIMESTAMP="$(
    awk -F '\t' '
        $1 != "" {
            print $1
        }
    ' "$TIMELINE" |
        sort |
        tail -n 1
)"

DWELL_TIME="Unavailable"

if [ -n "$FIRST_TIMESTAMP" ] &&
   [ -n "$LAST_TIMESTAMP" ]; then

    FIRST_EPOCH="$(date -d "$FIRST_TIMESTAMP" +%s 2>/dev/null || true)"
    LAST_EPOCH="$(date -d "$LAST_TIMESTAMP" +%s 2>/dev/null || true)"

    if [ -n "$FIRST_EPOCH" ] &&
       [ -n "$LAST_EPOCH" ]; then

        if [ "$LAST_EPOCH" -ge "$FIRST_EPOCH" ]; then

            DIFF=$((LAST_EPOCH - FIRST_EPOCH))

            DAYS=$((DIFF / 86400))
            HOURS=$(((DIFF % 86400) / 3600))
            MINUTES=$(((DIFF % 3600) / 60))

            DWELL_TIME="${DAYS}d ${HOURS}h ${MINUTES}m"

        fi

    fi

fi

# ================================================================
# 14. PRINT ATTACK TIMELINE
# ================================================================

echo "ATTACK TIMELINE:"

if [ ! -s "$TIMELINE" ]; then

    echo "  No qualifying Stage 4 correlation events were found."

else

    while IFS=$'\t' read -r \
        timestamp \
        phase \
        source \
        action \
        account \
        target \
        tool
    do

        echo "  [$phase]"

        if [ -n "$source" ] && [ -n "$target" ]; then
            echo "    $source -> $target: $action"
        elif [ -n "$source" ]; then
            echo "    $source: $action"
        else
            echo "    $action"
        fi

        if [ -n "$account" ]; then
            echo "    Account: $account"
        fi

        if [ -n "$tool" ]; then
            echo "    Tool: $tool"
        fi

        echo "    Time: $timestamp"
        echo

    done < "$TIMELINE"

fi

# ================================================================
# 15. ATTACK SUMMARY
# ================================================================

echo "ATTACK SUMMARY:"

if [ -n "$PIVOT_HOST" ]; then
    printf "  Pivot host:        %s\n" "$PIVOT_HOST"
else
    echo "  Pivot host:        Not established"
fi

if [ -n "$STOLEN_ACCOUNT" ]; then
    printf "  Credential used:   %s\n" "$STOLEN_ACCOUNT"
else
    echo "  Credential used:   Not established"
fi

if [ -n "$TARGETS" ]; then
    printf "  Targets:           %s\n" "$TARGETS"
else
    echo "  Targets:           Not established"
fi

if [ -n "$TOOLS" ]; then
    printf "  Tools used:        %s\n" "$TOOLS"
else
    echo "  Tools used:        Not established"
fi

printf "  Dwell time:        %s\n" "$DWELL_TIME"

echo

# ================================================================
# 16. CONFIDENCE ASSESSMENT
# ================================================================

CREDENTIAL_EVENTS="$(
    awk -F '\t' '$2 == "CREDENTIAL ACCESS" {count++}
        END {print count+0}' "$TIMELINE"
)"

LATERAL_EVENTS="$(
    awk -F '\t' '$2 == "LATERAL MOVEMENT" {count++}
        END {print count+0}' "$TIMELINE"
)"

RECON_EVENTS="$(
    awk -F '\t' '$2 == "RECONNAISSANCE" {count++}
        END {print count+0}' "$TIMELINE"
)"

STAGING_EVENTS="$(
    awk -F '\t' '$2 == "STAGING" {count++}
        END {print count+0}' "$TIMELINE"
)"

echo "ASSESSMENT:"

if [ "$CREDENTIAL_EVENTS" -gt 0 ] &&
   [ "$LATERAL_EVENTS" -gt 0 ] &&
   [ "$RECON_EVENTS" -gt 0 ] &&
   [ "$STAGING_EVENTS" -gt 0 ]; then

    echo "  Confidence: HIGH"
    echo
    echo "  HEALTHBANE Stage 4 was executed against MedDefense."
    echo "  The evidence shows a progression from credential access"
    echo "  through lateral movement, reconnaissance and staging."

elif [ "$CREDENTIAL_EVENTS" -gt 0 ] &&
     [ "$LATERAL_EVENTS" -gt 0 ]; then

    echo "  Confidence: HIGH"
    echo
    echo "  Evidence supports credential access followed by"
    echo "  lateral movement consistent with HEALTHBANE Stage 4."

elif [ "$CREDENTIAL_EVENTS" -gt 0 ] ||
     [ "$LATERAL_EVENTS" -gt 0 ]; then

    echo "  Confidence: MEDIUM"
    echo
    echo "  Suspicious Stage 4 activity was identified, but the"
    echo "  complete attack chain could not be established."

else

    echo "  Confidence: LOW / INSUFFICIENT"
    echo
    echo "  The available evidence did not establish a complete"
    echo "  HEALTHBANE Stage 4 attack chain."

fi

echo

# ================================================================
# 17. END
# ================================================================

echo "================================================================"
echo
