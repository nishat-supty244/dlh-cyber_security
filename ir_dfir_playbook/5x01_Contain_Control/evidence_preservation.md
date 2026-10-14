# Evidence Preservation Runbook: IR-2026-0414-01

Evidence store: `/evidence/IR-2026-0414-01/`  
Hash algorithm: **SHA-256**  
Hash manifest: `/evidence/IR-2026-0414-01/hashes.txt`  
Incident: suspicious execution and outbound traffic on `WST-WS-031` involving `MEDDEFENSE\dmarsh`  
Alert: `A-20260414-9841`, fired `2026-04-14T02:47:11Z`.

**Status:** This is a procedure, not a claim that acquisition occurred. Record operator, acquisition time (UTC), command output, success/failure, hash, and custody transfer in `incident_timeline.md`. Preserve originals read-only and work from copies. Prioritize immediate containment over acquisition if patient safety or ongoing damage demands it; document the exception.

## 0. Prepare and initialize the evidence store

Run the supplied `evidence_store_init.sh` **once** on the Linux evidence collector. Its incident ID is `IR-2026-0414-01` (note Task 1 used `IR-20260414-01`; reconcile the identifier in the incident record rather than silently mixing stores). The script creates `memory`, `disk`, `process_tree`, `network`, `endpoint_telemetry`, `siem`, `proxy_dns`, `authentication`, `malware`, and `correlation`, plus `hashes.txt`. The supplied script also has an `INCIDENCE_ID` environment override; leave it unset.

```bash
unset INCIDENCE_ID
bash evidence_store_init.sh
export EVIDENCE_DIR=/evidence/IR-2026-0414-01
ls -la "$EVIDENCE_DIR"
```

The initialized `hashes.txt` is the authoritative manifest; do not overwrite it. Use a controlled share for Windows acquisition, e.g. `\\evidence\IR-2026-0414-01\` mapped to the same Linux evidence directory. Confirm access, available disk space, tool integrity, and authorization before collection. Capture hashes of the original lab exports before copying them when possible. A directory being created is **not** proof that any artifact was collected.

For **each successfully collected artifact**, run the following on the Linux collector, replacing the relative path with the actual artifact. Use `flock` to serialize append operations:

```bash
cd /evidence/IR-2026-0414-01
ARTIFACT='proxy_dns/proxy_24h_dmarsh.log'  # replace for each artifact
sha256sum "$ARTIFACT" | tee -a hashes.txt
```

Do not add a manifest entry for an absent or failed acquisition. Record each artifact's capture time, tool, host, operator, original source, SHA-256, and destination in the incident timeline or chain-of-custody notes. Hash the manifest separately after finalizing the capture batch, not into itself.

## 1. Volatile memory — WST-WS-031

- **what:** Full physical memory dump, including possible injected code in `MSBuild.exe` PID 8104 (EDR noted an executable-writable region with an MZ header at `02:47:14Z`).
- **how:** On `WST-WS-031`, run an approved and integrity-checked WinPmem binary as administrator. Example command (verify binary flags for the installed version):

```powershell
& 'C:\IRTools\winpmem_3.3.rc3.exe' -o '\\evidence\IR-2026-0414-01\memory\wst-ws-031.mem'
certutil -hashfile '\\evidence\IR-2026-0414-01\memory\wst-ws-031.mem' SHA256
```

- **where:** `/evidence/IR-2026-0414-01/memory/wst-ws-031.mem`
- **hash algorithm / hash cmd (collector):** `sha256sum /evidence/IR-2026-0414-01/memory/wst-ws-031.mem`; append result to `hashes.txt`.
- **ordering rationale:** Acquire before process termination, reboot, or power-off, which destroys RAM contents. Network isolation may interrupt a remote acquisition; if urgent containment is required, record the trade-off and use an approved local collection path where possible.
- **verification:** Compare Windows `certutil` output with collector `sha256sum`; record discrepancies. **Status: pending live acquisition.**

## 2. Running process tree — WST-WS-031

- **what:** Live PID, parent PID, executable path, command line, and owner; particularly `update.exe` PID 7204 → `powershell.exe` PID 7812 → `MSBuild.exe` PID 8104.
- **how:** Run elevated PowerShell on the workstation:

```powershell
Get-CimInstance Win32_Process |
  Select-Object ProcessId,ParentProcessId,Name,ExecutablePath,CommandLine |
  Export-Csv '\\evidence\IR-2026-0414-01\process_tree\wst-ws-031-processes.csv' -NoTypeInformation -Encoding UTF8
```

- **where:** `/evidence/IR-2026-0414-01/process_tree/wst-ws-031-processes.csv`
- **hash algorithm / hash cmd:** `sha256sum /evidence/IR-2026-0414-01/process_tree/wst-ws-031-processes.csv`; append to `hashes.txt`.
- **ordering rationale:** Collect before killing processes, logging out users, or rebooting; otherwise PID/parent relationships and command lines may be lost.
- **verification:** Check CSV has expected columns, record any missing processes without inventing them. **Status: pending live acquisition.**

## 3. Active network connections — WST-WS-031

- **what:** Active TCP/UDP endpoints, states, and owning PIDs, including connections to `185.220.101.47:443`.
- **how:** Run elevated PowerShell before network isolation:

```powershell
Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess |
  Export-Csv '\\evidence\IR-2026-0414-01\network\wst-ws-031-tcp.csv' -NoTypeInformation -Encoding UTF8
Get-NetUDPEndpoint | Select-Object LocalAddress,LocalPort,OwningProcess |
  Export-Csv '\\evidence\IR-2026-0414-01\network\wst-ws-031-udp.csv' -NoTypeInformation -Encoding UTF8
```

- **where:** `/evidence/IR-2026-0414-01/network/wst-ws-031-tcp.csv` and `/evidence/IR-2026-0414-01/network/wst-ws-031-udp.csv`
- **hash algorithm / hash cmd:**

```bash
cd /evidence/IR-2026-0414-01
sha256sum network/wst-ws-031-tcp.csv network/wst-ws-031-udp.csv | tee -a hashes.txt
```

- **ordering rationale:** Connections vanish after network isolation, session termination, or process kill; capture first if safe.
- **verification:** Confirm export completeness and timestamps. **Status: pending live acquisition.**

## 4. Full endpoint telemetry — 24 hours before alert

- **what:** Full EDR event export for `WST-WS-031` including file creation, registry persistence, scheduled tasks, process ancestry, and network events. Alert-centered window: `2026-04-13T02:47:11Z` through `2026-04-14T02:47:11Z` (record later events separately, including the `02:47:14Z` memory-region observation and `02:47:30Z` connection).
- **how:** Preserve the provided `edr_wst_ws_031_24h.jsonl` in full, not a filtered excerpt:

```bash
cp -- edr_wst_ws_031_24h.jsonl /evidence/IR-2026-0414-01/endpoint_telemetry/
sha256sum /evidence/IR-2026-0414-01/endpoint_telemetry/edr_wst_ws_031_24h.jsonl | tee -a /evidence/IR-2026-0414-01/hashes.txt
```

- **where:** `/evidence/IR-2026-0414-01/endpoint_telemetry/edr_wst_ws_031_24h.jsonl`
- **hash algorithm / hash cmd:** `sha256sum /evidence/IR-2026-0414-01/endpoint_telemetry/edr_wst_ws_031_24h.jsonl`.
- **ordering rationale:** Export before retention expiry, sensor disruption, or remediation that changes telemetry; preserve the original full export before analyzing subsets.
- **verification:** Ensure JSONL lines parse and note the export includes post-alert events; compare coverage to the exact requested window. **Status: collection pending.**

## 5. SIEM alert JSON

- **what:** Original WazuhEDR/SIEM alert `A-20260414-9841`, including `wz-edr-100041`, PowerShell → MSBuild process tree, network IOC, and enrichment.
- **how:** Preserve the supplied JSON exactly:

```bash
cp -- alert_A-20260414-9841.json /evidence/IR-2026-0414-01/siem/
python3 -m json.tool /evidence/IR-2026-0414-01/siem/alert_A-20260414-9841.json >/dev/null
sha256sum /evidence/IR-2026-0414-01/siem/alert_A-20260414-9841.json | tee -a /evidence/IR-2026-0414-01/hashes.txt
```

- **where:** `/evidence/IR-2026-0414-01/siem/alert_A-20260414-9841.json`
- **hash algorithm / hash cmd:** `sha256sum /evidence/IR-2026-0414-01/siem/alert_A-20260414-9841.json`.
- **ordering rationale:** Preserve the raw alert before triage annotations, enrichment updates, or retention changes.
- **verification:** Validate JSON and `alert_id`. **Status: collection pending.**

## 6. Proxy and DNS web activity — dmarsh

### 6A. Proxy activity

- **what:** Full web/proxy activity for `MEDDEFENSE\dmarsh` / `WST-WS-031` (`10.42.118.31`), including the lookalike Microsoft 365 page, `POST /auth/submit`, `update.zip` download, and connections to `185.220.101.47:443`.
- **how:** Preserve the provided `proxy_24h_dmarsh.log`:

```bash
cp -- proxy_24h_dmarsh.log /evidence/IR-2026-0414-01/proxy_dns/
sha256sum /evidence/IR-2026-0414-01/proxy_dns/proxy_24h_dmarsh.log | tee -a /evidence/IR-2026-0414-01/hashes.txt
```

- **where:** `/evidence/IR-2026-0414-01/proxy_dns/proxy_24h_dmarsh.log`
- **hash algorithm / hash cmd:** `sha256sum /evidence/IR-2026-0414-01/proxy_dns/proxy_24h_dmarsh.log`.
- **ordering rationale:** Preserve before proxy retention/rotation or network-policy changes; capture original raw records before parsing or filtering.
- **verification:** Confirm user `dmarsh` and window. The provided export covers `2026-04-13T02:47:00Z` to `2026-04-14T02:47:00Z`, ending **11 seconds before the alert**; request the missing 11 seconds and retain separately if available. **Status: collection pending.**

### 6B. DNS activity

- **what:** DNS resolver queries/responses associated with `WST-WS-031`, `10.42.118.31`, and `dmarsh`, covering `2026-04-13T02:47:11Z`–`2026-04-14T02:47:11Z`; include suspicious domain `ms0365-support.login-verification.click` if observed.
- **how:** Export raw records from the organization's DNS logging/SIEM interface with filters `client_ip=10.42.118.31`, host `WST-WS-031`, and the exact UTC time range; choose raw CSV/JSON export (platform-specific API not supplied). Save as `dns_24h_dmarsh.jsonl`. Do not fabricate results.
- **where:** `/evidence/IR-2026-0414-01/proxy_dns/dns_24h_dmarsh.jsonl`
- **hash algorithm / hash cmd (once exported):**

```bash
sha256sum /evidence/IR-2026-0414-01/proxy_dns/dns_24h_dmarsh.jsonl | tee -a /evidence/IR-2026-0414-01/hashes.txt
```

- **ordering rationale:** DNS logs may rotate quickly and network containment stops new DNS activity; preserve existing records before changes.
- **verification:** Confirm source, host/client mapping, UTC window, row count, and SHA-256. **Status: pending — no DNS export provided.**

## 7. Authentication — dmarsh (Active Directory + Azure AD)

- **what:** Full `MEDDEFENSE\dmarsh` / `dmarsh@meddefense.local` authentication activity across AD domain controllers `ms-dc01`, `ms-dc02`, and Azure AD; include successful login, MFA, impossible-travel risk, and source IP. The supplied export contains a suspicious `2026-04-13T18:14:41Z` Office 365 sign-in from `45.63.9.88`, flagged `impossibleTravel`; this is a risk indicator, not conclusive credential theft.
- **how:** Preserve the provided `auth_24h_dmarsh.json` intact:

```bash
cp -- auth_24h_dmarsh.json /evidence/IR-2026-0414-01/authentication/
python3 -m json.tool /evidence/IR-2026-0414-01/authentication/auth_24h_dmarsh.json >/dev/null
sha256sum /evidence/IR-2026-0414-01/authentication/auth_24h_dmarsh.json | tee -a /evidence/IR-2026-0414-01/hashes.txt
```

- **where:** `/evidence/IR-2026-0414-01/authentication/auth_24h_dmarsh.json`
- **hash algorithm / hash cmd:** `sha256sum /evidence/IR-2026-0414-01/authentication/auth_24h_dmarsh.json`.
- **ordering rationale:** Preserve AD and Azure AD sign-in/MFA/risk evidence before credential resets, token/session revocation, or log retention changes. Existing historical logs generally survive resets, but preserve them promptly for continuity and custody.
- **verification:** Confirm `sources` includes AD and Azure AD and `user_principal` is `MEDDEFENSE\dmarsh`. Provided window ends `2026-04-14T02:47:00Z`, **11 seconds before the alert**; collect a supplementary window if available. **Status: collection pending.**

## 8. Verification — re-hash all evidence and compare

- **what:** Integrity check of every captured artifact against its original SHA-256 value in `hashes.txt`.
- **how:** From the evidence collector, after the manifest has been populated:

```bash
cd /evidence/IR-2026-0414-01
sha256sum --check hashes.txt | tee correlation/hash_verification.txt
sha256sum correlation/hash_verification.txt | tee -a hashes.txt
# Final check includes the verification report itself:
sha256sum --check hashes.txt
# Seal manifest separately (never hash hashes.txt into itself):
sha256sum hashes.txt > /evidence/IR-2026-0414-01-hashes.txt.sha256
```

- **where:** `/evidence/IR-2026-0414-01/correlation/hash_verification.txt`; manifest `/evidence/IR-2026-0414-01/hashes.txt`; detached manifest checksum `/evidence/IR-2026-0414-01-hashes.txt.sha256`.
- **hash algorithm / hash cmd:** `sha256sum --check hashes.txt` checks all recorded artifact SHA-256 hashes; `sha256sum hashes.txt` seals the manifest separately.
- **ordering rationale:** Verify integrity after acquisition and before handing evidence to another analyst or beginning destructive remediation.
- **verification:** All present artifacts must report `OK`. Any `FAILED`, missing artifact, incomplete export, or acquisition failure must be documented as an `OBSERVATION` in `incident_timeline.md` with time, owner, path, and remediation plan. Never silently replace evidence or edit old timeline entries.

## Evidence checklist

| Artifact | Destination relative to evidence store | State |
|---|---|---|
| RAM dump | `memory/wst-ws-031.mem` | Pending live acquisition |
| Process list / tree | `process_tree/wst-ws-031-processes.csv` | Pending live acquisition |
| TCP connections | `network/wst-ws-031-tcp.csv` | Pending live acquisition |
| UDP endpoints | `network/wst-ws-031-udp.csv` | Pending live acquisition |
| Endpoint telemetry | `endpoint_telemetry/edr_wst_ws_031_24h.jsonl` | Source provided; copy pending |
| SIEM alert | `siem/alert_A-20260414-9841.json` | Source provided; copy pending |
| Proxy/web activity | `proxy_dns/proxy_24h_dmarsh.log` | Source provided; copy pending |
| DNS activity | `proxy_dns/dns_24h_dmarsh.jsonl` | No source provided; export pending |
| AD + Azure AD authentication | `authentication/auth_24h_dmarsh.json` | Source provided; copy pending |
| Integrity verification | `correlation/hash_verification.txt` | Pending collection |

**Containment gate:** Before isolating `WST-WS-031`, killing `update.exe` / PowerShell / MSBuild, resetting `dmarsh` credentials, or revoking sessions, confirm critical volatile acquisitions and available exports are captured and hashed, or explicitly document why urgent patient-safety/security needs required a different order. Notify the clinical lead as required by the hospital playbook. Append every decision and action to `incident_timeline.md` with UTC timestamp and source.
