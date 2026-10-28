
# MedDefense Health Systems — Containment Execution Record

**Incident ID:** IR-2026-0420-01  
**Severity:** SEV1 — Critical  
**Incident date:** 2026-04-20  
**Prepared by:** Nishat Sultana Supty
**Analysis environment:** Kali Linux  
**Strategy:** Selective host isolation, C2 egress blocking and credential containment  
**Authorization:** IR Commander approval required  
**Execution status:** Evidence analysis completed; operational containment not executed  
**Time standard:** UTC  
**Record policy:** Append-only

---

## 1. Purpose and Execution Limitations

This document records the investigation supporting containment and defines the operational sequence required to contain the MedDefense incident.

The student was provided four evidence resources:

- `sysmon_multihost.sample.jsonl`
- `proxy_72h.sample.jsonl`
- `fileserver_access.sample.json`
- `torres_call_transcript.md`

These resources were analyzed using Kali Linux.

No live MedDefense endpoints, EDR console, firewall, Active Directory environment or post-containment telemetry were provided.

Therefore:

- Historical investigation findings are documented as completed analysis.
- Host isolation, firewall changes and credential revocation are documented as planned actions.
- No successful containment or C2 disconnection is claimed.
- Actual execution timestamps and outcomes remain pending.

Each operational action must be authorized, executed, verified and appended to the incident timeline when an authorized environment becomes available.

---

## 2. Confirmed Pre-Containment Evidence

### 2.1 C2 Infrastructure

**Domain:** `staging.office365-cdn.net`  
**IP address:** `45.152.66.114`  
**Port:** TCP/443  
**Suspicious executable:** `C:\ProgramData\Microsoft\svchost32.exe`

The proxy logs classify the destination as:

`cobalt_strike_team_server_known`

The logs also identify a beacon pattern:

`sleep_60s_jitter_10pct`

### 2.2 Affected Assets

| Asset | IP address | Evidence | Containment treatment |
|---|---|---|---|
| CS-WS-101 | 10.30.12.101 | C2, initial compromise, ransomware staging, suspected credential access | Full network isolation |
| CS-WS-104 | 10.30.12.104 | C2 and ransomware staging | Full network isolation |
| CS-WS-107 | 10.30.12.107 | C2 and ransomware staging | Full network isolation |
| CS-WS-112 | 10.30.12.112 | C2 and ransomware staging | Full network isolation |
| FILE-SVR-01 | 10.30.10.20 | Historical C2 connections and unauthorized clinical file access | Restricted network isolation |

FILE-SVR-01 has historical C2-related connections but no confirmed active beacon at containment time.

### 2.3 Compromised Account Evidence

**Account:** `MEDDEFENSE\jdoe`  
**Source:** CS-WS-101  
**Target:** FILE-SVR-01  
**Authentication:** Kerberos  
**Logon type:** 3  
**Logon ID:** `0xAF12C4B8`

The file-server log summary records:

- 1,847 Windows Security Event ID 4663 file-access events.
- Access between 2026-04-19 02:14:01Z and 02:41:12Z.
- Access to clinical laboratory and patient-note PDFs.
- Suspicious process `svchost32.exe`.
- No documented legitimate clinical need for this account to access those files.

The account is considered compromised or attacker-abused for containment planning.

The supplied proxy sample shows no other usernames, but this does not exclude additional compromised accounts.

---

## 3. Containment Execution Sequence

The following ACTION records define the authorized execution order.
### ACTION-001 — Authorize Containment

**Actor:** IR Commander — James Chen; Clinical Operations Lead  
**Action:** Approve selective containment and confirm clinical fallback arrangements.  
**Expected outcome:** Authorization obtained and patient-care safeguards confirmed.  
**Observed outcome:** NOT EXECUTED  
**Deviation notes:** No operational authorization record provided.  
**Status:** PLANNED

### ACTION-002 — Block C2 Egress
 
**Actor:** Network Security Engineer

**Action:**

1. Add a high-priority firewall deny rule for outbound traffic to `45.152.66.114`.
2. Block `staging.office365-cdn.net` using approved DNS and web-filtering controls.
3. Apply the policy to all affected network segments.
4. Verify the rule order and confirm the traffic path traverses the controls.
5. Enable firewall logging for matching traffic.

**Expected outcome:** New outbound connections to the known C2 destination are blocked.

**Observed outcome:** NOT EXECUTED

**Deviation notes:** No firewall access was provided. A domain block alone is insufficient if malware connects directly to an IP or uses another destination.

**Evidence:** `proxy_72h.sample.jsonl`, `sysmon_multihost.sample.jsonl`

**Status:** PLANNED

**Illustrative Linux lab command:**

```bash id="t6e2x1"
sudo nft add rule inet filter forward \
  ip daddr 45.152.66.114 counter drop
```

This command is an example, not an executed action. It requires an existing forwarding chain and a firewall positioned on the relevant traffic path. Production configuration must follow the approved firewall platform.

### ACTION-003 — Isolate CS-WS-101
 
**Actor:** Endpoint Response Analyst

**Action:** Confirm clinical handoff, then apply EDR network isolation while keeping the host powered on if safe.

**Expected outcome:** CS-WS-101 cannot communicate with C2 or production systems except through approved forensic management channels.

**Observed outcome:** NOT EXECUTED

**Deviation notes:** Memory was reportedly acquired by Mike Torres at 19:38Z, but the image has not been independently verified.

**Status:** PLANNED

### ACTION-004 — Isolate CS-WS-104


**Actor:** Endpoint Response Analyst

**Action:** Apply EDR network isolation after clinical handoff.

**Expected outcome:** C2 and lateral network communication are interrupted.

**Observed outcome:** NOT EXECUTED  
**Deviation notes:** No EDR access provided.  
**Status:** PLANNED

### ACTION-005 — Isolate CS-WS-107

 
**Actor:** Endpoint Response Analyst

**Action:** Apply EDR network isolation after clinical handoff.

**Expected outcome:** C2 and lateral network communication are interrupted.

**Observed outcome:** NOT EXECUTED  
**Deviation notes:** No EDR access provided.  
**Status:** PLANNED

### ACTION-006 — Isolate CS-WS-112

 
**Actor:** Endpoint Response Analyst

**Action:** Apply EDR network isolation after clinical handoff.

**Expected outcome:** C2 and lateral network communication are interrupted.

**Observed outcome:** NOT EXECUTED  
**Deviation notes:** No EDR access provided.  
**Status:** PLANNED

**Execution note:** The four workstation isolations should be performed in parallel where possible, rather than waiting for each host to finish before starting the next.

### ACTION-007 — Restrict FILE-SVR-01


**Actor:** Server Administrator / Network Security Engineer / Clinical Operations Lead

**Action:**

1. Preserve existing forensic evidence where feasible.
2. Block internet egress to the known C2 destination.
3. Restrict unnecessary inbound and outbound connections.
4. Allow only explicitly approved clinical file-service paths.
5. Monitor the server for suspicious activity.
6. Validate that authorized clinical workflows remain functional.

**Expected outcome:** FILE-SVR-01 is logically isolated from unnecessary network access while essential clinical file services continue.

**Observed outcome:** NOT EXECUTED

**Deviation notes:** Historical C2 connections and suspicious file access justify restrictions. No active beacon is confirmed at containment time. Clinical dependencies must be validated before restrictive changes.

**Status:** PLANNED

---

## 4. Credential Revocation Sequence

### ACTION-008 — Identify Accounts Exposed During the 72-Hour Dwell


**Actor:** Identity and Access Management Analyst

**Action:**

1. Review authentication records from the 72-hour dwell period.
2. Correlate logon events with compromised endpoints.
3. Identify user, administrator and service accounts involved.
4. Review Kerberos authentication and unusual remote logons.
5. Identify accounts with access to clinical files.
6. Prepare an evidence-backed credential containment list.

**Expected outcome:** All identified compromised or exposed accounts are prioritized for revocation.

**Observed investigation findings:**

The supplied logs identify:

- Account: `MEDDEFENSE\jdoe`
- Source: `CS-WS-101`
- Target: `FILE-SVR-01`
- Logon event: 4624
- Logon ID: `0xAF12C4B8`
- Authentication: Kerberos
- File-access events: 1,847
- Access window: 2026-04-19 02:14:01Z–02:41:12Z
- Session termination event: 4634 at 02:41:18Z

**Deviation notes:** The full authentication history was not provided. The sample identifies one account but cannot establish that it was the only account exposed.

**Status:** PARTIALLY ANALYZED — full account inventory pending

### ACTION-009 — Revoke Compromised Credentials


**Actor:** Identity and Access Management Analyst

**Planned sequence:**

1. Obtain IR Commander approval.
2. Arrange a safe scheduling-workflow fallback.
3. Temporarily disable `MEDDEFENSE\jdoe`.
4. Revoke applicable active sessions and authentication tokens.
5. Reset the password from a trusted administrative system.
6. Review and invalidate affected Kerberos authentication where technically supported.
7. Restrict or terminate remaining access from compromised endpoints.
8. Investigate other privileged and service accounts used during the dwell.
9. Rotate credentials confirmed to be exposed.
10. Restore legitimate access only after identity verification and IR approval.

**Expected outcome:** Compromised credentials and active sessions no longer provide attacker access.

**Observed outcome:** NOT EXECUTED

**Deviation notes:** Password resets alone may not immediately invalidate every existing Kerberos ticket. Additional session controls, ticket lifetime considerations and endpoint isolation are necessary.

**Status:** PLANNED

---

## 5. Proof of C2 Disconnection

### ACTION-010 — Verify Beacon Severance

**UTC timestamp:** PENDING  
**Actor:** SOC Analyst / Network Security Engineer

**Action:**

1. Confirm all four workstation isolation states in EDR.
2. Confirm FILE-SVR-01 network restrictions.
3. Verify the C2 IP and domain blocking controls are active.
4. Review firewall deny events and rule counters.
5. Review post-containment proxy, DNS and network telemetry.
6. Confirm no successful connections to the known C2 destination after containment.
7. Investigate any alternate suspicious destinations.
8. Record the observation window and supporting event IDs.

**Expected outcome:** No successful C2 communication from affected hosts during the defined verification window.

**Observed outcome:** NOT VERIFIED

**Deviation notes:** The available logs contain only historical pre-containment activity. No post-containment evidence was provided.



### Required Verification Matrix

| Verification item | Evidence required | Result |
|---|---|---|
| CS-WS-101 isolation | EDR isolation confirmation | PENDING |
| CS-WS-104 isolation | EDR isolation confirmation | PENDING |
| CS-WS-107 isolation | EDR isolation confirmation | PENDING |
| CS-WS-112 isolation | EDR isolation confirmation | PENDING |
| FILE-SVR-01 restrictions | Firewall/ACL confirmation | PENDING |
| C2 IP blocking | Firewall configuration and deny logs | PENDING |
| C2 domain blocking | DNS/web-filtering logs | PENDING |
| Credential revocation | Identity-system audit logs | PENDING |
| Beacon severance | Post-containment network telemetry | NOT PROVEN |
| Clinical continuity | Clinical operations validation | PENDING |

**Verification conclusion:** The known C2 infrastructure has been identified, but successful beacon disconnection cannot be established without execution and post-containment evidence.

---

## 6. Clinical Operations Validation

### ACTION-011 — Validate Patient-Care Continuity


**Actor:** Clinical Operations Lead / IT Operations

**Action:**

1. Confirm emergency clinical workflows remain available.
2. Verify approved access to clinical files.
3. Confirm scheduling alternatives are available.
4. Record any clinical disruption caused by containment.
5. Activate approved downtime procedures where necessary.
6. Escalate patient-safety concerns immediately.

**Expected outcome:** Essential patient care remains functional through approved services or fallback procedures.

**Observed outcome:** NOT EXECUTED

**Deviation notes:** No clinical operations environment was available for validation.

**Status:** PLANNED

---

## 7. Rollback Procedure

### ACTION-012 — Controlled Rollback if Required

**UTC timestamp:** PENDING  
**Actor:** IR Commander / Clinical Operations Lead / IT Operations

**Trigger:** Confirmed patient-safety impact or essential clinical service failure without a working fallback.

**Action:**

1. Document the affected clinical workflow.
2. Obtain IR Commander and clinical authorization.
3. Restore the minimum necessary trusted access.
4. Maintain C2 blocking and credential restrictions.
5. Avoid reconnecting compromised endpoints.
6. Verify clinical service recovery.
7. Record residual security risks and compensating controls.

**Expected outcome:** Essential clinical services are restored without unnecessarily reintroducing attacker access.

**Observed outcome:** NOT EXECUTED

**Status:** CONDITIONAL

---

## 8. Append-Only Incident Timeline Integration

Every completed operational ACTION must be appended to `incident_timeline.md` with:

- UTC timestamp
- Action ID
- Actor
- Asset
- Action
- Expected outcome
- Observed outcome
- Evidence reference
- Deviation notes

### Example Timeline Entry

The following is a template, not a completed event.

```markdown
### [ACTUAL_UTC_TIMESTAMP] — ACTION-003

- Type: ACTION
- Actor: [Actual responder]
- Asset: CS-WS-101
- Action: EDR network isolation applied
- Expected outcome: C2 and lateral connectivity interrupted
- Observed outcome: [Actual verified result]
- Evidence: [EDR event ID / network log]
- Deviation notes: [None or explanation]
```

Entries must be appended only after an action occurs.

Historical investigation findings may be added as separate ANALYSIS entries with actual analysis timestamps, but must not be represented as completed containment actions.

Do not overwrite or delete previous timeline entries.

---

## 9. Evidence Sources and Integrity

| Evidence file | SHA-256 |
|---|---|
| `sysmon_multihost.sample.jsonl` | `0fc34f78e86a403e9e262cad7b621713a464eae18d1bb70d5f743a7f32e49099` |
| `proxy_72h.sample.jsonl` | `1c82b57868333bdc40516c20fed99e24e41dd3fbb052e8cd27b67f34dd208e3a` |
| `fileserver_access.sample.json` | `dc184b375e6c3b1b76f9c9f8959a00ed7c0e0c4092c5d9f45c66ba8e2b538b7a` |
| `torres_call_transcript.md` | `f2f56e107f8afbe924ab9d5544c9950b236ebe4680b9f41e673a23adc8a865a0` |

Hashes were calculated using Kali Linux.

The supplied files are historical evidence, not proof of successful containment.

---

## 10. Final Execution Summary

| Requirement | Status |
|---|---|
| Scope affected assets | COMPLETED |
| Identify C2 domain and IP | COMPLETED |
| Identify known compromised account | COMPLETED |
| Select containment strategy | COMPLETED |
| Define isolation sequence for five assets | COMPLETED — PLAN |
| Define C2 firewall and domain block | COMPLETED — PLAN |
| Define credential revocation sequence | COMPLETED — PLAN |
| Execute host isolation | NOT EXECUTED |
| Apply C2 blocking | NOT EXECUTED |
| Revoke compromised credentials | NOT EXECUTED |
| Prove C2 beacon severed | NOT VERIFIED |
| Validate clinical operations | NOT EXECUTED |
| Append completed containment actions | NONE TO APPEND |

## 11. Final Assessment

The investigation identified Cobalt Strike activity on four workstations, historical suspicious C2 communication from FILE-SVR-01, and unauthorized clinical file access associated with `MEDDEFENSE\jdoe`. The selected containment strategy combines workstation isolation, restricted file-server access, C2 egress blocking and credential revocation. All operational steps have been documented with expected outcomes, responsible roles and verification requirements.


**Final status:** Evidence-based containment plan and execution record prepared. Operational execution remains pending.
