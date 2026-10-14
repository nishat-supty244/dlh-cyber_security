# Containment Execution: IR-2026-0414-01

**Asset:** `WST-WS-031` (`10.42.118.31`), MedDefense West Campus laboratory  
**Chosen containment:** Option A — quarantine VLAN 999, block unauthorized egress, preserve forensic access from an IR jumpbox. See `containment_decision.md`.  
**Record status:** **PARTIALLY VALIDATED — later clean-state API evidence exists; original execution events are not independently documented.** This is a simulated lab record, not an assertion that network commands were run.  
**Evidence distinction:** The original EDR alert confirms outbound contact with `185.220.101.47:443` at `2026-04-14T02:47:02Z`. The supplied mock validation API shows a clean state at `14:20–14:22Z`, *after* a reported rebuild at `10:12Z`. It does **not** supply switch audit logs, firewall commit time, endpoint isolation audit, or jumpbox test results.

## Preconditions and authority

- **Approving authority:** James Chen, IR Commander (role identified in Task 3); actual approval timestamp, approval message, and clinical lead coordination **not provided**. Do not claim approval occurred at the example `03:10Z` without a record.
- **Evidence preservation:** Task 2 runbook `evidence_preservation.md`; actual completion time and hashes **not supplied**. Capture volatile memory and live connections before containment where patient safety and threat urgency permit.
- **Execution window:** Example scenario proposes evidence collection ending `03:14Z` and isolation starting `03:16Z` (two minutes). These are **exercise example times, not verified actual events**. Actual elapsed time: **unknown**.
- **Rollback:** Preserve original VLAN and ACL configuration; if patient-care operations are unexpectedly blocked, coordinate with clinical lead and IR Commander, restore the original switchport VLAN only if authorized, apply selective firewall/host restrictions as fallback, verify safety, and log the rollback. See `containment_decision.md`.

## Step-by-step containment execution record

### Step 1 — Quarantine VLAN reassignment

- **Timestamp (UTC):** Not supplied; exercise example `2026-04-14T03:16:04Z` (unverified).
- **Actor:** Authorized network operator — identity not supplied.
- **Command or console action:** On the **verified switchport** associated with `WST-WS-031`, assign access VLAN `999` and enforce a quarantine ACL allowing only approved forensic management from the IR jumpbox. Example vendor-dependent CLI (not executed or evidenced):

```text
show mac address-table address <VERIFIED_HOST_MAC>
show running-config interface <VERIFIED_SWITCHPORT>
configure terminal
interface <VERIFIED_SWITCHPORT>
switchport mode access
switchport access vlan 999
end
show interfaces <VERIFIED_SWITCHPORT> switchport
```

- **Expected result:** Host cannot reach normal hospital VLANs or the internet; authorized jumpbox forensic access remains possible.
- **Observed result:** **NOT VERIFIED.** No switchport configuration, MAC mapping, ACL log, or change ticket supplied.
- **Deviation notes:** Unknown until console and connectivity outputs are provided.
- **Required execution evidence:** Switch change/audit export showing port, previous VLAN, new VLAN, actor, UTC time, and applied ACL.

### Step 2 — Block C2 destination at firewall egress

- **Timestamp (UTC):** Firewall rule installation time unknown; exercise example `2026-04-14T03:17:21Z` (unverified).
- **Actor:** Authorized firewall operator — identity not supplied.
- **Command or console action:** Create/commit a logged deny rule for source `10.42.118.31` to destination `185.220.101.47`, any protocol, above broad allow rules. Example policy specification (not proof of execution):

```text
Name: IR-2026-0414-01-block-C2
Source: 10.42.118.31
Destination: 185.220.101.47
Service: ANY
Action: DENY and LOG
Priority: above general ALLOW rules
```

- **Expected result:** No new permitted outbound sessions from the workstation to the suspicious IP; deny attempts are logged.
- **Observed result:** **LATER VALIDATION CONFIRMED:** At `2026-04-14T14:22:00Z`, the supplied `siem/netflow.json` reports `egress_deny_verified` for `185.220.101.47` (also `91.234.99.107`), with `0` packets and `0` bytes for both in its reported 24-hour window. This verifies the **API's reported clean-state result**, not the time, operator, scope, or implementation of the firewall rule.
- **Deviation notes:** Missing rule-commit audit and time-specific pre/post-containment logs; no verified source-host attribution is shown in the supplied aggregate JSON.
- **Evidence:** `mock_validation_api/siem/netflow.json` (user-provided content; API query `14:22Z`).

### Step 3 — Verify C2 communication has stopped

- **Timestamp (UTC):** `2026-04-14T14:22:00Z` (**actual timestamp in provided validation JSON**; not the original containment time).
- **Actor:** Mock validation API / analyst reviewing response; individual analyst identity not provided.
- **Command or console action:** Read the mock endpoint `/siem/netflow` and inspect `egress_deny_verified`, packet count, byte count, and observation-window metadata. Example local lab query:

```bash
curl -fsS http://127.0.0.1:8080/siem/netflow | jq '.data | {queried_at,window_hours,egress_deny_verified,connections_to_185_220_101_47}'
```

- **Expected result:** No permitted C2 traffic after isolation, with timestamped sensor/flow evidence establishing the cutoff.
- **Observed result:** JSON reports `window_hours: 24`, query at `14:22Z`, `connections_to_185_220_101_47.packets: 0`, `bytes: 0`, `first_seen_in_window: null`, `last_seen_in_window: null`; egress deny verified. **C2 absent in the reported clean-state data.**
- **Deviation notes:** The initial alert documents an established connection at `02:47:02Z`, within 24 hours of the later query. The mock API's zero-packet 24-hour result therefore **cannot be reconciled as a complete historical capture of the same traffic**; treat it as synthetic post-remediation validation, not proof of a precise `03:17Z` cutoff or a continuous pre/post netflow gap. No PCAP or timestamped flow transitions were supplied.
- **Evidence:** `mock_validation_api/siem/netflow.json`; initial baseline `alert_A-20260414-9841.json`.

### Step 4 — Endpoint containment flag (if supported)

- **Timestamp (UTC):** Not supplied; exercise example `2026-04-14T03:19:02Z` (unverified).
- **Actor:** Authorized endpoint/EDR operator — identity not supplied.
- **Command or console action:** If the actual endpoint platform supports host isolation, select `WST-WS-031` in the endpoint console, invoke **Contain/Isolate**, preserve approved forensic management access, and export the audit event. Wazuh alerting does not itself prove this feature is available.
- **Expected result:** Console explicitly reports device isolation enabled and logs who set it and when.
- **Observed result:** **NOT VERIFIED / PLATFORM CAPABILITY UNKNOWN.** The supplied endpoint JSONs report process and persistence status, not a containment flag. Do not substitute clean process trees for a device-isolation audit.
- **Deviation notes:** If unsupported, document `N/A — feature unavailable` with product/version evidence; rely on validated network quarantine.
- **Required execution evidence:** Endpoint console isolation state, audit timestamp, actor, and policy exceptions (or product evidence proving N/A).

### Step 5 — Confirm jumpbox-only access

- **Timestamp (UTC):** Not supplied; exercise example `2026-04-14T03:22:04Z` (unverified).
- **Actor:** SOC analyst with approved IR jumpbox and authorized non-IR test host — identity not supplied.
- **Command or console action:** From both the jumpbox and a normal user VLAN, test the **same approved forensic service/port** and preserve source IPs, UTC times, and outputs:

```powershell
Test-NetConnection 10.42.118.31 -Port <APPROVED_FORENSIC_PORT>
```

- **Expected result:** Jumpbox access succeeds; user VLAN access fails; ACL and firewall logs corroborate both.
- **Observed result:** **NOT VERIFIED.** No jumpbox IP, approved management port, access-test outputs, or ACL audit supplied.
- **Deviation notes:** Cannot claim jumpbox-only reachability from netflow destination counters alone.
- **Required execution evidence:** Timestamped positive and negative connection tests and corresponding network policy logs.

## Additional later endpoint validation (supporting evidence, not Task 4 execution proof)

| UTC timestamp | Source | Observed result | What it proves / does not prove |
|---|---|---|---|
| `2026-04-14T10:12:00Z` | `endpoint/processtree/WST-WS-031.json` note | Host reportedly rebuilt from clean baseline | Reported rebuild time; does not document earlier containment steps |
| `2026-04-14T14:20:00Z` | `endpoint/processtree/WST-WS-031.json` | `powershell_parent_msbuild_child: 0`; `sample_trees_inspected: 1284` | No matching lineage reported after rebuild; not proof processes were selectively killed at 03:19Z |
| `2026-04-14T14:21:00Z` | `endpoint/persistence/WST-WS-031.json` | No GUID-named scheduled tasks; Run keys empty; `update.xml` and `update.exe` absent | Later eradication/clean-state evidence, not VLAN or endpoint isolation audit |
| `2026-04-14T14:22:00Z` | `siem/netflow.json` | `egress_deny_verified` lists both bad IPs; zero packets/bytes in mock result | Later network clean-state check; not a time-resolved containment execution trace |

## Evidence preservation and integrity

Retain the original supplied JSON files, the initial alert, and any newly collected switch/firewall/EDR audit exports in the Task 2 evidence store. Record SHA-256 hashes **after the actual files are available**; no hash values are invented here.

```bash

cd /evidence/IR-2026-0414-01
sha256sum network/netflow_validation.json >> hashes.txt
sha256sum endpoint_telemetry/processtree_validation.json >> hashes.txt
sha256sum endpoint_telemetry/persistence_validation.json >> hashes.txt
# Confirm integrity of entries with paths relative to this directory:
sha256sum -c hashes.txt
```

## Incident timeline entries

Add **one `ACTION` entry for each real containment action** only after obtaining its actual UTC timestamp, actor, console output, and observed result. Do not use example timestamps as if confirmed. The later mock checks can be logged as `OBSERVATION` entries, not as evidence that a VLAN change or EDR isolation command was executed.

**Task 4 completion assessment:** Later network deny and clean-state indicators are supported by the supplied mock API; VLAN reassignment, precise C2 cutoff, endpoint isolation flag, jumpbox-only access, and action authorization are **not independently evidenced**. Therefore the Task 4 execution record is **not fully verified** from the supplied materials.
