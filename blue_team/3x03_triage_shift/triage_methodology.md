
Conversation with Gemini
Requirements

General

All scripts will be executed on Ubuntu 22.04 LTS

Allowed editors: vi, vim, emacs, nano

A README.md file at the root of the project directory is mandatory

All your files should end with a new line

Scripting

Bash scripts must start with #!/bin/bash and pass shellcheck

Python scripts must target python3 and must be valid under python3 -W error

Scripts must be idempotent: running them twice against the same input must produce identical output

Scripts must read dependency paths from environment variables, not from hardcoded home directories:

CATALOG_DIR points at the 3x02 detection_catalog/ directory, defaulting to ~/3x02_package/detection_catalog/

HANDOFF_DIR points at the 3x00 evidence_handoff/ directory, defaulting to ~/3x00_handoff/evidence_handoff/

BASELINE_PKG points at the 3x01 baseline_package/ directory, defaulting to ~/3x01_package/baseline_package/

ASSETS_DIR points at ~/3x03_assets/, which contains the provided ioc_context.json

Lab Access

Connection Details:

ParameterValueLab NameMedDefense SocTarget Host[PROVIDED_IP]UsernamestudentAuth MethodSSH Key provided by the lab platformBase Directory/home/student

Connection Example:

ssh student@[PROVIDED_IP]

After connecting, verify the lab and set environment variables:

source ~/m3_env.shexport ASSETS_DIR=$HOME/3x03_assetsecho $CATALOG_DIRecho $HANDOFF_DIRecho $BASELINE_PKGecho $TRIAGE_PKGecho $ASSETS_DIR

Expected values:

CATALOG_DIR=/home/student/3x02_package/detection_catalog

HANDOFF_DIR=/home/student/3x00_handoff/evidence_handoff

BASELINE_PKG=/home/student/3x01_package/baseline_package

TRIAGE_PKG=/home/student/3x03_package/triage_package

ASSETS_DIR=/home/student/3x03_assets

Important: ASSETS_DIR defaults to ~/3x04_assets in m3_env.sh. For 3x03 you must set it manually before running any task:

export ASSETS_DIR=$HOME/3x03_assets

Prerequisites: This project requires completed outputs from 3x00 ($HANDOFF_DIR), 3x01 ($BASELINE_PKG), and 3x02 ($CATALOG_DIR/alerts/alert_queue.json).

Available read-only asset inputs:

/home/student/3x03_assets/ioc_context.json (25 indicators: 6 malicious, 7 suspicious, 9 clean, 3 unknown)

Output directory:

$TRIAGE_PKG=/home/student/3x03_package/triage_package/

Note: No task may query a SIEM, API, or network service. All work is CLI against the provided flat JSON files. Do not hardcode /home/student — use environment variables. Create tickets/ subdirectory before running batch scripts.

Input Files

Scripts read the following locked inputs:

$CATALOG_DIR/

alerts/

alert_queue.json

alert_queue_schema.json$HANDOFF_DIR/

data/

enriched_events.json

context/

asset_inventory.json

network_zones.json$BASELINE_PKG/

baselines/

baseline_summary.json

anomalies/

ranked_anomalies.json$ASSETS_DIR/

ioc_context.json

ioc_context.json is a JSON object keyed by IP or domain, with each entry containing reputation (one of clean, suspicious, malicious, unknown), categories (list of threat feed categories), first_seen, last_seen, and optional geolocation fields.

Ticket Schema

Every processed alert must produce a structured ticket object with these locked fields:

ticket_id (deterministic from alert_id)

alert_id

classification (one of true_positive, false_positive, benign, escalated)

justification (plain text)

evidence_refs (list of event_ref pointers into enriched_events.json)

ioc_hits (list of entries from ioc_context.json that informed the decision)

attack_techniques (list of ATT&CK technique IDs, copied from the source rule)

recommended_action (one of close, escalate_tier2, monitor, tune_rule)

analyst_time_seconds (time from alert open to classification, read from runner metadata or estimated)

created_at (ISO 8601 UTC)

Specific Project Rules

Every ticket must reference at least one event_ref from enriched_events.json

Every classification other than benign must include at least one justification sentence naming the specific field and value that drove the decision

The triage_package/ directory produced in T14 must be self-contained and runnable against a fresh alert queue with zero configuration beyond the environment variables

No task may query a SIEM, API, or network service. All work is CLI against the provided files

Tasks



0. Queue Assessment

Goal: Load the alert queue, validate its schema, and produce a structured shift briefing that tells you exactly what you are walking into.

Context: A shift begins with situational awareness, not with opening the first ticket. Before you touch any individual alert you need to know the shape of the queue: how many alerts, distributed across which priority bands, hitting which hosts, firing which rules. This briefing is the first artifact you produce every day of your career in a SOC. It is the document you show James Chen in the first five minutes of your shift when he asks "how are we looking".

Instructions: Write a script 0-queue_assessment.sh that reads $CATALOG_DIR/alerts/alert_queue.json and $CATALOG_DIR/alerts/alert_queue_schema.json, validates every alert against the schema, and produces queue_assessment.json containing:

queue_size

validation_errors: list of alerts that failed schema validation

by_priority_band: counts for critical (>= 20), high (10–19), medium (5–9), low (1–4)

by_rule: count per rule_id sorted descending

by_hostname: count per target host sorted descending

by_attack_tactic: count per ATT&CK tactic derived from rule tags

time_span: first and last event_summary.timestamp in the queue

top_targets: the three hosts with the highest cumulative priority_score

Default CATALOG_DIR to ~/3x02_package/detection_catalog if not set. Print a human-readable shift briefing to stdout.

Expected Output:

$ source ~/m3_env.sh && ./0-queue_assessment.sh=== SHIFT BRIEFING <date> ===queue size : <N> alertsvalidation errors : <N>time span : <start> -> <end>priority bands

critical : 6

high : 14

medium : 12

low : 6top rules (5)

010 credential_theft_chain 4

012 medical_segment_egress 4

007 unknown_outbound_destination 5

001 ssh_brute_force 3

011 patient_data_access 3top hosts (3 by cumulative score)

db-patient-01 score 78

clin-ws-07 score 54

med-img-02 score 42attack tactics covered : 7queue_assessment.json written

Repo:

GitHub repository: dlh-cyber_security

Directory: blue_team/3x03_triage_shift

File: 0-queue_assessment.sh, queue_assessment.json

Bash
#!/bin/bash
# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Default CATALOG_DIR if not set
CATALOG_DIR="${CATALOG_DIR:-$HOME/3x02_package/detection_catalog}"
ALERTS_FILE="$CATALOG_DIR/alerts/alert_queue.json"
SCHEMA_FILE="$CATALOG_DIR/alerts/alert_queue_schema.json"
OUTPUT_FILE="queue_assessment.json"

if [ ! -f "$ALERTS_FILE" ]; then
    echo "Error: Alert queue file not found at $ALERTS_FILE" >&2
    exit 1
fi

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Schema file not found at $SCHEMA_FILE" >&2
    exit 1
fi

python3 - "$ALERTS_FILE" "$SCHEMA_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import json
from datetime import datetime
from collections import defaultdict

alerts_path = sys.argv[1]
schema_path = sys.argv[2]
output_path = sys.argv[3]

with open(alerts_path, 'r') as f:
    alerts = json.load(f)

with open(schema_path, 'r') as f:
    schema = json.load(f)

def validate_alert(alert, schema):
    try:
        import jsonschema
        jsonschema.validate(instance=alert, schema=schema)
        return True
    except ImportError:
        required = schema.get("required", [])
        for req in required:
            if req not in alert:
                return False
        return True
    except Exception:
        return False

validation_errors = []
valid_alerts = []

for alert in alerts:
    if validate_alert(alert, schema):
        valid_alerts.append(alert)
    else:
        validation_errors.append(alert.get("alert_id", "unknown"))

queue_size = len(alerts)

priority_bands = {"critical": 0, "high": 0, "medium": 0, "low": 0}
by_rule_counts = defaultdict(int)
by_host_counts = defaultdict(int)
by_tactic_counts = defaultdict(int)
host_scores = defaultdict(int)

timestamps = []

for alert in valid_alerts:
    score = alert.get("priority_score", 0)
    if score >= 20:
        priority_bands["critical"] += 1
    elif score >= 10:
        priority_bands["high"] += 1
    elif score >= 5:
        priority_bands["medium"] += 1
    else:
        priority_bands["low"] += 1

    rule_id = alert.get("rule_id", "unknown")
    by_rule_counts[rule_id] += 1

    if "target_host" in alert:
        host = alert["target_host"]
    elif "event_summary" in alert and "hostname" in alert["event_summary"]:
        host = alert["event_summary"]["hostname"]
    else:
        host = "unknown"
    
    by_host_counts[host] += 1
    host_scores[host] += score

    tactics = alert.get("attack_tactics", alert.get("tactics", []))
    if not tactics and "rule_tags" in alert:
        tactics = [t for t in alert["rule_tags"] if "tactic" in t.lower() or t.startswith("TA")]
    for t in tactics:
        by_tactic_counts[t] += 1

    ts = alert.get("event_summary", {}).get("timestamp")
    if ts:
        timestamps.append(ts)

timestamps.sort()
time_span = {
    "start": timestamps[0] if timestamps else "",
    "end": timestamps[-1] if timestamps else ""
}

sorted_rules = dict(sorted(by_rule_counts.items(), key=lambda x: x[1], reverse=True))
sorted_hosts = dict(sorted(by_host_counts.items(), key=lambda x: x[1], reverse=True))
sorted_tactics = dict(sorted(by_tactic_counts.items(), key=lambda x: x[1], reverse=True))

top_targets_sorted = sorted(host_scores.items(), key=lambda x: x[1], reverse=True)[:3]
top_targets = [{"hostname": h, "cumulative_score": s} for h, s in top_targets_sorted]

assessment_data = {
    "queue_size": queue_size,
    "validation_errors": validation_errors,
    "by_priority_band": priority_bands,
    "by_rule": sorted_rules,
    "by_hostname": sorted_hosts,
    "by_attack_tactic": sorted_tactics,
    "time_span": time_span,
    "top_targets": top_targets
}

with open(output_path, 'w') as f:
    json.dump(assessment_data, f, indent=2)

current_date = datetime.utcnow().strftime("%Y-%m-%d")
print(f"=== SHIFT BRIEFING {current_date} ===")
print(f"queue size           : {queue_size} alerts")
print(f"validation errors    :  {len(validation_errors)}")
print(f"time span            : {time_span['start']} -> {time_span['end']}")
print("priority bands")
for band, count in priority_bands.items():
    print(f"  {band:<10}: {count:>2}")

print("\ntop rules (5)")
for r, c in list(sorted_rules.items())[:5]:
    print(f"  {r:<30} {c:>2}")

print("\ntop hosts (3 by cumulative score)")
for h, s in top_targets_sorted:
    print(f"  {h:<15} score {s}")

print(f"\nattack tactics covered : {len(sorted_tactics)}")
print("queue_assessment.json written")
EOF
1. Triage Methodology Definition

Goal: Write the bounded triage methodology document that every classification decision in this shift will be graded against.

Context: Every mature SOC ships with a written triage methodology. New analysts read it on day one. Auditors read it at quarter end. Senior analysts cite it when they disagree with a classification. Without a written methodology the SOC runs on the personal judgment of whoever happens to be sitting at the console, and two analysts can classify the same alert differently with no objective way to resolve the disagreement. Your methodology is short, concrete, and reviewable. It is not a philosophy paper.

Instructions: Write triage_methodology.md, bounded to one page and four hundred words, with these exact sections in this order:

Classification Taxonomy (the four classes: true_positive, false_positive, benign, escalated, each with a one-sentence operational definition and at least one example drawn from the 3x02 rule catalog)

Priority Ordering Rule (how the shift analyst decides which alert to work next, using priority_score from the queue plus any override conditions)

Evidence Requirement (the minimum evidence needed to support each classification, referenced by field name from the enriched events)

Escalation Criteria (the specific conditions that trigger an escalation to Tier 2, expressed as a bullet list of boolean predicates)

SLA (the per-priority-band time budget for triage, for example critical: 15 minutes, high: 30 minutes, medium: 60 minutes, low: same day)

Documentation Standard (the mandatory ticket fields from the project Requirements section, stated as a checklist)

Any section exceeding the budget must be trimmed. This document lives at triage_package/spec/triage_methodology.md in T14.

Expected Output:

$ wc -w triage_methodology.md

382 triage_methodology.md

$ head -3 triage_methodology.md# MedDefense SOC Triage Methodology

## Classification Taxonomy

Repo:

GitHub repository: dlh-cyber_security

Directory: blue_team/3x03_triage_shift

File: triage_methodology.md

Your Markdown file is ready

MD icon
triage_package/spec/triage_methodology
 MD 
Repo: GitHub repository: dlh-cyber_security, Directory: blue_team/3x03_triage_shift, File: triage_methodology.md




Gemini is AI and can make mistakes, including about people. Your privacy & GeminiOpens in a new window

Analyzing
# MedDefense SOC Triage Methodology

## Classification Taxonomy
- **true_positive**: An alert representing an actual malicious or unauthorized activity verified by concrete indicators and rule context, such as rule 010 (credential_theft_chain) firing on unauthorized LSASS access.
- **false_positive**: An alert triggered by benign administrative or operational activity that mimics malicious patterns, such as rule 001 (ssh_brute_force) triggered by an automated deployment script.
- **benign**: An alert caused by expected, authorized business processes that match baseline system behavior, such as rule 012 (medical_segment_egress) firing during routine scheduled database backups.
- **escalated**: An alert involving complex, high-risk, or ambiguous indicators requiring senior investigation and Tier 2 response, such as rule 007 (unknown_outbound_destination) contacting an unclassified external IP.

## Priority Ordering Rule
Analysts must process alerts strictly in descending order of `priority_score`. Override conditions require immediate handling of any unacknowledged critical alert (`priority_score >= 20`) or active threat flagged in `ioc_context.json`, superseding lower-scored queue positions regardless of arrival timestamp.

## Evidence Requirement
Every classification must reference specific fields from `enriched_events.json`. Minimum evidence requires: `event_id` and `timestamp` for presence, `src_ip` or `hostname` for source identification, and specific payload fields (`command`, `dest_port`, or `user`) that drove the decision.

## Escalation Criteria
- `priority_score >= 20` combined with a malicious `ioc_hits` match.
- Presence of lateral movement indicators across multiple internal subnets.
- Unresolved system compromise affecting critical medical patient databases.
- Rule firing with unrecognized external destination lacking baseline precedent.

## SLA
- **critical**: 15 minutes
- **high**: 30 minutes
- **medium**: 60 minutes
- **low**: Same day shift close

## Documentation Standard
- [ ] `ticket_id` (deterministic from alert_id)
- [ ] `alert_id`
- [ ] `classification` (true_positive, false_positive, benign, escalated)
- [ ] `justification` (plain text with field/value names)
- [ ] `evidence_refs` (pointers into enriched_events.json)
- [ ] `ioc_hits` (entries from ioc_context.json)
- [ ] `attack_techniques` (ATT&CK technique IDs)
- [ ] `recommended_action` (close, escalate_tier2, monitor, tune_rule)
- [ ] `analyst_time_seconds`
- [ ] `created_z` (ISO 8601 UTC)
triage_package/spec/triage_methodology.md
Displaying triage_package/spec/triage_methodology.md.
