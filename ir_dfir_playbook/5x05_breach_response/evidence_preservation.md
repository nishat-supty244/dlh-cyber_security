
# Task 1 — Evidence Preservation

## MedDefense Health Systems

**Incident ID:** IR-2026-0420-01  
**Severity:** SEV1 — Critical  
**Incident date:** 2026-04-20  
**Evidence source:** Supplied incident transcript, Sysmon, proxy and file-server logs  
**Analysis environment:** Kali Linux  
**Document status:**  Evidence analysis completed; forensic acquisitions pending  
**Analyst:** Nishat Sultana Supty

---

## 1. Objective

The purpose of this task is to preserve evidence related to the suspected compromise of MedDefense Health Systems.

The investigation focuses on five hosts:

1. CS-WS-101
2. CS-WS-104
3. CS-WS-107
4. CS-WS-112
5. FILE-SVR-01

Evidence must be preserved without unnecessarily altering the affected systems.

The preservation process includes:

- Identifying affected hosts and suspicious activity.
- Prioritizing volatile evidence such as RAM.
- Planning memory and disk acquisition.
- Calculating SHA-256 hashes to verify file integrity.
- Maintaining chain-of-custody records.
- Documenting missing evidence and limitations.

All acquisition activity must be coordinated with the incident commander and authorized system owners.

---

## 2. Initial Evidence and Incident Context

Mike Torres reported suspicious activity involving a nurse's workstation, a scheduling server, and several other workstations.

The reported indicators included:

- Unusual workstation behavior.
- Changed filenames.
- High CPU and disk usage on the scheduling server.
- SIEM alert `wz-edr-200214`.
- Suspicious service installation involving `WinHealthSvc`.
- Suspicious executable `C:\ProgramData\Microsoft\svchost32.exe`.

According to the incident transcript:

| Event | Timestamp (UTC) |
|---|---|
| CS-WS-101 memory capture by Mike Torres | 2026-04-20 19:38 |
| Memory image written to evidence share | 2026-04-20 19:41 |
| Mike Torres contacted on-call IR | 2026-04-20 19:43:18 |

Reported memory image:

`\\evidence\share\IR-2026-0420-01\cs-ws-101.mem`

**Important:** The transcript reports that this memory image was acquired, but the actual image was not provided to the student. Its SHA-256 hash was not recorded at acquisition and cannot currently be verified.

---

## 3. Evidence Analysis Performed in Kali Linux

The supplied evidence files were placed in the Kali Linux investigation directory.

SHA-256 hashes were calculated using:

```bash
sha256sum *.md *.json *.jsonl
```

### 3.1 SHA-256 Evidence Register

| Evidence file | SHA-256 |
|---|---|
| `torres_call_transcript.md` | `f2f56e107f8afbe924ab9d5544c9950b236ebe4680b9f41e673a23adc8a865a0` |
| `fileserver_access.sample.json` | `dc184b375e6c3b1b76f9c9f8959a00ed7c0e0c4092c5d9f45c66ba8e2b538b7a` |
| `proxy_72h.sample.jsonl` | `1c82b57868333bdc40516c20fed99e24e41dd3fbb052e8cd27b67f34dd208e3a` |
| `sysmon_multihost.sample.jsonl` | `0fc34f78e86a403e9e262cad7b621713a464eae18d1bb70d5f743a7f32e49099` |


These hashes were obtained from actual Kali command output.

They represent the files at the time of hashing and do not establish the integrity of any missing memory or disk images.

### 3.2 Hash Verification Procedure

Save a manifest for the original evidence files:

```bash
sha256sum \
  torres_call_transcript.md \
  fileserver_access.sample.json \
  proxy_72h.sample.jsonl \
  sysmon_multihost.sample.jsonl \
  > evidence_hashes.sha256
```

Verify the evidence:

```bash
sha256sum -c evidence_hashes.sha256
```

Record the verification result and actual UTC timestamp.

**Verification status:** Initial hashes calculated; independent manifest verification result not yet supplied.

---

## 4. Suspicious Network Activity

Sysmon network events were analyzed with:

```bash
jq -r '
  select(.event_type == "network_connection") |
  [.ts, .host, .dst_ip, .dst_port, .image] |
  @tsv
' sysmon_multihost.sample.jsonl
```

### Confirmed Results

| Timestamp (UTC) | Host | Destination | Process |
|---|---|---|---|
| 2026-04-17 14:24:02 | CS-WS-101 | 45.152.66.114:443 | svchost32.exe |
| 2026-04-19 00:04:12 | CS-WS-104 | 45.152.66.114:443 | svchost32.exe |
| 2026-04-19 00:12:44 | CS-WS-107 | 45.152.66.114:443 | svchost32.exe |
| 2026-04-19 00:18:02 | CS-WS-112 | 45.152.66.114:443 | svchost32.exe |
| 2026-04-20 19:32:04 | CS-WS-101 | 45.152.66.114:443 | svchost32.exe |

All four workstations communicated with the same suspicious destination.

The executable was:

`C:\ProgramData\Microsoft\svchost32.exe`

This is not the normal Windows service-host executable path.

The findings are consistent with possible command-and-control activity, but the network events alone do not establish the full nature of the communications.

The last recorded suspicious connection from CS-WS-101 occurred approximately six minutes before its reported memory acquisition.

---

## 5. Ransomware Staging Evidence

Sysmon file-creation events were analyzed using:

```bash
jq -r '
  select(.event_type == "file_create") |
  select(.target? | strings | contains("encryption_staging.ps1")) |
  [.ts, .host, .target] |
  @tsv
' sysmon_multihost.sample.jsonl
```

### Confirmed Results

| Timestamp (UTC) | Host | File |
|---|---|---|
| 2026-04-20 14:23:18 | CS-WS-101 | encryption_staging.ps1 |
| 2026-04-20 14:25:02 | CS-WS-104 | encryption_staging.ps1 |
| 2026-04-20 14:25:42 | CS-WS-107 | encryption_staging.ps1 |
| 2026-04-20 14:26:14 | CS-WS-112 | encryption_staging.ps1 |

Full path:

`C:\Windows\System32\encryption_staging.ps1`

### Interpretation

The same suspicious script was created on all four workstations within approximately three minutes.

This supports a finding of coordinated ransomware preparation.

However, the available file-creation events do not prove that the script executed or that encryption was completed.

Memory images, disk images and additional process-execution logs are needed to confirm the subsequent activity.

---

## 6. Credential Access Indicator

The supplied scenario's Sysmon records include suspicious access to the Windows LSASS process on CS-WS-101.

**Timestamp:** 2026-04-17 14:25:02 UTC  
**Source:** `svchost32.exe`  
**Target:** `lsass.exe`  
**Access rights:** `0x1010`

LSASS manages authentication-related operations and may contain sensitive credential material.

Access from the suspicious executable indicates possible credential theft or credential dumping.

However, process-access telemetry alone does not prove that credentials were successfully extracted.

The related memory image and security logs should be preserved for further analysis.

---

## 7. Evidence Acquisition Priorities

| Priority | Host | Reason | Acquisition status |
|---|---|---|---|
| P0 | CS-WS-101 | Initial compromise, suspicious C2, LSASS access and ransomware staging | RAM reportedly captured; image unavailable |
| P1 | CS-WS-104 | Suspicious service installation, C2 and ransomware staging | Planned |
| P1 | CS-WS-107 | Suspicious C2 and ransomware staging | Planned |
| P1 | CS-WS-112 | Suspicious C2 and ransomware staging | Planned |
| P1 | FILE-SVR-01 | Suspicious executable activity and possible patient-data exposure | Planned |

Priority P1 hosts should be handled in parallel where sufficient resources are available.

CS-WS-101's previously acquired memory image must be located and hashed before relying on it as verified evidence.

The scheduling server `SCHED-SVR-01` also requires scope assessment because suspicious activity and service degradation were reported. Its inclusion in the formal acquisition scope requires authorization.

---

## 8. Memory Acquisition Procedure

### Objective

Preserve volatile evidence before shutdown, reboot or other disruptive activity.

Volatile evidence may include:

- Running processes.
- Active network connections.
- Malware in memory.
- Authentication material.
- Active sessions.
- Loaded modules.

### Procedure for Authorized Windows Hosts

1. Record the hostname, analyst, UTC timestamp and system state.
2. Confirm acquisition authorization.
3. Avoid unnecessary interaction with the host.
4. Capture memory using an approved forensic tool such as WinPmem.
5. Store the memory image in the approved evidence location.
6. Calculate the SHA-256 hash.
7. Record the output path, file size, acquisition tool and hash.
8. Transfer the evidence to secured storage.
9. Recalculate the hash after transfer.
10. Document any errors or deviations.

Example acquisition command, subject to the installed WinPmem version:

```powershell
.\winpmem_mini_x64.exe C:\Evidence\host_memory.raw
```

Example hashing command:

```powershell
Get-FileHash `
  -Path "C:\Evidence\host_memory.raw" `
  -Algorithm SHA256
```

The exact acquisition command must be validated against the tool version and approved operational procedure.

### Existing CS-WS-101 Memory Image

| Field | Value |
|---|---|
| Host | CS-WS-101 |
| Reported collector | Mike Torres |
| Tool | WinPmem |
| Reported capture time | 2026-04-20 19:38 UTC |
| Reported storage time | 2026-04-20 19:41 UTC |
| Evidence path | `\\evidence\share\IR-2026-0420-01\cs-ws-101.mem` |
| SHA-256 at acquisition | Not recorded |
| Image available to student | No |
| Integrity verification | Pending |
| Status | Reported acquired; not independently verified |

---

## 9. Disk and Log Acquisition Procedure

### Disk Preservation

For each affected host:

1. Obtain authorization for disk acquisition.
2. Record the host identity and storage-device details.
3. Coordinate with clinical operations to avoid unsafe disruption.
4. Use an approved forensic imaging method.
5. Prefer a write blocker where applicable.
6. Acquire a forensic disk image.
7. Record acquisition start and end times.
8. Calculate and verify the SHA-256 hash.
9. Store the image in restricted evidence storage.
10. Document the transfer and custody.

Example tools include FTK Imager and other approved forensic acquisition utilities.

**Status:** No disk images were provided or acquired by the student.

### Log Preservation

Preserve relevant Windows event logs, Sysmon logs, authentication logs, service-installation events and network logs.

Example Windows commands:

```powershell
wevtutil epl Security C:\Evidence\Security.evtx
wevtutil epl System C:\Evidence\System.evtx
wevtutil epl Microsoft-Windows-Sysmon/Operational C:\Evidence\Sysmon.evtx
```

The resulting files must be hashed and recorded in the evidence register.

---

## 10. Chain of Custody

A chain-of-custody record documents who collected, accessed, transferred or stored each evidence item.

### 10.1 Existing and Planned Host Evidence

| Evidence ID | Host | Evidence | Custodian / collector | Status |
|---|---|---|---|---|
| E-001 | CS-WS-101 | Memory image | Mike Torres (reported) | Reported acquired; not provided |
| E-002 | CS-WS-101 | Disk image | Not assigned | Planned |
| E-003 | CS-WS-104 | Memory and disk | Not assigned | Planned |
| E-004 | CS-WS-107 | Memory and disk | Not assigned | Planned |
| E-005 | CS-WS-112 | Memory and disk | Not assigned | Planned |
| E-006 | FILE-SVR-01 | Memory and disk | Not assigned | Planned |

### 10.2 Supplied Evidence Files

| Evidence ID | File | Status |
|---|---|---|
| E-007 | torres_call_transcript.md | SHA-256 calculated |
| E-008 | sysmon_multihost.sample.jsonl | SHA-256 calculated |
| E-009 | proxy_72h.sample.jsonl | SHA-256 calculated |
| E-010 | fileserver_access.sample.json | SHA-256 calculated |

The complete SHA-256 values are recorded in Section 3.

### 10.3 Custody Transfer Record

| Timestamp (UTC) | Evidence ID | From | To | Action | Verification |
|---|---|---|---|---|---|
| 2026-04-20 19:38 | E-001 | CS-WS-101 | Mike Torres | Reported memory acquisition | Hash not recorded |
| 2026-04-20 19:41 | E-001 | Mike Torres | Evidence share | Reported image storage | Hash not recorded |
| Pending | E-001 | Evidence share | Forensic analyst | Retrieve and verify image | SHA-256 required |
| Pending | E-002–E-006 | Affected hosts | Forensic evidence storage | Authorized acquisition | SHA-256 required |

The supplied log files were hashed in Kali Linux, but their original collection and transfer history was not provided.

Their source provenance and custody details must therefore be confirmed separately.

---

## 11. Evidence Integrity and Storage

Evidence must be protected against unauthorized changes.

Required controls:

- Store originals in access-controlled evidence storage.
- Restrict write access to authorized custodians.
- Perform analysis using working copies.
- Calculate SHA-256 hashes at acquisition.
- Verify hashes after transfer.
- Record each access and transfer.
- Maintain UTC timestamps.
- Preserve original filenames and metadata where possible.

Example verification:

```bash
sha256sum -c evidence_hashes.sha256
```

Any mismatch must be documented and investigated before the affected evidence is used.

---

## 12. Missing Evidence and Limitations

The following information or artifacts remain unavailable:

| Missing item | Impact | Required follow-up |
|---|---|---|
| CS-WS-101 memory image | Cannot independently examine RAM or verify image integrity | Retrieve reported image |
| Original memory SHA-256 | Cannot establish hash continuity from acquisition | Document gap and hash available image |
| Memory images for other hosts | Volatile evidence unavailable | Acquire if hosts remain accessible |
| Disk images for five hosts | Cannot independently confirm full malware execution or encryption | Obtain authorized images |
| Full chain-of-custody history | Original evidence provenance incomplete | Obtain custodian records |
| Live host access | Cannot perform direct forensic acquisition | Confirm lab availability |
| Acquisition tool versions and operator records | Acquisition procedure cannot be fully validated | Obtain tool logs and records |
| FILE-SVR-01 detailed forensic results | File-server compromise scope remains incomplete | Analyze relevant host and access logs |
| SCHED-SVR-01 forensic image | Scheduling-server compromise cannot be fully assessed | Escalate acquisition scope |

No missing hash, acquisition timestamp or forensic artifact has been fabricated.

---

## 13. Conclusion

Evidence analysis in Kali Linux identified suspicious network connections from four workstations to `45.152.66.114:443`, all involving `svchost32.exe`.

The same ransomware staging script, `encryption_staging.ps1`, was created on all four workstations on 20 April 2026.

The supplied evidence files were successfully hashed using SHA-256.

The initial CS-WS-101 memory acquisition was reported by Mike Torres, but the image and its acquisition hash were not available for independent verification.

The remaining host memory and disk acquisitions are planned rather than completed.

**Immediate next action:** Secure and verify the reported CS-WS-101 memory image, preserve volatile evidence from the other affected hosts, and complete chain-of-custody documentation.

**Overall Task 1 status:** Partially completed — supplied-file hashing and initial evidence assessment completed; full forensic acquisition and verification pending.
