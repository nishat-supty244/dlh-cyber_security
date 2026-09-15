# MedDefense Tool-Agnostic Investigation Playbook v1

## Purpose
This playbook establishes a standardized, platform-agnostic investigative workflow for MedDefense SOC analysts. It ensures consistent, high-fidelity threat triage across any SIEM environment through uniform methodology and side-by-side technical execution paths.

## Scope
This playbook covers routine and advanced Tier 1 incident investigations including credential theft, unauthorized data egress, and brute-force access attempts against internal clinical nodes. It does not cover physical security breaches, infrastructure provisioning, or non-technical compliance audits.

## Inputs
* Enriched events repository (`enriched_events.json`)
* Asset inventory database (`asset_inventory.json`)
* System baselines and network zones (`network_zones.json`)
* Detection rules catalog (`detection_catalog/`)
* Triage packages and dashboard credentials (`dashboard_credentials.json`)
* Threat intelligence and IOC contexts

## Workflow Steps

| Step | CLI Action (jq / Sigma) | Dashboard / Export Action (KQL / UI) |
| :--- | :--- | :--- |
| 1. Initialize | Load enriched logs and set environment variables. | Verify index metadata and load dashboard export assets. |
| 2. Scope Target | Filter events by host or target asset ID via `jq`. | Select target asset via host filter or KQL query bar. |
| 3. Set Window | Constrain record timestamp variables to incident bounds. | Adjust dashboard global absolute time picker / range. |
| 4. Extract IOCs | Query unique attacker IPs or user handles via pipeline. | Inspect aggregation tables and discover top actors. |
| 5. Trace Chain | Group event sequences by correlation ID or timestamp. | Expand hit documents to review individual log lines. |
| 6. Match Rule | Compare extracted behaviors against Sigma detection rules. | Verify correlation alerts against built-in Wazuh rules. |
| 7. Validate | Cross-reference findings against asset criticality data. | Confirm event context via dashboard context panels. |
| 8. Package | Export structured JSON findings via schema template. | Save dashboard trace evidence and export findings object. |

## Field Name Translation Table

| Normalized Schema | Wazuh Field Name |
| :--- | :--- |
| `hostname` | `agent.name` |
| `src_ip` | `source.ip` |
| `dst_ip` | `destination.ip` |
| `user` | `user.name` |
| `event_id` | `winlog.event_id` |
| `timestamp` | `@timestamp` |
| `raw_message` | `full_log` |
| `process_name` | `process.name` |
| `command_line` | `process.command_line` |
| `file_path` | `file.path` |

## Query Decomposition Rule
Every investigation query follows a three-part rule: **Filter** (target asset/IP), **Aggregation** (grouping behavior or count), and **Time Window** (bounding start/end).
* **jq**: `[.[] | select(.host == "db-patient-01" and .timestamp >= "start")] | group_by(.source_ip)`
* **Sigma**: `selection: host: db-patient-01; condition: selection`
* **KQL**: `agent.name: "db-patient-01" and @timestamp >= "start"`
* **Lucene**: `agent.name:"db-patient-01" AND timestamp:[start TO end]`

## Finding Schema
Locked investigation findings conform to this standard JSON format:
`finding_id`, `scenario_id`, `interface`, `investigation_start`, `investigation_end`, `time_to_first_answer_seconds`, `actions`, `fields_touched`, `event_refs`, `attack_techniques`, `hypothesis`, `confidence`, `created_at`.

## Exit Criteria
An investigation is complete and ready for finding submission when the target host context is verified, the attack timeline bounds are established, matching event counts are reconciled, and a high-confidence hypothesis with corresponding MITRE ATT&CK techniques is documented.

## Known Pitfalls
1. Relying on default dashboard field aliases without checking the translation table can cause silent query misses on raw fields.
2. Failing to bound time windows explicitly in CLI scripts can lead to high memory consumption and slow evaluations across massive log sets.
3. Assuming raw log structures remain identical after platform migrations will break automated parsing pipelines if field paths drift.
