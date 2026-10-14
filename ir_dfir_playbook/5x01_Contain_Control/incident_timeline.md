# Incident Timeline: IR-20260414-01

## Header

- incident_id: IR-20260414-01
- declared_at: PENDING — enter actual UTC declaration timestamp
- declared_by: PENDING — on-call SOC analyst name
- initial_severity: SEV2 (proposed; record confirmation at declaration)
- current_severity: SEV2 (provisional; reassess as scope changes)
- ir_commander: James Chen, SOC Lead
- scribe: PENDING — on-call SOC analyst name

> **Record status:** Initial timeline drafted from the two supplied lab evidence sources. Historical observations below use event timestamps, not analyst discovery timestamps. No incident declaration, containment, forensic acquisition, or notification is claimed to have occurred without an execution record. Complete the pending declaration fields and append the actual declaration decision when performed. For this exercise, treat this file as append-only after initial creation: do not delete or rewrite entries; add corrections as new entries referencing the affected entry.

## Legend

- **OBSERVATION:** Raw fact from an alert, log, or artifact; observations do not by themselves establish attacker intent.
- **DECISION:** Choice made by an authorized actor, with rationale.
- **ACTION:** Operation executed against an asset, with owner and outcome.
- **COMMUNICATION:** Message sent or received, including audience.
- **EVIDENCE:** Preserved artifact, including hash and storage path when available.

**Certainty scale:** `confirmed` = directly present in supplied records or independently verified action; `high` = strongly supported interpretation; `probable` = likely but not confirmed; `possible` = plausible hypothesis requiring corroboration.

## Entries

- 2026-04-13T18:13:44Z | OBSERVATION | Proxy logging service | Account dmarsh requested an Outlook message URL immediately before visiting a Microsoft 365 lookalike domain. | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-13T18:14:02Z | OBSERVATION | Proxy logging service | dmarsh GET to `https://ms0365-support.login-verification.click/auth` returned HTTP 200; referrer was an Outlook message URL. | source=proxy_24h_dmarsh.log; alert_A-20260414-9841.json supporting_indicators | certainty=confirmed

- 2026-04-13T18:14:07Z | OBSERVATION | Proxy logging service | Browser fetched `/auth/static/ms-logo.svg` from the lookalike domain (HTTP 200). | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-13T18:14:09Z | OBSERVATION | Proxy logging service | Browser fetched `/auth/static/login.css` from the lookalike domain (HTTP 200). | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-13T18:14:41Z | OBSERVATION | Proxy logging service | dmarsh POST to lookalike domain `/auth/submit` returned HTTP 302; request contents and credential exposure are not established by this log. | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-13T18:14:43Z | OBSERVATION | Proxy logging service | dmarsh GET to lookalike domain `/auth/drop/update.zip` returned HTTP 200 (logged bytes: 421004); execution of the downloaded file is not proven by this event. | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-14T02:46:41Z | OBSERVATION | WazuhEDR | `powershell.exe` PID 7812 started under `MEDDEFENSE\\dmarsh` with hidden-window, execution-policy-bypass, and encoded-command flags on clinical workstation `WST-WS-031`. | source=alert_A-20260414-9841.json process_tree.parent | certainty=confirmed

- 2026-04-14T02:46:44Z | OBSERVATION | Proxy logging service | dmarsh CONNECT request to `185.220.101.47:443` logged; this record alone does not establish a completed tunnel. | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-14T02:46:57Z | OBSERVATION | WazuhEDR | `MSBuild.exe` PID 8104 started as child of PowerShell, referencing `C:\\Users\\dmarsh\\AppData\\Local\\Temp\\update.xml`. | source=alert_A-20260414-9841.json process_tree.child | certainty=confirmed

- 2026-04-14T02:47:02Z | OBSERVATION | WazuhEDR / Proxy logging service | EDR recorded established outbound TCP connection from MSBuild PID 8104 (`10.42.118.31:54917`) to `185.220.101.47:443`; proxy recorded a CONNECT 200 at the same timestamp. | source=alert_A-20260414-9841.json network_connection; proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-14T02:47:08Z | OBSERVATION | Proxy logging service | Additional dmarsh CONNECT 200 to `185.220.101.47:443` logged (bytes field: 11203); proxy byte direction cannot be inferred from this entry alone. | source=proxy_24h_dmarsh.log | certainty=confirmed

- 2026-04-14T02:47:11Z | OBSERVATION | WazuhEDR rule `wz-edr-100041` | Alert `A-20260414-9841` fired for suspicious PowerShell-to-MSBuild process tree and outbound connection on high-criticality clinical workstation `WST-WS-031`; default rule severity `high`. | source=alert_A-20260414-9841.json | certainty=confirmed

- 2026-04-14T02:47:11Z | OBSERVATION | WazuhEDR enrichment | Alert-associated internal intelligence labels remote IP `185.220.101.47` as Tor exit/anonymizer/high-risk; reputation supports concern but does not independently prove malicious ownership or exfiltration. | source=alert_A-20260414-9841.json enrichment | certainty=confirmed

- 2026-04-14T02:47:11Z | DECISION | On-call SOC analyst (proposed; not yet executed) | Recommend initial SEV2 because suspicious script execution and an established high-risk outbound connection affect a high-criticality laboratory workstation with LIS access; credential theft, lateral movement, and data exposure remain unconfirmed. **Do not treat this proposal as a completed severity assignment until the analyst declares it and records the actual time.** | source=alert_A-20260414-9841.json; proxy_24h_dmarsh.log | certainty=high

- 2026-04-14T02:52:18Z | OBSERVATION | soc-evidence-collector v2.1 | Proxy log header reports export time `2026-04-14T02:52:18Z`; export timestamp is not proof of forensic preservation, integrity hash, or evidence-chain custody. | source=proxy_24h_dmarsh.log header | certainty=confirmed

## Pending live-response entries — append only when actually performed

Use this template for each subsequent entry:

`- YYYY-MM-DDTHH:MM:SSZ | TYPE | actor | one-line description including decision rationale or action outcome | source=alert ID / log / artifact path / ticket | certainty=confirmed|high|probable|possible`

Required next real entry: incident declaration with actual UTC timestamp, named on-call analyst, SEV2 assignment (or revised severity), and rationale. Then append evidence acquisition (artifact path and SHA-256), containment evaluation/authorization, executed actions, communications, scope reassessments, eradication verification, recovery proof, and handoff. If later evidence changes an earlier interpretation, append a new correction entry referencing the earlier timestamp; never edit the old entry.

## Open questions / unverified hypotheses

- Did the `/auth/submit` POST contain valid credentials? Requires authentication, identity-provider, and/or captured request evidence.
- Was `update.zip` saved or executed? Requires endpoint file/process evidence.
- What was the decoded PowerShell command, and what did `update.xml` contain? Requires validated analysis of collected artifacts.
- Did traffic to `185.220.101.47` include command-and-control or data exfiltration? Requires network/host investigation.
- Are additional hosts, accounts, or clinical services affected? Requires scope expansion and severity reassessment.

## Source evidence

- `alert_A-20260414-9841.json` — WazuhEDR alert `A-20260414-9841` (content supplied in task conversation).
- `proxy_24h_dmarsh.log` — 24-hour proxy export for `MEDDEFENSE\\dmarsh`, exported at `2026-04-14T02:52:18Z` (content supplied in task conversation).

> **Integrity note:** No evidence file hash is provided. Hash and immutable evidence-storage locations must be recorded only after actual collection; do not invent them.
