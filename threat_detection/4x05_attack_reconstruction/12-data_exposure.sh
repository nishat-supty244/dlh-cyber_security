#!/bin/bash
#!/usr/bin/env bash
# Task 12: HEALTHBANE Data Exposure Assessment
# Produces an evidence-led report. Findings require analyst validation.

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$BASE_DIR/task12_output"
REPORT="$OUT_DIR/data_exposure_assessment.txt"
CSV="$OUT_DIR/host_exposure.csv"

mkdir -p "$OUT_DIR"

export BASE_DIR OUT_DIR REPORT CSV

python3 <<'PY'
import csv
import ipaddress
import json
import os
import re
from pathlib import Path

BASE = Path(os.environ["BASE_DIR"])
OUT = Path(os.environ["OUT_DIR"])
REPORT = Path(os.environ["REPORT"])
CSV_PATH = Path(os.environ["CSV"])

ASSET = BASE / "reference" / "meddefense_asset_inventory.txt"
TOPOLOGY = BASE / "reference" / "network_topology.txt"

# Search known project evidence locations; missing files are reported.
CANDIDATE_FILES = [
    ("T1 memory", BASE / "ir_evidence" / "memory_artifacts.txt"),
    ("T2 disk", BASE / "ir_evidence" / "disk_forensics_report.txt"),
    ("T3 firewall", BASE / "ir_evidence" / "firewall_sessions_ws_recv_03.json"),
    ("IR notes", BASE / "ir_evidence" / "ir_team_notes.txt"),
    ("T4 hunt", BASE / "previous_findings" / "4x04_hunting_report.txt"),
    ("T5 stages 1-2", BASE / "task5_output" / "stages_1_2_reconstruction.txt"),
    ("T5 stages 1-2", BASE / "task5_output" / "stage_1_2_reconstruction.txt"),
    ("T6 stage 3", BASE / "task6_output" / "stage_3_reconstruction.txt"),
    ("T7 stage 4", BASE / "task7_output" / "stage_4_reconstruction.txt"),
    ("T8 timeline", BASE / "task8_output" / "unified_timeline.txt"),
]

HOST_RE = re.compile(
    r"\b(?:WS|SRV|DC|DB|FILE|CLIN|BILLING|WEB|APP)[-_][A-Z0-9_-]+\b",
    re.I
)

def read_text(path):
    try:
        return path.read_text(errors="replace")
    except (OSError, IsADirectoryError):
        return ""

def say(line=""):
    print(line)
    with REPORT.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

def extract_hosts(text):
    return sorted({x.upper() for x in HOST_RE.findall(text)})

def is_internal_ip(value):
    try:
        ip = ipaddress.ip_address(str(value).strip())
        return (
            ip.is_private or ip.is_loopback or ip.is_link_local
        )
    except ValueError:
        return None

def load_json(path):
    try:
        return json.loads(path.read_text(errors="replace"))
    except (OSError, json.JSONDecodeError):
        return None

def flatten_dicts(obj):
    """Yield nested dictionaries from JSON arrays and objects."""
    if isinstance(obj, dict):
        yield obj
        for value in obj.values():
            yield from flatten_dicts(value)
    elif isinstance(obj, list):
        for value in obj:
            yield from flatten_dicts(value)

def first_value(d, aliases):
    lower = {str(k).lower(): v for k, v in d.items()}
    for alias in aliases:
        if alias in lower and lower[alias] not in (None, ""):
            return lower[alias]
    return None

def parse_bytes(value):
    if isinstance(value, (int, float)):
        return int(value)
    if isinstance(value, str):
        value = value.replace(",", "").strip()
        match = re.fullmatch(r"(\d+(?:\.\d+)?)\s*(B|KB|MB|GB)?", value, re.I)
        if match:
            amount = float(match.group(1))
            unit = (match.group(2) or "B").upper()
            multiplier = {"B": 1, "KB": 1000, "MB": 1000**2,
                          "GB": 1000**3}
            return int(amount * multiplier[unit])
    return None

def human_bytes(value):
    if value is None:
        return "unknown"
    units = ["B", "KB", "MB", "GB", "TB"]
    size = float(value)
    for unit in units:
        if size < 1000 or unit == units[-1]:
            return f"{size:.2f} {unit}"
        size /= 1000
    return f"{value} B"

# Load available evidence.
source_text = {}
missing = []
for label, path in CANDIDATE_FILES:
    if path.is_file():
        source_text.setdefault(label, []).append((path, read_text(path)))
    else:
        missing.append(str(path.relative_to(BASE)))

asset_text = read_text(ASSET)
topology_text = read_text(TOPOLOGY)
if not ASSET.is_file():
    missing.append(str(ASSET.relative_to(BASE)))

# Assemble a searchable corpus and source references.
corpus_parts = []
for label, entries in source_text.items():
    for path, content in entries:
        corpus_parts.append((label, path.name, content))
corpus = "\n".join(content for _, _, content in corpus_parts)

# Hosts in the asset inventory are the starting point.
asset_hosts = extract_hosts(asset_text)
known_hosts = set(asset_hosts)

# Also include hosts mentioned in lateral movement and IR evidence.
for label, filename, content in corpus_parts:
    if label in ("T2 disk", "T3 firewall", "IR notes", "T4 hunt",
                 "T7 stage 4", "T8 timeline"):
        known_hosts.update(extract_hosts(content))

# Data access and movement indicators.
confirmed_terms = re.compile(
    r"query_results\.csv|file accessed|database query|"
    r"query executed|records exported|file copied|"
    r"data collected|file created|archive created|"
    r"staging_export|accessed patient|patient records accessed",
    re.I
)
staging_terms = re.compile(
    r"staging_export|staged data|data staging|staging directory|"
    r"query_results\.csv|\.zip\b|\.7z\b|\.rar\b|Compress-Archive",
    re.I
)
movement_terms = re.compile(
    r"lateral movement|psexec|wmic|wmi|powershell remoting|"
    r"remote logon|remote service|svc_healthsync|"
    r"SRV-HEALTH-DB|SRV-INS-DB|SRV-FILE-01|SRV-DC-01",
    re.I
)

# Data sensitivity is a first-pass inventory description, not proof of access.
def host_profile(host, inventory):
    lines = [
        line.strip() for line in inventory.splitlines()
        if host.lower() in line.lower()
    ]
    detail = " | ".join(lines[:2]) if lines else "No matching inventory row found"

    h = host.upper()
    if "HEALTH-DB" in h or "PATIENT" in h or "CLIN" in h:
        data = "Patient health records / possible PHI"
        sensitivity = "CRITICAL"
    elif "INS-DB" in h or "BILLING" in h or "INSURANCE" in h:
        data = "Insurance / billing / financial data"
        sensitivity = "HIGH"
    elif "HR" in h or "PAYROLL" in h or "EMPLOYEE" in h:
        data = "Employee records"
        sensitivity = "HIGH"
    elif "DC" in h or "DOMAIN" in h:
        data = "Authentication / identity data"
        sensitivity = "HIGH"
    elif "FILE" in h:
        data = "Shared files; content needs validation"
        sensitivity = "MEDIUM"
    elif h.startswith("WS-"):
        data = "Local workstation data; user access may broaden scope"
        sensitivity = "Depends on user and files"
    else:
        data = "Review asset inventory for data type"
        sensitivity = "Unknown"
    return data, sensitivity, detail

def evidence_mentions_host(host):
    results = []
    for label, filename, content in corpus_parts:
        if re.search(r"\b" + re.escape(host) + r"\b", content, re.I):
            snippets = []
            for line in content.splitlines():
                if re.search(r"\b" + re.escape(host) + r"\b", line, re.I):
                    if re.search(
                        r"access|query|file|copy|stage|archive|"
                        r"psexec|wmi|remote|logon|credential|"
                        r"database|record|contain|isolat",
                        line, re.I
                    ):
                        snippets.append(line.strip()[:240])
            results.append((label, filename, snippets[:3]))
    return results

def classify_host(host):
    ev = evidence_mentions_host(host)
    lines = [snippet for _, _, snippets in ev for snippet in snippets]
    combined = "\n".join(lines)
    mentioned_in_chain = bool(re.search(
        r"lateral movement|psexec|wmic|wmi|remote logon|"
        r"remote service|target|connected to|connection to",
        combined, re.I
    ))
    direct_data = bool(confirmed_terms.search(combined))

    if direct_data:
        level = "CONFIRMED ACCESS - VERIFY"
        basis = "Data-interaction indicator found in a host-related line; verify original artifact."
    elif mentioned_in_chain:
        level = "POTENTIAL ACCESS"
        basis = "Host-related movement or connection indicator found; direct data interaction not established."
    else:
        level = "NO EVIDENCE FOUND"
        basis = "No matching access indicator found in searched evidence; this does not prove no access occurred."

    refs = sorted({f"{label}:{filename}" for label, filename, _ in ev})
    return level, basis, refs, lines

# Check disk evidence for staging.
disk_entries = source_text.get("T2 disk", [])
disk_text = "\n".join(content for _, content in disk_entries)
staging_matches = []
for line in disk_text.splitlines():
    if staging_terms.search(line):
        staging_matches.append(line.strip()[:300])

staging_status = "UNKNOWN"
if staging_matches:
    staging_status = "INDICATED - VALIDATE ARTIFACT"
if re.search(r"(staging|archive).{0,80}(confirmed|created|identified)", disk_text, re.I):
    staging_status = "POTENTIALLY CONFIRMED - REVIEW DISK EVIDENCE"

# Analyze firewall records conservatively.
firewall_path = BASE / "ir_evidence" / "firewall_sessions_ws_recv_03.json"
firewall_data = load_json(firewall_path)
external_candidates = []
schema_notes = []
if firewall_data is None:
    schema_notes.append("Firewall JSON missing or could not be parsed.")
else:
    src_aliases = ["src", "src_ip", "source", "source_ip", "srcip",
                   "sourceip", "source_address", "src_addr"]
    dst_aliases = ["dst", "dst_ip", "destination", "destination_ip",
                   "dstip", "destinationip", "destination_address", "dst_addr"]
    out_aliases = ["bytes_out", "out_bytes", "sent_bytes", "bytes_sent",
                   "bytes_tx", "tx_bytes", "client_bytes", "upload_bytes"]
    total_aliases = ["bytes", "bytes_total", "total_bytes", "bytes_transferred"]
    for obj in flatten_dicts(firewall_data):
        src = first_value(obj, src_aliases)
        dst = first_value(obj, dst_aliases)
        if not src or not dst:
            continue

        src_internal = is_internal_ip(src)
        dst_internal = is_internal_ip(dst)
        if src_internal is True and dst_internal is False:
            raw_out = first_value(obj, out_aliases)
            byte_count = parse_bytes(raw_out)
            direction_basis = "Internal source to external destination"
            if byte_count is None:
                byte_count = parse_bytes(first_value(obj, total_aliases))
                if byte_count is not None:
                    direction_basis += "; total session bytes only, not verified outbound bytes"
            external_candidates.append({
                "src": str(src), "dst": str(dst),
                "bytes": byte_count,
                "direction": direction_basis,
                "raw": json.dumps(obj, ensure_ascii=False)[:500],
            })

# Detect containment clues from all searched reports.
containment_lines = []
for label, filename, content in corpus_parts:
    for line in content.splitlines():
        if re.search(r"isolat|containment|blocked|disabled account|"
                     r"firewall rule|host quarantin|hunt detection",
                     line, re.I):
            containment_lines.append(f"{label}:{filename}: {line.strip()[:220]}")

# Data categories: only classify based on evidence; never infer exact record count
# from archive size alone.
category_rules = {
    "Patient health records (PHI)": re.compile(
        r"patient|PHI|health.?record|query_results\.csv|"
        r"SRV-HEALTH-DB", re.I),
    "Insurance and billing data": re.compile(
        r"insurance|billing|claim|SRV-INS-DB", re.I),
    "Employee records": re.compile(
        r"employee|payroll|human resources|HR system", re.I),
    "Operational data": re.compile(
        r"operational|configuration|network|server logs|"
        r"SRV-FILE-01|WS-RECV-03", re.I),
}

# Write host CSV.
host_rows = []
for host in sorted(known_hosts):
    data, sensitivity, detail = host_profile(host, asset_text)
    level, basis, refs, lines = classify_host(host)
    host_rows.append({
        "host": host,
        "asset_data_profile": data,
        "sensitivity": sensitivity,
        "access_assessment": level,
        "assessment_basis": basis,
        "evidence_sources": "; ".join(refs) if refs else "No matching evidence source",
        "asset_inventory_row": detail,
    })

with CSV_PATH.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "host", "asset_data_profile", "sensitivity", "access_assessment",
        "assessment_basis", "evidence_sources", "asset_inventory_row"
    ])
    writer.writeheader()
    writer.writerows(host_rows)

# Write human-readable report.
REPORT.write_text("", encoding="utf-8")
say("=" * 72)
say("                 DATA EXPOSURE ASSESSMENT")
say("=" * 72)
say()
say("EVIDENCE SOURCES")
say(f"  Asset inventory: {'FOUND' if ASSET.is_file() else 'MISSING'}")
say(f"  Firewall JSON:   {'PARSED' if firewall_data is not None else 'MISSING/UNREADABLE'}")
for label, entries in source_text.items():
    for path, _ in entries:
        say(f"  {label}: {path.relative_to(BASE)}")
if missing:
    say("  Other expected files not found:")
    for item in sorted(set(missing)):
        say(f"    - {item}")

say()
say("COMPROMISED / RELEVANT HOST MAPPING")
say("  Access labels are evidence leads; verify against original records.")
say("-" * 72)
for row in host_rows:
    say(f"  Host: {row['host']}")
    say(f"    Data profile: {row['asset_data_profile']}")
    say(f"    Sensitivity:  {row['sensitivity']}")
    say(f"    Assessment:   {row['access_assessment']}")
    say(f"    Basis:        {row['assessment_basis']}")
    say(f"    Sources:      {row['evidence_sources']}")
    say()

say("STAGING ASSESSMENT")
say(f"  Staging status: {staging_status}")
if staging_matches:
    say("  Matching disk-evidence lines:")
    for line in staging_matches[:20]:
        say(f"    - {line}")
else:
    say("  No staging indicator matched in the available disk report.")
    say("  Check whether Task 2 output is stored in a different path.")
say()

say("EXTERNAL TRANSMISSION ASSESSMENT")
say(f"  Candidate internal-to-external sessions: {len(external_candidates)}")
if external_candidates:
    say("  These are candidate flows, not proof that attacker data was exfiltrated.")
    for item in external_candidates[:50]:
        say(f"    Source: {item['src']} -> Destination: {item['dst']}")
        say(f"      Byte field: {human_bytes(item['bytes'])}")
        say(f"      Basis: {item['direction']}")
        say(f"      Raw record: {item['raw']}")
else:
    say("  No candidate external flows were parsed using the recognized field names.")
    say("  This is NOT proof that no data left the network.")
    say("  Inspect the firewall JSON schema and network topology manually.")

if schema_notes:
    for note in schema_notes:
        say(f"  Note: {note}")

say()
say("DATA EXPOSURE BY TYPE")
for category, pattern in category_rules.items():
    matches = []
    for label, filename, content in corpus_parts:
        if pattern.search(content):
            matches.append(f"{label}:{filename}")
    say(f"  {category}:")
    if matches:
        say("    Evidence references: " + "; ".join(sorted(set(matches))))
        say("    Status: REVIEW REQUIRED - a reference alone does not prove exposure.")
    else:
        say("    Status: NOT ESTABLISHED - no matching reference found.")
    say("    Record count: UNKNOWN unless a verified source gives a defensible count.")

say()
say("REGULATORY / OPERATIONAL ASSESSMENT")
say("  HIPAA reportability: UNDETERMINED BY THIS SCRIPT")
say("  Basis:")
say("    - Determine whether unsecured PHI was accessed, acquired, used, or disclosed.")
say("    - Verify the actual data involved, affected individuals, encryption status,")
say("      and whether there is evidence of acquisition or exfiltration.")
say("    - Have the privacy officer and legal counsel assess applicable obligations.")
say("  Estimated records at risk: UNKNOWN until files, database queries, and record")
say("  counts are validated. File size alone cannot establish a record count.")
say()
say("MITIGATING FACTORS TO VERIFY")
say("  - Whether affected data was encrypted and whether keys were compromised.")
say("  - Whether egress controls blocked or limited external transfer.")
say("  - Detection and containment timestamps from verified incident records.")
say("  - Whether the attacker accessed only local files or queried remote databases.")
say("  - Whether outbound sessions can be tied to the staged files and attacker activity.")
say()
say("CONCLUSION")
say("  This automated report identifies exposure leads; it does not establish that")
say("  exfiltration occurred or that a HIPAA breach is or is not reportable.")
say("  Review the source artifacts before reaching a final conclusion.")
say()
say(f"Host inventory CSV: {CSV_PATH}")
say(f"Full report:        {REPORT}")
say("=" * 72)
PY
