#!/bin/bash
#!/usr/bin/env bash
# Task 9: Final HEALTHBANE ATT&CK technique inventory
# Uses Python 3 to read the Navigator JSON and search local evidence.
# Confidence classifications are candidates for analyst review, not proof.

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFERENCE="$BASE_DIR/reference/attck_navigator_80pct.json"
OUTPUT_DIR="$BASE_DIR/task9_output"
REPORT="$OUTPUT_DIR/final_attack_inventory.txt"
CSV="$OUTPUT_DIR/final_attack_inventory.csv"

mkdir -p "$OUTPUT_DIR"

if [[ ! -f "$REFERENCE" ]]; then
    echo "[ERROR] Navigator file not found: $REFERENCE"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] Python 3 is required."
    exit 1
fi

export BASE_DIR REFERENCE OUTPUT_DIR REPORT CSV

python3 <<'PY'
import csv
import json
import os
import re
from pathlib import Path

base = Path(os.environ["BASE_DIR"])
reference = Path(os.environ["REFERENCE"])
out_dir = Path(os.environ["OUTPUT_DIR"])
report_path = Path(os.environ["REPORT"])
csv_path = Path(os.environ["CSV"])

# Assignment's expected total model size.
# Change this if your actual project defines a different denominator.
TOTAL_MODEL_TECHNIQUES = 29

# Search the investigations in chronological order.
SOURCE_GROUPS = [
    ("4x00", [base / "previous_findings" / "4x00_phishing_summary.txt"]),
    ("4x01", [base / "previous_findings" / "4x01_network_timeline.txt"]),
    ("4x02", [base / "previous_findings" / "4x02_attack_mapping.json"]),
    ("4x03", [base / "previous_findings" / "4x03_malware_summary.txt"]),
    ("4x04", [base / "previous_findings" / "4x04_hunting_report.txt"]),
    ("4x05-IR", [
        base / "ir_evidence" / "memory_artifacts.txt",
        base / "ir_evidence" / "disk_forensics_report.txt",
        base / "ir_evidence" / "firewall_sessions_ws_recv_03.json",
        base / "ir_evidence" / "ir_team_notes.txt",
    ]),
]

# Required new technique candidates.
# "strong" patterns look for concrete artifact descriptions.
NEW_RULES = {
    "T1053.005": {
        "name": "Scheduled Task",
        "tactic": "Persistence",
        "files": ["memory_artifacts.txt"],
        "terms": [
            r"scheduled task", r"task scheduler",
            r"HealthSync Update Check"
        ],
        "strong": [
            r"task name\s*[:=]", r"task created",
            r"scheduled task.{0,50}(created|registered|executed)",
            r"HealthSync Update Check"
        ],
    },
    "T1074.001": {
        "name": "Local Data Staging",
        "tactic": "Collection",
        "files": ["disk_forensics_report.txt"],
        "terms": [
            r"data staging", r"staging directory",
            r"staged data", r"staging_export"
        ],
        "strong": [
            r"staging_export_[\w.-]+",
            r"file.{0,40}(staged|staging)",
            r"staging directory.{0,50}(identified|found|created)"
        ],
    },
    "T1560.001": {
        "name": "Archive Collected Data: Archive via Utility",
        "tactic": "Collection",
        "files": ["disk_forensics_report.txt"],
        "terms": [
            r"archive via utility", r"archive collected data",
            r"\.zip\b", r"\.7z\b", r"\.rar\b"
        ],
        "strong": [
            r"(7z|7-zip|winrar|rar\.exe|Compress-Archive)",
            r"(created|built|generated).{0,40}\.(zip|7z|rar)\b",
            r"archive.{0,50}(created|command|utility)"
        ],
    },
    "T1070.001": {
        "name": "Clear Windows Event Logs",
        "tactic": "Defense Evasion",
        "files": ["disk_forensics_report.txt"],
        "terms": [
            r"event log clearing", r"cleared event logs",
            r"windows event log", r"wevtutil"
        ],
        "strong": [
            r"event.?id\s*1102",
            r"wevtutil\s+cl",
            r"(security|system|application).{0,40}log.{0,30}(cleared|clear)",
            r"logs? (were )?cleared"
        ],
    },
    "T1005": {
        "name": "Data from Local System",
        "tactic": "Collection",
        "files": ["disk_forensics_report.txt", "ir_team_notes.txt"],
        "terms": [
            r"local file access", r"data from local system",
            r"local data", r"file access"
        ],
        "strong": [
            r"(accessed|collected|copied).{0,60}(local file|local data|file system)",
            r"local system.{0,50}(accessed|collected|copied)",
            r"file access.{0,50}(confirmed|observed|identified)"
        ],
    },
}

def read_text(path):
    try:
        return path.read_text(errors="replace")
    except (OSError, IsADirectoryError):
        return ""

def discover_evidence():
    """Read known investigation files and relevant task output reports."""
    files = []
    for label, paths in SOURCE_GROUPS:
        for path in paths:
            if path.is_file():
                files.append((label, path, read_text(path)))

    # Include reconstruction outputs when present.
    for task_dir, label in [
        ("task5_output", "4x05"),
        ("task6_output", "4x05"),
        ("task7_output", "4x05"),
        ("task8_output", "4x05"),
    ]:
        folder = base / task_dir
        if folder.is_dir():
            for path in sorted(folder.glob("*.txt")):
                files.append((label, path, read_text(path)))

    return files

def load_navigator(path):
    """Read standard MITRE Navigator layers and collect technique records."""
    data = json.loads(path.read_text(errors="replace"))
    records = []

    def walk(obj):
        if isinstance(obj, dict):
            if obj.get("techniqueID"):
                records.append(obj)
            for value in obj.values():
                walk(value)
        elif isinstance(obj, list):
            for value in obj:
                walk(value)

    walk(data)

    # Remove duplicate technique/tactic combinations.
    unique = {}
    for item in records:
        tid = str(item.get("techniqueID", "")).strip()
        if not tid:
            continue
        tactic = str(item.get("tactic", "")).strip()
        key = (tid, tactic)
        unique[key] = item

    return data, list(unique.values())

def confidence_from_score(item):
    """Use the Navigator score only as the previous assessment."""
    try:
        score = float(item.get("score", 0))
    except (TypeError, ValueError):
        score = 0
    if score >= 80:
        return "CONFIRMED"
    if score >= 40:
        return "PROBABLE"
    return "POSSIBLE"

def technique_id_in(text, tid):
    return re.search(r"(?<![A-Z0-9])" + re.escape(tid) +
                     r"(?![A-Z0-9])", text, re.I) is not None

def evidence_for_existing(tid, name, files):
    """Find references to an existing technique in investigation evidence."""
    matches = []
    for label, path, content in files:
        if technique_id_in(content, tid):
            matches.append((label, path.name, "Technique ID mentioned"))
        elif name and re.search(re.escape(name), content, re.I):
            matches.append((label, path.name, "Technique name mentioned"))
    return matches

def evidence_for_new(tid, rule, files):
    """Check the specified IR files for technique-related evidence."""
    matches = []
    terms_found = []
    strong_found = []

    for label, path, content in files:
        if path.name not in rule["files"]:
            continue

        for pattern in rule["terms"]:
            if re.search(pattern, content, re.I):
                terms_found.append((label, path.name, pattern))

        for pattern in rule["strong"]:
            if re.search(pattern, content, re.I):
                strong_found.append((label, path.name, pattern))

    for label, filename, pattern in strong_found:
        matches.append((label, filename, "Artifact pattern: " + pattern))
    if not matches:
        for label, filename, pattern in terms_found:
            matches.append((label, filename, "Related term: " + pattern))

    if strong_found:
        confidence = "CONFIRMED"
    elif terms_found:
        confidence = "PROBABLE"
    else:
        confidence = "POSSIBLE"

    return matches, confidence

def first_investigation(tid, name, files):
    """Find the earliest investigation with a matching reference."""
    for label, path, content in files:
        if technique_id_in(content, tid):
            return label
        if name and re.search(re.escape(name), content, re.I):
            return label
    return "Not established"

def status_for(old_conf, new_conf, is_new):
    if is_new:
        return "NEW"
    rank = {"POSSIBLE": 1, "PROBABLE": 2, "CONFIRMED": 3}
    if rank[new_conf] > rank[old_conf]:
        return "UPGRADED"
    if rank[new_conf] < rank[old_conf]:
        return "DOWNGRADED"
    return "UNCHANGED"

def tactic_name(value):
    if not value:
        return "Unknown"
    return value.replace("-", " ").title()

try:
    navigator, baseline = load_navigator(reference)
except (json.JSONDecodeError, OSError) as exc:
    raise SystemExit(f"[ERROR] Could not parse Navigator JSON: {exc}")

files = discover_evidence()
inventory = {}

# Add all techniques from the baseline Navigator layer.
for item in baseline:
    tid = str(item.get("techniqueID", "")).strip()
    name = str(item.get("technique", "") or item.get("name", "")).strip()
    tactic = tactic_name(str(item.get("tactic", "")))
    old_conf = confidence_from_score(item)

    matches = evidence_for_existing(tid, name, files)
    if matches:
        # References in reports are corroboration leads, not automatic proof.
        # Retain the baseline assessment unless evidence explicitly supports
        # a change; these candidates should be verified by the analyst.
        confidence = old_conf
    else:
        confidence = "POSSIBLE"

    first = first_investigation(tid, name, files)
    source_names = sorted({f"{label}:{filename}" for label, filename, _ in matches})

    inventory[tid] = {
        "id": tid,
        "name": name or "Name not supplied in Navigator",
        "tactic": tactic,
        "evidence": "; ".join(source_names) if source_names else "No matching reference found",
        "confidence": confidence,
        "first_identified": first,
        "status": status_for(old_conf, confidence, False),
        "review": "Verify artifact and confidence against source evidence",
        "baseline_confidence": old_conf,
    }

# Add the five required technique candidates.
for tid, rule in NEW_RULES.items():
    matches, confidence = evidence_for_new(tid, rule, files)
    sources = sorted({f"{label}:{filename}" for label, filename, _ in matches})

    if tid in inventory:
        # The technique already exists in the Navigator layer.
        row = inventory[tid]
        row["evidence"] = "; ".join(sorted(set(
            row["evidence"].split("; ") +
            sources
        )))
        row["confidence"] = confidence
        row["status"] = status_for(row["baseline_confidence"], confidence, False)
        row["review"] = "Review IR artifact patterns and prior mapping"
    else:
        inventory[tid] = {
            "id": tid,
            "name": rule["name"],
            "tactic": rule["tactic"],
            "evidence": "; ".join(sources) if sources else "No matching IR evidence found",
            "confidence": confidence,
            "first_identified": "4x05-IR" if sources else "Not established",
            "status": "NEW",
            "review": "Verify the matched artifact; keywords alone may be insufficient",
            "baseline_confidence": "POSSIBLE",
        }

# Add any further technique IDs explicitly identified in reconstruction reports.
# These are included as review candidates, not automatically confirmed.
for label, path, content in files:
    if label not in ("4x05", "4x05-IR"):
        continue
    for tid in set(re.findall(r"\bT\d{4}(?:\.\d{3})?\b", content)):
        if tid in inventory:
            continue
        inventory[tid] = {
            "id": tid,
            "name": "Name/tactic require ATT&CK lookup",
            "tactic": "Review",
            "evidence": f"{label}:{path.name}",
            "confidence": "POSSIBLE",
            "first_identified": label,
            "status": "NEW",
            "review": "Validate technique ID, name, tactic, and supporting artifact",
            "baseline_confidence": "POSSIBLE",
        }

rows = sorted(inventory.values(), key=lambda row: row["id"])
supported = sum(1 for row in rows if row["confidence"] in ("CONFIRMED", "PROBABLE"))
coverage = 100 * supported / TOTAL_MODEL_TECHNIQUES if TOTAL_MODEL_TECHNIQUES else 0

# CSV gives a sortable, spreadsheet-friendly inventory.
with csv_path.open("w", newline="", encoding="utf-8") as handle:
    writer = csv.DictWriter(handle, fieldnames=[
        "id", "name", "tactic", "evidence", "confidence",
        "first_identified", "status", "review", "baseline_confidence"
    ])
    writer.writeheader()
    writer.writerows(rows)

with report_path.open("w", encoding="utf-8") as report:
    def out(line=""):
        print(line)
        report.write(line + "\n")

    out("=" * 72)
    out("   HEALTHBANE ATT&CK TECHNIQUE INVENTORY (FINAL)")
    out(f"   Techniques in generated inventory: {len(rows)}")
    out(f"   Threat-model denominator: {TOTAL_MODEL_TECHNIQUES}")
    out("=" * 72)
    out(f"{'#':>3}  {'Technique':<12} {'Tactic':<20} {'Conf':<10} "
        f"{'First ID':<10} Status")
    out("-" * 90)

    for i, row in enumerate(rows, 1):
        out(f"{i:>3}  {row['id']:<12} {row['tactic'][:20]:<20} "
            f"{row['confidence']:<10} {row['first_identified']:<10} "
            f"{row['status']}")

    out()
    out("COVERAGE")
    out(f"  Post-4x02 benchmark:         12/{TOTAL_MODEL_TECHNIQUES} "
        f"({100*12/TOTAL_MODEL_TECHNIQUES:.1f}%)")
    out(f"  Post-4x03 benchmark:         16/{TOTAL_MODEL_TECHNIQUES} "
        f"({100*16/TOTAL_MODEL_TECHNIQUES:.1f}%)")
    out(f"  Post-4x04 benchmark:         23/{TOTAL_MODEL_TECHNIQUES} "
        f"({100*23/TOTAL_MODEL_TECHNIQUES:.1f}%)")
    out(f"  Final evidence-supported:    {supported}/{TOTAL_MODEL_TECHNIQUES} "
        f"({coverage:.1f}%)")
    out()
    out("STATUS COUNTS")
    for status in ("UPGRADED", "NEW", "CORRECTED", "DOWNGRADED", "UNCHANGED"):
        selected = [row for row in rows if row["status"] == status]
        out(f"  {status}: {len(selected)}")
        for row in selected:
            out(f"    {row['id']} {row['name']} | {row['evidence']}")

    out()
    out("REVIEW ITEMS / EVIDENCE GAPS")
    review_items = [
        row for row in rows
        if row["confidence"] == "POSSIBLE"
        or row["first_identified"] == "Not established"
        or row["tactic"] == "Review"
    ]
    if review_items:
        for row in review_items:
            out(f"  {row['id']} {row['name']}: {row['review']}")
            out(f"    Evidence: {row['evidence']}")
    else:
        out("  No rows met the automated review flags; manual validation is still required.")

    out()
    out("IMPORTANT LIMITATIONS")
    out("  - Navigator score is used as a rough prior confidence only.")
    out("  - Mentioning a technique ID or name is not proof it occurred.")
    out("  - Keyword matches require manual validation against the original artifact.")
    out("  - CORRECTED must be assigned by an analyst when earlier mapping is demonstrably wrong.")
    out("  - Historical percentages above are assignment benchmarks, not recalculated history.")
    out("  - Check the actual denominator and remaining gap before submitting.")
    out()
    out(f"CSV inventory: {csv_path}")
    out(f"Full report:   {report_path}")
    out("=" * 72)

print(f"\n[+] CSV saved: {csv_path}")
print(f"[+] Report saved: {report_path}")
PY
