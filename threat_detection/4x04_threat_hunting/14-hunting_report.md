**MedDefense Threat Hunting Report**

**HEALTHBANE Stage 4 — Lateral Movement Investigation**

**Prepared for:** MedDefense Security Operations and Dr. Morales  
**Scope:** T0–T13 Threat Hunting Activities  
**Hunt Window:** 14 days of SIEM data

**1\. Executive Summary**

MedDefense conducted a hypothesis-driven threat hunt to determine whether the HEALTHBANE Stage 4 attack pattern was present in the environment. The hunt focused on credential access, service-account abuse, and lateral movement using legitimate Windows tools such as PsExec, WMI, and PowerShell Remoting.

The investigation identified evidence consistent with **HEALTHBANE Stage 4 lateral movement**. Suspicious activity centered on **WS-RECV-03**, including anomalous LSASS access, unauthorized use of the svc_healthsync service account, and lateral movement activity involving legitimate Windows administration tools.

The reconstructed activity indicates that the attacker used **WS-RECV-03 as a pivot host** and reached **SRV-HEALTH-DB**, with subsequent activity involving **SRV-INS-DB** and **SRV-DC-01**. These systems potentially exposed sensitive health, insurance, and directory-related information. The available hunt evidence does not by itself prove that specific data was successfully exfiltrated.

Before the hunt, MedDefense had approximately **55% ATT&CK coverage** for techniques observed in the HEALTHBANE campaign. Following the hunt and detection-engineering work, documented coverage improved to **80%**.

The key lesson is that the absence of a SIEM alert did not mean the environment was safe. HEALTHBANE relied on legitimate Windows tools and stolen credentials, demonstrating the need for behavioral detection and recurring threat hunting.

**2\. Hunt Methodology**

The investigation followed a hypothesis-driven approach:

1. Review the HC3 HEALTHBANE advisory to understand the expected Stage 4 behaviors.
2. Map the expected behaviors to MITRE ATT&CK techniques.
3. Identify gaps in existing ATT&CK detection coverage.
4. Build hypotheses around PsExec, LSASS access, WMI, PowerShell Remoting, and service-account abuse.
5. Search the 14-day Wazuh SIEM data for relevant evidence.
6. Establish a legitimate administrator baseline to separate normal administration from anomalous behavior.
7. Correlate individual findings into a unified attack timeline.
8. Convert confirmed hunt findings into improved detection coverage.

**Data Sources**

The hunt used:

- Wazuh alert data
- Raw Windows Sysmon data
- reference/hc3_advisory_004.txt
- reference/4x03_attack_mapping.json
- reference/admin_schedule.txt
- reference/service_accounts.txt
- reference/network_topology.txt
- Robert Kim's legitimate activity baseline

**Baseline Establishment**

Robert Kim was identified as the legitimate IT administrator for the relevant administrative activity. His normal PsExec, WMI, and PowerShell Remoting activity was associated with:

- Source host: WS-ADMIN-01
- Normal hours: approximately 08:00–18:00
- Scheduled maintenance days
- Authorized administrator account: MEDDEFENSE\\\\robert.kim

This baseline provided the context needed to distinguish legitimate administrative activity from suspicious use of the same tools.

**3\. Findings per Hypothesis**

**H1 — PsExec Lateral Movement**

**ATT&CK:** T1021.002 — SMB/Windows Admin Shares  
**Status:** POSITIVE  
**Confidence:** HIGH

The hunt identified PsExec activity that deviated from the established administrator baseline. Legitimate PsExec activity was associated with Robert Kim and WS-ADMIN-01 during scheduled maintenance periods.

Suspicious activity instead originated from **WS-RECV-03**, including activity involving the svc_healthsync account and the target **SRV-HEALTH-DB**.

This behavior is consistent with lateral movement using PsExec.

**H2 — Credential Access / LSASS**

**ATT&CK:** T1003.001 — LSASS Memory  
**Status:** POSITIVE  
**Confidence:** HIGH

The hunt identified suspicious access to lsass.exe from a non-standard process on **WS-RECV-03**.

The source process and access characteristics were inconsistent with normal Windows system activity and were consistent with credential-access behavior.

The finding became significantly stronger when correlated with subsequent unauthorized use of the svc_healthsync service account.

**H3 — WMI Activity**

**ATT&CK:** T1047 — Windows Management Instrumentation  
**Status:** POSITIVE  
**Confidence:** HIGH

WMI-related activity was identified as part of the Stage 4 sequence.

WMI is a legitimate Windows administration technology, but it can also be abused for remote execution and reconnaissance. The activity was therefore assessed using source host, account, destination, timing, and command context rather than the presence of WMI alone.

**H4 — PowerShell Remoting**

**ATT&CK:** T1021.006 — Windows Remote Management  
**Status:** POSITIVE  
**Confidence:** HIGH

PowerShell Remoting/WinRM activity was identified in the reconstructed attack sequence.

The activity was significant because it occurred in combination with unauthorized service-account use and other lateral movement behaviors.

This demonstrated how an attacker could use legitimate Windows remote-management functionality without deploying a traditional malware binary.

**H5 — Service Account Abuse**

**ATT&CK:** T1078.002 — Domain Accounts  
**Status:** POSITIVE  
**Confidence:** CRITICAL

The svc_healthsync account was observed being used from **WS-RECV-03**, a workstation, rather than from its authorized service context.

This violated the service-account authorization matrix and provided strong evidence of credential misuse.

The finding became even stronger when the unauthorized authentication was correlated with lateral movement activity from the same source host.

**4\. Reconstructed Attack Timeline**

The individual hunt findings were correlated into a unified Stage 4 attack sequence.

| **Phase**                 | **Evidence**                                   | **Interpretation**               |
| ------------------------- | ---------------------------------------------- | -------------------------------- |
| Credential Access         | Suspicious LSASS access on WS-RECV-03          | Possible credential theft        |
| Credential Use            | svc_healthsync authenticated from WS-RECV-03   | Unauthorized service-account use |
| Lateral Movement          | PsExec activity toward SRV-HEALTH-DB           | Remote execution                 |
| Reconnaissance            | WMI activity against target systems            | Remote discovery/reconnaissance  |
| Staging / Remote Activity | PowerShell Remoting and file-transfer activity | Remote staging and execution     |
| Expansion                 | Activity involving SRV-INS-DB and SRV-DC-01    | Further network expansion        |

**Attack Summary**

- **Pivot host:** WS-RECV-03
- **Credential used:** svc_healthsync
- **Primary target:** SRV-HEALTH-DB
- **Additional targets:** SRV-INS-DB, SRV-DC-01
- **Tools/channels:** PsExec, WMI, PowerShell Remoting

The combination of these events provides substantially stronger evidence than any individual alert viewed in isolation.

**5\. ATT&CK Update**

The hunt demonstrated that the previous **55% ATT&CK coverage** created a false sense of security. Several important Stage 4 techniques were outside existing detection coverage.

**Coverage Improvement**

Before hunt: 55% ███████████░░░░░░░░░

After hunt: 80% ████████████████░░░░

**Improvement: +25 percentage points**

The hunt identified important previously uncovered techniques:

- **T1021.002 — SMB/Windows Admin Shares**
- **T1047 — Windows Management Instrumentation**
- **T1021.006 — Windows Remote Management**
- **T1003.001 — LSASS Memory**
- **T1078.002 — Domain Accounts**

The remaining 20% of uncovered techniques must continue to be treated as detection gaps.

**6\. Detection Improvements**

Following the hunt, MedDefense improved detection coverage by moving beyond simple IOC-based detection toward behavioral detection.

**New Detection Areas**

**1\. Anomalous PsExec usage**

- Unexpected source hosts
- Off-hours execution
- Unexpected users
- Unexpected targets
- Deviation from the administrator baseline

**2\. Suspicious LSASS access**

- Process access to lsass.exe
- Unusual source processes
- Suspicious access permissions

**3\. WMI activity**

- Unexpected remote WMI execution
- Unusual source-to-target relationships

**4\. PowerShell Remoting**

- Unexpected WinRM/PowerShell remote activity
- Suspicious source hosts and commands

**5\. Service-account misuse**

- Service-account authentication from unauthorized hosts
- Interactive logons
- Workstation-originated authentication
- Deviation from the service-account authorization matrix

Documented ATT&CK coverage improved from **55% to 80%**.

The main improvement is the addition of **behavioral context**: who performed the action, where it originated, where it went, when it occurred, and whether it matched an authorized baseline.

**7\. Remaining Gaps and Recommendations**

**Remaining Gap**

Approximately **20% of the relevant ATT&CK coverage remains uncovered**. These techniques should be reviewed and prioritized rather than assumed to be low risk.

**Immediate Actions**

- Initiate incident response for **WS-RECV-03**.
- Preserve endpoint, authentication, and SIEM evidence.
- Investigate WS-RECV-03 for credential theft and persistence.
- Follow the **Module 5 incident-response bridge** process.
- Determine whether additional credentials or systems were compromised.

**Short-Term Actions**

- Rotate svc_healthsync credentials and other potentially exposed service credentials.
- Review privileged and service-account access.
- Verify service-account authorization matrices.
- Remove unnecessary service-account permissions.
- Review authentication to SRV-HEALTH-DB, SRV-INS-DB, and SRV-DC-01.

**Medium-Term Actions**

- Implement full **Sysmon** deployment across relevant Windows systems.
- Implement behavioral analytics for LOLBin activity.
- Improve correlation between process execution, authentication, remote execution, and network activity.
- Continue closing the remaining ATT&CK detection gaps.

**8\. Lessons Learned**

The **55% ATT&CK coverage** created a false sense of security because the uncovered techniques included methods that attackers could successfully use for credential access and lateral movement.

Reactive SIEM detection alone is insufficient against **LOLBin-based attacks** because PsExec, WMI, and PowerShell Remoting are legitimate administrative tools and may not have malicious file hashes or known network IOCs.

The investigation showed that context is essential: a legitimate tool becomes suspicious when it is used by an unexpected account, from an unusual workstation, at an unusual time, or against an unexpected target.

Threat hunting must therefore be a **recurring operational discipline**, not a one-time exercise. Regular hunts can discover new attacker behaviors, validate detection rules, establish updated baselines, and identify remaining coverage gaps.

The most important operational lesson is:

**No SIEM alert does not mean no threat.**

MedDefense should continue combining automated detection with hypothesis-driven threat hunting to maintain and improve its security posture.

**Overall Assessment**

**Did HEALTHBANE Stage 4 happen to us?**

The correlated evidence identified during the hunt is **consistent with HEALTHBANE Stage 4 lateral movement in the MedDefense environment**, including suspicious credential access, unauthorized service-account use, and lateral movement through legitimate Windows administration mechanisms.

**What have we done to detect it if it happens again?**

MedDefense has expanded documented behavioral detection coverage from **55% to 80%**, added detections for the key Stage 4 behaviors identified during the hunt, strengthened service-account and administrator baselines, and improved correlation between credential access and lateral movement.

**Final Assessment: POSITIVE — HIGH CONFIDENCE**
