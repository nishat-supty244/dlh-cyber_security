#!/usr/bin/env bash
# MedDefense Task 7 — Recovery validation (read-only).
# Usage: API_BASE=http://127.0.0.1:8080 EVIDENCE_DIR=/evidence/IR-2026-0414-01 ./recovery_validation.sh
set -uo pipefail

API_BASE="${API_BASE:-http://127.0.0.1:8080}"
EVIDENCE_DIR="${EVIDENCE_DIR:-/evidence/IR-2026-0414-01}"
HOSTS=(WST-WS-031 WST-WS-017 LIS-WSIDE-01)
FAILED=()

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; FAILED+=("$1"); }
fetch() { curl --fail --silent --show-error --max-time 10 "${API_BASE%/}/$1"; }
valid_json() { jq -e '.status == "ok" and (.data | type == "object")' >/dev/null 2>&1; }

if ! command -v curl >/dev/null || ! command -v jq >/dev/null || ! command -v sha256sum >/dev/null; then
  fail 'prerequisites: curl, jq, and sha256sum must be installed'
  printf 'FAILED CHECKS: %s\n' "${FAILED[*]}"
  exit 1
fi

# 1. Suspicious process lineage on each host, within 24-hour data window.
process_ok=true
process_reason=''
for host in "${HOSTS[@]}"; do
  if ! response=$(fetch "endpoint/processtree/$host") || ! printf '%s' "$response" | valid_json; then
    process_ok=false; process_reason+="$host API unavailable/invalid; "; continue
  fi
  if ! printf '%s' "$response" | jq -e --arg h "$host" '
    .data.host == $h and .data.window_hours >= 24 and
    (.data.process_trees_matching.powershell_parent_msbuild_child | type == "number" and . == 0)
  ' >/dev/null; then
    process_ok=false; process_reason+="$host suspicious tree or missing 24h proof; "
  fi
done
if "$process_ok"; then
  pass 'process tree: no powershell->msbuild in last 24h across WST-WS-031, WST-WS-017, LIS-WSIDE-01'
else
  fail "process tree: $process_reason"
fi

# 2. Netflow must show zero traffic to both known C2 destinations.
if response=$(fetch 'siem/netflow') && printf '%s' "$response" | valid_json &&
  printf '%s' "$response" | jq -e '
    .data.window_hours >= 24 and
    (["185.220.101.47", "91.234.99.107"] - .data.egress_deny_verified | length == 0) and
    (.data.connections_to_185_220_101_47.packets == 0) and
    (.data.connections_to_185_220_101_47.bytes == 0) and
    (.data.connections_to_91_234_99_107.packets == 0) and
    (.data.connections_to_91_234_99_107.bytes == 0)
  ' >/dev/null; then
  pass 'netflow: no outbound to 185.220.101.47 or 91.234.99.107 in last 24h'
else
  fail 'netflow: C2 traffic detected, deny not verified, or 24h API evidence unavailable'
fi

# 3. Persistence: no GUID tasks, no Run entries, no payloads present.
persistence_ok=true
persistence_reason=''
for host in "${HOSTS[@]}"; do
  if ! response=$(fetch "endpoint/persistence/$host") || ! printf '%s' "$response" | valid_json; then
    persistence_ok=false; persistence_reason+="$host API unavailable/invalid; "; continue
  fi
  if ! printf '%s' "$response" | jq -e --arg h "$host" '
    .data.host == $h and
    (.data.scheduled_tasks_with_guid_names | type == "array" and length == 0) and
    (.data.run_keys | type == "object" and length > 0 and all(.[]; type == "array" and length == 0)) and
    (.data.temp_dropped_payloads | type == "object" and length > 0 and all(.[]; . == "absent" or . == false))
  ' >/dev/null; then
    persistence_ok=false; persistence_reason+="$host persistence found or fields missing; "
  fi
done
if "$persistence_ok"; then
  pass 'persistence: no GUID scheduled tasks, Run keys, or dropped payloads across affected hosts'
else
  fail "persistence: $persistence_reason"
fi

# 4. The mock server is HTTP on localhost; it represents the HTTPS clinical services.
services_ok=true
service_reason=''
for service in epic-api lis-api; do
  bodyfile=$(mktemp) || { services_ok=false; service_reason+='mktemp failed; '; continue; }
  http_code=$(curl --silent --show-error --max-time 10 --output "$bodyfile" --write-out '%{http_code}' "${API_BASE%/}/service/$service/health") || http_code='000'
  body=$(cat "$bodyfile"); rm -f "$bodyfile"
  if [[ "$http_code" != 200 || "$body" != OK ]]; then
    services_ok=false; service_reason+="$service HTTP=$http_code body=$body; "
  fi
done
if "$services_ok"; then
  pass 'service health: epic-api returns 200/OK; lis-api returns 200/OK (mock HTTP health endpoints)'
else
  fail "service health: $service_reason"
fi

# 5. Detection rule active AND synthetic test reports an actual expected hit.
# Read-only mock endpoint: the /synthetic resource is a fixture representing injection outcome.
if rule=$(fetch 'siem/detection/wz-edr-100041') && synthetic=$(fetch 'siem/detection/wz-edr-100041/synthetic') &&
  printf '%s' "$rule" | valid_json && printf '%s' "$synthetic" | valid_json &&
  printf '%s' "$rule" | jq -e '
    (.data.rule_id // .data.id // "wz-edr-100041") == "wz-edr-100041" and
    (.data.active == true or .data.enabled == true or .data.status == "active")
  ' >/dev/null &&
  printf '%s' "$synthetic" | jq -e '
    (.data.rule_id // .data.matched_rule_id // .data.detection_rule_id // "wz-edr-100041") == "wz-edr-100041" and
    (.data.hit == true or .data.detected == true or .data.alert_triggered == true or .data.matched == true or (.data.hits | type == "number" and . > 0) or (.data.hit_count | type == "number" and . > 0) or (.data.alerts | type == "array" and length > 0))
  ' >/dev/null; then
  pass 'detection: wz-edr-100041 active and synthetic test produced a hit'
else
  fail 'detection: rule inactive, synthetic hit missing, or API response invalid'
fi

# 6. Validate every original SHA-256 manifest entry against the local evidence files.
manifest="$EVIDENCE_DIR/hashes.txt"
if [[ ! -f "$manifest" ]]; then
  fail "evidence hashes: manifest missing ($manifest)"
else
  # Require at least one SHA-256 line; never count header comments as artifacts.
  count=$(grep -Ec '^[[:xdigit:]]{64} [ *].+' "$manifest" || true)
  if (( count == 0 )); then
    fail 'evidence hashes: manifest has no recorded SHA-256 artifacts'
  elif (cd "$EVIDENCE_DIR" && sha256sum --check --status hashes.txt); then
    pass "evidence hashes: $count/$count artifacts match original SHA-256"
  else
    fail "evidence hashes: one or more of $count artifacts missing, modified, or invalid in manifest"
  fi
fi

if (( ${#FAILED[@]} == 0 )); then
  printf 'ALL CHECKS PASSED\n'
  exit 0
fi
printf 'FAILED CHECKS (%d): ' "${#FAILED[@]}"
printf '%s' "${FAILED[0]}"
for ((i=1; i<${#FAILED[@]}; i++)); do printf '; %s' "${FAILED[i]}"; done
printf '\n'
exit 1
