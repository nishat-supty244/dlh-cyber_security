
# Memory Analysis: ART-002 and ART-003

## 1. Case Information

- **Case ID:** LH-2026-0414-01
- **Incident ID:** IR-2026-0414-01
- **Primary Host:** WST-WS-031
- **Secondary Host:** WST-WS-017
- **Evidence ART-002:** wst-ws-031.mem
- **Evidence ART-003:** wst-ws-017.mem
- **Investigator:** Nishat Sultana Supty
- **Analysis Tool:** Volatility 3
- **Analysis Status:** PARTIAL — memory images not provided

## 2. Objective

Examine volatile memory evidence to identify:

- Suspicious processes and parent-child relationships.
- Command-line arguments used during execution.
- Network connections associated with suspicious processes.
- DLLs loaded by suspicious executables.
- Potential executable memory injection.
- LSASS-related activity and credential exposure.
- Additional suspicious activity on WST-WS-017.

The SIEM alert is used only as investigative context.
Memory findings must be independently confirmed using
Volatility 3 before being classified as confirmed.

---

## 3. Artifact Verification

### ART-002: WST-WS-031 Memory

| Field | Result |
|---|---|
| Evidence ID | ART-002 |
| Filename | wst-ws-031.mem |
| Acquisition tool | WinPmem v3.3-rc3 |
| Acquisition time | 2026-04-14 03:02 UTC |
| Acquisition SHA-256 | Not recorded |
| First-access baseline | Not provided |
| Hash verification | Pending |
| Chain-of-custody update | Pending |
| Memory analysis | Not executed |

### ART-003: WST-WS-017 Memory

| Field | Result |
|---|---|
| Evidence ID | ART-003 |
| Filename | wst-ws-017.mem |
| Acquisition tool | WinPmem |
| Acquisition time | 2026-04-14 03:38 UTC |
| Acquisition SHA-256 | Not recorded |
| First-access baseline | Not provided |
| Hash verification | Pending |
| Chain-of-custody update | Pending |
| Memory analysis | Not executed |

### Verification Commands

```bash
sha256sum wst-ws-031.mem
sha256sum wst-ws-017.mem
```

The computed hashes must be compared against the
first-access baselines in `hashes.txt`.

No matching hashes are claimed because the memory
images and baseline values were not supplied.

Both memory images must be examined without modifying
the original evidence.

---

# 4. WST-WS-031 Memory Analysis (ART-002)

## ART-002-M01: Process List

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.pslist.PsList
```

### Purpose

Identify running processes and examine:

- Process name
- Process ID (PID)
- Parent process ID (PPID)
- Creation timestamp
- Exit timestamp, where available

### Relevant SIEM Context

The SIEM reported:

| Process | PID | Timestamp (UTC) |
|---|---|---|
| powershell.exe | 7812 | 2026-04-14 02:46:41 |
| MSBuild.exe | 8104 | 2026-04-14 02:46:57 |

These are SIEM-reported process details, not
Volatility results.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

The process list should be checked for PowerShell
and MSBuild processes matching the SIEM alert.

Their creation times and PIDs should be compared
with the reported incident timeline.

### Assessment

- **Finding:** Suspicious processes reported by SIEM.
- **PIDs of interest:** 7812 and 8104.
- **Memory confirmation:** Pending.
- **ATT&CK:** T1059.001, T1127.001.
- **Certainty:** Possible — not memory-confirmed.

---

## ART-002-M02: Process Parent-Child Tree

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.pstree.PsTree
```

### Purpose

Identify process relationships and determine whether
PowerShell launched MSBuild.

### Relevant SIEM Context

```text
powershell.exe (PID 7812)
    |
    +-- MSBuild.exe (PID 8104)
```

The above process relationship was reported by SIEM.

It is not independently confirmed by Volatility.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

A matching Volatility process tree would provide
independent evidence supporting the SIEM process
relationship.

MSBuild is a legitimate Windows development utility,
but attackers may abuse it to execute malicious code.

### Assessment

- **Finding:** PowerShell-to-MSBuild execution reported.
- **Parent PID:** 7812.
- **Child PID:** 8104.
- **ATT&CK:** T1127.001.
- **Certainty:** Possible — pending Volatility confirmation.

---

## ART-002-M03: Command-Line Analysis

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.cmdline.CmdLine
```

### Purpose

Recover command-line arguments associated with
processes found in memory.

### Relevant SIEM Context

PowerShell command:

```text
powershell.exe -ep bypass -w hidden -enc JABzAD0AIgBoAHQAdABwAHMAOgAvAC8AbQBzADAAMwA2ADUA...
```

MSBuild command:

```text
msbuild.exe C:\Users\dmarsh\AppData\Local\Temp\update.xml
```

The PowerShell command includes:

- `-ep bypass`: execution-policy bypass.
- `-w hidden`: hidden window.
- `-enc`: encoded command.

The encoded command in the SIEM export is truncated,
so its complete contents cannot be established.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

The reported commands suggest suspicious PowerShell
execution followed by use of an XML file through MSBuild.

Volatility command-line results are needed to
independently confirm these arguments.

### Assessment

- **Finding:** Suspicious command-line activity.
- **PIDs:** 7812 and 8104.
- **ATT&CK:** T1059.001, T1127.001.
- **Certainty:** Possible — pending memory confirmation.

---

## ART-002-M04: Network Connection Analysis

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.netscan.NetScan
```

### Purpose

Identify active and recently closed network connections,
including:

- Local IP and port
- Remote IP and port
- Connection state
- Owning PID
- Process name, where available

### Relevant SIEM Context

```text
Remote IP: 185.220.101.47
Remote Port: 443
Protocol: TCP
State: ESTABLISHED
```

The SIEM tagged the destination as a Tor exit relay
or anonymizer.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

The network scan should determine whether a process
on WST-WS-031 maintained a connection to this
destination during memory acquisition.

A matching remote address alone does not establish
command-and-control activity.

The owning PID, process identity, timing, and related
evidence must be examined.

### Assessment

- **Finding:** Suspicious network connection reported.
- **Remote IP:** 185.220.101.47.
- **Owning PID:** Not established by memory evidence.
- **ATT&CK:** T1071.001 (candidate, if C2 is established).
- **Certainty:** Possible — pending memory confirmation.

---

## ART-002-M05: Loaded DLL Analysis

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.dlllist.DllList --pid 8104
```

### Purpose

List DLLs loaded by the suspected MSBuild process.

The PID must first be verified through `pslist`
or `pstree`.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

Loaded DLLs should be reviewed for:

- Unusual paths
- Unexpected module names
- DLLs loaded from temporary directories
- Modules associated with suspicious execution

A DLL's presence alone does not establish malicious
behavior.

### Assessment

- **Finding:** No verified DLL findings.
- **PID of interest:** 8104.
- **ATT&CK:** Not assigned without evidence.
- **Certainty:** Possible — investigation pending.

---

## ART-002-M06: Suspicious Executable Memory

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.malfind.Malfind
```

### Purpose

Identify memory regions with properties potentially
associated with injected or unpacked code.

### Investigation Focus

Check whether `MSBuild.exe` has:

- Unusual executable memory regions
- Suspicious memory protections
- PE headers in unexpected locations
- Memory contents inconsistent with normal execution

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

A suspicious executable memory region may indicate
code injection or unpacking.

However, executable writable memory and PE headers
alone do not conclusively prove malicious injection.

Memory contents must be examined and correlated with
process behavior and other evidence.

### Assessment

- **Finding:** No verified injection evidence.
- **PID of interest:** 8104.
- **ATT&CK:** T1055 (candidate only).
- **Certainty:** Possible — investigation pending.

---

## ART-002-M07: LSASS Handle Analysis

### Step 1: Identify LSASS PID

```bash
vol -f wst-ws-031.mem windows.pslist.PsList
```

Locate the process:

```text
lsass.exe
```

Record its actual PID.

### Step 2: Examine LSASS Handles

```bash
vol -f wst-ws-031.mem windows.handles.Handles --pid <LSASS_PID>
```

### Purpose

Examine handles owned by LSASS at acquisition time.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

LSASS manages Windows authentication-related
operations.

The requested command lists handles held by LSASS.
It does not, by itself, identify other processes
that opened handles to LSASS.

To investigate possible credential dumping,
additional process-handle correlation and memory
evidence would be necessary.

### Assessment

- **Finding:** Credential-access activity not verified.
- **LSASS PID:** Unknown.
- **ATT&CK:** T1003.001 (candidate only).
- **Certainty:** Possible — investigation pending.

---

## ART-002-M08: SAM Hash Extraction

### Volatility Command

```bash
vol -f wst-ws-031.mem windows.hashdump.Hashdump
```

### Purpose

Attempt to recover locally stored Windows account
hash information from relevant registry material
present in memory.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

The presence of recoverable NTLM hashes does not
prove that an attacker accessed or stole them.

This plugin should not be described as a complete
LSA-secrets extraction method.

Credential exposure requires additional evidence,
such as suspicious access to LSASS, credential
dumping tools, or related telemetry.

### Sensitive Evidence Handling

If hashes are recovered:

1. Preserve results in restricted evidence storage.
2. Do not publish raw credential hashes to GitHub.
3. Record artifact identifiers and hashes of exports.
4. Include only redacted information in this report.
5. Escalate confirmed credential exposure through
   the incident response process.

### Assessment

- **Finding:** No credential hashes recovered or verified.
- **PID:** Not applicable.
- **ATT&CK:** T1003.002 (candidate only).
- **Certainty:** Possible — investigation pending.

---

# 5. WST-WS-017 Memory Analysis (ART-003)

## ART-003-M01: Process List

### Volatility Command

```bash
vol -f wst-ws-017.mem windows.pslist.PsList
```

### Purpose

Identify running processes and suspicious execution
on the second workstation.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

Compare the process list against WST-WS-031,
looking for:

- PowerShell execution
- MSBuild execution
- Unexpected administrative tools
- Suspicious process creation times

### Assessment

- **Finding:** No additional process findings verified.
- **PIDs:** Unknown.
- **ATT&CK:** Not assigned.
- **Certainty:** Possible — investigation pending.

---

## ART-003-M02: Network Connections

### Volatility Command

```bash
vol -f wst-ws-017.mem windows.netscan.NetScan
```

### Purpose

Identify network connections associated with
WST-WS-017.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

Investigate whether WST-WS-017 communicated with:

- 185.220.101.47
- Other suspicious external addresses
- WST-WS-031
- Unexpected internal hosts

A connection must be correlated with its owning
process and other evidence before drawing conclusions.

### Assessment

- **Finding:** No network activity independently verified.
- **PIDs:** Unknown.
- **ATT&CK:** Not assigned.
- **Certainty:** Possible — investigation pending.

---

## ART-003-M03: Command-Line Analysis

### Volatility Command

```bash
vol -f wst-ws-017.mem windows.cmdline.CmdLine
```

### Purpose

Examine process command-line arguments for signs
of suspicious execution.

### Volatility Output

```text
NOT AVAILABLE — memory image not supplied.
```

### Forensic Significance

Look for encoded PowerShell commands, unexpected
MSBuild usage, suspicious script paths, or commands
associated with lateral movement.

### Assessment

- **Finding:** No suspicious command lines verified.
- **PIDs:** Unknown.
- **ATT&CK:** Not assigned.
- **Certainty:** Possible — investigation pending.

---

# 6. Cross-Host Comparison

| Indicator | WST-WS-031 | WST-WS-017 |
|---|---|---|
| PowerShell execution | SIEM reported | Unknown |
| MSBuild execution | SIEM reported | Unknown |
| Encoded command | SIEM reported | Unknown |
| Suspicious remote IP | SIEM reported | Unknown |
| Injected memory | Not verified | Not examined |
| Credential exposure | Not verified | Not examined |
| Lateral movement | Not established | Not established |

No conclusion about compromise of WST-WS-017
can be made from the available memory evidence.

---

# 7. Findings Summary

| Evidence ID | Plugin | Finding | Certainty |
|---|---|---|---|
| ART-002-M01 | pslist | SIEM-reported suspicious processes | Possible |
| ART-002-M02 | pstree | SIEM-reported PowerShell → MSBuild | Possible |
| ART-002-M03 | cmdline | SIEM-reported encoded command | Possible |
| ART-002-M04 | netscan | SIEM-reported external connection | Possible |
| ART-002-M05 | dlllist | DLL analysis pending | Possible |
| ART-002-M06 | malfind | Injection analysis pending | Possible |
| ART-002-M07 | handles | LSASS examination pending | Possible |
| ART-002-M08 | hashdump | Hash extraction pending | Possible |
| ART-003-M01 | pslist | Process analysis pending | Possible |
| ART-003-M02 | netscan | Network analysis pending | Possible |
| ART-003-M03 | cmdline | Command-line analysis pending | Possible |

The "possible" labels indicate investigative
hypotheses, not positive Volatility findings.

**Confirmed memory findings: 0**

**Probable memory findings: 0**

**Independently verified memory findings: 0**

---

# 8. Evidence Limitations

## 8.1 Missing Memory Images

Neither memory image was supplied for this analysis.

Therefore, the Volatility commands have not been
executed and their outputs cannot be documented.

## 8.2 Missing Acquisition Hashes

The acquisition notes state that SHA-256 hashes
were not calculated at acquisition time.

First-access baseline hashes must be established
and recorded.

## 8.3 Chain-of-Custody Gaps

The acquisition notes identify incomplete custody
documentation before evidence handoff.

Actual analyst access and verification events
must be recorded.

## 8.4 SIEM Versus Memory Evidence

The SIEM alert reports suspicious PowerShell,
MSBuild, and network activity.

These observations provide investigative leads.

They are not substitutes for independent memory
analysis.

## 8.5 Sensitive Credential Material

Recovered credential hashes or secrets must
be handled as restricted evidence.

They must not be included in a public repository.

---

# 9. Conclusion

The SIEM evidence identifies suspicious activity
on WST-WS-031 involving PowerShell, MSBuild,
and an external network connection. The primary memory image was acquired at
03:02 UTC on 2026-04-14 while the workstation
was still live and reportedly beaconing. The secondary workstation memory was acquired
at 03:38 UTC. These memory images may contain valuable
evidence of process execution, network activity,
and potential credential access. However, neither image was available for this
analysis. As a result, no Volatility-based findings can
be independently confirmed.
