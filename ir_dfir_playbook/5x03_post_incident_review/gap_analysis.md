
# Gap Analysis: IR-2026-0414-01

**Case ID:** LH-2026-0414-01  
**Organization:** MedDefense  
**Source:** control_effectiveness.yaml, forensic_findings_summary.md

## Gap Register

| Gap ID | Phase | Gap Description | Control Category | Recommended Improvement | Priority | Linked Findings |
|---|---|---|---|---|---|---|
| GAP-001 | Credential phishing and submission | The phishing domain `ms0365-support.login-verification.click` was accessible, allowing the user to submit credentials. | Preventive | Configure the secure web gateway and DNS filtering to block the phishing domain and newly identified malicious login domains. | P1 critical | Task 1 Phase 1; proxy log; T1566.002 |
| GAP-002 | Credential phishing and submission | No confirmed real-time alert or preventive action occurred when credentials were submitted to the phishing site. | Detective | Create a Wazuh SIEM correlation rule for access to suspicious login domains followed by HTTP POST requests to authentication endpoints. | P1 critical | Task 1 Phase 1; phishing POST at 18:14:41Z |
| GAP-003 | VPN access using stolen credentials from a foreign IP | Azure AD risk signals were suppressed by the compliant-device conditional access rule, reducing protection against suspicious foreign authentication. VPN access remains unverified. | Preventive | Review Microsoft Entra Conditional Access policies, enforce phishing-resistant MFA, and require sign-in risk evaluation even for compliant devices. | P1 critical | Task 1 Phase 2; forensic summary open investigative items |
| GAP-004 | VPN access using stolen credentials from a foreign IP | The suspicious authentication associated with IP `45.63.9.88` was not fully traced, leaving uncertainty about session activity. | Detective | Enable Microsoft Entra sign-in log monitoring and create Wazuh alerts for high-risk foreign sign-ins, unfamiliar locations, and impossible-travel patterns. | P2 high | Task 1 Phase 2; foreign IP 45.63.9.88 |
| GAP-005 | PowerShell to MSBuild LOLBin execution | PowerShell launched MSBuild.exe and executed the malicious `update.xml` loader before effective prevention occurred. | Preventive | Configure Windows Defender Application Control/App Control for Business to restrict unauthorized MSBuild execution and block untrusted inline-task XML from user-writable directories. | P1 critical | ART-001-F01; ART-001-E01; ART-002-M01 |
| GAP-006 | PowerShell to MSBuild LOLBin execution | Wazuh detected the suspicious process chain, but malicious execution was not prevented before the alert. | Detective | Deploy a Sigma rule in Wazuh to detect PowerShell spawning MSBuild.exe, especially when executing XML files from AppData or Temp directories. | P2 high | ART-002-M01; Wazuh alert A-20260414-9841 |
| GAP-007 | C2 beaconing to external IPs | MSBuild.exe established outbound C2 communication with `185.220.101.47:443` and `91.234.99.107:443` without confirmed preventive blocking. | Preventive | Configure firewall and secure web gateway deny rules for both C2 IPs and restrict unauthorized outbound connections from clinical workstations. | P1 critical | ART-002-M02; ART-003-M01 |
| GAP-008 | C2 beaconing to external IPs | No confirmed automatic containment occurred when suspicious MSBuild execution was correlated with external C2 communication. | Corrective | Configure Wazuh Active Response with approved EDR isolation workflows for high-confidence MSBuild-to-C2 alerts, including clinical safety approval and rollback procedures. | P2 high | ART-002-M01; ART-002-M02; Task 1 Phase 4 |
| GAP-009 | LSASS credential access and Kerberos ticket extraction | NTLM credential material was present in LSASS memory, while effective protection against credential dumping was not established. | Preventive | Enable Windows Credential Guard and LSA protection on supported MedDefense endpoints, and validate protection using Microsoft security configuration checks. | P1 critical | ART-002-M04; T1003.001 |
| GAP-010 | LSASS credential access and Kerberos ticket extraction | No confirmed real-time alert identified suspicious credential access or Kerberos ticket abuse during the incident. | Detective | Configure Sysmon Event ID 10 monitoring for suspicious LSASS access and correlate Windows Kerberos events 4768 and 4769 with abnormal account and host activity in Wazuh. | P1 critical | ART-002-M04; ART-003-M01; T1558.003 |
| GAP-011 | Lateral movement and PHI access | Compromised account `MEDDEFENSE\dmarsh` was used across multiple hosts, indicating insufficient restriction of lateral authentication paths. | Preventive | Apply Windows Defender Firewall segmentation, restrict SMB and remote administrative access between workstation VLANs, and enforce least-privilege account permissions. | P1 critical | ART-003-M01; T1550.003; Task 1 Phase 6 |
| GAP-012 | Lateral movement and PHI access | The compromised account accessed 14 laboratory report PDFs through `LIS_REPORTS$`, without confirmed real-time abnormal-access detection. | Detective | Enable Windows file-share auditing (Events 5140 and 5145), review NTFS/share permissions, and configure Wazuh alerts for unusual bulk PHI access. | P1 critical | AD-LOG-01; T1005; Task 1 Phase 6 |

## Priority summary

- **GAP-001 (P1):** The phishing domain was accessible and enabled credential submission. Blocking malicious login domains could prevent similar initial access.

- **GAP-002 (P1):** Credential submission occurred without confirmed real-time security response. A Wazuh correlation rule could detect suspicious phishing activity earlier.

- **GAP-003 (P1):** Microsoft Entra Conditional Access suppressed risk signals for a compliant device. Strengthening conditional access and MFA would reduce the risk of stolen-account access.

- **GAP-005 (P1):** Malicious PowerShell-to-MSBuild execution succeeded. Application control restrictions could prevent unauthorized execution of malicious MSBuild tasks.

- **GAP-007 (P1):** Two compromised hosts communicated with external C2 infrastructure. Firewall egress restrictions could prevent known malicious connections.

- **GAP-009 (P1):** Credential material was found in LSASS memory, with effective credential protection unverified. Credential Guard and LSA protection could reduce credential theft opportunities.

- **GAP-010 (P1):** No confirmed real-time credential-access or Kerberos-abuse alert was identified. Improved Sysmon and Kerberos monitoring would strengthen detection of credential attacks.

- **GAP-011 (P1):** The attacker moved between MedDefense systems using compromised account authentication. Network segmentation and least-privilege access would limit lateral movement.

- **GAP-012 (P1):** The attacker accessed 14 sensitive laboratory reports containing PHI. File-access auditing and abnormal-access detection would help identify unauthorized access earlier.

## Evidence limitations

- The foreign-IP Office 365 session involving `45.63.9.88` requires further investigation. VPN access has not been independently confirmed.
- The forensic summary lists Kerberos ticket extraction as an observed technique, but the supplied evidence does not independently establish the extraction mechanism.
- NTLM hash material found in LSASS memory does not by itself prove that credential dumping succeeded.
- Access to 14 PHI reports is confirmed, but external data exfiltration has not been established.
- Recommendations involving unverified control failures must be validated against actual security configurations and logs before deployment.
