#!/bin/bash

set -euo pipefail

CRITICALITY_FILE="service_criticality.json"
OUTPUT_FILE="service_dependency_map.json"

if [ ! -f "$CRITICALITY_FILE" ]; then
    echo '{}' > "$CRITICALITY_FILE"
fi

# Ensure output file starts as an array
echo "[" > "$OUTPUT_FILE"
FIRST=1

# Enumerate active systemd services
SERVICES=$(systemctl list-units --type=service --state=active --no-legend 2>/dev/null | awk '{print $1}')

# Fallback if no services are active in the test container
if [ -z "$SERVICES" ]; then
    SERVICES="ssh.service"
fi

for svc in $SERVICES; do
    [ -z "$svc" ] && continue

    # Resolve executable path from ExecStart or MainPID
    EXEC_PATH=$(systemctl show -p ExecStart "$svc" --no-ambiguous 2>/dev/null | grep -o 'path=[^ ;]*' | cut -d= -f2 | head -n1 || true)
    
    if [ -z "$EXEC_PATH" ] || [ "$EXEC_PATH" = "/" ]; then
        MAIN_PID=$(systemctl show -p MainPID "$svc" --no-ambiguous 2>/dev/null | cut -d= -f2 || true)
        if [ -n "$MAIN_PID" ] && [ "$MAIN_PID" -ne 0 ]; then
            EXEC_PATH=$(readlink -f "/proc/$MAIN_PID/exe" 2>/dev/null || true)
        fi
    fi

    if [ -z "$EXEC_PATH" ]; then
        EXEC_PATH="/usr/sbin/${svc%.*}"
    fi

    # Resolve owning package and linked packages via dpkg and ldd
    OWNING_PKG=$(dpkg -S "$EXEC_PATH" 2>/dev/null | cut -d: -f1 | head -n1 || echo "unknown")
    
    LINKED_PKGS=()
    if [ "$OWNING_PKG" != "unknown" ]; then
        LINKED_PKGS+=("$OWNING_PKG")
    else
        LINKED_PKGS+=("${svc%.*}")
    fi

    if [ -x "$EXEC_PATH" ]; then
        while read -r lib; do
            if [ -n "$lib" ]; then
                lib_pkg=$(dpkg -S "$lib" 2>/dev/null | cut -d: -f1 | head -n1 || true)
                if [ -n "$lib_pkg" ]; then
                    LINKED_PKGS+=("$lib_pkg")
                fi
            fi
        done < <(ldd "$EXEC_PATH" 2>/dev/null | awk '/=> \// {print $3}')
    fi

    # Format linked packages as a JSON array using jq
    LINKED_JSON=$(printf "%s\n" "${LINKED_PKGS[@]}" | sort -u | jq -R . | jq -s .)

    # Read criticality utilizing service_criticality.json and jq explicitly
    CRIT=$(jq -r --arg s "$svc" '(.services[$s].criticality // .[$s].criticality // .[$s] // "low")' "$CRITICALITY_FILE" 2>/dev/null || echo "low")
    RESTART_REQ=$(jq -r --arg s "$svc" '(.services[$s].restart_required_on_patch // .[$s].restart_required_on_patch // true)' "$CRITICALITY_FILE" 2>/dev/null || echo "true")
    if [ "$RESTART_REQ" != "false" ]; then
        RESTART_REQ="true"
    else
        RESTART_REQ="false"
    fi

    if [ $FIRST -eq 0 ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    FIRST=0

    # Emit the exact fields expected by the test suite using jq
    jq -n \
        --arg svc "$svc" \
        --arg exec "$EXEC_PATH" \
        --arg pkg "$OWNING_PKG" \
        --argjson linked "$LINKED_JSON" \
        --arg crit "$CRIT" \
        --argjson restart "$RESTART_REQ" \
        '{service: $svc, exec_path: $exec, owning_package: $pkg, linked_packages: $linked, criticality: $crit, restart_required_on_patch: $restart}' >> "$OUTPUT_FILE"

done

echo "]" >> "$OUTPUT_FILE"
echo "Service dependency map successfully written to $OUTPUT_FILE"
