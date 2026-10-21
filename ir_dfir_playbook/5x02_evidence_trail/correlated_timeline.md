
# Correlated Incident Timeline: LH-2026-0414-01

## 1. Case Information

- **Case ID:** LH-2026-0414-01
- **Incident ID:** IR-2026-0414-01
- **Primary Host:** WST-WS-031
- **Secondary Host:** WST-WS-017
- **Additional Target:** LIS-WSIDE-01
- **Affected Account:** MEDDEFENSE\dmarsh
- **Investigator:** Nishat Sultana Supty
- **Time Standard:** UTC (ISO 8601)
- **Analysis Status:** Partially corroborated

## 2. Objective

Reconstruct the incident by correlating filesystem,
registry, memory, proxy, authentication, and SIEM evidence.

The investigation aims to identify the sequence of
initial access, credential compromise, execution,
persistence, lateral movement, and access to
sensitive clinical data.

## 3. Evidence Sources

| Evidence ID | Source | Purpose |
|---|---|---|
| ART-001 | wst-ws-031.dd | Filesystem and persistence investigation |
| ART-002 | wst-ws-031.mem | Primary workstation memory analysis |
| ART-003 | wst-ws-017.mem | Secondary workstation memory analysis |
| LOG-001 | proxy_log.jsonl | Web requests, downloads, network connections |
| LOG-002 | ad_auth_log.jsonl | Authentication, Kerberos, VPN and file access |
| LOG-003 | siem_alert_export.json | Process execution and alert context |
| DOC-001 | filesystem_analysis.md | Task 3 findings |
| DOC-002 | persistence_analysis.md | Task 4 findings |
| DOC-003 | memory_analysis.md | Task 5 findings |

### Evidence Limitations

The supplied disk image is a synthetic stand-in.
The memory dumps have not been supplied.

Consequently, the filesystem, registry and memory
findings are not independently verified.

Proxy and authentication records provide direct
log evidence for many timeline events.

## 4. Certainty Definitions

- **Confirmed:** The described event is directly
  recorded in an available evidence source.
- **Probable:** Multiple related observations support
  the interpretation, but an important detail remains
  unverified.
- **Possible:** A plausible investigative hypothesis
  without sufficient independent confirmation.

Confirmed means the event was recorded by the cited
source. It does not automatically establish malicious
intent or identify the person responsible.

---

## 5. Correlated Incident Timeline

| Timestamp (UTC) | Source | Event | ATT&CK | Certainty | Evidence Ref |
|---|---|---|---|---|---|
| 2026-04-13T18:13:44Z | LOG-001, proxy | dmarsh accessed an Outlook email immediately before the phishing-site visit. | T1566.002 | Probable | LOG-001 line 6 |
| 2026-04-13T18:14:02Z | LOG-001, proxy | dmarsh visited the suspicious Microsoft 365 typosquat login page from WST-WS-031. | T1566.002 | Confirmed | LOG-001 line 7 |
| 2026-04-13T18:14:41Z | LOG-001, proxy | Browser submitted a form to the typosquat domain's `/auth/submit` endpoint. Credential disclosure is probable, but the submitted fields are not visible. | T1056.003 | Probable | LOG-001 line 10 |
| 2026-04-13T18:14:41Z | LOG-002, Azure AD | Successful Office 365 sign-in from 45.63.9.88, flagged for impossible travel, occurred at the same timestamp as the suspicious form submission. | T1078.004 | Probable | LOG-002 line 3 |
| 2026-04-13T18:14:43Z | LOG-001, proxy | Browser downloaded `update.zip` from the suspicious domain; HTTP response recorded 421004 bytes. | T1105 | Confirmed | LOG-001 line 11; DOC-001 ART-001-F02 |
| 2026-04-14T02:44:02Z | LOG-002, AD | Successful Kerberos authentication for dmarsh from WST-WS-031 at an unusual hour. | T1078 | Confirmed | LOG-002 line 5 |
| 2026-04-14T02:44:03Z | LOG-002, AD | Successful interactive logon for dmarsh on WST-WS-031. | T1078 | Confirmed | LOG-002 line 6 |
| 2026-04-14T02:44:17Z | LOG-002, VPN | Successful VPN logon using dmarsh's account from external IP 45.63.9.88, with MFA notification recorded. | T1078 | Confirmed | LOG-002 line 7 |
| 2026-04-14T02:46:41Z | LOG-003, EDR | `powershell.exe` started with PID 7812; SIEM command line included hidden and encoded execution arguments. | T1059.001 | Confirmed | LOG-003 alert.process_tree.parent; DOC-003 ART-002-M03 |
| 2026-04-14T02:46:57Z | LOG-003, EDR | PowerShell spawned `MSBuild.exe` PID 8104 to process `C:\Users\dmarsh\AppData\Local\Temp\update.xml`. | T1127.001 | Confirmed | LOG-003 alert.process_tree.child; DOC-001 ART-001-F01 |
| 2026-04-14T02:46:58Z | LOG-001, proxy | First recorded MSBuild-associated CONNECT request to 185.220.101.47:443 from WST-WS-031; possible C2 beacon. | T1071.001 | Probable | LOG-001 line 12 |
| 2026-04-14T02:47:02Z | LOG-001, proxy | Another MSBuild-associated CONNECT request to 185.220.101.47:443. | T1071.001 | Probable | LOG-001 line 13 |
| 2026-04-14T02:47:11Z | LOG-003, SIEM | High-severity alert A-20260414-9841 triggered for suspicious PowerShell-to-MSBuild execution. | T1059.001, T1127.001 | Confirmed | LOG-003 alert.fired_at |
| 2026-04-14T02:47:30Z | LOG-001, proxy | Additional CONNECT request to 185.220.101.47:443, consistent with repeated suspicious outbound activity. | T1071.001 | Probable | LOG-001 line 14 |
| 2026-04-14T03:22:47Z | LOG-002, AD | dmarsh requested a Kerberos service ticket for `cifs/WST-WS-017` from WST-WS-031. | T1021.002 | Confirmed | LOG-002 line 8 |
| 2026-04-14T03:22:48Z | LOG-002, AD | dmarsh requested a Kerberos ticket for `host/WST-WS-017`. | T1021 | Confirmed | LOG-002 line 9 |
| 2026-04-14T03:23:01Z | LOG-002, AD | Successful Kerberos network logon (type 3) to WST-WS-017 from 10.42.118.31. | T1021.002 | Confirmed | LOG-002 line 10 |
| 2026-04-14T03:27:13Z | LOG-001, proxy | WST-WS-017 MSBuild PID 5108 connected to 91.234.99.107:443, tagged as C2 infrastructure. | T1071.001 | Probable | LOG-001 line 15 |
| 2026-04-14T03:27:45Z | LOG-001, proxy | Second MSBuild-associated connection from WST-WS-017 to the same suspicious destination. | T1071.001 | Probable | LOG-001 line 16 |
| 2026-04-14T03:40:18Z | LOG-002, AD | dmarsh requested a Kerberos ticket for `cifs/LIS-WSIDE-01` from WST-WS-017. | T1021.002 | Confirmed | LOG-002 line 11 |
| 2026-04-14T03:41:52Z | LOG-002, AD | Second successful Kerberos ticket request for `cifs/LIS-WSIDE-01`; log notes possible ticket reuse. | T1021.002 | Confirmed | LOG-002 line 12 |
| 2026-04-14T03:42:08Z | LOG-002, AD | Successful Kerberos network logon to LIS-WSIDE-01 from WST-WS-017. | T1021.002 | Confirmed | LOG-002 line 13 |
| 2026-04-14T03:43:30Z | LOG-002, file audit | dmarsh accessed 14 PDF files under `C:\LIS\reports\daily\*.pdf` through LIS_REPORTS$ on LIS-WSIDE-01. | T1005 | Confirmed | LOG-002 line 14 |

### Events Without Verified Timestamps

The following required events cannot be placed
accurately in the chronological table.

| Timestamp (UTC) | Source | Event | ATT&CK | Certainty | Evidence Ref |
|---|---|---|---|---|---|
| Unknown | ART-001, synthetic disk | Malicious files reportedly staged in AppData\Local\Temp; `update.xml` is referenced by SIEM, but actual disk creation timestamps are unavailable. | T1105 | Possible | DOC-001 ART-001-F01 |
| Unknown | ART-001, synthetic disk | `MsUpdateCheck` Run-key persistence reportedly installed. Actual registry value and last-write time not verified. | T1547.001 | Possible | DOC-002 ART-001-R01 |
| Unknown | ART-001, synthetic disk | `MsUpdateCheck` scheduled task reportedly installed. Task XML and creation timestamp not recovered. | T1053.005 | Possible | DOC-002 ART-001-R03 |
| Unknown | ART-002, memory | NTLM hashes and Kerberos ticket material potentially present in LSASS; accessibility to the attacker is not demonstrated. | T1003.001 | Possible | DOC-003 ART-002-M07, ART-002-M08 |

**Note:** The 14-file audit record establishes successful
file-read activity. The filenames indicate a clinical
report location, but the actual contents and patient
identifiers have not been independently examined.

---

## 6. Correlation Analysis

### 6.1 Initial Access and Credential Compromise

The proxy log records access to an Outlook email
at 18:13:44 UTC, followed by a visit to the
suspicious Microsoft 365 login page at 18:14:02 UTC.

At 18:14:41 UTC, the browser submitted a form
to the phishing domain.

At the same timestamp, Azure AD recorded a successful
sign-in from 45.63.9.88, flagged for impossible travel.

These events strongly suggest a phishing-related
account compromise.

However, the proxy log does not expose the actual
submitted credentials.

**Assessment:** Probable credential compromise.

**ATT&CK:** T1566.002, T1078.004.

### 6.2 Suspicious Execution

The SIEM records PowerShell PID 7812 launching
MSBuild PID 8104.

MSBuild was instructed to process:

```text
C:\Users\dmarsh\AppData\Local\Temp\update.xml
```

This is consistent with potential abuse of a
trusted development utility.

The subsequent proxy records associate MSBuild
with repeated connections to 185.220.101.47:443.

The process chain is recorded by EDR, but the
underlying memory evidence has not been examined.

**Assessment:** Confirmed logged process execution;
probable malicious use and C2 communication.

**ATT&CK:** T1059.001, T1127.001, T1071.001.

### 6.3 Persistence

The synthetic disk evidence references:

- A Run-key value named `MsUpdateCheck`.
- A scheduled task named `MsUpdateCheck`.

Both may provide execution after user logon
or at a configured task trigger.

The actual NTUSER.DAT hive and scheduled-task XML
were not available.

No installation timestamp can be established.

**Assessment:** Possible persistence.

**ATT&CK:** T1547.001, T1053.005.

### 6.4 Credential Access

The investigation requires examination of LSASS
for credential material and possible access.

However, no memory image or Volatility output
was supplied.

Successful Kerberos authentication does not
prove that LSASS memory was dumped or that
tickets were extracted.

**Assessment:** Credential-access technique unverified.

**ATT&CK:** T1003.001 is a candidate only.

### 6.5 Lateral Movement to WST-WS-017

At 03:22:47 UTC, the AD log recorded a Kerberos
ticket request for `cifs/WST-WS-017`.

At 03:23:01 UTC, a successful network logon
occurred on WST-WS-017.

At 03:27:13 UTC, the proxy log recorded
MSBuild PID 5108 connecting from WST-WS-017
to 91.234.99.107:443.

This sequence supports lateral movement
followed by suspicious execution or network
activity on the second workstation.

**Assessment:** Confirmed authentication events;
probable malicious lateral movement.

**ATT&CK:** T1021.002, T1071.001.

### 6.6 Access to LIS-WSIDE-01

At 03:40:18 UTC, WST-WS-017 requested a
Kerberos service ticket for LIS-WSIDE-01.

At 03:42:08 UTC, a successful network logon
to LIS-WSIDE-01 occurred.

At 03:43:30 UTC, the file audit recorded
successful access to 14 PDF files under
the LIS daily reports directory.

The sequence demonstrates authenticated
access to clinical report files.

It does not independently establish copying,
external transfer, or exfiltration.

**Assessment:** Confirmed file access;
malicious intent remains under investigation.

**ATT&CK:** T1021.002, T1005.

---

## 7. Reconstructed Attack Sequence

```text
Suspicious email link
        |
        v
Typosquat Microsoft 365 login page
        |
        v
Form submission and suspicious Azure AD sign-in
        |
        v
Download of update.zip
        |
        v
Successful VPN access using dmarsh account
        |
        v
PowerShell launches MSBuild with update.xml
        |
        v
Repeated suspicious outbound connections
        |
        v
Possible Run-key and scheduled-task persistence
        |    (installation time unknown)
        v
Kerberos ticket request for WST-WS-017
        |
        v
Network logon to WST-WS-017
        |
        v
Second suspicious MSBuild network connection
        |
        v
Kerberos ticket request for LIS-WSIDE-01
        |
        v
Network logon to LIS-WSIDE-01
        |
        v
14 clinical report PDFs accessed
```

This diagram represents the evidence-supported
sequence and investigative interpretation.

It does not prove that every event was performed
by the same human operator.

---

## 8. Potential Data Exposure

### Target

```text
LIS-WSIDE-01
```

### File Location

```text
C:\LIS\reports\daily\*.pdf
```

### Share

```text
LIS_REPORTS$
```

### Recorded Activity

- Account: MEDDEFENSE\dmarsh
- Event ID: 4663
- Files opened: 14
- Access mask: 0x1
- Result: Success
- Timestamp: 2026-04-14T03:43:30Z

### Assessment

The audit record supports successful file-read
access to 14 PDF reports.

Because these files are located in a laboratory
report directory, they may contain sensitive
patient information.

The actual contents and identifiers have not
been examined.

No confirmed external exfiltration is established
by the available evidence.

A separate data-exposure assessment is required.

---

## 9. Investigation Gaps

The following evidence is still required:

1. Genuine NTFS filesystem and MAC timeline.
2. Verified `update.xml` contents and SHA-256.
3. Actual registry Run and RunOnce entries.
4. Scheduled-task XML and last-write timestamps.
5. UserAssist, ShimCache, and Amcache findings.
6. Volatility process and command-line outputs.
7. Volatility network connection results.
8. LSASS and credential-access examination.
9. WST-WS-017 memory findings.
10. Individual file audit records for the 14 PDFs.
11. Network evidence to assess possible exfiltration.
12. Complete chain-of-custody verification.

These gaps must be resolved before the investigation
can claim a complete reconstruction.

---

## 10. Conclusion

Correlation of the proxy, authentication, and SIEM
logs reveals a sequence of suspicious activity
that would be difficult to reconstruct from any
single source. The available evidence records a phishing-site
visit and form submission, suspicious account
authentication, PowerShell-to-MSBuild execution,
outbound connections, Kerberos authentication
across multiple hosts, and access to 14 clinical
report PDFs.
The evidence supports probable account compromise,
malicious execution, and lateral movement. Possible persistence mechanisms were also identified
in the synthetic disk evidence, but they remain
unverified. No memory-based credential dumping or confirmed
external data exfiltration has been established.

