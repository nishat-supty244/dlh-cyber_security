**Task 8: Detection Gap Analysis — HEALTHBANE Campaign**

**1\. Executive Summary & Methodology**

Mapping the HEALTHBANE campaign provides a comprehensive view of adversary behavior, but a defensive posture is only as strong as its visibility. This detection gap analysis compares the 20 techniques mapped in Task 7 against MedDefense's current detection capabilities (incorporating 4x00 email/IOC rules, 4x01 network recommendations, indicator blocklists, and upcoming YARA/behavioral rules).

Each technique is evaluated across three coverage statuses:

- **DETECTED:** Direct coverage via documented Wazuh rules, YARA rules, automated IOC blocking, or high-fidelity telemetry.
- **PARTIALLY DETECTED:** Telemetry or basic indicators exist, but detection is narrow, prone to evasion, or relies heavily on manual analyst review.
- **NOT DETECTED:** No documented detection mechanism or reliable logging covers the technique.

Gaps are subsequently prioritized into three action tiers:

1. **Priority 1:** OBSERVED and NOT DETECTED (Highest operational risk).
2. **Priority 2:** INFERRED and NOT DETECTED (Strategic/proactive coverage gaps).
3. **Priority 3:** PARTIALLY DETECTED (Refinement and tuning required).

**2\. Comprehensive Technique Coverage & Gap Assessment**

| **Technique ID** | **Technique Name**                | **Status** | **Coverage**           | **Evidence of Coverage / Current State**                                             | **Gap Explanation**                                                                                          | **Recommendation to Close Gap**                                                                                       |
| ---------------- | --------------------------------- | ---------- | ---------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **T1589.002**    | Gather Victim Identity: Email     | OBSERVED   | **PARTIALLY DETECTED** | Email gateway logs record inbound traffic; OSINT monitoring tracks targeted staff.   | No proactive detection for external reconnaissance / social media scraping.                                  | Implement external threat intelligence monitoring for employee email exposure.                                        |
| **T1583.001**    | Acquire Infrastructure: Domains   | OBSERVED   | **DETECTED**           | Wazuh rule 100080 (CDB list blocking campaign domains) and email gateway blocklists. | Domain age and registration patterns are blocked after creation, but predictive hunting is missing.          | Monitor passive DNS and certificate transparency logs for newly registered healthcare keywords.                       |
| **T1585.002**    | Establish Accounts: Email         | OBSERVED   | **DETECTED**           | DMARC enforcement and email gateway filtering on lookalike headers.                  | Free mail or compromised external accounts can bypass static domain blocklists.                              | Enforce strict DMARC alignment (p=reject) and reputation-based inbound mail scoring.                                  |
| **T1587.001**    | Develop Capabilities: Malware     | OBSERVED   | **NOT DETECTED**       | No visibility into adversary staging environments or pre-deployment code building.   | Adversary development occurs entirely outside organizational visibility.                                     | Rely on downstream artifact analysis (YARA/EDR) rather than upstream development detection.                           |
| **T1608.005**    | Link Target                       | OBSERVED   | **PARTIALLY DETECTED** | URL inspection rules on email gateway (100080).                                      | Polymorphic links or shortened URLs can bypass static gateway filters.                                       | Implement URL rewriting and safe-links click-time analysis.                                                           |
| **T1566.002**    | Spearphishing Link                | OBSERVED   | **DETECTED**           | Wazuh rules 100080 & 100081; Phishing disinfections from 4x00.                       | Link destinations can rotate rapidly, requiring continuous IOC updates.                                      | Implement automated IOC feed ingestion into email gateways and firewalls.                                             |
| **T1566.001**    | Spearphishing Attachment          | OBSERVED   | **DETECTED**           | EDR file hash blocklists for .docm attachments (a1b2c3d4...).                        | Novel dropper variants with unknown hashes can bypass static file hash blocks.                               | Deploy behavior-based macro blocking and AMSI inspection for Office documents.                                        |
| **T1204.001**    | User Execution: Malicious Link    | OBSERVED   | **PARTIALLY DETECTED** | SIEM web proxy connection logs tracking outbound clicks (dmarsh case).               | Relies on post-click proxy logs rather than real-time browser isolation.                                     | Deploy browser isolation or secure web gateway (SWG) filtering for external links.                                    |
| **T1204.002**    | User Execution: Malicious File    | OBSERVED   | **PARTIALLY DETECTED** | EDR execution logs; Office macro warnings.                                           | Relies on user compliance or macro warning prompts.                                                          | Disable Office macros globally via Group Policy; require signed/attested templates.                                   |
| **T1059.005**    | Command and Scripting: VBA        | OBSERVED   | **PARTIALLY DETECTED** | EDR alerts on Office applications spawning child processes.                          | Native macro execution in memory can evade simple process creation logs.                                     | Block Win32 API calls (CreateProcess) spawned directly from Microsoft Office applications.                            |
| **T1059.001**    | Command and Scripting: PowerShell | OBSERVED   | **NOT DETECTED**       | Basic process execution logs exist, but script block logging is not fully tuned.     | PowerShell obfuscation (sync_healthdata.ps1) bypasses basic command-line logging.                            | Enable PowerShell Script Block Logging (Event ID 4104) and Transcription; integrate AMSI.                             |
| **T1053.005**    | Scheduled Task                    | OBSERVED   | **NOT DETECTED**       | Standard Windows Security Event logs (Event ID 4698), but no active alerting rule.   | Attackers create tasks named "HealthSync Update Service" under user or service contexts without alerting.    | Write SIEM/EDR rule to alert on scheduled task creation containing "Sync", "Update", or "Service" by non-admins.      |
| **T1547.001**    | Registry Run Keys                 | OBSERVED   | **NOT DETECTED**       | Sysmon Event ID 12/13 generates raw telemetry, but no active alert rule deployed.    | Run-key modifications blend with legitimate software installers.                                             | Alert on Registry Run-key additions originating outside recognized installer paths or software distribution contexts. |
| **T1056.003**    | Input Capture: Web Portal Capture | OBSERVED   | **DETECTED**           | SIEM connection logs for HTTPS sessions to lookalike domains (dmarsh incident).      | Limited to external web portals; internal phishing simulations not continuously tested.                      | Implement outbound credential guard and monitor for credential submission to unclassified external domains.           |
| **T1071.004**    | Application Layer: DNS            | OBSERVED   | **PARTIALLY DETECTED** | DNS query logging enabled, but length anomaly detection not fully active.            | Base32/base64 subdomain tunneling (data-sync.healthbane-c2.net) mimics normal traffic without anomaly rules. | Deploy DNS query-length anomaly detection (alert on subdomain labels > 40 characters with base32/64 entropy).         |
| **T1071.001**    | Application Layer: Web Protocols  | OBSERVED   | **DETECTED**           | Wazuh proxy and firewall rules alerting on outbound HTTPS to campaign IPs (100081).  | Encrypted HTTPS traffic hides payload contents, requiring TLS inspection or C2 heuristics.                   | Implement TLS inspection and outbound JA3/JA4 SSL client fingerprinting.                                              |
| **T1048.003**    | Exfiltration Over Non-C2 Protocol | OBSERVED   | **PARTIALLY DETECTED** | Standard DNS query monitoring; no specific exfiltration threshold rules.             | Tunneling traffic is blended with normal corporate DNS resolver traffic.                                     | Monitor outbound DNS query volume per host and frequency to external non-standard name servers.                       |
| **T1041**        | Exfiltration Over C2 Channel      | OBSERVED   | **DETECTED**           | Firewall rules blocking outbound connection to known C2 IPs (healthbane-c2.net).     | Relies on static IP/domain indicators which rotate frequently.                                               | Implement behavioral data loss prevention (DLP) and anomaly detection on outbound data volume.                        |
| **T1078**        | Valid Accounts                    | INFERRED   | **PARTIALLY DETECTED** | Active Directory authentication logs; basic failed login tracking.                   | Credential reuse from Stage 1 phishing makes unauthorized logins appear legitimate.                          | Require MFA across all remote access entry points and enforce geographic anomaly detection.                           |
| **T1021**        | Remote Services                   | INFERRED   | **NOT DETECTED**       | Firewall logs for RDP/SMB, but no lateral movement detection rules.                  | Internal RDP/SMB traffic between workstations is often permitted by default.                                 | Restrict internal lateral movement protocols, isolate network zones, and monitor for unexpected admin logons.         |

**3\. Prioritized Gap List & Action Plan**

**Priority 1: OBSERVED and NOT DETECTED (Critical Operational Risks)**

These gaps represent techniques confirmed to have been used in the HEALTHBANE campaign for which MedDefense currently lacks automated detection.

1. **T1059.001 (PowerShell Execution - sync_healthdata.ps1)**
   - _Why it matters:_ PowerShell is the primary vehicle for executing post-exploitation scripts and staging data exfiltration.
   - _Detection Idea:_ Alert on encoded PowerShell commands (-enc, -encodedcommand) or script blocks exceeding 1,024 characters containing networking or compression cmdlets.
   - _Required Data Source:_ Windows PowerShell Event Logs (Event ID 4104 - Script Block Logging).
   - _Suggested Owner:_ Endpoint Security / Detection Engineering Team.
2. **T1053.005 (Scheduled Task Creation - "HealthSync Update Service")**
   - _Why it matters:_ Used by the malware to establish persistence (svchost_update.exe) across reboots.
   - _Detection Idea:_ Create an SIEM/EDR rule flagging schtasks /create or WinEvent 4698 where task names contain "Sync", "Update", or "Service" executed by non-system/non-admin users.
   - _Required Data Source:_ Windows Security Event Log (Event ID 4698) or Sysmon (Event ID 1).
   - _Suggested Owner:_ SOC Tier 2 / Incident Response Team.
3. **T1547.001 (Registry Run Keys Persistence)**
   - _Why it matters:_ Ensures secondary malware execution upon user logon.
   - _Detection Idea:_ Alert on registry modifications to HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run or HKLM\\... originating from non-installer parent processes (e.g., cmd.exe, powershell.exe, or temp directories).
   - _Required Data Source:_ Sysmon Event ID 12 / 13 (Registry Event).
   - _Suggested Owner:_ EDR Operations Team.

**Priority 2: INFERRED and NOT DETECTED (Proactive Strategic Gaps)**

Techniques assessed as likely adversary paths that require proactive hardening.

1. **T1021 (Lateral Movement via Remote Services)**
   - _Why it matters:_ Attackers leverage harvested credentials to move laterally across internal hospital systems.
   - _Detection Idea:_ Monitor for anomalous RDP (Port 3389) or SMB (Port 445) connections between workstations (client-to-client traffic).
   - _Required Data Source:_ Firewall flow logs, Zeek/Suricata network telemetry, or Windows Security Event ID 4624 (Logon Type 10).
   - _Suggested Owner:_ Network Security Team.

**Priority 3: PARTIALLY DETECTED (Refinement & Tuning Required)**

Techniques with existing telemetry that require enhanced analytic coverage to prevent evasion.

1. **T1071.004 (DNS Tunneling - Exfiltration via data-sync.healthbane-c2.net)**
   - _Why it matters:_ Stage 3 exfiltration bypasses traditional web proxies by utilizing DNS TXT records.
   - _Detection Idea:_ Deploy threshold-based alerts for DNS query length anomalies (subdomain labels > 40 characters) and high frequency queries to a single external domain.
   - _Required Data Source:_ Internal DNS server query logs (BIND / Windows DNS analytical logs).
   - _Suggested Owner:_ Network Monitoring & Threat Hunting Team.
