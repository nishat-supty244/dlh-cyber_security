# Containment Execution: IR-2026-0414-01

**Target:** WST-WS-031 (`10.42.118.31`)  
**Selected strategy:** Quarantine VLAN 999, restricted IR jumpbox access, and explicit C2 egress deny  
**Record type:** **LAB-SIMULATED execution scenario**. The 03:16–03:23 actions below are proposed exercise records modeled on the Task 4 example, **not independently observed operational events**. The later mock API outputs are real *provided simulation data*, not proof of those earlier commands.  
**Operator:** Steve, on-call SOC analyst (**scenario-assigned; not confirmed in supplied logs**)  
**Approval:** James Chen, IR Commander (**approval required; actual approval record unavailable**)

## Execution steps — scenario records (not independently verified)

| UTC timestamp (illustrative) | Actor | Command / console action | Expected result | Observed result / evidence | Deviation notes |
|---|---|---|---|---|---|
| 2026-04-14T03:16:04Z | Steve (scenario) | NAC/switch console: locate switchport for `WST-WS-031`; assign access VLAN `999`; apply quarantine ACL permitting only IR jumpbox management traffic; save config | Production network and internet blocked; jumpbox forensic access remains | **NOT VERIFIED at 03:16.** Requires NAC/switch audit event showing host MAC, switch/port, old/new VLAN, commit time | Missing switch audit; do not mark confirmed |
| 2026-04-14T03:17:21Z | Steve (scenario) | Perimeter firewall console: create enabled, logged deny rule: `src=10.42.118.31`, `dst=185.220.101.47`, `service=any`, `action=deny`; publish policy (adjust source to actual post-quarantine IP) | C2 egress blocked and logged | **PARTIALLY SUPPORTED LATER:** mock `siem/netflow.json` at 14:22Z reports `egress_deny_verified` including `185.220.101.47`, with 0 packets/bytes in its reported window. No 03:17 firewall commit record | Exact rule, scope and installation time not verified |
| 2026-04-14T03:18:47Z | Steve (scenario) | EDR management console: open `WST-WS-031`, select **Isolate/Contain device**, retain IR management channel if supported; record job ID | Endpoint containment enabled; approved IR channel remains | **NOT VERIFIED.** Supplied Wazuh alert is a detection, not an endpoint isolation audit event; Wazuh deployment may lack this control | If unsupported, record `N/A` and rely on VLAN/firewall isolation |
| 2026-04-14T03:20:13Z | Steve (scenario) | On switch SPAN / network sensor, capture 60 seconds of traffic for host `10.42.118.31` and remote `185.220.101.47`; analyze PCAP using `tshark -r c2_post_isolation.pcap -Y 'ip.addr == 185.220.101.47'` | No successful post-isolation C2 flows; denied attempts may appear in firewall logs | **NOT VERIFIED at 03:20.** No PCAP or timestamped netflow cutoff supplied. Later 14:22Z mock SIEM reports 0 packets/bytes | Do not claim a 60-second PCAP or last-packet timestamp without a capture |
| 2026-04-14T03:22:04Z | Steve (scenario) | From approved IR jumpbox, test permitted management connection to **current quarantine IP**; from user VLAN, test same destination; inspect quarantine ACL and session logs | Jumpbox succeeds, user VLAN fails | **NOT VERIFIED.** No source/destination test logs or post-VLAN IP mapping provided | ICMP alone is insufficient to prove 'only jumpbox' access; validate actual management port and ACL |
| 2026-04-14T03:23:41Z | Steve (scenario) | Clinical coordination: verify LIS access from quarantined workstation is denied and alternative lab workstation/downtime process is available | Infected workstation cannot reach LIS; patient workflows continue via approved fallback | **NOT VERIFIED.** No LIS access test or clinical acknowledgement supplied | Record clinical lead approval and fallback evidence before calling this successful |

## Later validation evidence actually supplied

| UTC timestamp | Source | Observed result | What it proves / limitation |
|---|---|---|---|
| 2026-04-14T10:12:00Z | `mock_validation_api/endpoint/processtree/WST-WS-031.json` | Clean baseline rebuild reported | A rebuild is reported; not who executed earlier containment |
| 2026-04-14T14:20:00Z | `mock_validation_api/endpoint/processtree/WST-WS-031.json` | 0 PowerShell→MSBuild trees among 1,284 sampled | Clean post-rebuild process state; not the 03:16 execution |
| 2026-04-14T14:21:00Z | `mock_validation_api/endpoint/persistence/WST-WS-031.json` | No GUID-named scheduled tasks, listed Run keys empty, `update.xml` and `update.exe` absent | Persistence absent at validation time; eradication evidence |
| 2026-04-14T14:22:00Z | `mock_validation_api/siem/netflow.json` | `egress_deny_verified` includes `185.220.101.47` and `91.234.99.107`; 0 packets, 0 bytes reported for each | Later mock validation of egress deny; does **not** provide rule creation time or first zero-flow interval |

## Containment state summary

| Control | Status | Basis |
|---|---|---|
| Quarantine VLAN 999 | **SIMULATED / UNVERIFIED** | No switch/NAC audit |
| Firewall deny `185.220.101.47` | **VALIDATED LATER BY MOCK API** | `siem/netflow.json`, queried 14:22Z |
| Endpoint containment flag | **UNVERIFIED / CAPABILITY UNKNOWN** | No EDR containment audit |
| C2 severance at 03:17–03:22 | **UNVERIFIED AT THAT TIME** | No timestamped PCAP or firewall logs; later zero-flow report only |
| IR jumpbox-only access | **UNVERIFIED** | No ACL export or dual-source reachability tests |
| Post-rebuild clean process/persistence state | **VALIDATED BY MOCK API** | Endpoint JSON at 14:20–14:21Z |

## Evidence preservation and execution window

- **Evidence preservation end:** Not established by supplied evidence; Task 2 must record actual acquisition/hashes.
- **Containment start (exercise example):** `2026-04-14T03:16:04Z`; **not an observed timestamp**.
- **Clinical approval:** Must be obtained before interrupting LIS-related workflows; not provided.
- **IR Commander approval:** Required from James Chen; timestamp and approval record not supplied.

## Rollback / patient safety

If quarantine prevents essential laboratory work, notify the clinical lead and IR Commander immediately. Prefer a spare workstation or approved downtime workflow. If authorized to relax isolation, document the approval, restore only the minimum necessary network path, keep the explicit C2 deny in force, monitor the endpoint closely, and log every configuration change. Do not silently restore full connectivity.

## Required proof to close Task 4 as executed

Obtain (1) switch/NAC audit for VLAN 999, (2) firewall rule ID, commit and deny logs, (3) timestamped PCAP/netflow around isolation, (4) endpoint containment job/status or `N/A` with platform justification, (5) jumpbox allow and user-VLAN deny test outputs, (6) clinical authorization and fallback record. Only then replace scenario fields with verified observations and `certainty=confirmed` ACTION entries.

## Timeline integration

The six **scenario ACTION** entries have been appended to `incident_timeline.md` with `certainty=possible` and explicit `LAB-SIMULATED` labels. Later mock API results remain `OBSERVATION` entries. Do not relabel simulated actions `confirmed` without execution evidence.
