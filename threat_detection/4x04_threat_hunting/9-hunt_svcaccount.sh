#!/bin/bash

# ================================================================
# HUNT EXECUTION - H5: Service Account Abuse
# Technique: T1078.002 Domain Accounts
#
# Goal:
#   Cross-reference service account authentication events against
#   the authorized usage matrix and identify unauthorized use,
#   especially interactive use from workstation endpoints.
#
# SIEM format:
#   JSONL - one JSON object per line.
#
# Source files are read-only and are never modified.
# ================================================================

set -u
set -o pipefail

BASE_DIR="."
REFERENCE_DIR="$BASE_DIR/reference"
SIEM_DIR="$BASE_DIR/siem_export"

SERVICE_FILE="$REFERENCE_DIR/service_accounts.txt"
ALERTS="$SIEM_DIR/wazuh_alerts_14d.json"
SYSMON="$SIEM_DIR/wazuh_raw_sysmon_14d.json"

TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

MATRIX="$TMP_DIR/service_matrix.tsv"
ACCOUNTS="$TMP_DIR/service_accounts.txt"
AUTH_EVENTS="$TMP_DIR/auth_events.tsv"
UNAUTHORIZED="$TMP_DIR/unauthorized.tsv"
LATERAL="$TMP_DIR/lateral.tsv"
CORRELATED="$TMP_DIR/correlated.tsv"

touch "$MATRIX"
touch "$AUTH_EVENTS"
touch "$UNAUTHORIZED"
touch "$LATERAL"
touch "$CORRELATED"

# ================================================================
# FUNCTIONS
# ================================================================

die() {
    echo "[ERROR] $1" >&2
    exit 1
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || die "$1 is required but not installed."
}

check_file() {
    [ -f "$1" ] || die "Required file not found: $1"
}

# ---------------------------------------------------------------
# Validate JSONL correctly.
#
# IMPORTANT:
# The SIEM files are JSONL, not one large JSON document.
# Each line is checked separately.
# ---------------------------------------------------------------

validate_jsonl() {

    local file="$1"
    local line_number=0
    local line

    while IFS= read -r line || [ -n "$line" ]; do

        line_number=$((line_number + 1))

        # Ignore empty lines.
        [ -z "$line" ] && continue

        if ! printf '%s\n' "$line" | jq -e '.' >/dev/null 2>&1; then
            die "Invalid JSON on line $line_number of: $file"
        fi

    done < "$file"
}

# ---------------------------------------------------------------
# Convert a string to lowercase.
# ---------------------------------------------------------------

lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# ---------------------------------------------------------------
# Get an account name without domain.
#
# MEDDEFENSE\svc_healthsync
# becomes:
# svc_healthsync
# ---------------------------------------------------------------

normalize_account() {

    local account="$1"

    account="${account##*\\}"
    account="${account##*/}"

    lower "$account"
}

# ================================================================
# REQUIREMENTS
# ================================================================

check_command jq
check_command awk
check_command grep
check_command sort

check_file "$SERVICE_FILE"
check_file "$ALERTS"
check_file "$SYSMON"

# ================================================================
# JSONL VALIDATION
# ================================================================

validate_jsonl "$ALERTS"
validate_jsonl "$SYSMON"

# ================================================================
# HEADER
# ================================================================

echo
echo "================================================================"
echo "   HUNT EXECUTION - H5: Service Account Abuse"
echo "   Technique: T1078.002 Domain Accounts"
echo "================================================================"
echo

# ================================================================
# 1. LOAD SERVICE ACCOUNT AUTHORIZATION MATRIX
# ================================================================

echo "SERVICE ACCOUNT AUTHORIZATION MATRIX:"
echo

# ----------------------------------------------------------------
# Extract service accounts from service_accounts.txt.
#
# We specifically look for names beginning with svc_.
# ----------------------------------------------------------------

grep -Eio 'svc_[a-zA-Z0-9_.-]+' "$SERVICE_FILE" |
    lower |
    sort -u > "$ACCOUNTS"

# If nothing was found, fail clearly.
if [ ! -s "$ACCOUNTS" ]; then
    die "No service accounts beginning with 'svc_' were found in $SERVICE_FILE"
fi

# ----------------------------------------------------------------
# Build account -> authorized host mapping.
#
# The parser looks at each line containing a service account and
# extracts SRV-* hostnames from that same line.
# ----------------------------------------------------------------

while IFS= read -r account; do

    while IFS= read -r line; do

        # Does this line contain this service account?
        if ! printf '%s\n' "$line" | grep -Eiq "(^|[^a-zA-Z0-9_])${account}([^a-zA-Z0-9_]|$)"; then
            continue
        fi

        # Extract every SRV-* hostname from this line.
        printf '%s\n' "$line" |
            grep -Eio 'SRV-[A-Za-z0-9_.-]+' |
            lower |
            sort -u |
            while IFS= read -r host; do

                [ -n "$host" ] || continue

                printf '%s\t%s\n' "$account" "$host" >> "$MATRIX"

            done

    done < "$SERVICE_FILE"

done < "$ACCOUNTS"

sort -u "$MATRIX" -o "$MATRIX"

# ----------------------------------------------------------------
# Display matrix.
# ----------------------------------------------------------------

while IFS= read -r account; do

    hosts="$(
        awk -F '\t' -v a="$account" '
            $1 == a {
                if (result != "") {
                    result = result ", "
                }
                result = result $2
            }
            END {
                print result
            }
        ' "$MATRIX"
    )"

    if [ -n "$hosts" ]; then
        printf "  %-18s Authorized on %s only\n" "$account" "$hosts"
    else
        printf "  %-18s [WARNING] No authorized host parsed\n" "$account"
    fi

done < "$ACCOUNTS"

echo

# ================================================================
# 2. EXTRACT AUTHENTICATION EVENTS
# ================================================================

echo "AUTHENTICATION AUDIT:"
echo

# ---------------------------------------------------------------
# Function to process one JSONL file.
#
# Event ID 4624 = successful Windows logon.
# ---------------------------------------------------------------

process_auth_file() {

    local file="$1"
    local json

    while IFS= read -r json || [ -n "$json" ]; do

        [ -n "$json" ] || continue

        # -------------------------------------------------------
        # Event ID
        # -------------------------------------------------------

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

        # -------------------------------------------------------
        # Account
        # -------------------------------------------------------

        local raw_account
        local account

        raw_account="$(
            printf '%s\n' "$json" |
                jq -r '.data.win.eventdata.targetUserName // ""'
        )"

        [ -n "$raw_account" ] || continue

        account="$(normalize_account "$raw_account")"

        # Only service accounts.
        if ! grep -Fxqi "$account" "$ACCOUNTS"; then
            continue
        fi

        # -------------------------------------------------------
        # Timestamp
        # -------------------------------------------------------

        local timestamp

        timestamp="$(
            printf '%s\n' "$json" |
                jq -r '
                    .timestamp //
                    .data.win.eventdata.utcTime //
                    ""
                '
        )"

        # -------------------------------------------------------
        # Source workstation
        # -------------------------------------------------------

        local source_host

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

        # -------------------------------------------------------
        # Source IP
        # -------------------------------------------------------

        local source_ip

        source_ip="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.eventdata.ipAddress //
                    .agent.ip //
                    ""
                '
        )"

        # -------------------------------------------------------
        # Destination computer
        # -------------------------------------------------------

        local destination

        destination="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.system.computer //
                    .data.win.eventdata.computer //
                    .agent.name //
                    ""
                '
        )"

        # -------------------------------------------------------
        # Logon type
        # -------------------------------------------------------

        local logon_type

        logon_type="$(
            printf '%s\n' "$json" |
                jq -r '.data.win.eventdata.logonType // ""'
        )"

        # -------------------------------------------------------
        # Authentication package
        # -------------------------------------------------------

        local auth_package

        auth_package="$(
            printf '%s\n' "$json" |
                jq -r '
                    .data.win.eventdata.authenticationPackageName //
                    .data.win.eventdata.authPackageName //
                    ""
                '
        )"

        # -------------------------------------------------------
        # Authorized host list
        # -------------------------------------------------------

        local authorized_hosts

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
            ' "$MATRIX"
        )"

        # -------------------------------------------------------
        # Classification
        # -------------------------------------------------------

        local status="AUTHORIZED"
        local flags=""

        local source_lower
        source_lower="$(lower "$source_host")"

        # -------------------------------------------------------
        # Check source host.
        # -------------------------------------------------------

        if [ -n "$authorized_hosts" ]; then

            local host_match="false"
            local allowed_host

            IFS=',' read -r -a allowed_array <<< "$authorized_hosts"

            for allowed_host in "${allowed_array[@]}"; do

                if [ "$source_lower" = "$allowed_host" ]; then
                    host_match="true"
                    break
                fi

            done

            if [ "$host_match" != "true" ]; then
                status="UNAUTHORIZED"
                flags="${flags}WRONG_SOURCE_HOST,"
            fi

        else

            # No matrix entry means we cannot prove authorization.
            status="UNAUTHORIZED"
            flags="${flags}NO_AUTHORIZATION_ENTRY,"
        fi

        # -------------------------------------------------------
        # Check workstation source.
        #
        # Examples:
        #   WS-RECV-03
        #   WS-NURSE-04
        # -------------------------------------------------------

        if printf '%s\n' "$source_host" |
            grep -Eiq '(^|[-_])(WS|WKSTN|WORKSTATION)([-_]|$)'; then

            status="UNAUTHORIZED"
            flags="${flags}WORKSTATION_SOURCE,"
        fi

        # -------------------------------------------------------
        # Check interactive logon.
        #
        # 2  = Interactive
        # 10 = RemoteInteractive / RDP
        # 11 = CachedInteractive
        # -------------------------------------------------------

        case "$logon_type" in

            2)
                status="UNAUTHORIZED"
                flags="${flags}INTERACTIVE_LOGON,"
                ;;

            10)
                status="UNAUTHORIZED"
                flags="${flags}REMOTE_INTERACTIVE_LOGON,"
                ;;

            11)
                status="UNAUTHORIZED"
                flags="${flags}CACHED_INTERACTIVE_LOGON,"
                ;;

        esac

        # -------------------------------------------------------
        # Check NTLM.
        # -------------------------------------------------------

        if printf '%s\n' "$auth_package" |
            grep -Eiq '^NTLM|NTLM'; then

            flags="${flags}NTLM,"
        fi

        # Remove trailing comma.
        flags="${flags%,}"

        # -------------------------------------------------------
        # Store event.
        #
        # account
        # timestamp
        # source_host
        # source_ip
        # destination
        # logon_type
        # auth_package
        # status
        # flags
        # -------------------------------------------------------

        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$account" \
            "$timestamp" \
            "$source_host" \
            "$source_ip" \
            "$destination" \
            "$logon_type" \
            "$auth_package" \
            "$status" \
            "$flags" \
            >> "$AUTH_EVENTS"

    done < "$file"
}

# Process both SIEM sources.
process_auth_file "$ALERTS"
process_auth_file "$SYSMON"

# Remove duplicate events.
sort -u "$AUTH_EVENTS" -o "$AUTH_EVENTS"

# ================================================================
# 3. DISPLAY AUTHENTICATION RESULTS
# ================================================================

while IFS= read -r account; do

    [ -n "$account" ] || continue

    total="$(
        awk -F '\t' -v a="$account" '
            $1 == a {count++}
            END {print count+0}
        ' "$AUTH_EVENTS"
    )"

    authorized="$(
        awk -F '\t' -v a="$account" '
            $1 == a && $8 == "AUTHORIZED" {count++}
            END {print count+0}
        ' "$AUTH_EVENTS"
    )"

    unauthorized="$(
        awk -F '\t' -v a="$account" '
            $1 == a && $8 == "UNAUTHORIZED" {count++}
            END {print count+0}
        ' "$AUTH_EVENTS"
    )"

    echo "  $account:"
    echo "    Total auth events: $total"
    echo "    Authorized: $authorized"
    echo "    UNAUTHORIZED: $unauthorized"

    if [ "$unauthorized" -gt 0 ]; then

        awk -F '\t' -v a="$account" '
            $1 == a && $8 == "UNAUTHORIZED" {

                printf "      [%s] %s",
                    $2,
                    $3

                if ($5 != "") {
                    printf " -> %s", $5
                }

                if ($9 != "") {
                    printf " [%s]", $9
                }

                printf "\n"
            }
        ' "$AUTH_EVENTS"

    fi

    echo

done < "$ACCOUNTS"

# ================================================================
# 4. SAVE UNAUTHORIZED EVENTS
# ================================================================

awk -F '\t' '$8 == "UNAUTHORIZED"' "$AUTH_EVENTS" |
    sort -u > "$UNAUTHORIZED"

# ================================================================
# 5. SEARCH FOR LATERAL MOVEMENT
# ================================================================

echo "LATERAL MOVEMENT CORRELATION:"
echo

# ---------------------------------------------------------------
# Process SIEM files looking for:
#
#   PsExec
#   WMI
#   WinRM
#   PowerShell Remoting
#
# Tool names alone are NOT treated as malicious.
# They are used for correlation with unauthorized service-account
# activity.
# ---------------------------------------------------------------

process_lateral_file() {

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
        # Search for lateral movement indicators.
        # -------------------------------------------------------

        if ! printf '%s\n' "$event_text" |
            grep -Eiq \
            'psexec|wmic|wmiprvse|winrm|winrs|enter-pssession|invoke-command|powershell.*-computername|powershell.*-session'; then
            continue
        fi

        local timestamp
        local source
        local tool
        local target

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
                    .data.win.eventdata.computer //
                    ""
                '
        )"

        tool="$(
            printf '%s\n' "$json" |
                jq -r '
                    .hunt_meta.tool //
                    .data.win.eventdata.image //
                    .rule.description //
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

        printf '%s\t%s\t%s\t%s\n' \
            "$timestamp" \
            "$source" \
            "$tool" \
            "$target" \
            >> "$LATERAL"

    done < "$file"
}

process_lateral_file "$ALERTS"
process_lateral_file "$SYSMON"

sort -u "$LATERAL" -o "$LATERAL"

# ================================================================
# 6. CORRELATE UNAUTHORIZED SERVICE ACCOUNT + LATERAL MOVEMENT
# ================================================================

while IFS=$'\t' read -r \
    account \
    auth_time \
    source_host \
    source_ip \
    destination \
    logon_type \
    auth_package \
    status \
    flags
do

    [ -n "$account" ] || continue

    while IFS=$'\t' read -r \
        lateral_time \
        lateral_source \
        lateral_tool \
        lateral_target
    do

        [ -n "$lateral_source" ] || continue

        # Same source host.
        if [ "$(lower "$source_host")" = "$(lower "$lateral_source")" ]; then

            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$account" \
                "$auth_time" \
                "$source_host" \
                "$destination" \
                "$lateral_time" \
                "$lateral_tool" \
                "$lateral_target" \
                >> "$CORRELATED"

        fi

    done < "$LATERAL"

done < "$UNAUTHORIZED"

sort -u "$CORRELATED" -o "$CORRELATED"

# ================================================================
# 7. DISPLAY CORRELATION
# ================================================================

if [ -s "$CORRELATED" ]; then

    while IFS=$'\t' read -r \
        account \
        auth_time \
        source \
        auth_destination \
        lateral_time \
        lateral_tool \
        lateral_target
    do

        echo "  [$account]"
        echo "    Authentication: $auth_time"
        echo "    Source:         $source"

        if [ -n "$auth_destination" ]; then
            echo "    Auth destination: $auth_destination"
        fi

        echo "    Lateral event:  $lateral_time"
        echo "    Tool/activity:  $lateral_tool"

        if [ -n "$lateral_target" ]; then
            echo "    Lateral target:  $lateral_target"
        fi

        echo

    done < "$CORRELATED"

else

    echo "  No same-source correlation found."
    echo

fi

# ================================================================
# 8. SUMMARY COUNTS
# ================================================================

TOTAL_AUTH="$(wc -l < "$AUTH_EVENTS" | tr -d ' ')"
TOTAL_UNAUTHORIZED="$(wc -l < "$UNAUTHORIZED" | tr -d ' ')"
TOTAL_LATERAL="$(wc -l < "$LATERAL" | tr -d ' ')"
TOTAL_CORRELATED="$(wc -l < "$CORRELATED" | tr -d ' ')"

echo "HUNT SUMMARY:"
echo "  Total service-account authentication events: $TOTAL_AUTH"
echo "  Unauthorized authentication events:         $TOTAL_UNAUTHORIZED"
echo "  Lateral movement events:                    $TOTAL_LATERAL"
echo "  Correlated events:                           $TOTAL_CORRELATED"
echo

# ================================================================
# 9. FINAL FINDING
# ================================================================

echo "FINDING:"

if [ "$TOTAL_UNAUTHORIZED" -gt 0 ] &&
   [ "$TOTAL_CORRELATED" -gt 0 ]; then

    echo "  Status: POSITIVE - CRITICAL CONFIDENCE"
    echo
    echo "  Unauthorized service-account authentication was detected"
    echo "  from a non-authorized source and correlated with lateral"
    echo "  movement activity."
    echo
    echo "  This strongly indicates possible service-account credential"
    echo "  abuse and lateral movement."

elif [ "$TOTAL_UNAUTHORIZED" -gt 0 ]; then

    echo "  Status: POSITIVE - HIGH CONFIDENCE"
    echo
    echo "  Unauthorized service-account authentication was detected."
    echo
    echo "  However, this script did not establish a same-source"
    echo "  correlation with lateral movement."

elif [ "$TOTAL_AUTH" -gt 0 ]; then

    echo "  Status: NO POSITIVE FINDING"
    echo
    echo "  Service-account authentication was observed, but all"
    echo "  observed usage matched the available authorization matrix."

else

    echo "  Status: NO SERVICE-ACCOUNT AUTHENTICATION EVENTS FOUND"
    echo
    echo "  No Event ID 4624 authentication events for the listed"
    echo "  service accounts were found in the available SIEM data."

fi

echo
echo "================================================================"
echo "   HUNT COMPLETE"
echo "================================================================"
echo
