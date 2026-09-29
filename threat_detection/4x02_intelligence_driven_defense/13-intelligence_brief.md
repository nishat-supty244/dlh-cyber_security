**13\. Intelligence Brief: The HEALTHBANE Campaign**

**1\. Executive Summary**

HEALTHBANE is a multi-stage healthcare phishing campaign orchestrated across the Midwest ISAC region, leveraging lookalike infrastructure and credential harvesting to infiltrate medical organizations. During the campaign window, MedDefense experienced targeted spear-phishing attempts, resulting in one confirmed user interaction and credential submission (dmarsh). Concurrently, broader sector reporting revealed that external healthcare partners suffered deeper compromises, including macro-enabled malware delivery and DNS-tunneling data exfiltration. MedDefense has established foundational perimeter defenses, threat intelligence ingestion, and YARA-based scanning rules, achieving 100% detection on tested PDF lures. However, critical gaps remain around endpoint script logging and internal lateral movement visibility. To mitigate ongoing risk, leadership must execute three priority actions: enforce PowerShell script block logging across all endpoints, mandate multi-factor authentication (MFA) across all external access portals, and integrate automated indicator feeds into gateway security controls.

**2\. Adversary Profile**

The adversary orchestrating the HEALTHBANE campaign exhibits moderate operational sophistication, specializing in targeted social engineering and credential harvesting against the healthcare sector. Operating under disputed attribution monikers (VITALSCORE via commercial feeds versus APT-MEDAGENT via independent researchers), the threat actor demonstrates a clear preference for rapid infrastructure rotation, domain fronting via standard registrars (Namecheap), and utilizing open-source mailers (PHPMailer 6.6.0) alongside custom PDF generators (wkhtmltopdf 0.12.6). Their strategic objective is initial access and subsequent data monetization within resource-constrained medical environments.

**3\. Campaign Analysis**

The HEALTHBANE campaign unfolded across three distinct operational phases during April 2026:

- **Stage 1: Credential Harvesting:** Attackers registered lookalike domains (meddefense-portal.com, etc.) and deployed spear-phishing emails containing malicious PDF attachments and credential-harvesting landing pages. MedDefense observed staff interaction and credential entry during this phase.
- **Stage 2: Malware Delivery:** Threat actors leveraged harvested credentials to authenticate into compromised email accounts, sending internal follow-up emails with macro-enabled .docm attachments (HEALTHBANE_S2_invoice.docm) to deploy secondary payloads (svchost_update.exe) and persistence mechanisms.
- **Stage 3: Data Exfiltration:** Compromised environments experienced base32-encoded DNS TXT-record exfiltration queries targeting patient and insurance records via data-sync.healthbane-c2.net.
- **Evidence Confidence:** Initial reconnaissance and Stage 1 mechanics maintain **HIGH** confidence (corroborated by internal logs and HC3 advisories), while attribution and exact exfiltration volumes remain **MEDIUM** to **LOW** confidence due to fractured external reporting.

**4\. ATT&CK Mapping**

The campaign's behavior is mapped using a rigorous two-tier framework distinguishing confirmed telemetry from analytical deductions:

- **Observed Techniques (Score 100):** Includes _Gather Victim Identity_ (T1589.002), _Acquire Infrastructure_ (T1583.001), _Spearphishing Link/Attachment_ (T1566.002 / T1566.001), _User Execution_ (T1204), _VBA/PowerShell Execution_ (T1059), _Scheduled Tasks_ (T1053.005), and _DNS Exfiltration_ (T1071.004).
- **Inferred Techniques (Score 50):** Includes _Valid Accounts_ (T1078) and _Remote Services Lateral Movement_ (T1021), deduced from standard adversary post-compromise progression.
- **Detection Relevance:** Perimeter defenses cover initial access well, but internal execution and persistence mechanisms require urgent endpoint monitoring enhancements.

**5\. Detection Gap Assessment**

Prioritized gaps identified during the analysis require immediate remediation:

1. **Priority 1 (Observed & Not Detected):** PowerShell execution (sync_healthdata.ps1), scheduled task creation ("HealthSync Update Service"), and registry run-key persistence lack active alerting rules.
2. **Priority 2 (Inferred & Not Detected):** Internal lateral movement via RDP/SMB between corporate workstations remains unmonitored.
3. **Priority 3 (Partially Detected):** DNS tunneling exfiltration (data-sync.healthbane-c2.net) relies on basic query logging without subdomain length or entropy anomaly rules.

**6\. Indicator of Compromise (IoC) Table**

| **Indicator**               | **Type**   | **Phase** | **Confidence** | **Recommended Action**              |
| --------------------------- | ---------- | --------- | -------------- | ----------------------------------- |
| meddefense-portal.com       | Domain     | Stage 1   | High           | Block at Web Gateway / DNS Sinkhole |
| 91.234.99.107               | IP Address | Stage 1   | High           | Block in Firewall / Perimeter ACLs  |
| a1b2c3d4... (invoice.docm)  | SHA-256    | Stage 2   | High           | Add to EDR File Hash Blocklist      |
| healthbane-c2.net           | Domain     | Stage 2/3 | High           | Block outbound proxy & sinkhole DNS |
| data-sync.healthbane-c2.net | Domain     | Stage 3   | High           | Monitor & block DNS TXT queries     |

**7\. YARA Rule Summary**

- **Rules Developed:** 9-yara_phishing_pdf.yar (targeting wkhtmltopdf and credential harvesting URL structures) and 10-yara_arsenal.yar (composite campaign rules).
- **Test Results:** Achieved **100% True Positives** (phishing_sample.pdf, healthbane_lure_02.pdf) and **100% True Negatives** (clean_invoice.pdf, benign_invoice.pdf).
- **Deployment Status:** Recommended for **DEPLOY** at the email gateway and file-scanning ingest points.

**8\. Recommendations**

- **Immediate (48 Hours):**
  1. Enforce PowerShell Script Block Logging (Event ID 4104) across all endpoints.
  2. Block all active IoCs (domains and IPs) in the perimeter firewall and email gateway.
  3. Force password resets and revoke active sessions for any user accounts flagged in Stage 1 logs (e.g., dmarsh).
- **Short-Term (2 Weeks):**
  1. Deploy EDR detection rules for scheduled task creation and registry run-key modifications.
  2. Implement DNS query-length anomaly monitoring to catch DNS tunneling attempts.
  3. Run awareness training focused on healthcare lookalike phishing lures.
- **Medium-Term (30 Days):**
  1. Restrict internal lateral movement protocols (SMB/RDP) between workstations.
  2. Integrate automated threat intelligence feeds into SIEM ingestion pipelines.
  3. Conduct an internal tabletop exercise simulating a Stage 2 lateral movement scenario.

**9\. Intelligence Gaps and Collection Priorities**

- **What Remains Unknown:** The exact volume of patient data exfiltrated during Stage 3 at external partner sites, and whether MedDefense credentials harvested in Stage 1 were successfully leveraged outside organizational perimeters.
- **What Collection Would Answer It:** Comprehensive packet captures (PCAPs) from external partners, centralized cloud identity provider authentication logs, and deeper forensic analysis of seized phishing kit source code.
- **Who to Ask / Data to Review:** Collaborate with regional ISAC partners to share unredacted telemetry, request cloud tenant sign-in logs from IT administration, and review internal firewall traffic flows for abnormal DNS query volumes.

**13\. Intelligence Brief: The HEALTHBANE Campaign**

**1\. Executive Summary**

HEALTHBANE is a multi-stage healthcare phishing campaign orchestrated across the Midwest ISAC region, leveraging lookalike infrastructure and credential harvesting to infiltrate medical organizations. During the campaign window, MedDefense experienced targeted spear-phishing attempts, resulting in one confirmed user interaction and credential submission (dmarsh). Concurrently, broader sector reporting revealed that external healthcare partners suffered deeper compromises, including macro-enabled malware delivery and DNS-tunneling data exfiltration. MedDefense has established foundational perimeter defenses, threat intelligence ingestion, and YARA-based scanning rules, achieving 100% detection on tested PDF lures. However, critical gaps remain around endpoint script logging and internal lateral movement visibility. To mitigate ongoing risk, leadership must execute three priority actions: enforce PowerShell script block logging across all endpoints, mandate multi-factor authentication (MFA) across all external access portals, and integrate automated indicator feeds into gateway security controls.

**2\. Adversary Profile**

The adversary orchestrating the HEALTHBANE campaign exhibits moderate operational sophistication, specializing in targeted social engineering and credential harvesting against the healthcare sector. Operating under disputed attribution monikers (VITALSCORE via commercial feeds versus APT-MEDAGENT via independent researchers), the threat actor demonstrates a clear preference for rapid infrastructure rotation, domain fronting via standard registrars (Namecheap), and utilizing open-source mailers (PHPMailer 6.6.0) alongside custom PDF generators (wkhtmltopdf 0.12.6). Their strategic objective is initial access and subsequent data monetization within resource-constrained medical environments.

**3\. Campaign Analysis**

The HEALTHBANE campaign unfolded across three distinct operational phases during April 2026:

- **Stage 1: Credential Harvesting:** Attackers registered lookalike domains (meddefense-portal.com, etc.) and deployed spear-phishing emails containing malicious PDF attachments and credential-harvesting landing pages. MedDefense observed staff interaction and credential entry during this phase.
- **Stage 2: Malware Delivery:** Threat actors leveraged harvested credentials to authenticate into compromised email accounts, sending internal follow-up emails with macro-enabled .docm attachments (HEALTHBANE_S2_invoice.docm) to deploy secondary payloads (svchost_update.exe) and persistence mechanisms.
- **Stage 3: Data Exfiltration:** Compromised environments experienced base32-encoded DNS TXT-record exfiltration queries targeting patient and insurance records via data-sync.healthbane-c2.net.
- **Evidence Confidence:** Initial reconnaissance and Stage 1 mechanics maintain **HIGH** confidence (corroborated by internal logs and HC3 advisories), while attribution and exact exfiltration volumes remain **MEDIUM** to **LOW** confidence due to fractured external reporting.

**4\. ATT&CK Mapping**

The campaign's behavior is mapped using a rigorous two-tier framework distinguishing confirmed telemetry from analytical deductions:

- **Observed Techniques (Score 100):** Includes _Gather Victim Identity_ (T1589.002), _Acquire Infrastructure_ (T1583.001), _Spearphishing Link/Attachment_ (T1566.002 / T1566.001), _User Execution_ (T1204), _VBA/PowerShell Execution_ (T1059), _Scheduled Tasks_ (T1053.005), and _DNS Exfiltration_ (T1071.004).
- **Inferred Techniques (Score 50):** Includes _Valid Accounts_ (T1078) and _Remote Services Lateral Movement_ (T1021), deduced from standard adversary post-compromise progression.
- **Detection Relevance:** Perimeter defenses cover initial access well, but internal execution and persistence mechanisms require urgent endpoint monitoring enhancements.

**5\. Detection Gap Assessment**

Prioritized gaps identified during the analysis require immediate remediation:

1. **Priority 1 (Observed & Not Detected):** PowerShell execution (sync_healthdata.ps1), scheduled task creation ("HealthSync Update Service"), and registry run-key persistence lack active alerting rules.
2. **Priority 2 (Inferred & Not Detected):** Internal lateral movement via RDP/SMB between corporate workstations remains unmonitored.
3. **Priority 3 (Partially Detected):** DNS tunneling exfiltration (data-sync.healthbane-c2.net) relies on basic query logging without subdomain length or entropy anomaly rules.

**6\. Indicator of Compromise (IoC) Table**

| **Indicator**               | **Type**   | **Phase** | **Confidence** | **Recommended Action**              |
| --------------------------- | ---------- | --------- | -------------- | ----------------------------------- |
| meddefense-portal.com       | Domain     | Stage 1   | High           | Block at Web Gateway / DNS Sinkhole |
| 91.234.99.107               | IP Address | Stage 1   | High           | Block in Firewall / Perimeter ACLs  |
| a1b2c3d4... (invoice.docm)  | SHA-256    | Stage 2   | High           | Add to EDR File Hash Blocklist      |
| healthbane-c2.net           | Domain     | Stage 2/3 | High           | Block outbound proxy & sinkhole DNS |
| data-sync.healthbane-c2.net | Domain     | Stage 3   | High           | Monitor & block DNS TXT queries     |

**7\. YARA Rule Summary**

- **Rules Developed:** 9-yara_phishing_pdf.yar (targeting wkhtmltopdf and credential harvesting URL structures) and 10-yara_arsenal.yar (composite campaign rules).
- **Test Results:** Achieved **100% True Positives** (phishing_sample.pdf, healthbane_lure_02.pdf) and **100% True Negatives** (clean_invoice.pdf, benign_invoice.pdf).
- **Deployment Status:** Recommended for **DEPLOY** at the email gateway and file-scanning ingest points.

**8\. Recommendations**

- **Immediate (48 Hours):**
  1. Enforce PowerShell Script Block Logging (Event ID 4104) across all endpoints.
  2. Block all active IoCs (domains and IPs) in the perimeter firewall and email gateway.
  3. Force password resets and revoke active sessions for any user accounts flagged in Stage 1 logs (e.g., dmarsh).
- **Short-Term (2 Weeks):**
  1. Deploy EDR detection rules for scheduled task creation and registry run-key modifications.
  2. Implement DNS query-length anomaly monitoring to catch DNS tunneling attempts.
  3. Run awareness training focused on healthcare lookalike phishing lures.
- **Medium-Term (30 Days):**
  1. Restrict internal lateral movement protocols (SMB/RDP) between workstations.
  2. Integrate automated threat intelligence feeds into SIEM ingestion pipelines.
  3. Conduct an internal tabletop exercise simulating a Stage 2 lateral movement scenario.

**9\. Intelligence Gaps and Collection Priorities**

- **What Remains Unknown:** The exact volume of patient data exfiltrated during Stage 3 at external partner sites, and whether MedDefense credentials harvested in Stage 1 were successfully leveraged outside organizational perimeters.
- **What Collection Would Answer It:** Comprehensive packet captures (PCAPs) from external partners, centralized cloud identity provider authentication logs, and deeper forensic analysis of seized phishing kit source code.
- **Who to Ask / Data to Review:** Collaborate with regional ISAC partners to share unredacted telemetry, request cloud tenant sign-in logs from IT administration, and review internal firewall traffic flows for abnormal DNS query volumes.

**13\. Intelligence Brief: The HEALTHBANE Campaign**

**1\. Executive Summary**

HEALTHBANE is a multi-stage healthcare phishing campaign orchestrated across the Midwest ISAC region, leveraging lookalike infrastructure and credential harvesting to infiltrate medical organizations. During the campaign window, MedDefense experienced targeted spear-phishing attempts, resulting in one confirmed user interaction and credential submission (dmarsh). Concurrently, broader sector reporting revealed that external healthcare partners suffered deeper compromises, including macro-enabled malware delivery and DNS-tunneling data exfiltration. MedDefense has established foundational perimeter defenses, threat intelligence ingestion, and YARA-based scanning rules, achieving 100% detection on tested PDF lures. However, critical gaps remain around endpoint script logging and internal lateral movement visibility. To mitigate ongoing risk, leadership must execute three priority actions: enforce PowerShell script block logging across all endpoints, mandate multi-factor authentication (MFA) across all external access portals, and integrate automated indicator feeds into gateway security controls.

**2\. Adversary Profile**

The adversary orchestrating the HEALTHBANE campaign exhibits moderate operational sophistication, specializing in targeted social engineering and credential harvesting against the healthcare sector. Operating under disputed attribution monikers (VITALSCORE via commercial feeds versus APT-MEDAGENT via independent researchers), the threat actor demonstrates a clear preference for rapid infrastructure rotation, domain fronting via standard registrars (Namecheap), and utilizing open-source mailers (PHPMailer 6.6.0) alongside custom PDF generators (wkhtmltopdf 0.12.6). Their strategic objective is initial access and subsequent data monetization within resource-constrained medical environments.

**3\. Campaign Analysis**

The HEALTHBANE campaign unfolded across three distinct operational phases during April 2026:

- **Stage 1: Credential Harvesting:** Attackers registered lookalike domains (meddefense-portal.com, etc.) and deployed spear-phishing emails containing malicious PDF attachments and credential-harvesting landing pages. MedDefense observed staff interaction and credential entry during this phase.
- **Stage 2: Malware Delivery:** Threat actors leveraged harvested credentials to authenticate into compromised email accounts, sending internal follow-up emails with macro-enabled .docm attachments (HEALTHBANE_S2_invoice.docm) to deploy secondary payloads (svchost_update.exe) and persistence mechanisms.
- **Stage 3: Data Exfiltration:** Compromised environments experienced base32-encoded DNS TXT-record exfiltration queries targeting patient and insurance records via data-sync.healthbane-c2.net.
- **Evidence Confidence:** Initial reconnaissance and Stage 1 mechanics maintain **HIGH** confidence (corroborated by internal logs and HC3 advisories), while attribution and exact exfiltration volumes remain **MEDIUM** to **LOW** confidence due to fractured external reporting.

**4\. ATT&CK Mapping**

The campaign's behavior is mapped using a rigorous two-tier framework distinguishing confirmed telemetry from analytical deductions:

- **Observed Techniques (Score 100):** Includes _Gather Victim Identity_ (T1589.002), _Acquire Infrastructure_ (T1583.001), _Spearphishing Link/Attachment_ (T1566.002 / T1566.001), _User Execution_ (T1204), _VBA/PowerShell Execution_ (T1059), _Scheduled Tasks_ (T1053.005), and _DNS Exfiltration_ (T1071.004).
- **Inferred Techniques (Score 50):** Includes _Valid Accounts_ (T1078) and _Remote Services Lateral Movement_ (T1021), deduced from standard adversary post-compromise progression.
- **Detection Relevance:** Perimeter defenses cover initial access well, but internal execution and persistence mechanisms require urgent endpoint monitoring enhancements.

**5\. Detection Gap Assessment**

Prioritized gaps identified during the analysis require immediate remediation:

1. **Priority 1 (Observed & Not Detected):** PowerShell execution (sync_healthdata.ps1), scheduled task creation ("HealthSync Update Service"), and registry run-key persistence lack active alerting rules.
2. **Priority 2 (Inferred & Not Detected):** Internal lateral movement via RDP/SMB between corporate workstations remains unmonitored.
3. **Priority 3 (Partially Detected):** DNS tunneling exfiltration (data-sync.healthbane-c2.net) relies on basic query logging without subdomain length or entropy anomaly rules.

**6\. Indicator of Compromise (IoC) Table**

| **Indicator**               | **Type**   | **Phase** | **Confidence** | **Recommended Action**              |
| --------------------------- | ---------- | --------- | -------------- | ----------------------------------- |
| meddefense-portal.com       | Domain     | Stage 1   | High           | Block at Web Gateway / DNS Sinkhole |
| 91.234.99.107               | IP Address | Stage 1   | High           | Block in Firewall / Perimeter ACLs  |
| a1b2c3d4... (invoice.docm)  | SHA-256    | Stage 2   | High           | Add to EDR File Hash Blocklist      |
| healthbane-c2.net           | Domain     | Stage 2/3 | High           | Block outbound proxy & sinkhole DNS |
| data-sync.healthbane-c2.net | Domain     | Stage 3   | High           | Monitor & block DNS TXT queries     |

**7\. YARA Rule Summary**

- **Rules Developed:** 9-yara_phishing_pdf.yar (targeting wkhtmltopdf and credential harvesting URL structures) and 10-yara_arsenal.yar (composite campaign rules).
- **Test Results:** Achieved **100% True Positives** (phishing_sample.pdf, healthbane_lure_02.pdf) and **100% True Negatives** (clean_invoice.pdf, benign_invoice.pdf).
- **Deployment Status:** Recommended for **DEPLOY** at the email gateway and file-scanning ingest points.

**8\. Recommendations**

- **Immediate (48 Hours):**
  1. Enforce PowerShell Script Block Logging (Event ID 4104) across all endpoints.
  2. Block all active IoCs (domains and IPs) in the perimeter firewall and email gateway.
  3. Force password resets and revoke active sessions for any user accounts flagged in Stage 1 logs (e.g., dmarsh).
- **Short-Term (2 Weeks):**
  1. Deploy EDR detection rules for scheduled task creation and registry run-key modifications.
  2. Implement DNS query-length anomaly monitoring to catch DNS tunneling attempts.
  3. Run awareness training focused on healthcare lookalike phishing lures.
- **Medium-Term (30 Days):**
  1. Restrict internal lateral movement protocols (SMB/RDP) between workstations.
  2. Integrate automated threat intelligence feeds into SIEM ingestion pipelines.
  3. Conduct an internal tabletop exercise simulating a Stage 2 lateral movement scenario.

**9\. Intelligence Gaps and Collection Priorities**

- **What Remains Unknown:** The exact volume of patient data exfiltrated during Stage 3 at external partner sites, and whether MedDefense credentials harvested in Stage 1 were successfully leveraged outside organizational perimeters.
- **What Collection Would Answer It:** Comprehensive packet captures (PCAPs) from external partners, centralized cloud identity provider authentication logs, and deeper forensic analysis of seized phishing kit source code.
- **Who to Ask / Data to Review:** Collaborate with regional ISAC partners to share unredacted telemetry, request cloud tenant sign-in logs from IT administration, and review internal firewall traffic flows for abnormal DNS query volumes.

**13\. Intelligence Brief: The HEALTHBANE Campaign**

**1\. Executive Summary**

HEALTHBANE is a multi-stage healthcare phishing campaign orchestrated across the Midwest ISAC region, leveraging lookalike infrastructure and credential harvesting to infiltrate medical organizations. During the campaign window, MedDefense experienced targeted spear-phishing attempts, resulting in one confirmed user interaction and credential submission (dmarsh). Concurrently, broader sector reporting revealed that external healthcare partners suffered deeper compromises, including macro-enabled malware delivery and DNS-tunneling data exfiltration. MedDefense has established foundational perimeter defenses, threat intelligence ingestion, and YARA-based scanning rules, achieving 100% detection on tested PDF lures. However, critical gaps remain around endpoint script logging and internal lateral movement visibility. To mitigate ongoing risk, leadership must execute three priority actions: enforce PowerShell script block logging across all endpoints, mandate multi-factor authentication (MFA) across all external access portals, and integrate automated indicator feeds into gateway security controls.

**2\. Adversary Profile**

The adversary orchestrating the HEALTHBANE campaign exhibits moderate operational sophistication, specializing in targeted social engineering and credential harvesting against the healthcare sector. Operating under disputed attribution monikers (VITALSCORE via commercial feeds versus APT-MEDAGENT via independent researchers), the threat actor demonstrates a clear preference for rapid infrastructure rotation, domain fronting via standard registrars (Namecheap), and utilizing open-source mailers (PHPMailer 6.6.0) alongside custom PDF generators (wkhtmltopdf 0.12.6). Their strategic objective is initial access and subsequent data monetization within resource-constrained medical environments.

**3\. Campaign Analysis**

The HEALTHBANE campaign unfolded across three distinct operational phases during April 2026:

- **Stage 1: Credential Harvesting:** Attackers registered lookalike domains (meddefense-portal.com, etc.) and deployed spear-phishing emails containing malicious PDF attachments and credential-harvesting landing pages. MedDefense observed staff interaction and credential entry during this phase.
- **Stage 2: Malware Delivery:** Threat actors leveraged harvested credentials to authenticate into compromised email accounts, sending internal follow-up emails with macro-enabled .docm attachments (HEALTHBANE_S2_invoice.docm) to deploy secondary payloads (svchost_update.exe) and persistence mechanisms.
- **Stage 3: Data Exfiltration:** Compromised environments experienced base32-encoded DNS TXT-record exfiltration queries targeting patient and insurance records via data-sync.healthbane-c2.net.
- **Evidence Confidence:** Initial reconnaissance and Stage 1 mechanics maintain **HIGH** confidence (corroborated by internal logs and HC3 advisories), while attribution and exact exfiltration volumes remain **MEDIUM** to **LOW** confidence due to fractured external reporting.

**4\. ATT&CK Mapping**

The campaign's behavior is mapped using a rigorous two-tier framework distinguishing confirmed telemetry from analytical deductions:

- **Observed Techniques (Score 100):** Includes _Gather Victim Identity_ (T1589.002), _Acquire Infrastructure_ (T1583.001), _Spearphishing Link/Attachment_ (T1566.002 / T1566.001), _User Execution_ (T1204), _VBA/PowerShell Execution_ (T1059), _Scheduled Tasks_ (T1053.005), and _DNS Exfiltration_ (T1071.004).
- **Inferred Techniques (Score 50):** Includes _Valid Accounts_ (T1078) and _Remote Services Lateral Movement_ (T1021), deduced from standard adversary post-compromise progression.
- **Detection Relevance:** Perimeter defenses cover initial access well, but internal execution and persistence mechanisms require urgent endpoint monitoring enhancements.

**5\. Detection Gap Assessment**

Prioritized gaps identified during the analysis require immediate remediation:

1. **Priority 1 (Observed & Not Detected):** PowerShell execution (sync_healthdata.ps1), scheduled task creation ("HealthSync Update Service"), and registry run-key persistence lack active alerting rules.
2. **Priority 2 (Inferred & Not Detected):** Internal lateral movement via RDP/SMB between corporate workstations remains unmonitored.
3. **Priority 3 (Partially Detected):** DNS tunneling exfiltration (data-sync.healthbane-c2.net) relies on basic query logging without subdomain length or entropy anomaly rules.

**6\. Indicator of Compromise (IoC) Table**

| **Indicator**               | **Type**   | **Phase** | **Confidence** | **Recommended Action**              |
| --------------------------- | ---------- | --------- | -------------- | ----------------------------------- |
| meddefense-portal.com       | Domain     | Stage 1   | High           | Block at Web Gateway / DNS Sinkhole |
| 91.234.99.107               | IP Address | Stage 1   | High           | Block in Firewall / Perimeter ACLs  |
| a1b2c3d4... (invoice.docm)  | SHA-256    | Stage 2   | High           | Add to EDR File Hash Blocklist      |
| healthbane-c2.net           | Domain     | Stage 2/3 | High           | Block outbound proxy & sinkhole DNS |
| data-sync.healthbane-c2.net | Domain     | Stage 3   | High           | Monitor & block DNS TXT queries     |

**7\. YARA Rule Summary**

- **Rules Developed:** 9-yara_phishing_pdf.yar (targeting wkhtmltopdf and credential harvesting URL structures) and 10-yara_arsenal.yar (composite campaign rules).
- **Test Results:** Achieved **100% True Positives** (phishing_sample.pdf, healthbane_lure_02.pdf) and **100% True Negatives** (clean_invoice.pdf, benign_invoice.pdf).
- **Deployment Status:** Recommended for **DEPLOY** at the email gateway and file-scanning ingest points.

**8\. Recommendations**

- **Immediate (48 Hours):**
  1. Enforce PowerShell Script Block Logging (Event ID 4104) across all endpoints.
  2. Block all active IoCs (domains and IPs) in the perimeter firewall and email gateway.
  3. Force password resets and revoke active sessions for any user accounts flagged in Stage 1 logs (e.g., dmarsh).
- **Short-Term (2 Weeks):**
  1. Deploy EDR detection rules for scheduled task creation and registry run-key modifications.
  2. Implement DNS query-length anomaly monitoring to catch DNS tunneling attempts.
  3. Run awareness training focused on healthcare lookalike phishing lures.
- **Medium-Term (30 Days):**
  1. Restrict internal lateral movement protocols (SMB/RDP) between workstations.
  2. Integrate automated threat intelligence feeds into SIEM ingestion pipelines.
  3. Conduct an internal tabletop exercise simulating a Stage 2 lateral movement scenario.

**9\. Intelligence Gaps and Collection Priorities**

- **What Remains Unknown:** The exact volume of patient data exfiltrated during Stage 3 at external partner sites, and whether MedDefense credentials harvested in Stage 1 were successfully leveraged outside organizational perimeters.
- **What Collection Would Answer It:** Comprehensive packet captures (PCAPs) from external partners, centralized cloud identity provider authentication logs, and deeper forensic analysis of seized phishing kit source code.
- **Who to Ask / Data to Review:** Collaborate with regional ISAC partners to share unredacted telemetry, request cloud tenant sign-in logs from IT administration, and review internal firewall traffic flows for abnormal DNS query volumes.
