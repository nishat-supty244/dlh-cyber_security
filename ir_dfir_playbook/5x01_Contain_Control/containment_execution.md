# Containment Execution: IR-2026-0414-01

- Incident alias in Task 1: `IR-20260414-01` (same case; use `IR-2026-0414-01` consistently going forward).
- Host: `WST-WS-031` / `10.42.118.31` (West Campus Laboratory).
- Selected approach: quarantine VLAN 999, permit approved IR jumpbox only, deny other traffic; block `185.220.101.47` at egress.
- **Status: NOT EXECUTED / NOT VERIFIED.** The supplied artifacts document activity through 02:47:30Z and do not include execution-console outputs, packet capture, netflow, or authorization records. Example times below are **lab scenario targets**, not observed times. Replace them with real UTC times and outputs before claiming execution.
- Approval: James Chen, IR Commander — **pending documented authorization**. Clinical coordination and priority evidence capture — **pending verification**.

## Preconditions (do not skip)

1. Confirm James Chen's authorization (record channel/ticket, actor, UTC timestamp) and laboratory clinical lead's approved alternate workflow; stop if unapproved patient-care disruption is possible.
2. Confirm memory, live processes, active connections, and relevant short-lived evidence have been captured or document why urgent containment must precede collection. Reference `evidence_preservation.md` and actual hashes.
3. Identify the switch and physical/logical port for `WST-WS-031` from the network inventory/MAC table; do **not** guess an interface. Identify the actual IR jumpbox IP, quarantine VLAN interface, and management ACLs.
4. Begin packet capture/netflow observation **before** isolation; preserve a pre-change baseline, timestamps, and collection method.
5. Record the original switchport VLAN, ACL and firewall configuration for rollback. Confirm quarantine policy blocks all non-approved paths, including IPv6 and alternate interfaces.

## Execution log — fill observed fields after each real action

### Step 1 — Move host to quarantine VLAN

- timestamp (UTC): `PENDING` (example scenario: `2026-04-14T03:16:04Z`)
- actor: `PENDING` (authorized network operator)
- command or console action: On the **verified host switchport** in the network console, change access VLAN from its recorded original value to `999`; apply quarantine ACL allowing only the verified IR jumpbox (and explicitly required management). Example Cisco-like commands (adapt to actual platform):

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

- expected result: Host assigned to VLAN 999, normal hospital and internet traffic denied; approved forensic access remains available.
- observed result: `PENDING — attach switch config/console output and timestamp`.
- deviation notes: `PENDING — record unexpected disruption, link failure, DHCP/IPv6 issues, or 'none' after verification`.
- evidence path: `/evidence/IR-2026-0414-01/network/vlan_change_<UTC>.txt` (capture output and SHA-256).

### Step 2 — Deny suspicious IP at egress

- timestamp (UTC): `PENDING` (example: `2026-04-14T03:17:21Z`)
- actor: `PENDING` (authorized firewall operator)
- command or console action: Create a **deny** rule on the actual managed firewall for source `10.42.118.31` to destination `185.220.101.47` (all relevant protocols/ports), positioned above allow rules, with logging enabled. Use firewall console/API; verify committed policy and rule order. Example policy specification:

```text
Rule: IR-2026-0414-01-block-C2
Source: 10.42.118.31
Destination: 185.220.101.47
Service: ANY
Action: DENY + LOG
Placement: before general allow rules
```

- expected result: No **new permitted** egress from this workstation to `185.220.101.47`; attempted connections are denied/logged.
- observed result: `PENDING — attach policy commit, rule-hit logs and netflow evidence`.
- deviation notes: `PENDING`.
- evidence path: `/evidence/IR-2026-0414-01/network/firewall_block_<UTC>.txt` (hash after capture).

### Step 3 — Verify C2 traffic stopped (packet capture/netflow)

- timestamp (UTC): `PENDING` (example verification starts after `2026-04-14T03:17:21Z`)
- actor: `PENDING` (SOC/network analyst)
- command or console action: Export timestamped firewall/netflow records for `10.42.118.31` ↔ `185.220.101.47` covering at least a baseline before the change and an observation period after it. If authorized on a monitoring sensor, capture with:

```bash
sudo tcpdump -i <SENSOR_INTERFACE> -nn -s 0 \
  'host 10.42.118.31 and host 185.220.101.47' \
  -w /evidence/IR-2026-0414-01/network/c2_verification.pcap
sha256sum /evidence/IR-2026-0414-01/network/c2_verification.pcap
```

- expected result: Before-change flow is visible (where sensors cover it); after-change there are no successful/allowed C2 flows. Firewall drop counters or logs may still show **blocked attempts**. A quiet capture alone is insufficient without validating sensor visibility.
- observed result: `PENDING — record first/last permitted packet timestamps, observation window, firewall drop logs and capture path`.
- deviation notes: `PENDING — document blind spots and any alternative paths`.
- evidence path: `/evidence/IR-2026-0414-01/network/c2_verification.pcap` and netflow export; SHA-256 in `hashes.txt`.

### Step 4 — Set endpoint containment flag, if supported

- timestamp (UTC): `PENDING` (example: `2026-04-14T03:19:02Z`)
- actor: `PENDING` (EDR console operator)
- command or console action: In WazuhEDR/connected endpoint platform, open `WST-WS-031`, select **Contain/Isolate device** **only if the installed product supports this control**, confirm policy exceptions for the IR jumpbox, and export console audit details. Wazuh alerting alone does not establish that a host-isolation flag exists.
- expected result: Endpoint reports contained/isolated and permits only authorized forensic management traffic.
- observed result: `PENDING — supported / unsupported / failed, with console evidence`.
- deviation notes: `PENDING — if unsupported, record N/A and rely on validated network quarantine`.
- evidence path: `/evidence/IR-2026-0414-01/endpoint_telemetry/containment_flag_<UTC>.json` or console audit export.

### Step 5 — Confirm jumpbox-only reachability

- timestamp (UTC): `PENDING` (example: `2026-04-14T03:22:04Z`)
- actor: `PENDING` (SOC/network analyst)
- command or console action: From the **approved IR jumpbox**, test a known approved management service to `WST-WS-031`; from an authorized user VLAN test the same service and verify deny. Verify access lists and firewall flow logs. ICMP ping is optional and not sufficient by itself (it may be disabled).

```powershell
# Execute separately from the approved jumpbox and authorized user-VLAN test host
Test-NetConnection 10.42.118.31 -Port <APPROVED_FORENSIC_SERVICE_PORT>
```

- expected result: Approved jumpbox connection succeeds; same service from user VLAN fails; internet and lateral egress remain denied.
- observed result: `PENDING — record source hosts/IPs, ports, outputs, timestamps, and ACL evidence`.
- deviation notes: `PENDING`.
- evidence path: `/evidence/IR-2026-0414-01/network/isolation_validation_<UTC>.txt`.

## Post-execution record and integrity

- For **each completed step**, write the actual timestamp, actor, exact command/console action, expected result, observed result, and deviation. Preserve raw output/screenshots/API audit exports and SHA-256 hashes in `/evidence/IR-2026-0414-01/hashes.txt` using `sha256sum <artifact>`; rehash and compare at handoff.
- Do not treat command issuance as successful containment: validate the switch state, firewall enforcement, endpoint status (if available), flow cessation, and jumpbox-only reachability.
- Record clinical impact and notify the clinical lead and James Chen of completion or failure. If clinical services are disrupted, follow the authorized rollback in `containment_decision.md`; record every reversal and verify it.

## Timeline append format (ONLY after actual execution)

Append one `ACTION` entry per verified step to `incident_timeline.md`, **in actual execution order**, without altering earlier entries:

```text
- <ACTUAL_UTC_TIMESTAMP> | ACTION | <ACTOR> | VLAN 999 applied to verified WST-WS-031 switchport; <OBSERVED_RESULT>; deviations=<DETAIL> | source=containment_execution.md; <SWITCH_EVIDENCE_PATH> | certainty=confirmed
- <ACTUAL_UTC_TIMESTAMP> | ACTION | <ACTOR> | Firewall egress deny for 10.42.118.31 -> 185.220.101.47 committed; <OBSERVED_RESULT>; deviations=<DETAIL> | source=containment_execution.md; <FIREWALL_EVIDENCE_PATH> | certainty=confirmed
- <ACTUAL_UTC_TIMESTAMP> | ACTION | <ACTOR> | C2 verification capture/netflow collected; <OBSERVED_RESULT>; deviations=<DETAIL> | source=containment_execution.md; <PCAP_OR_FLOW_PATH> | certainty=confirmed
- <ACTUAL_UTC_TIMESTAMP> | ACTION | <ACTOR> | Endpoint containment flag <SET_OR_UNSUPPORTED>; <OBSERVED_RESULT>; deviations=<DETAIL> | source=containment_execution.md; <EDR_AUDIT_PATH> | certainty=confirmed
- <ACTUAL_UTC_TIMESTAMP> | ACTION | <ACTOR> | Jumpbox-only reachability verified; <OBSERVED_RESULT>; deviations=<DETAIL> | source=containment_execution.md; <VALIDATION_PATH> | certainty=confirmed
```

**No containment `ACTION` entry is claimed as completed in this runbook.**
