
# Persistence Artifact Analysis: ART-001 (wst-ws-031.dd)

## 1. Case Information

- **Case ID:** LH-2026-0414-01
- **Incident ID:** IR-2026-0414-01
- **Evidence ID:** ART-001
- **Evidence File:** wst-ws-031.dd
- **Hostname:** WST-WS-031
- **Operating System:** Windows 10 Pro 22H2
- **User:** MEDDEFENSE\dmarsh
- **Investigator:** Nishat Sultana Supty
- **Analysis Type:** Windows Registry and Persistence
- **Status:** PARTIAL — further artifact verification required

## 2. Objective

Identify possible persistence mechanisms installed by the
attacker to maintain access after a system reboot.

The investigation focuses on Windows startup registry keys,
scheduled tasks, execution history, application compatibility
artifacts, and recently accessed files.

All findings must be correlated with other forensic evidence
before being considered confirmed.

---

## 3. Artifact Verification

| Verification Item | Result |
|---|---|
| Artifact | wst-ws-031.dd |
| Evidence ID | ART-001 |
| Acquisition tool | FTK Imager |
| Acquisition date | 2026-04-14 |
| Acquisition started | 04:51 UTC |
| Acquisition completed | 06:14 UTC |
| Acquisition-time SHA-256 | Not recorded |
| Baseline verification | Not independently confirmed |
| Read-only mount | Not performed |
| Chain-of-custody update | Pending |
| Registry hives extracted | No |

The acquisition notes confirm that the original disk
image was not hashed during acquisition.

The acquirer also accessed the live filesystem read-write
before imaging, potentially affecting metadata.

The supplied disk image is a synthetic stand-in and does
not contain extractable NTFS registry hives.

Therefore, registry values and timestamps cannot be
independently verified.

### Required Verification Command

```bash
sha256sum wst-ws-031.dd
```

The resulting hash must match the first-access baseline
recorded in `hashes.txt`.

Analysis access must be recorded in
`chain_of_custody.md`.

---

## 4. Registry Persistence Analysis

### ART-001-R01: Suspicious Run-Key Entry

**Registry Key:**

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
```

**Reported Value Name:**

```text
MsUpdateCheck
```

**Reported Value Data:**

```text
powershell.exe -ep bypass -w hidden -enc ...
```

| Field | Finding |
|---|---|
| Evidence ID | ART-001-R01 |
| Registry hive | NTUSER.DAT |
| User | dmarsh |
| Value name | MsUpdateCheck |
| Value data | PowerShell encoded command, incomplete |
| Last-write timestamp | Unknown |
| Registry value type | Not verified |
| Source | Synthetic disk evidence |
| Confidence | Possible persistence |

**Forensic Significance:**

Windows Run keys can automatically launch configured
programs when a user signs in.

The reported `MsUpdateCheck` value appears suspicious
because it references PowerShell with execution-policy
bypass, a hidden window, and an encoded command.

These options are not automatically malicious, but
they warrant investigation in the context of the
PowerShell-to-MSBuild SIEM alert.

The actual NTUSER.DAT hive has not been recovered.
Therefore, the entry's existence, complete command,
and last-write timestamp remain unverified.

**MITRE ATT&CK:** T1547.001

### ART-001-R02: RunOnce Key Examination

**Registry Key:**

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce
```

| Field | Finding |
|---|---|
| Evidence ID | ART-001-R02 |
| Registry hive | NTUSER.DAT |
| Value name | Not available |
| Value data | Not available |
| Last-write timestamp | Not available |
| Status | Not examined from actual hive |

**Forensic Significance:**

RunOnce entries can execute programs during a subsequent
user sign-in.

They may be used for legitimate installation tasks or
one-time malicious execution.

No RunOnce entry has been independently recovered.

This does not establish that the key was empty.

---

## 5. Scheduled Task Persistence

### ART-001-R03: MsUpdateCheck Scheduled Task

**Reported Task Name:**

```text
\MsUpdateCheck
```

**Expected Task Directory:**

```text
C:\Windows\System32\Tasks\
```

| Field | Finding |
|---|---|
| Evidence ID | ART-001-R03 |
| Task name | MsUpdateCheck |
| XML file | Not recovered |
| Trigger | Unknown |
| Action | Not independently verified |
| Principal | Unknown |
| Run level | Unknown |
| Last-write timestamp | Unknown |
| Source | Synthetic disk evidence |
| Confidence | Possible persistence |

**Forensic Significance:**

Windows Task Scheduler can execute programs automatically
at startup, user sign-in, or a configured time.

The synthetic evidence references a task named
`MsUpdateCheck` and associated TaskCache information.

This could represent a persistence mechanism intended
to execute suspicious commands repeatedly.

However, the actual task XML was not extracted.

Its trigger, action, principal, and execution conditions
cannot be confirmed.

**MITRE ATT&CK:** T1053.005

### Scheduled Task XML Examination

For a genuine NTFS image, extract the scheduled task
XML file and examine these elements:

```xml
<Triggers>
    <!-- Actual trigger information -->
</Triggers>

<Principals>
    <!-- Actual execution account -->
</Principals>

<Actions>
    <!-- Actual command and arguments -->
</Actions>
```

The example above illustrates fields to inspect.
It is not recovered evidence.

---

## 6. UserAssist Execution Evidence

### ART-001-E01: UserAssist Examination

**Registry Path:**

```text
HKCU\Software\Microsoft\Windows\
CurrentVersion\Explorer\UserAssist
```

**Registry Hive:**

```text
C:\Users\dmarsh\NTUSER.DAT
```

| Field | Finding |
|---|---|
| Evidence ID | ART-001-E01 |
| Registry artifact | UserAssist |
| Executable | Not recovered |
| ROT13-decoded value | Not available |
| Run count | Unknown |
| Last execution time | Unknown |
| Source | NTUSER.DAT required |
| Status | Unverified |

**Forensic Significance:**

UserAssist records may provide information about
programs launched through Windows Explorer.

Its values commonly require ROT13 decoding.

Relevant entries should be checked for:

- powershell.exe
- MSBuild.exe
- cmd.exe
- Any unfamiliar executable

No UserAssist records were available for extraction.

The SIEM records process creation, but that does not
establish the existence of corresponding UserAssist
entries.

UserAssist does not record every process execution.

---

## 7. AppCompatCache / ShimCache Analysis

### ART-001-E02: ShimCache Examination

**Registry Hive:**

```text
C:\Windows\System32\config\SYSTEM
```

**Relevant Registry Location:**

```text
SYSTEM\CurrentControlSet\Control\
Session Manager\AppCompatCache
```

The actual stored location may be under a numbered
ControlSet rather than the CurrentControlSet alias.

| Field | Finding |
|---|---|
| Evidence ID | ART-001-E02 |
| Registry artifact | AppCompatCache / ShimCache |
| Executable path | Not recovered |
| Entry order | Not available |
| Available timestamps | Unknown |
| Last-write timestamp | Unknown |
| Status | Unverified |

**Forensic Significance:**

ShimCache can contain information about executables
observed by Windows application compatibility
mechanisms.

It may help identify suspicious executable paths
that are no longer present on disk.

However, ShimCache alone does not reliably prove
that a program executed.

The recorded order and timestamp semantics depend
on the Windows version and parser.

The SYSTEM hive was not available for examination.

---

## 8. Amcache Analysis

### ART-001-E03: Amcache Examination

**Artifact Path:**

```text
C:\Windows\AppCompat\Programs\Amcache.hve
```

| Field | Finding |
|---|---|
| Evidence ID | ART-001-E03 |
| Artifact | Amcache.hve |
| Executable path | Not recovered |
| SHA-1 | Unknown |
| File size | Unknown |
| Available timestamps | Unknown |
| First execution time | Not established |
| Status | Unverified |

**Forensic Significance:**

Amcache can contain executable metadata, file paths,
hash-related information, and timestamps.

It may help identify suspicious binaries and correlate
them with other forensic artifacts.

Amcache timestamps should not automatically be
interpreted as first execution times.

The meaning of each timestamp depends on the
specific Amcache record and Windows version.

No Amcache hive was available for extraction.

---

## 9. Recent LNK File Analysis

### ART-001-E04: Windows Recent Files

**Directory:**

```text
C:\Users\dmarsh\AppData\Roaming\
Microsoft\Windows\Recent\
```

| Field | Finding |
|---|---|
| Evidence ID | ART-001-E04 |
| Artifact type | Windows shortcut (.lnk) |
| Shortcut filename | Not recovered |
| Target path | Unknown |
| Target timestamps | Unknown |
| LNK timestamps | Unknown |
| Status | Unverified |

**Forensic Significance:**

Windows LNK files can reveal files or locations
accessed through the user interface.

Relevant targets would include:

```text
C:\Users\dmarsh\AppData\Local\Temp\update.xml
C:\Users\dmarsh\Downloads\update.zip
```

These are investigation targets, not confirmed
LNK findings.

No actual shortcut files were recovered.

---

## 10. Correlation With SIEM Evidence

The SIEM alert provides the following activity:

| Timestamp (UTC) | Event |
|---|---|
| 2026-04-13 18:14:02 | Suspicious login website visited |
| 2026-04-14 02:46:41 | PowerShell process created |
| 2026-04-14 02:46:57 | MSBuild process created |
| 2026-04-14 02:47:11 | SIEM alert triggered |

**Alert ID:**

```text
A-20260414-9841
```

**Reported Process Tree:**

```text
powershell.exe
    |
    +-- MSBuild.exe
          |
          +-- C:\Users\dmarsh\
              AppData\Local\Temp\update.xml
```

**MITRE ATT&CK Techniques:**

- T1059.001 — PowerShell
- T1127.001 — MSBuild

The synthetic disk evidence also references
`MsUpdateCheck` persistence artifacts.

This suggests a possible relationship between
the reported process execution and persistence.

However, the exact relationship cannot be confirmed
without registry and scheduled-task evidence.

---

## 11. Persistence Findings Summary

| Evidence ID | Artifact | Assessment |
|---|---|---|
| ART-001-R01 | HKCU Run / MsUpdateCheck | Possible persistence |
| ART-001-R02 | HKCU RunOnce | Not verified |
| ART-001-R03 | Scheduled task / MsUpdateCheck | Possible persistence |
| ART-001-E01 | UserAssist | Not verified |
| ART-001-E02 | ShimCache | Not verified |
| ART-001-E03 | Amcache | Not verified |
| ART-001-E04 | Recent LNK files | Not verified |

**Confirmed persistence mechanisms: 0**

**Possible persistence mechanisms identified: 2**

These counts reflect the evidence available for this
report, not a complete examination of the original
workstation.

---

## 12. Eradication Considerations

The following actions are recommended only after
preserving evidence and verifying the suspected
persistence mechanisms.

### 12.1 Registry Run Key

If `MsUpdateCheck` is confirmed to be malicious:

1. Export and preserve the relevant registry evidence.
2. Record the complete value data and timestamps.
3. Remove the malicious Run-key value through an
   approved remediation process.
4. Verify that the value does not return.

### 12.2 Scheduled Task

If the scheduled task is confirmed to be malicious:

1. Preserve the original scheduled-task XML.
2. Record its trigger, action, principal, and timestamps.
3. Disable the task.
4. Remove it through the approved eradication process.
5. Check for recreation after reboot.

### 12.3 Associated Payloads

If malicious payloads are independently confirmed:

1. Preserve forensic copies and hashes.
2. Identify related processes and files.
3. Remove malicious components through approved
   containment and eradication procedures.
4. Validate the system after reboot.
5. Continue monitoring for recurrence.

No remediation action is claimed to have been
performed during this analysis.

---

## 13. Evidence Limitations

The investigation has several limitations.

### 13.1 Synthetic Disk Image

The supplied `wst-ws-031.dd` does not contain a usable
NTFS filesystem.

Therefore, registry hives, scheduled-task XML files,
and LNK artifacts cannot be extracted.

### 13.2 Missing Acquisition Hashes

The acquisition notes confirm that SHA-256 hashes
were not calculated during acquisition.

### 13.3 Read-Write Access Before Imaging

The original filesystem was accessed read-write
before imaging.

This may have affected some timestamps or metadata.

### 13.4 Missing Chain-of-Custody Records

The acquisition notes identify undocumented access
between acquisition and handoff.

The actual analysis access must be added to the
authoritative chain-of-custody record.

### 13.5 Unverified Persistence Timestamps

No actual registry last-write timestamps, UserAssist
run counts, ShimCache records, Amcache timestamps,
or LNK targets were recovered.

These details must not be fabricated.

---

## 14. Conclusion

The available evidence suggests two possible Windows
persistence mechanisms associated with the name
`MsUpdateCheck`:

1. A registry Run-key entry.
2. A scheduled task.

The reported Run-key command is suspicious because
it references hidden, encoded PowerShell execution.

The scheduled-task reference may indicate another
method of maintaining access after reboot.

These findings are consistent with the broader
investigation of suspicious PowerShell and MSBuild
activity on WST-WS-031.

However, neither persistence mechanism has been
independently verified from extracted Windows artifacts.

UserAssist, ShimCache, Amcache, RunOnce, and Recent
LNK analysis also remain incomplete.

