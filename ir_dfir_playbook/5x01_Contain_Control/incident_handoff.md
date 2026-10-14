# Incident Handoff — IR-2026-0414-01

> **Disposition: OPEN — NOT READY FOR CLOSURE.** Authoritative consolidation of available exercise materials, with unresolved gaps explicitly identified. This handoff does not certify successful containment, eradication, or recovery.

## 1. Incident identity

| Field | Record |
|---|---|
| Incident ID | `IR-2026-0414-01` (Task 1 timeline uses alias `IR-20260414-01`; reconcile in case system) |
| Initial / current severity | SEV2 / **SEV1 recommended** following multi-host lateral movement and LIS report access; formal escalation unverified |
| Declared | `2026-04-14T02:51:04Z` — **exercise-assumed**, not backed by declaration log |
| Closed | **Not closed; timestamp: null** |
| IR Commander | James Chen, SOC Lead — named in exercise, authorization not evidenced |
| Scribe | On-call SOC Analyst (exercise role; individual not identified) |
| Primary alert | `A-20260414-9841`, rule `wz-edr-100041`, `2026-04-14T02:47:11Z` |
| Handoff basis | `incident_timeline.md`, `containment_decision.md`, `containment_execution.md`, `evidence_preservation.md`, `eradication_checklist.yaml`, `recovery_validation.sh`, available mock validation JSON and reported CLI output |

## 2. Executive summary

- Suspicious `powershell.exe` → `MSBuild.exe` execution on `WST-WS-031` and external TCP to `185.220.101.47:443` triggered the alert.
- Proxy records show a Microsoft 365 lookalike site, credential-submission endpoint POST, and `update.zip` download; actual submitted contents remain unknown.
- `MEDDEFENSE\dmarsh` authentication moved from `WST-WS-031` to `WST-WS-017`, then to `LIS-WSIDE-01`; expansion log includes 14 LIS patient-report PDF reads.
- `WST-WS-017` established suspicious `msbuild.exe` traffic to `91.234.99.107:443`; exfiltration is not established.
- Severity escalation to SEV1 is recommended; HIPAA breach-risk assessment is triggered, but reportability is undecided.
- Quarantine VLAN 999 was selected as the preferred containment strategy; 03:16–03:23 execution entries are **simulated and not operationally verified**.
- Mock validation later reports `WST-WS-031` rebuilt at 10:12Z, clean process/persistence state at 14:20–14:21Z, and egress deny/zero flows at 14:22Z; these do not prove the earlier execution steps.
- Eradication checklist: **0 complete / 15 pending**; latest script run: **0 PASS / 6 FAIL** due to unavailable local API and missing original hash manifest.

## 3. Scope and impact

| Dimension | Known / unresolved |
|---|---|
| User/account | Daniel Marsh, `MEDDEFENSE\dmarsh`; suspicious Azure AD sign-in and lateral authentication. Credential exposure suspected, not conclusively proven. |
| Host 1 | `WST-WS-031` (`10.42.118.31`): malware-related execution, persistence, first C2. |
| Host 2 | `WST-WS-017`: lateral logon and MSBuild connection to second C2 IP. |
| Host 3 | `LIS-WSIDE-01`: lateral logon and 14 PDF reads under `/LIS/reports/daily/`. |
| Data | Credentials/authentication metadata, clinical laboratory report PDFs (potential PHI), endpoint and network telemetry. |
| C2 indicators | `185.220.101.47`, `91.234.99.107`; suspicious login site `ms0365-support.login-verification.click`. |
| Impact limits | PDF access **does not establish exfiltration**; patient harm, disclosure recipients, and affected individuals not determined. |
| Timing caveat | Scope evidence supplied as a 03:34Z discovery includes events timestamped 03:41–03:43Z; verify acquisition/clock chronology before treating them as known at 03:34Z. |

## 4. Timeline — verbatim append-only source (UTC)

The following reproduces the current `incident_timeline.md` without silently changing its SEV2 header or converting exercise actions into confirmed events. Any new SEV1 declaration must be appended to the source timeline with a verified time.

# Incident Timeline: IR-20260414-01

## Header

- incident_id: IR-20260414-01
- declared_at: 2026-04-14T02:51:04Z
- declared_by: On-call SOC Analyst (exercise role)
- initial_severity: SEV2
- current_severity: SEV2
- ir_commander: James Chen, SOC Lead
- scribe: On-call SOC Analyst (exercise role)

> Exercise assumption: the incident declaration at 02:51:04Z is taken from the assignment's example, not independently evidenced by the supplied alert or proxy log. Replace it with the actual lab declaration time if available. The entries below distinguish observed events from analyst decisions. Append future updates; do not rewrite prior operational entries.

## Legend

- OBSERVATION: raw fact from an alert, log, or artifact
- DECISION: a choice made by an authorized actor, with rationale
- ACTION: an operation executed against an asset, with owner
- COMMUNICATION: a message sent or received, with audience
- EVIDENCE: a preserved artifact with hash and storage path

## Entries

- 2026-04-13T18:13:44Z | OBSERVATION | Proxy logging service | dmarsh accessed an Outlook message URL before visiting a lookalike Microsoft 365 domain | source=proxy_24h_dmarsh.log | certainty=confirmed
- 2026-04-13T18:14:02Z | OBSERVATION | Proxy logging service | dmarsh accessed https://ms0365-support.login-verification.click/auth (HTTP 200) from an Outlook message referrer | source=proxy_24h_dmarsh.log | certainty=confirmed
- 2026-04-13T18:14:41Z | OBSERVATION | Proxy logging service | dmarsh POSTed to the lookalike site's /auth/submit endpoint (HTTP 302); credential contents are unknown | source=proxy_24h_dmarsh.log | certainty=confirmed
- 2026-04-13T18:14:43Z | OBSERVATION | Proxy logging service | dmarsh requested /auth/drop/update.zip (HTTP 200; 421004 logged bytes); execution is not established | source=proxy_24h_dmarsh.log | certainty=confirmed
- 2026-04-14T02:46:41Z | OBSERVATION | WazuhEDR | powershell.exe PID 7812 started with execution-policy bypass, hidden window and encoded command under MEDDEFENSE\dmarsh | source=alert_A-20260414-9841.json | certainty=confirmed
- 2026-04-14T02:46:44Z | OBSERVATION | Proxy logging service | CONNECT request to 185.220.101.47:443 recorded without a completed-status indication | source=proxy_24h_dmarsh.log | certainty=confirmed
- 2026-04-14T02:46:57Z | OBSERVATION | WazuhEDR | PowerShell spawned MSBuild.exe PID 8104 executing C:\Users\dmarsh\AppData\Local\Temp\update.xml | source=alert_A-20260414-9841.json | certainty=confirmed
- 2026-04-14T02:47:02Z | OBSERVATION | WazuhEDR | MSBuild PID 8104 established outbound TCP from 10.42.118.31:54917 to 185.220.101.47:443 | source=alert_A-20260414-9841.json | certainty=confirmed
- 2026-04-14T02:47:08Z | OBSERVATION | Proxy logging service | Additional CONNECT 200 event recorded for 185.220.101.47:443 | source=proxy_24h_dmarsh.log | certainty=confirmed
- 2026-04-14T02:47:11Z | OBSERVATION | WazuhEDR rule wz-edr-100041 | Alert A-20260414-9841 fired: suspicious PowerShell-to-MSBuild execution with outbound connection on clinical workstation WST-WS-031 | source=alert_A-20260414-9841.json | certainty=confirmed
- 2026-04-14T02:47:11Z | OBSERVATION | WazuhEDR enrichment | Internal intelligence categorized remote IP 185.220.101.47 as Tor exit/anonymizer/high-risk; malicious use and exfiltration not yet established | source=alert_A-20260414-9841.json | certainty=confirmed
- 2026-04-14T02:51:04Z | DECISION | On-call SOC Analyst (exercise role) | Incident IR-20260414-01 declared at SEV2 due to suspicious execution and established high-risk outbound traffic on a high-criticality clinical workstation with LIS access; credential theft and data exposure unconfirmed (exercise-assumed declaration time) | source=alert_A-20260414-9841.json; proxy_24h_dmarsh.log; assignment example | certainty=confirmed
- 2026-04-14T02:52:18Z | OBSERVATION | soc-evidence-collector v2.1 | Proxy log export timestamp recorded; no evidence integrity hash or custody storage path supplied | source=proxy_24h_dmarsh.log | certainty=confirmed

## Next entries (append only)

Append actual evidence acquisition with hashes and storage paths, containment evaluation and authorization, actions, communications, scope reassessment, eradication verification, recovery proof, and handoff as they occur. If an earlier conclusion changes, append a correction referencing the original entry; do not edit that entry.

## Outstanding questions

- Did the suspicious POST expose credentials? Not confirmed.
- Was update.zip saved or executed? Not confirmed.
- Did the external connection carry command-and-control or exfiltrated data? Not confirmed.
- Are additional systems or accounts affected? Not confirmed.

## Task 3 containment decision (planning entry; appended, no execution claimed)

- 2026-04-14T03:10:00Z | DECISION | On-call SOC Analyst (exercise planning timestamp; actual decision time unverified) | Recommend Option A: quarantine WST-WS-031 to VLAN 999 after priority volatile evidence capture and clinical coordination; avoids destructive power-off and incomplete selective process blocking; James Chen approval and actual execution remain pending | source=containment_decision.md | certainty=possible

## Task 4 containment execution — awaiting operational evidence

- No Task 4 containment ACTION is recorded as executed: supplied evidence does not contain switchport change logs, firewall rule commits, post-containment netflow/packet capture, endpoint containment audit, or jumpbox reachability results. See `containment_execution.md` for the five step-by-step ACTION templates. Append each entry with its actual UTC timestamp and evidence **only after execution**; do not convert illustrative timestamps into confirmed events.

## Task 4 follow-up — mock validation observations (appended)

- 2026-04-14T10:12:00Z | OBSERVATION | Mock endpoint validation dataset | WST-WS-031 reportedly rebuilt from a clean baseline; the supplied JSON does not identify who performed the rebuild | source=mock_validation_api/endpoint/processtree/WST-WS-031.json | certainty=confirmed
- 2026-04-14T14:20:00Z | OBSERVATION | Mock endpoint validation API | No PowerShell-parent/MSBuild-child process tree in 1,284 inspected sample trees; clean-state verification after reported rebuild, not proof of earlier isolation action | source=mock_validation_api/endpoint/processtree/WST-WS-031.json | certainty=confirmed
- 2026-04-14T14:21:00Z | OBSERVATION | Mock endpoint validation API | No GUID-named scheduled tasks or listed Run-key entries; update.xml and update.exe reported absent | source=mock_validation_api/endpoint/persistence/WST-WS-031.json | certainty=confirmed
- 2026-04-14T14:22:00Z | OBSERVATION | Mock SIEM validation API | Synthetic post-remediation netflow response reports egress deny verified for 185.220.101.47 and 91.234.99.107 and zero packets/bytes; does not establish precise containment cutoff | source=mock_validation_api/siem/netflow.json; containment_execution.md | certainty=confirmed

No switch, firewall-commit, EDR isolation, or jumpbox-test ACTION entries can be verified from the available source files; append those only when operational audit evidence is supplied.


## Task 4 ACTION entries — LAB-SIMULATED, not independently verified

- 2026-04-14T03:16:04Z | ACTION | Steve (exercise-assigned actor) | LAB-SIMULATED: switch/NAC VLAN reassignment of WST-WS-031 to VLAN 999; switch audit unavailable | source=containment_execution.md | certainty=possible
- 2026-04-14T03:17:21Z | ACTION | Steve (exercise-assigned actor) | LAB-SIMULATED: publish firewall egress deny for 185.220.101.47; later mock API reports deny verified at 14:22Z, but rule commit timestamp unknown | source=containment_execution.md; mock_validation_api/siem/netflow.json | certainty=possible
- 2026-04-14T03:18:47Z | ACTION | Steve (exercise-assigned actor) | LAB-SIMULATED: request endpoint containment flag for WST-WS-031 if supported; EDR action audit unavailable | source=containment_execution.md | certainty=possible
- 2026-04-14T03:20:13Z | ACTION | Steve (exercise-assigned actor) | LAB-SIMULATED: post-isolation C2 packet capture/flow verification; no contemporaneous capture provided | source=containment_execution.md | certainty=possible
- 2026-04-14T03:22:04Z | ACTION | Steve (exercise-assigned actor) | LAB-SIMULATED: verify management reachability from IR jumpbox and rejection from user VLAN; test outputs unavailable | source=containment_execution.md | certainty=possible
- 2026-04-14T03:23:41Z | ACTION | Steve (exercise-assigned actor) | LAB-SIMULATED: test LIS network access restriction and clinical fallback; no clinical verification supplied | source=containment_execution.md | certainty=possible

## 5. Decisions

| Decision | Reference / outcome |
|---|---|
| Initial incident declaration | `incident_timeline.md`: SEV2 at exercise-assumed 02:51:04Z; verify actual authorization. |
| Containment selection | `containment_decision.md`: prefer quarantine VLAN 999, restricted jumpbox access, preserve volatile evidence; reject power-off (RAM loss) and selective kill alone (persistence/missed processes). Approval pending. |
| Containment execution | `containment_execution.md`: proposed six-step scenario; no contemporaneous NAC/firewall/EDR/PCAP/jumpbox audit supplied. |
| Scope expansion | New authentication and LIS evidence supports **recommended SEV1 escalation** and expansion to three hosts; formal decision entry pending. |
| `krbtgt` | `eradication_checklist.yaml`: investigate ticket abuse/secret compromise before deciding on disruptive double reset; Pass-the-Ticket/`krbtgt` compromise not proven by TGS requests alone. |
| Closure | **Deferred** until containment proof, eradication completion, recovery PASS, hash reconciliation, and clinical/legal sign-off. |

## 6. Evidence index / chain of custody

**Expected evidence root:** `/evidence/IR-2026-0414-01`; **Task 2 manifest:** `/evidence/IR-2026-0414-01/hashes.txt`. No original manifest, actual SHA-256 values, or chain-of-custody receipts were supplied. Paths below are planned destinations from the preservation runbook, **not proof of capture**. Do not invent hashes.

| Artifact | Storage path | SHA-256 | Preservation |
|---|---|---|---|
| SIEM alert | `/evidence/IR-2026-0414-01/siem/alert_A-20260414-9841.json` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| EDR export | `/evidence/IR-2026-0414-01/endpoint_telemetry/edr_wst_ws_031_24h.jsonl` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| Proxy export | `/evidence/IR-2026-0414-01/proxy_dns/proxy_24h_dmarsh.log` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| AD/Azure authentication | `/evidence/IR-2026-0414-01/authentication/auth_24h_dmarsh.json` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| Scope expansion auth log | `/evidence/IR-2026-0414-01/authentication/auth_expansion_0334Z.log` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| RAM capture (planned) | `/evidence/IR-2026-0414-01/memory/wst-ws-031.mem` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| Process list (planned) | `/evidence/IR-2026-0414-01/process_tree/wst-ws-031-processes.csv` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| TCP connections (planned) | `/evidence/IR-2026-0414-01/network/wst-ws-031-tcp.csv` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| UDP connections (planned) | `/evidence/IR-2026-0414-01/network/wst-ws-031-udp.csv` | **Unavailable — no Task 2 manifest supplied** | Not verified |
| DNS export (planned) | `/evidence/IR-2026-0414-01/proxy_dns/dns_24h_dmarsh.jsonl` | **Unavailable — no Task 2 manifest supplied** | Not verified |

**Later mock validation evidence:** `mock_validation_api/endpoint/processtree/WST-WS-031.json` (14:20Z), `mock_validation_api/endpoint/persistence/WST-WS-031.json` (14:21Z), and `mock_validation_api/siem/netflow.json` (14:22Z); SHA-256 and custody paths unavailable. **To complete this index:** import the original Task 2 manifest and copy every actual artifact/path/hash line; run `cd /evidence/IR-2026-0414-01 && sha256sum -c hashes.txt`, retain its output, and resolve discrepancies. Never create a new baseline to conceal missing original hashes.

## 7. Eradication status

**Source:** `eradication_checklist.yaml` — **15 total; 0 complete; 15 pending; 0 failed recorded**. All items have `executed_at: null` and `executed_by: null`. Categories: malware artifacts, processes, `dmarsh` password/session revocation, machine accounts on all three hosts, `krbtgt` decision, and network controls for both C2 IPs. Later clean-state mock responses do **not** automatically change execution statuses. Owners: IR Commander to assign SOC/endpoint/AD/network engineers.

## 8. Recovery validation — latest observed terminal output

**Source:** user-provided `./recovery_validation.sh` run; run timestamp not supplied. This is a compact faithful transcription of the six FAIL results (repeated curl diagnostics collapsed); **not a successful validation**.

```text
$ ./recovery_validation.sh
curl: (7) Failed to connect to 127.0.0.1:8080 (repeated for API checks)
[FAIL] process tree: all three host APIs unavailable/invalid
[FAIL] netflow: API evidence unavailable
[FAIL] persistence: all three host APIs unavailable/invalid
[FAIL] service health: epic-api HTTP=000; lis-api HTTP=000
[FAIL] detection: rule/synthetic-hit API unavailable
[FAIL] evidence hashes: manifest missing (/evidence/IR-2026-0414-01/hashes.txt)
FAILED CHECKS (6): process tree; netflow; persistence; service health; detection; evidence hashes
```

**Interpretation:** `127.0.0.1:8080` was not serving the mock API, and `/evidence/IR-2026-0414-01/hashes.txt` was absent. Re-run with the server started from `mock_validation_api/` and the genuine Task 2 evidence store. Do not treat API connectivity failure as a finding of active compromise.

## 9. Outstanding actions — owners and deadlines

Deadlines below are **proposed relative SLAs from handoff acceptance**, not agreed operational commitments; the receiving IR Commander must assign UTC due times.

| Action | Accountable owner | Proposed deadline |
|---|---|---|
| Formally declare SEV1, reconcile incident ID and event chronology; append decisions to timeline | James Chen / IR Commander | Within 30 min of acceptance |
| Obtain VLAN/switch, firewall commit, EDR isolation, timestamped C2 flow, and jumpbox-only audit proof; coordinate clinical fallback | Network lead + SOC lead + clinical lead | Within 1 h |
| Acquire/reconcile original Task 2 hashes and chain of custody; populate evidence index | DFIR evidence custodian | Within 2 h |
| Investigate PDF access, potential PHI exposure and exfiltration; preserve LIS audit and identity evidence | DFIR + LIS owner | Within 4 h |
| Assign and complete 15 eradication items, including account/session and machine-account resets; document `krbtgt` decision | Endpoint lead + AD/identity lead | Priority; initial plan within 2 h |
| Start mock API, verify real evidence manifest, rerun all six recovery checks and attach full output | Recovery lead / SOC analyst | After eradication; before closure |
| Complete HIPAA breach-risk/legal assessment, document notification decision and any required clocks | Privacy Officer + Legal | Begin immediately; statutory deadlines per assessment |
| Obtain clinical restoration and IR Commander closure approval; issue final communication | Clinical lead + IR Commander | Only after all closure gates pass |

## 10. Regulatory posture

**HIPAA breach-notification assessment is triggered for review, not automatically a reportable breach determination.** The suspicious account activity and access to 14 laboratory-report PDFs on `LIS-WSIDE-01` create a credible risk of unauthorized access to protected health information; the record does not yet establish data exfiltration, recipients, patient count, or whether an applicable exception or low-probability-of-compromise finding can be supported. The **Privacy Officer, supported by Legal/Compliance**, owns the documented risk assessment, preservation of access/audit evidence, determination of applicability and notification obligations, and any legally required notices. Escalate promptly and record decisions and dates; do not declare HIPAA notification complete or unnecessary from these logs alone.

## 11. Communications log (UTC)

| UTC time | Audience | Template / channel | Evidence of issuance |
|---|---|---|---|
| Not supplied | IR Commander / SOC shift | Initial SEV2 incident notification (template not supplied) | **No sent-message record available** |
| Not supplied | Clinical laboratory lead | Workstation isolation / downtime coordination (template not supplied) | **No sent-message record available** |
| Not supplied | IR Commander, Privacy/Legal | SEV1 expansion and potential PHI exposure notice (template not supplied) | **No sent-message record available** |
| Not supplied | Receiving analyst | This handoff document | **Draft prepared; delivery/acknowledgment not evidenced** |

**Handoff acceptance:** receiving analyst `PENDING`; acceptance UTC `PENDING`; closure authorization `PENDING`. Preserve this document and all referenced evidence under the incident legal-hold/retention policy if directed by Legal.
