# Incident Timeline: IR-20260414-01

## Header

- incident_id: IR-20260414-01
- declared_at: 2026-04-14T02:51:04Z
- declared_by: On-call SOC Analyst (exercise role)
- initial_severity: SEV2
- current_severity: SEV2
- ir_commander: James Chen, SOC Lead
- scribe: On-call SOC Analyst (exercise role)


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
