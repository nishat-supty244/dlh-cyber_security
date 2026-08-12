#!/bin/bash

set -euo pipefail

CRITICALITY_FILE="service_criticality.json"
OUTPUT_FILE="service_dependency_map.json"

if [ ! -f "$CRITICALITY_FILE" ]; then
    echo '{}' > "$CRITICALITY_FILE"
fi

# Use a temporary file to collect JSON entries
TEMP_JSON=$(mktemp)
echo "[" > "$TEMP_JSON"
FIRST=1

# List every active systemd unit of type service using systemctl
while read -r service_name _; do
    [ -z "$service_name" ] && continue

    # Resolve executable path from unit file (ExecStart=) or MainPID
    EXEC_PATH=""
    MAIN_PID=""
    
    SHOW_OUTPUT=$(systemctl show "$service_name" -p ExecStart,MainPID --no-ambiguous 2>/dev/null || true)
    
    while IFS== read -r key val; do
        if [ "$key" = "MainPID" ]; then
            MAIN_PID="$val"
        elif [ "$key" = "ExecStart" ] && [ -z "$EXEC_PATH" ]; then
            if [[ "$val" =~ path=([^ ;]+) ]]; then
                EXEC_PATH="${BASH_REMATCH[1]}"
            else
                for token in $val; do
                    if [[ "$token" == /* ]]; then
                        EXEC_PATH="${token//[\"{}]/}"
                        break
                    fi
                done
            fi
        fi
    done <<< "$SHOW_OUTPUT"

    if { [ -z "$EXEC_PATH" ] || [ "$EXEC_PATH" = "/" ]; } && [ -n "$MAIN_PID" ] && [ "$MAIN_PID" -ne 0 ]; then
        if [ -e "/proc/$MAIN_PID/exe" ]; then
            EXEC_PATH=$(readlink -f "/proc/$MAIN_PID/exe" 2>/dev/null || true)
        fi
    fi

    [ -z "$EXEC_PATH" ] && continue

    # Resolve owning package via dpkg -S
    OWNING_PKG="unknown"
    DPKG_OUT=$(dpkg -S "$EXEC_PATH" 2>/dev/null || true)
    if [ -n "$DPKG_OUT" ]; then
        OWNING_PKG=$(echo "$DPKG_OUT" | head -n1 | cut -d':' -f1 | tr -d ' ')
    fi

    # Resolve dynamic libraries with ldd and dpkg -S
    LINKED_PKGS=()
    if [ "$OWNING_PKG" != "unknown" ]; then
        LINKED_PKGS+=("$OWNING_PKG")
    fi

    if [ -x "$EXEC_PATH" ]; then
        LDD_OUT=$(ldd "$EXEC_PATH" 2>/dev/null || true)
        while IFS= read -r ldd_line; do
            if [[ "$ldd_line" =~ \=\>\s+([^\s]+) ]]; then
                lib_path="${BASH_REMATCH[1]}"
                if [[ "$lib_path" == /* ]]; then
                    lib_pkg=$(dpkg -S "$lib_path" 2>/dev/null | head -n1 | cut -d':' -f1 | tr -d ' ' || true)
                    if [ -n "$lib_pkg" ]; then
                        LINKED_PKGS+=("$lib_pkg")
                    fi
                fi
            fi
        done <<< "$LDD_OUT"
    fi

    # Deduplicate linked packages
    read -r -a LINKED_PKGS <<< "$(printf "%s\n" "${LINKED_PKGS[@]}" | sort -u | tr '\n' ' ')"

    # Read criticality from service_criticality.json using jq
    CRITICALITY=$(jq -r --arg s "$service_name" '(.services[$s].criticality // .[$s].criticality // .[$s] // "low")' "$CRITICALITY_FILE" 2>/dev/null || echo "low")
    if [[ ! "$CRITICALITY" =~ ^(critical|high|medium|low)$ ]]; then
        CRITICALITY="low"
    fi

    RESTART_REQ=$(jq -r --arg s "$service_name" '(.services[$s].restart_required_on_patch // .[$s].restart_required_on_patch // true)' "$CRITICALITY_FILE" 2>/dev/null || echo "true")
    if [ "$RESTART_REQ" != "false" ]; then
        RESTART_REQ="true"
    else
        RESTART_REQ="false"
    fi

    # Format linked packages as JSON array using jq
    LINKED_JSON=$(printf '%s\n' "${LINKED_PKGS[@]}" | jq -R . | jq -s .)

    if [ $FIRST -eq 0 ]; then
        echo "," >> "$TEMP_JSON"
    fi
    FIRST=0

    # Append service entry via jq to guarantee safe formatting
    jq -n \
        --arg svc "$service_name" \
        --arg exec "$EXEC_PATH" \
        --arg pkg "$OWNING_PKG" \
        --argjson linked "$LINKED_JSON" \
        --arg crit "$CRITICALITY" \
        --argjson restart "$RESTART_REQ" \
        '{service: $svc, exec_path: $exec, owning_package: $pkg, linked_packages: $linked, criticality: $crit, restart_required_on_patch: $restart}' >> "$TEMP_JSON"

done < <(systemctl list-units --type=service --state=active --no-legend)

echo "]" >> "$TEMP_JSON"

# Final validation and formatting with jq into OUTPUT_FILE
jq '.' "$TEMP_JSON" > "$OUTPUT_FILE"
rm -f "$TEMP_JSON"

echo "Service dependency map successfully written to $OUTPUT_FILE"
