
# Filesystem Analysis: ART-001 (`wst-ws-031.dd`)

## 1. Case Information

- **Case ID:** LH-2026-0414-01
- **Incident ID:** IR-2026-0414-01
- **Evidence ID:** ART-001
- **Evidence File:** wst-ws-031.dd
- **Host:** WST-WS-031
- **Operating System:** Windows 10 Pro 22H2
- **Location:** West Campus
- **User:** MEDDEFENSE\dmarsh
- **Investigator:** Steve, Cybersecurity Engineer
- **Tools:** The Sleuth Kit (TSK), SHA-256
- **Analysis Status:** PARTIAL

**Important:** The supplied `wst-ws-031.dd` is a synthetic
stand-in rather than a valid NTFS disk image. Therefore, the
filesystem analysis cannot be fully completed. Findings below
are based on the supplied evidence and are marked accordingly.

---

## 2. Artifact Verification

Before performing forensic analysis, evidence integrity must
be verified using SHA-256.

| Verification Item | Result |
|---|---|
| Artifact ID | ART-001 |
| File | wst-ws-031.dd |
| Uploaded file size | 1,048,576 bytes |
| SHA-256 verification | NOT VERIFIED against baseline |
| Acquisition hash | NOT RECORDED |
| Read-only mount | NO |
| Chain of custody updated | NO |
| Analysis status | PARTIAL |

**SHA-256 of uploaded stand-in:**

```text
d4eaffefef6c6e7c0b99b65d94cced2752f3e556679a4789f664d7cbb4296761
```

This hash identifies the uploaded synthetic file only.
It is not an acquisition-time hash.

The acquisition notes confirm that no SHA-256 hash was
calculated during the original disk acquisition.

### Verification Command

```bash
sha256sum wst-ws-031.dd
```

The hash must be compared against the value in `hashes.txt`
before further forensic analysis.

---

## 3. Partition Layout

### Command

```bash
mmls wst-ws-031.dd
```

### Purpose

The `mmls` command identifies disk partitions and their
starting sector offsets.

The NTFS partition offset is required for subsequent
filesystem analysis.

### Results

The supplied file is a synthetic stand-in containing readable
text and zero padding rather than a valid partitioned image.

The expected MBR signature is absent, and no valid NTFS boot
sector is available.

Therefore:

- Partition table: NOT AVAILABLE
- NTFS partition: NOT IDENTIFIED
- NTFS sector offset: NOT DETERMINED

**Finding:** A valid NTFS partition layout cannot be recovered
from the supplied file.

---

## 4. Filesystem Metadata

### Command

```bash
fsstat -o <NTFS_OFFSET> wst-ws-031.dd
```

### Purpose

The `fsstat` command displays filesystem information,
including:

- Filesystem type
- Volume serial number
- Sector and cluster sizes
- NTFS metadata
- Available mount and filesystem timestamps

### Results

The supplied image does not contain a valid NTFS filesystem.

| Metadata | Result |
|---|---|
| Filesystem type | Not determined |
| Volume serial number | Not available |
| Last mount time | Not available |
| Cluster size | Not available |
| NTFS offset | Not determined |

**Finding:** Filesystem metadata cannot be verified from
the supplied synthetic image.

---

## 5. Recursive File Listing

### Command

```bash
fls -r -o <NTFS_OFFSET> wst-ws-031.dd > fls_output.txt
```

### Purpose

The `fls` command recursively lists filesystem entries,
including allocated and potentially deleted files.

It helps identify:

- Suspicious files
- File metadata addresses (inodes)
- Deleted entries
- Directories used for malware staging
- Files potentially associated with persistence

### Results

A genuine NTFS file listing cannot be generated from the
synthetic image.

The following information remains unavailable:

- Verified inode numbers
- Actual NTFS file sizes
- Deleted-file flags
- Filesystem allocation status

**Output:** `fls_output.txt` cannot be populated with valid
TSK results from this image.

---

## 6. MAC Timeline Analysis

### Commands

A TSK body file must first be generated using `fls -m`.

```bash
fls -r -m / -o <NTFS_OFFSET> wst-ws-031.dd > fls_body.txt

mactime -b fls_body.txt -d -z UTC > mac_timeline.csv
```

### Purpose

A MAC timeline reconstructs file activity using filesystem
timestamps.

- **M:** Modified time
- **A:** Accessed time
- **C:** Metadata changed time
- **B:** Birth or creation time

These timestamps can help identify when suspicious files
were created, modified, or accessed.

### Results

A verified MAC timeline could not be generated because the
supplied image has no usable NTFS filesystem.

**Output:** `mac_timeline.csv` not available.

The chronology documented below uses SIEM records and
descriptive information from the supplied evidence.

It must not be treated as a verified filesystem MAC timeline.

---

## 7. Examination of Required Directories

### 7.1 Temporary Directory

**Path:**

```text
C:\Users\dmarsh\AppData\Local\Temp\
```

**Purpose:** Identify malware staging and execution files.

**Observation:**

The supplied evidence identifies a suspicious file named
`update.xml`.

The SIEM alert reports that `MSBuild.exe` executed using
this file.

The acquisition notes also state that the acquirer observed
`update.xml` before imaging.

**Status:** Reported presence; not independently recovered
from NTFS.

### 7.2 Scheduled Tasks Directory

**Path:**

```text
C:\Windows\System32\Tasks\
```

**Purpose:** Identify scheduled tasks potentially used for
malware persistence.

**Observation:**

The synthetic stand-in references a scheduled task named:

```text
\MsUpdateCheck
```

It also mentions TaskCache registry information.

However, no actual scheduled-task XML file has been
extracted or verified.

**Status:** Suspected persistence; not confirmed.

### 7.3 Windows Recent Directory

**Path:**

```text
C:\Users\dmarsh\AppData\Roaming\Microsoft\Windows\Recent\
```

**Purpose:** Examine Windows shortcut (LNK) files to
identify recently accessed files.

**Observation:**

No LNK artifacts were supplied or recovered.

**Status:** No verified findings available.

### 7.4 Browser History Directory

**Path:**

```text
C:\Users\dmarsh\AppData\Local\Microsoft\Windows\History\
```

**Purpose:** Examine available browsing history artifacts.

**Observation:**

The SIEM records a visit to a suspicious login website,
but no browser history file was recovered from the disk.

**Status:** Browser activity reported by SIEM; not
filesystem-verified.

---

## 8. Key Forensic Findings

### ART-001-F01: Suspicious MSBuild Staging File

**Artifact:** `update.xml`

| Field | Finding |
|---|---|
| Full path | C:\Users\dmarsh\AppData\Local\Temp\update.xml |
| Created | Unknown |
| Modified | Unknown |
| Accessed | Unknown |
| Metadata changed | Unknown |
| Size | Unknown |
| SHA-256 | Unknown |
| Inode | Unknown |
| Evidence source | SIEM, acquisition notes, synthetic stand-in |

**Forensic Significance:**

The SIEM alert indicates that PowerShell launched MSBuild
using the suspicious XML file.

Reported process sequence:

```text
powershell.exe (PID 7812)
        |
        v
MSBuild.exe (PID 8104)
        |
        v
C:\Users\dmarsh\AppData\Local\Temp\update.xml
```

The reported MSBuild process started at:

```text
2026-04-14T02:46:57Z
```

This activity is consistent with suspected abuse of
MSBuild for execution.

**MITRE ATT&CK:** T1127.001

The contents of `update.xml` have not been independently
examined, so malicious functionality is not confirmed
from disk evidence.

### ART-001-F02: Suspicious Downloaded Archive

**Artifact:** `update.zip`

| Field | Finding |
|---|---|
| Full path | C:\Users\dmarsh\Downloads\update.zip |
| Reported timestamp | 2026-04-13T18:14:43Z |
| Reported size | 421004 bytes |
| Modified | Unknown |
| Accessed | Unknown |
| SHA-256 | Unknown |
| Inode | Unknown |
| Evidence source | Synthetic stand-in |

**Forensic Significance:**

The synthetic stand-in describes `update.zip` as a
downloaded or dropped archive.

It may be associated with the suspected initial access
or malware staging activity.

However, the actual ZIP file was not extracted.

Its contents, true size, creation time, and hash remain
unverified.

**Status:** Provisional finding.

### ART-001-F03: Suspicious Scheduled Task

**Artifact:** `MsUpdateCheck`

| Field | Finding |
|---|---|
| Task name | \MsUpdateCheck |
| Scheduled task XML | Not recovered |
| Created | Unknown |
| Modified | Unknown |
| Accessed | Unknown |
| Size | Unknown |
| SHA-256 | Unknown |
| Inode | Unknown |
| Evidence source | Synthetic stand-in |

**Reported Registry Reference:**

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Run\MsUpdateCheck
```

**Forensic Significance:**

The synthetic evidence references a scheduled task and
registry Run-key entry associated with PowerShell and
MSBuild execution.

These mechanisms may allow suspicious code to execute
again after a restart or user login.

However, the actual task XML and registry hive have not
been examined.

**Status:** Possible persistence; requires confirmation.

---

## 9. Reconstructed Attack Chronology

The following events are based on SIEM records,
acquisition notes, and synthetic artifact descriptions.

**This is not a verified NTFS MAC timeline.**

| Timestamp (UTC) | Event | Source |
|---|---|---|
| 2026-04-13 18:14:02 | Suspicious login website visited | SIEM proxy event |
| 2026-04-13 18:14:43 | update.zip reportedly dropped | Synthetic stand-in |
| 2026-04-14 02:46:41 | PowerShell process created | SIEM EDR |
| 2026-04-14 02:46:57 | MSBuild process created | SIEM EDR |
| 2026-04-14 02:47:11 | High-severity SIEM alert triggered | SIEM |
| 2026-04-14 04:51 | Disk acquisition started | Acquisition notes |
| 2026-04-14 06:14 | Disk acquisition completed | Acquisition notes |

### Additional Network Evidence

The SIEM alert reports a connection to:

```text
IP: 185.220.101.47
Port: 443
Protocol: TCP
```

The destination was tagged as an anonymizer or Tor exit relay.

This is suspicious in the context of the reported process
execution, but the purpose of the connection and any data
exfiltration have not been independently established.

---

## 10. Individual File Extraction

### Command

```bash
icat -o <NTFS_OFFSET> wst-ws-031.dd <INODE> > extracted_file.bin
```

### Calculate Extracted File Hash

```bash
sha256sum extracted_file.bin
```

### Check File Size

```bash
stat -c %s extracted_file.bin
```

### Results

File extraction could not be completed because:

1. The supplied image has no usable NTFS filesystem.
2. No valid NTFS partition offset is available.
3. No verified inode numbers can be recovered.

Therefore, no individual-file SHA-256 hashes are claimed.

---

## 11. Evidence Handling and Chain of Custody

The acquisition notes identify several limitations.

### 11.1 Missing Acquisition Hash

No SHA-256 hash was recorded when the original disk image
was acquired.

A hash calculated later establishes a first-access
baseline, not an acquisition-time baseline.

### 11.2 Read-Write Filesystem Access

Before imaging, the acquirer mounted the live filesystem
read-write and opened Windows Explorer to inspect
`update.xml`.

This may have affected filesystem timestamps or metadata.

### 11.3 Incomplete Custody Documentation

The acquisition notes indicate that a formal chain-of-
custody record was not created during acquisition.

Access between acquisition and handoff was also not
fully documented.

### 11.4 Current Analysis Logging

The uploaded chain-of-custody document has not been
modified during preparation of this report.

The investigator must record the actual examination,
timestamp, artifact identifier, and hash in the
authoritative chain-of-custody record.

---

## 12. Conclusion

The available evidence suggests a possible attack sequence
involving:

1. A visit to a suspicious login website.
2. A reported downloaded archive named `update.zip`.
3. PowerShell execution followed by MSBuild.
4. Use of the suspicious `update.xml` file.
5. Possible persistence through `MsUpdateCheck`.
6. A reported outbound connection to an anonymizer IP.

The SIEM evidence supports investigation of suspicious
PowerShell and MSBuild activity on WST-WS-031.

However, the supplied disk image is a synthetic stand-in,
not a genuine NTFS image.

As a result, partition layout, filesystem metadata,
MAC timestamps, inode numbers, extracted file contents,
and file-specific SHA-256 hashes remain unverified.

**Final Status: PARTIAL — further NTFS forensic evidence
is required to complete Task 3.**

### Required Follow-up

Obtain a genuine NTFS disk image or authenticated TSK
outputs, verify its baseline SHA-256, mount it read-only,
and complete the following:

- `mmls` partition analysis
- `fsstat` filesystem metadata examination
- `fls` recursive file listing
- `mactime` MAC timeline generation
- `icat` extraction of suspicious files
- File-level SHA-256 calculations
- Chain-of-custody updates

Only after these steps can the filesystem findings be
classified as independently verified.
