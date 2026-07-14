# Data Mapping and Protection Analysis

This assessment identifies the major data categories within **MedDefense Health Systems**, tracks their lifecycle states (**at rest, in transit, and in use**), and documents existing protection mechanisms and security gaps identified from previous assessments.

---

# Data Mapping Table

| Data Category | Classification | At Rest (Where) | In Transit (How) | In Use (By Whom, On What) | Current Protection | Protection Gaps |
|---------------|---------------|-----------------|------------------|---------------------------|-------------------|----------------|
| **Patient Medical Records** | Restricted | EHR Database (`ehr-db-01`) | Internal network communication (Flat / Unencrypted) | Physicians and nurses on clinical workstations | Active Directory (AD) authentication | Unlocked user sessions (Task 3); flat network architecture allows broad access and increases lateral movement risk. |
| **Medical Imaging (PACS)** | Restricted | PACS Server (`pacs-srv-01`) | Network communication using DICOM | Radiologists on diagnostic workstations | Active Directory (AD) authentication | No encryption for data transmission; vulnerable legacy MRI endpoint increases risk of compromise. |
| **Financial / Billing Data** | Restricted | Billing Server (`billing-srv-01`) | IPsec VPN communication | Finance staff on administrative workstations | Basic firewall protection | Existing cryptominer compromise; weak backup configuration (Task 2). |
| **Employee HR Records** | Confidential | File Server (`file-srv-01`) | SMB network communication | HR personnel on workstations | NTFS file permissions | Located on the same network segment as clinical and potentially compromised devices, increasing exposure risk (Task 1). |
| **System Credentials** | Restricted | Domain Controllers | LDAP / Kerberos network communication | System administrators managing infrastructure | Password policy controls | No Multi-Factor Authentication (MFA); credentials exposed through insecure practices and possible clear-text storage/transmission (Task 3). |
| **Audit Logs** | Internal | Log Server and local system disks | Syslog communication | IT and security personnel using management workstations | Minimal logging controls | No centralized security analysis; insufficient monitoring for suspicious activity and threats (Tasks 4/5). |
| **Website Content** | Public | Web Server (`web-srv-01`) | HTTPS | Public internet users | Firewall protection and DMZ placement | Previous website defacement incidents; no integrity monitoring solution implemented (Task 1). |

---

# Data Risk Summary

MedDefense Health Systems' most significant data protection weakness is the combination of **insufficient network segmentation** and reliance on **authentication-based security without Multi-Factor Authentication (MFA)**. These weaknesses leave Restricted-level data, particularly patient medical records, highly exposed across all three data lifecycle states:

- **Data at Rest:** Although databases and file systems use access controls, these protections can be bypassed if attackers compromise privileged accounts or move laterally through the network.
- **Data in Transit:** The flat network architecture allows compromised devices to potentially intercept sensitive communications because many internal transmissions lack encryption.
- **Data in Use:** Unlocked user sessions and insufficient authentication controls increase the risk of unauthorized access to sensitive healthcare information.

Because the network uses a flat **10.10.0.0/16 subnet**, a compromised device—such as the cryptominer-infected billing server or vulnerable legacy MRI scanner—can provide attackers with a pathway to access critical systems. This significantly reduces the effectiveness of existing protections such as database permissions, file access controls, and authentication mechanisms.

The most critical security gap is the organization's exposure to **lateral movement attacks**, where an attacker gaining initial access through a lower-security asset can move throughout the environment and potentially compromise highly sensitive clinical and financial data.

---

# Key Protection Priorities

1. **Implement Network Segmentation**
   - Separate clinical systems, administrative systems, medical IoT devices, and guest networks.
   - Restrict communication between network zones using firewall policies.

2. **Deploy Multi-Factor Authentication (MFA)**
   - Require MFA for administrators, remote access users, and systems containing Restricted data.

3. **Encrypt Data in Transit**
   - Enable encryption for internal communications involving EHR, PACS, databases, and administrative systems.

4. **Improve Endpoint Security**
   - Remove vulnerable legacy systems.
   - Deploy endpoint detection and response (EDR) solutions.

5. **Strengthen Monitoring and Logging**
   - Centralize audit logs.
   - Implement Security Information and Event Management (SIEM) monitoring for threat detection and incident response.

---

# Conclusion

MedDefense's primary data protection challenge is not only protecting stored information but controlling how data moves throughout the environment. Without proper segmentation, encryption, MFA, and continuous monitoring, sensitive healthcare and financial information remains vulnerable to unauthorized access, data theft, ransomware, and regulatory violations.
