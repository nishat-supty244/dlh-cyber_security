# Containment Decision: IR-2026-0414-01

- Incident: IR-2026-0414-01 (same incident as Task 1 file `IR-20260414-01`; normalize identifier across deliverables)
- Asset: `WST-WS-031` (`10.42.118.31`), West Campus Laboratory, high-criticality clinical workstation with LIS access
- Account: `MEDDEFENSE\dmarsh`
- Severity: SEV2 (reassess if scope or patient impact increases)
- Decision status: **Recommended — pending documented approval and evidence-preservation completion**
- Evidence: `alert_A-20260414-9841.json`, `edr_wst_ws_031_24h.jsonl`, `proxy_24h_dmarsh.log`, `auth_24h_dmarsh.json`

## Known facts and uncertainties

- EDR recorded `update.exe` running as PID 7204, spawning PowerShell PID 7812 and MSBuild PID 8104; MSBuild established outbound TCP connections to `185.220.101.47:443`.
- EDR records a Registry Run entry (`WindowsUpdateSvc`) and a logon-triggered scheduled task launching `update.exe`. Terminating one process does not eliminate persistence.
- The proxy recorded access to a Microsoft 365 lookalike site, a POST to `/auth/submit`, and download of `update.zip`; Azure AD recorded a risky sign-in from `45.63.9.88` with an impossible-travel signal.
- Credential compromise, exfiltration, lateral movement, clinical-service impact, spare-workstation availability, and successful acquisition of volatile evidence **have not been confirmed**.

## Candidate strategies

### A. Network isolation — quarantine VLAN (preferred)

- **action:** After priority volatile collection and clinical coordination, move `WST-WS-031` to dedicated quarantine VLAN 999; deny all other ingress/egress, permit only explicitly approved forensic jumpbox traffic (and essential EDR management if required). Verify ACLs and actual flow cessation.
- **effect on attacker:** Cuts external command-and-control and limits lateral movement; attacker-controlled processes may remain on the host, so monitor locally.
- **effect on evidence:** Keeps machine powered on and generally preserves RAM, processes, files and persistence; disrupts active connections and changes network state, so capture connections and memory first where safe.
- **effect on patient care:** Removes this workstation's LIS/network access; could interrupt lab workflows. **Spare workstation availability is unverified**, so contact the laboratory/clinical lead to confirm an approved alternate or downtime procedure.
- **time to execute:** Estimated 3–5 minutes once authorized and switch/EDR access is available; not a measured time.
- **reversibility:** High; revert switch port/VLAN/ACL assignment, but only after IR and clinical approval, and verify the return path.

### B. Host power-off

- **action:** Shut down or power off `WST-WS-031` immediately.
- **effect on attacker:** Stops on-host execution and network communications while powered off; does not revoke stolen credentials or remove persistence on disk.
- **effect on evidence:** **Destroys live RAM, process state, and active connections**; shutdown may alter disk artifacts. Avoid unless patient/safety or uncontrolled spread demands it.
- **effect on patient care:** Workstation unavailable; potential LIS workflow disruption until replacement or restoration.
- **time to execute:** Estimated under 1–2 minutes, depending on access and shutdown method.
- **reversibility:** Power can be restored, but volatile evidence cannot be recovered and malware may restart.

### C. Selective process termination + firewall egress block

- **action:** Block outbound traffic to `185.220.101.47:443` at a centrally managed firewall (and other confirmed destinations as discovered), then terminate verified malicious process tree (`update.exe` PID 7204, PowerShell PID 7812, MSBuild PID 8104) after recording PIDs and acquiring relevant memory. Monitor for restart and new destinations.
- **effect on attacker:** Interrupts known C2 and execution but may miss other destinations, injected code, scheduled-task relaunches, and stolen-credential access.
- **effect on evidence:** Process termination destroys live process memory and relationships; egress block modifies active connections. Requires evidence capture first.
- **effect on patient care:** Potentially retains more clinical network connectivity than quarantine, but process killing can destabilize the workstation and does not guarantee safety.
- **time to execute:** Estimated 2–5 minutes for known IP/processes, plus ongoing monitoring and tuning.
- **reversibility:** Firewall rules can be rolled back; terminated process state and lost volatile evidence cannot be restored.

## Chosen strategy: A — quarantine VLAN 999 (recommended, not yet executed)

**Rationale:** Quarantine VLAN isolation is preferred because it blocks the observed external connection and constrains further attacker communication without powering off the workstation, preserving more forensic state than Option B; it also provides stronger containment than Option C, which risks missing alternate C2 channels and the confirmed Run-key/scheduled-task persistence. The trade-off is loss of LIS connectivity from one high-criticality clinical workstation, so the clinical lead must first confirm a safe fallback or downtime process, and the responder must preserve RAM, process and connection snapshots before isolation when operationally safe. Unlike power-off, the VLAN change is reversible, although restoration must not occur merely to restore convenience while the host remains compromised.

## Execution window — Task 2 to Task 4

- Evidence preservation start: **pending actual collection record**.
- Evidence preservation end: **pending actual completion and SHA-256 manifest verification**; do not reuse the example `03:14Z` as fact.
- Containment execution start: **pending authorization and Task 4 execution**; example `03:16Z` is illustrative only.
- Maximum planned gap: **as short as practicable, target ≤2 minutes after critical volatile evidence and safety checks are complete**; if risk escalates, contain sooner and document evidence lost.
- Before execution: check memory capture and process/network snapshots; record capture completion and hashes in `/evidence/IR-2026-0414-01/hashes.txt`; verify clinical fallback and authorized network-change access.
- Record actual timestamps (UTC ISO 8601), evidence IDs, change ticket and operator in `incident_timeline.md` at the moment each event occurs.

## Approval

- **Approving authority:** James Chen, SOC Lead / IR Commander, per scenario.
- **Approval status:** **Pending**; no approval time or authorization message supplied.
- **Clinical coordination:** West Campus laboratory/clinical duty lead must confirm continuity arrangements before disruptive isolation, unless an immediate threat necessitates emergency action under the incident policy.
- **Required record:** approver name, exact UTC approval time, approved strategy, clinical coordination result and change/ticket reference. The task's example `03:10Z` is **not** proof of approval.

## Execution checks (Task 4; do not mark completed here)

1. Confirm forensic access through IR jumpbox is permitted by quarantine ACL; verify VLAN 999 policy denies other traffic.
2. Record original switch port/VLAN/ACL and endpoint management state for rollback.
3. After authorization, move only `WST-WS-031` to quarantine VLAN 999; record actual time, operator and change ID.
4. Verify loss of connectivity to `185.220.101.47:443` and other nonapproved destinations; verify forensic jumpbox connectivity.
5. Monitor EDR for process restart, additional hosts, credential misuse and changes to clinical availability; reassess severity and scope.

## Rollback / unintended impact

- **Trigger:** Clinical lead reports unsafe laboratory workflow interruption, or isolation unexpectedly affects additional systems.
- **First response:** Activate approved alternative workstation or downtime workflow; prioritize patient safety and inform James Chen.
- **If emergency restoration is authorized:** Preserve current state and change records; restore original VLAN/ACL (target ≤5 minutes, estimate not guarantee), then apply Option C's targeted egress controls as a temporary compensating measure and intensify monitoring.
- **Safety gate:** Do not reconnect a known-compromised host to production solely for convenience; IR commander and clinical lead must explicitly approve any risk-bearing rollback.
- **Verification:** Confirm LIS workflow continuity, original network configuration or approved fallback, continued block of malicious traffic, and no unexpected lateral connections.
- **Documentation:** Append COMMUNICATION, DECISION, ACTION and OBSERVATION entries with exact UTC times, responsible actors, evidence and outcomes.

## Timeline linkage

A planning `DECISION` entry is appended to `incident_timeline.md` referencing this document. It records **selection for approval**, not containment execution or an authorization that has not occurred. Replace any exercise-assumed planning timestamp with the actual decision timestamp in a new corrective entry if the lab provides one; preserve prior entries in the append-only timeline.
