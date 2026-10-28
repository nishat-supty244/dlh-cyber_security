
#!/usr/bin/env bash

# MedDefense - Task 7 Recovery Validation
# Incident: IR-2026-0420-01
#
# Read-only validation.
# No host modifications are performed.
# Missing or incomplete evidence causes failure.
#
# Required evidence files:
# recovery_evidence/coverage.json
# recovery_evidence/process_events.jsonl
# recovery_evidence/network_events.jsonl
# recovery_evidence/file_inventory.jsonl
# recovery_evidence/services.json
# recovery_evidence/edr.json
# recovery_evidence/detection.json
# evidence_hashes.sha256
#
# Required JSON contracts are documented below.

set -uo pipefail

EVIDENCE_DIR="${EVIDENCE_DIR:-recovery_evidence}"
HASH_MANIFEST="${HASH_MANIFEST:-evidence_hashes.sha256}"
REQUIRED_HASH_COUNT=11

HOSTS=(
  CS-WS-101
  CS-WS-104
  CS-WS-107
  CS-WS-112
  FILE-SVR-01
)

C2_DOMAIN="staging.office365-cdn.net"
C2_IP="45.152.66.114"

FAILURES=0

pass() {
  echo "[PASS] $1"
}

fail() {
  echo "[FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

need_file() {
  local path="$1"
  local label="$2"

  if [[ ! -s "$path" ]]; then
    fail "$label: missing or empty $path"
    return 1
  fi

  return 0
}

valid_json() {
  jq -e . "$1" >/dev/null 2>&1
}

valid_jsonl() {
  jq -e . "$1" >/dev/null 2>&1
}

echo "========================================"
echo "MedDefense Recovery Validation"
echo "Incident: IR-2026-0420-01"
echo "========================================"

if ! command -v jq >/dev/null 2>&1; then
  echo "[FAIL] jq is not installed"
  exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "[FAIL] sha256sum is unavailable"
  exit 1
fi

NOW=$(date -u +%s)
WINDOW_START=$((NOW - 86400))
EDR_CUTOFF=$((NOW - 300))

# ----------------------------------------
# 1. Validate monitoring coverage
# ----------------------------------------

COVERAGE_OK=0

if need_file "$EVIDENCE_DIR/coverage.json" "coverage"; then
  if valid_json "$EVIDENCE_DIR/coverage.json"; then

    COVERAGE_OK=1

    for host in "${HOSTS[@]}"; do
      if ! jq -e \
        --arg host "$host" \
        --argjson start "$WINDOW_START" \
        --argjson now "$NOW" '
          .hosts[$host] as $h
          | ($h != null)
            and ($h.processes.complete == true)
            and ($h.network.complete == true)
            and ($h.files.complete == true)
            and ($h.processes.start_epoch <= $start)
            and ($h.network.start_epoch <= $start)
            and ($h.files.start_epoch <= $start)
            and ($h.processes.end_epoch >= $now - 300)
            and ($h.network.end_epoch >= $now - 300)
            and ($h.files.end_epoch >= $now - 300)
        ' "$EVIDENCE_DIR/coverage.json" >/dev/null 2>&1; then

        fail "coverage: incomplete 24h telemetry for $host"
        COVERAGE_OK=0
      fi
    done

    if [[ "$COVERAGE_OK" -eq 1 ]]; then
      pass "coverage: all five hosts have complete 24h telemetry"
    fi

  else
    fail "coverage: invalid JSON"
  fi
fi

# ----------------------------------------
# 2. Beacon process history
# ----------------------------------------

PROCESS_FILE="$EVIDENCE_DIR/process_events.jsonl"

if need_file "$PROCESS_FILE" "beacon"; then
  if valid_jsonl "$PROCESS_FILE" && [[ "$COVERAGE_OK" -eq 1 ]]; then

    if jq -e \
      --argjson start "$WINDOW_START" \
      --argjson now "$NOW" '
        select(.ts_epoch >= $start and .ts_epoch <= $now)
        | select(
            (.image // "" | ascii_downcase |
              contains("svchost32.exe"))
            or
            (.parent_image // "" | ascii_downcase |
              contains("svchost32.exe"))
            or
            (.cmdline // "" | ascii_downcase |
              contains("winhealthsvc"))
          )
      ' "$PROCESS_FILE" >/dev/null; then

      fail "beacon: malicious process activity detected"
    else
      pass "beacon: no known malicious process tree in 24h"
    fi

  else
    fail "beacon: invalid or incomplete process evidence"
  fi
fi

# ----------------------------------------
# 3. C2 network connections
# ----------------------------------------

NETWORK_FILE="$EVIDENCE_DIR/network_events.jsonl"

if need_file "$NETWORK_FILE" "c2"; then
  if valid_jsonl "$NETWORK_FILE" && [[ "$COVERAGE_OK" -eq 1 ]]; then

    if jq -e \
      --arg ip "$C2_IP" \
      --arg domain "$C2_DOMAIN" \
      --argjson start "$WINDOW_START" \
      --argjson now "$NOW" '
        select(.ts_epoch >= $start and .ts_epoch <= $now)
        | select(
            .dst_ip == $ip
            or ((.dst_hostname // "" | ascii_downcase) == $domain)
            or ((.url // "" | ascii_downcase) |
              contains($domain))
          )
        | select(.action == "allow" or .status == 200)
      ' "$NETWORK_FILE" >/dev/null; then

      fail "c2: successful connection to known C2 detected"
    else
      pass "c2: no successful known C2 connections in 24h"
    fi

  else
    fail "c2: invalid or incomplete network evidence"
  fi
fi

# ----------------------------------------
# 4. Ransomware staging files
# ----------------------------------------

FILE_INVENTORY="$EVIDENCE_DIR/file_inventory.jsonl"

if need_file "$FILE_INVENTORY" "ransomware staging"; then
  if valid_jsonl "$FILE_INVENTORY" && [[ "$COVERAGE_OK" -eq 1 ]]; then

    if jq -e '
      select(.exists == true)
      | select(
          (.path // "" | ascii_downcase |
            contains("encryption_staging.ps1"))
          or
          (
            (.malicious == true)
            and
            (
              (.path // "" | ascii_downcase |
                contains("system32"))
              or
              (.path // "" | ascii_downcase |
                contains("programdata"))
            )
          )
        )
    ' "$FILE_INVENTORY" >/dev/null; then

      fail "ransomware staging: malicious files still present"
    else
      pass "ransomware staging: no known staged payloads present"
    fi

  else
    fail "ransomware staging: invalid or incomplete file inventory"
  fi
fi

# ----------------------------------------
# 5. Clinical service endpoints
# ----------------------------------------

SERVICES_FILE="$EVIDENCE_DIR/services.json"

if need_file "$SERVICES_FILE" "services"; then
  if valid_json "$SERVICES_FILE"; then

    SERVICES_OK=1

    for service in epic-api lis-api scheduling-api; do
      if ! jq -e \
        --arg service "$service" \
        --argjson cutoff "$EDR_CUTOFF" '
          .services[$service].http_status == 200
          and .services[$service].checked_at_epoch >= $cutoff
          and .services[$service].checked_at_epoch <= now
        ' "$SERVICES_FILE" >/dev/null 2>&1; then

        fail "services: $service not verified healthy"
        SERVICES_OK=0
      fi
    done

    if [[ "$SERVICES_OK" -eq 1 ]]; then
      pass "services: all three clinical endpoints return HTTP 200"
    fi

  else
    fail "services: invalid JSON"
  fi
fi

# ----------------------------------------
# 6. EDR agent status
# ----------------------------------------

EDR_FILE="$EVIDENCE_DIR/edr.json"

if need_file "$EDR_FILE" "edr"; then
  if valid_json "$EDR_FILE"; then

    EDR_OK=1

    for host in "${HOSTS[@]}"; do
      if ! jq -e \
        --arg host "$host" \
        --argjson cutoff "$EDR_CUTOFF" \
        --argjson now "$NOW" '
          .hosts[$host].healthy == true
          and .hosts[$host].last_seen_epoch >= $cutoff
          and .hosts[$host].last_seen_epoch <= $now
        ' "$EDR_FILE" >/dev/null 2>&1; then

        fail "edr: $host not reporting within five minutes"
        EDR_OK=0
      fi
    done

    if [[ "$EDR_OK" -eq 1 ]]; then
      pass "edr: all five hosts reporting"
    fi

  else
    fail "edr: invalid JSON"
  fi
fi

# ----------------------------------------
# 7. Sigma rule and synthetic test
# ----------------------------------------

DETECTION_FILE="$EVIDENCE_DIR/detection.json"

if need_file "$DETECTION_FILE" "detection"; then
  if valid_json "$DETECTION_FILE"; then

    if jq -e \
      --argjson cutoff "$EDR_CUTOFF" \
      --argjson now "$NOW" '
        .rule_name == "sigma_cobalt_strike_beacon.yml"
        and .active == true
        and .synthetic_test.detected == true
        and .synthetic_test.tested_at_epoch >= $cutoff
        and .synthetic_test.tested_at_epoch <= $now
      ' "$DETECTION_FILE" >/dev/null 2>&1; then

      pass "detection: Sigma rule active and synthetic test detected"
    else
      fail "detection: rule or synthetic test not verified"
    fi

  else
    fail "detection: invalid JSON"
  fi
fi

# ----------------------------------------
# 8. Evidence hash verification
# ----------------------------------------

if need_file "$HASH_MANIFEST" "evidence hashes"; then

  HASH_COUNT=$(
    grep -Ec '^[[:xdigit:]]{64}[[:space:]]+' \
      "$HASH_MANIFEST" || true
  )

  if [[ "$HASH_COUNT" -ne "$REQUIRED_HASH_COUNT" ]]; then
    fail "evidence hashes: expected 11 entries, found $HASH_COUNT"

  elif sha256sum -c --status "$HASH_MANIFEST"; then
    pass "evidence hashes: 11/11 match supplied manifest"
  else
    fail "evidence hashes: missing files or hash mismatch"
  fi

fi

# ----------------------------------------
# Final decision
# ----------------------------------------

echo
echo "========================================"

if [[ "$FAILURES" -eq 0 ]]; then
  echo "ALL CHECKS PASSED"
  echo "Recovery evidence checks completed successfully."
  echo "Final reconnection still requires IR and clinical approval."
  exit 0
else
  echo "RECOVERY VALIDATION FAILED"
  echo "Failed checks: $FAILURES"
  echo "DO NOT APPROVE RECONNECTION"
  exit 1
fi
