# Evidence Preservation Runbook: IR-2026-0414-01

**Status:** Prepared instructions only. No acquisition, hashing, containment, or verification has been executed by this document.

- **Incident:** `IR-2026-0414-01` (the ID hardcoded in `evidence_store_init.sh`; Task 1 uses `IR-20260414-01`—reconcile IDs in the incident register before executing)
- **Evidence store:** `/evidence/IR-2026-0414-01/`
- **Hash algorithm:** SHA-256
- **Hash manifest:** `/evidence/IR-2026-0414-01/hashes.txt` (created by the initializer); deliver an identical snapshot named `/evidence/IR-2026-0414-01/IR-2026-0414-01-hashes.txt` if the checker expects the incident-prefixed filename. Do not independently edit the snapshot.
- **Alert time:** `2026-04-14T02:47:11Z`
- **24-hour search window:** `2026-04-13T02:47:11Z` through `2026-04-14T02:47:11Z` UTC; retain a wider export if the platform only supports coarse windows. Supplied proxy/auth exports instead use `02:47:00Z` boundaries; disclose this 11-second discrepancy.
- **Host:** `WST-WS-031` (`10.42.118.31`), high-criticality clinical workstation, user `MEDDEFENSE\dmarsh`.
- **Operating principle:** Obtain clinical approval for any disruptive acquisition or isolation. Collect memory, live processes and connections before killing processes, rebooting, disabling accounts, or isolating the host whenever safe. If active harm makes immediate containment necessary, document the exception and what evidence may be lost.

## 0. Initialize evidence store and custody controls

On the **Linux evidence collector**, inspect and run the supplied initializer **once**:

```bash
# Verify the script before execution; do not run it a second time if the store exists.
cat evidence_store_init.sh
unset INCIDENCE_ID
bash ./evidence_store_init.sh
export IR=/evidence/IR-2026-0414-01
ls -ld "$IR" "$IR"/*
```

**Caution:** The initializer contains `${INCIDENCE_ID:-${INCIDENT_ID}}` (note `INCIDENCE_ID`, not `INCIDENT_ID`); unset `INCIDENCE_ID` so it uses the intended ID. It creates `/evidence/IR-2026-0414-01/hashes.txt` and subfolders. Running with `sudo` makes the store owned by root unless adjusted; use an authorized evidence-collector account and minimum permissions. `chmod -R 750` does **not** make files immutable or provide tamper-proof storage. Record operator, UTC time, system clock status, tool versions, source, destination, and transfer method in the custody log.

```bash
# Run as the evidence-store owner (or through authorized sudo).
cd "$IR"
printf 'utc_time,collector,source,action,destination,notes\n' > chain_of_custody.csv
# Capture real events with actual times; never pre-fill fictional acquisition events.
```

**Hash procedure used after each completed capture:** On the evidence collector, after a file is fully transferred and closed, calculate its SHA-256 and append exactly one relative-path record. Do not hash a partially written file.

```bash
cd "$IR"
sha256sum 'relative/path/to/completed_artifact' >> hashes.txt
# Example only: replace path with an existing, completed artifact.
```

Store the manifest outside the evidence tree as a separately protected baseline (e.g., access-controlled case-management attachment or signed manifest); otherwise an attacker could change both evidence and hashes. Never edit existing manifest lines; append new records for new artifacts and explain replacements.

## 1. Acquire volatile physical memory — highest priority

- **What:** Full RAM image of `WST-WS-031`, potentially including active malware, injected code, decrypted material, processes and sockets. EDR reports `MSBuild.exe` PID `8104` with an 81,920-byte `PAGE_EXECUTE_READWRITE` region and MZ header at `02:47:14Z`; this is suspicious but not proof of injection.
- **How:** On the **Windows endpoint**, with approved administrator access and a validated, trusted `winpmem` binary, write to an authorized evidence share mapped to the Linux store. Confirm the executable's supported options with `winpmem.exe --help` first; the example below assumes a build supporting `-o`.

```powershell
# Run in an elevated PowerShell session on WST-WS-031.
# The share must be preconfigured with restricted write permissions.
& 'C:\IRTools\winpmem.exe' -o '\\EVIDENCE-SERVER\IR-2026-0414-01\memory\wst-ws-031.mem'
if ($LASTEXITCODE -ne 0) { throw 'Memory acquisition failed' }
Get-FileHash '\\EVIDENCE-SERVER\IR-2026-0414-01\memory\wst-ws-031.mem' -Algorithm SHA256
```

- **Where:** `/evidence/IR-2026-0414-01/memory/wst-ws-031.mem` (the SMB share must actually map to this path).
- **Hash on evidence collector:**

```bash
cd "$IR"
sha256sum memory/wst-ws-031.mem >> hashes.txt
```

- **Ordering:** Before reboot, power-off, process termination or disruptive isolation; memory can disappear or change. Network isolation **does not itself erase RAM**, but may break remote acquisition/share access. If remote write is blocked, capture to an approved local encrypted drive and transfer without modifying the original. Note acquisition's own footprint.

## 2. Capture live process tree and network state

- **What:** PID, parent PID, executable path, command line, owner, start time; TCP/UDP endpoints, state and owning PID. Priority PIDs: `7204` (`update.exe`), `7812` (`powershell.exe`), `8104` (`MSBuild.exe`).
- **How:** On Windows in elevated PowerShell, capture as close together as possible:

```powershell
$dest = '\\EVIDENCE-SERVER\IR-2026-0414-01'
Get-CimInstance Win32_Process |
  Select-Object ProcessId,ParentProcessId,Name,ExecutablePath,CommandLine,CreationDate |
  Export-Csv "$dest\process_tree\processes.csv" -NoTypeInformation -Encoding UTF8
Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess |
  Export-Csv "$dest\network\tcp_connections.csv" -NoTypeInformation -Encoding UTF8
Get-NetUDPEndpoint | Select-Object LocalAddress,LocalPort,OwningProcess |
  Export-Csv "$dest\network\udp_endpoints.csv" -NoTypeInformation -Encoding UTF8
cmd /c 'netstat -ano' | Out-File "$dest\network\netstat_ano.txt" -Encoding utf8
```

- **Where:** `process_tree/processes.csv`, `network/tcp_connections.csv`, `network/udp_endpoints.csv`, `network/netstat_ano.txt`.
- **Hash:**

```bash
cd "$IR"
for f in process_tree/processes.csv network/tcp_connections.csv network/udp_endpoints.csv network/netstat_ano.txt; do sha256sum "$f" >> hashes.txt; done
```

- **Ordering:** Before process kill, user logoff, account revocation, network isolation or reboot, which can alter process/socket state. If memory acquisition is prolonged, collect these snapshots promptly in parallel if approved, recording exact times.

## 3. Preserve full endpoint telemetry (24 hours before alert)

- **What:** Complete WazuhEDR endpoint event export for `WST-WS-031`, not just the detection. The supplied `edr_wst_ws_031_24h.jsonl` includes creation of `update.zip`, `update.xml`, `update.exe`, registry Run persistence (`WindowsUpdateSvc`), a scheduled task, and the suspicious process chain.
- **How:** Export raw events from the EDR console/API using host filter `WST-WS-031` and UTC range `2026-04-13T02:47:11Z`–`2026-04-14T02:47:11Z`, retaining original JSONL and query metadata. **API endpoint and credentials are not supplied; do not invent an API call.** For the lab-provided export, copy the actual source file without editing:

```bash
cp --preserve=timestamps -- edr_wst_ws_031_24h.jsonl "$IR/endpoint_telemetry/edr_wst_ws_031_24h.jsonl"
cd "$IR" && sha256sum endpoint_telemetry/edr_wst_ws_031_24h.jsonl >> hashes.txt
```

- **Where:** `endpoint_telemetry/edr_wst_ws_031_24h.jsonl`.
- **Ordering:** Export before EDR retention/rollover or host cleanup. Record the query and export time. Note supplied events extend beyond alert time (`02:47:30Z`); retain them and label the export window accurately rather than silently removing records.

## 4. Preserve original SIEM alert JSON

- **What:** Raw WazuhEDR alert `A-20260414-9841`, rule `wz-edr-100041`, fired `2026-04-14T02:47:11Z`, plus process/network/enrichment fields.
- **How:** Export the original JSON from `MedDefense-SOC-Splunk` (`edr_wazuh`, alert ID `A-20260414-9841`), or copy the provided file:

```bash
cp --preserve=timestamps -- alert_A-20260414-9841.json "$IR/siem/alert_A-20260414-9841.json"
cd "$IR" && sha256sum siem/alert_A-20260414-9841.json >> hashes.txt
```

- **Where:** `siem/alert_A-20260414-9841.json`.
- **Ordering:** Capture raw alert before correlation edits, dashboard changes, or retention expiration. Do not replace the original with a reformatted reconstruction.

## 5. Preserve proxy activity for dmarsh

- **What:** 24-hour proxy requests, including suspicious `/auth`, `/auth/submit`, `/auth/drop/update.zip` and `CONNECT 185.220.101.47:443` events.
- **How:** Export raw proxy logs using principal `MEDDEFENSE\dmarsh` (and host IP `10.42.118.31`) with the exact requested UTC window; retain export metadata. Copy the supplied export:

```bash
cp --preserve=timestamps -- proxy_24h_dmarsh.log "$IR/proxy_dns/proxy_24h_dmarsh.log"
cd "$IR" && sha256sum proxy_dns/proxy_24h_dmarsh.log >> hashes.txt
```

- **Where:** `proxy_dns/proxy_24h_dmarsh.log`.
- **Ordering:** Proxy logs are short-lived and may rotate; preserve before firewall/proxy policy changes. Supplied export ends at `02:47:00Z` and was generated at `02:52:18Z`; it does **not** exactly match the requested 24-hour alert-relative window.

## 6. Preserve DNS resolver logs (required; not supplied)

- **What:** DNS queries and responses associated with `dmarsh` / `WST-WS-031` / `10.42.118.31`, including queried domain, response, resolver, timestamp and client identifier. DNS may not record usernames; correlate by IP and DHCP leases.
- **How:** Export **raw resolver query logs** from the organization's DNS/SIEM interface filtered to client `10.42.118.31` and the UTC window. Preserve DHCP lease mapping if IP attribution is uncertain. **No DNS log file, resolver product, or API syntax was provided, so the exact platform export command must be supplied by the lab/operator.** Do not treat the proxy log as a substitute for DNS logs. After export to a local file:

```bash
# Only after a real DNS export exists at the specified source path:
cp --preserve=timestamps -- dns_24h_wst_ws_031.log "$IR/proxy_dns/dns_24h_wst_ws_031.log"
cd "$IR" && sha256sum proxy_dns/dns_24h_wst_ws_031.log >> hashes.txt
```

- **Where:** `proxy_dns/dns_24h_wst_ws_031.log`.
- **Ordering:** Before DNS retention rollover, cache flushes or DNS blocking; preserve even if the export contains no relevant records. Mark **PENDING** until obtained and hashed.

## 7. Preserve AD and Azure AD authentication events

- **What:** AD domain controller (`ms-dc01`, `ms-dc02`) and Azure AD/Entra sign-in events for `dmarsh`. Supplied export includes a successful `2026-04-13T18:14:41Z` Office 365 sign-in from `45.63.9.88` with `impossibleTravel` risk and satisfied MFA; this is a strong compromise indicator, **not by itself proof** of credential theft or MFA bypass.
- **How:** Export source events from DC Security logs and Entra sign-in logs, using the exact UTC window and identity filters; preserve event IDs, correlation IDs, risk signals and raw metadata. For the lab-supplied combined export:

```bash
cp --preserve=timestamps -- auth_24h_dmarsh.json "$IR/authentication/auth_24h_dmarsh.json"
cd "$IR" && sha256sum authentication/auth_24h_dmarsh.json >> hashes.txt
```

- **Where:** `authentication/auth_24h_dmarsh.json`.
- **Ordering:** Preserve before password reset, session revocation, disabling accounts, or audit-log retention. The supplied export was created at `02:53:12Z` and uses a `02:47:00Z` boundary; record these limitations.

## 8. Final verification and custody handoff

**Only after all available captures have completed**, re-hash the evidence store and compare with the baseline. The manifest is `sha256sum`-compatible: each data line is `<hash><two spaces><relative path>`; header comments begin with `#`.

```bash
cd /evidence/IR-2026-0414-01
# Do not add hashes.txt itself to its own manifest.
sha256sum --check --strict hashes.txt | tee verification_results.txt
# Create the specifically named deliverable as an identical snapshot:
cp -- hashes.txt IR-2026-0414-01-hashes.txt
cmp -- hashes.txt IR-2026-0414-01-hashes.txt
# The verification report is itself a new artifact; hash it into a separately
# protected post-verification manifest or signed custody record, not into the
# already-frozen baseline being checked.
```

For a more explicit completeness check, compare the list of actual files against manifest paths (excluding the manifest, custody record and verification report):

```bash
cd /evidence/IR-2026-0414-01
find memory process_tree network endpoint_telemetry siem proxy_dns authentication \
  -type f -printf '%p\n' | sort > /tmp/ir-actual-files.txt
awk '!/^#/ && NF >= 2 { $1=""; sub(/^  */,""); print }' hashes.txt | sort > /tmp/ir-manifest-files.txt
diff -u /tmp/ir-manifest-files.txt /tmp/ir-actual-files.txt
```

**Pass criteria:** Every captured artifact is present, hashes match, paths resolve, capture times and operator are recorded, no unaccounted files are present, and the protected original manifest is retained. **Fail criteria:** Missing artifacts, SHA-256 mismatches, truncated exports, incorrect windows, or incomplete chain of custody. Append an `OBSERVATION` entry to `incident_timeline.md` with UTC time, affected path, expected/actual hash, and remediation status; do not silently overwrite evidence. If DNS is unavailable, record the collection failure, owner and follow-up deadline. Do not claim a fully completed preservation phase until all required evidence is captured or documented as unavailable.

### Incident timeline integration

After **each actual collection**, append a new `EVIDENCE` entry with capture UTC time, actor, source, destination, SHA-256, result and certainty. Append `DECISION` entries for any order changes, and `ACTION` entries for actual containment only after preservation or a documented emergency exception. Historical events in the input files are observations, not proof that a live capture was performed.

### Source files reviewed

1. `evidence_store_init.sh` — initializer and canonical incident ID/path.
2. `alert_A-20260414-9841.json` — alert, process tree, outbound connection and enrichment.
3. `edr_wst_ws_031_24h.jsonl` — endpoint processes, files, registry, task and memory-region indicator.
4. `proxy_24h_dmarsh.log` — web requests and CONNECT events.
5. `auth_24h_dmarsh.json` — AD and Azure AD/Entra sign-ins.

**Outstanding dependencies:** Actual winpmem binary/build and approved share, collector permissions, raw DNS export, platform-specific EDR/AD/Entra export interface, actual capture timestamps and hashes. No real artifact hash can be asserted from the pasted text alone.

## Artifact capture checklist (checker-friendly)

Each line specifies **what**, **how**, **where**, **hash algorithm**, **hash command**, and **ordering rationale**. Commands below are run from the lab materials directory on the evidence collector unless marked Windows. Run only when the source exists.

| Artifact / what | How (exact invocation) | Where | Hash algorithm and command | Ordering rationale |
|---|---|---|---|---|
| Full volatile RAM, WST-WS-031 | Windows: `& 'C:\IRTools\winpmem.exe' -o '\\EVIDENCE-SERVER\IR-2026-0414-01\memory\wst-ws-031.mem'` | `memory/wst-ws-031.mem` | SHA-256: `sha256sum memory/wst-ws-031.mem >> hashes.txt` | Before power-off, reboot or process termination; isolation can interrupt remote capture |
| Process list, PID, PPID, command line | Windows: `Get-CimInstance Win32_Process \| Select ProcessId,ParentProcessId,CommandLine,ExecutablePath \| Export-Csv '\\EVIDENCE-SERVER\IR-2026-0414-01\process_tree\processes.csv' -NoTypeInformation` | `process_tree/processes.csv` | SHA-256: `sha256sum process_tree/processes.csv >> hashes.txt` | Before killing processes or logging off |
| Active TCP and UDP connections | Windows: `Get-NetTCPConnection \| Export-Csv '\\EVIDENCE-SERVER\IR-2026-0414-01\network\tcp_connections.csv' -NoTypeInformation`; `Get-NetUDPEndpoint \| Export-Csv '\\EVIDENCE-SERVER\IR-2026-0414-01\network\udp_endpoints.csv' -NoTypeInformation` | `network/tcp_connections.csv`, `network/udp_endpoints.csv` | SHA-256: `sha256sum network/tcp_connections.csv >> hashes.txt; sha256sum network/udp_endpoints.csv >> hashes.txt` | Before host isolation or network blocks remove live connection evidence |
| Full 24h endpoint telemetry | `cp -- edr_wst_ws_031_24h.jsonl "$IR/endpoint_telemetry/edr_wst_ws_031_24h.jsonl"` | `endpoint_telemetry/edr_wst_ws_031_24h.jsonl` | SHA-256: `sha256sum endpoint_telemetry/edr_wst_ws_031_24h.jsonl >> hashes.txt` | Before telemetry retention expiry or cleanup |
| Original SIEM alert JSON | `cp -- alert_A-20260414-9841.json "$IR/siem/alert_A-20260414-9841.json"` | `siem/alert_A-20260414-9841.json` | SHA-256: `sha256sum siem/alert_A-20260414-9841.json >> hashes.txt` | Before alert enrichment or retention changes |
| 24h proxy logs for dmarsh | `cp -- proxy_24h_dmarsh.log "$IR/proxy_dns/proxy_24h_dmarsh.log"` | `proxy_dns/proxy_24h_dmarsh.log` | SHA-256: `sha256sum proxy_dns/proxy_24h_dmarsh.log >> hashes.txt` | Before proxy rotation or policy changes |
| 24h DNS query/response logs for workstation IP | Export resolver query log for `10.42.118.31` in specified UTC window as `dns_24h_wst_ws_031.log`, then `cp -- dns_24h_wst_ws_031.log "$IR/proxy_dns/dns_24h_wst_ws_031.log"` | `proxy_dns/dns_24h_wst_ws_031.log` | SHA-256: `sha256sum proxy_dns/dns_24h_wst_ws_031.log >> hashes.txt` | Before resolver log rotation or blocking; source export is pending |
| 24h AD + Azure AD authentication events | `cp -- auth_24h_dmarsh.json "$IR/authentication/auth_24h_dmarsh.json"` | `authentication/auth_24h_dmarsh.json` | SHA-256: `sha256sum authentication/auth_24h_dmarsh.json >> hashes.txt` | Before session revocation, password reset or log expiry |

**Capture checklist limitation:** The DNS collector/export command depends on the resolver product, which was not supplied. The precise command for the lab-supplied file is provided; an actual DNS export must still be obtained. Commands in the table are instructions, not proof of execution. All relative SHA-256 commands run after `cd /evidence/IR-2026-0414-01`. The pipe character shown as `\|` in the table is a Markdown escape; in PowerShell enter it as `|`.
