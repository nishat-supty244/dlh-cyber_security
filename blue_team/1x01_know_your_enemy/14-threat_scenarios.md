# The Three Scenarios

## Strategic Threat Modeling for MedDefense Health Systems




---

# Scenario 1: External — "Operation Blackout"

## Title

**Operation Blackout**

### Threat Actor

**Organized Crime / RaaS Group (BlackReef Affiliate)**  
*Reference: Task 6 Profile*

### Motivation

Financial Gain (Ransom Demand + Sale of PHI)

### Initial Vector

Phishing / Spear Phishing (Human / External Surface)

### Attack Surface Exploited

- External (Web-facing services)
- Human (IT Administrator)
- Internal (Flat Network)

---

## Attack Sequence

| Step | Action | MITRE ATT&CK |
|------|--------|--------------|
| **1** | Attacker emails IT Director Sarah Park while impersonating Fortinet Support. The email contains a malicious macro-enabled Microsoft Word document. | **Initial Access** – Spearphishing Attachment (**T1566.001**) |
| **2** | The malicious macro launches a PowerShell reverse shell and creates a scheduled task disguised as Windows Update. | **Execution** (**T1059.001**) + **Persistence** (**T1053.005**) |
| **3** | The attacker performs network discovery using **nltest** and **BloodHound**, identifying **ad-dc-01**, **ehr-db-01**, and **NAS-01** on the flat **10.10.0.0/16** network. | **Discovery** – Network Service Discovery (**T1046**) |
| **4** | Mimikatz extracts the **svc_backup** Domain Admin hash from LSASS memory. | **Credential Access** – OS Credential Dumping (**T1003.001**) |
| **5** | Pass-the-Hash grants Domain Admin privileges. Group Policy deploys ransomware across the environment while backups on **NAS-01** are destroyed. | **Lateral Movement** (**T1550.002**) + **Impact** (**T1486**) |

---

## STRIDE Categories Triggered

- **Spoofing** – Impersonation of IT and backup services
- **Tampering** – Encryption of production data and configuration changes
- **Denial of Service** – Complete disruption of clinical and billing operations

---

## MedDefense Assets Impacted

- Active Directory (**ad-dc-01**, **ad-dc-02**)
- EHR Database (**ehr-db-01**)
- Backup Storage (**NAS-01**)
- Approximately **2,000 workstations**

---

## Business Impact

### Clinical

- Critical downtime
- Emergency patient diversions

### Financial

- Estimated recovery costs of **$2.7M–$5M**

### Regulatory

- HIPAA breach penalties

### Reputational

- Public exposure of patient data
- Significant loss of patient trust

---

## Gaps Exploited

- **GAP-004:** No MFA
- **GAP-003:** No SIEM
- **GAP-001:** Flat Network
- **GAP-005:** Backup Co-location

---

## Detection Opportunities

| Step | Detection Opportunity |
|------|------------------------|
| **Step 1** | Email Security / O365 ATP filtering |
| **Step 2** | EDR with PowerShell logging and behavioral protection |
| **Step 4** | SIEM monitoring for unauthorized LSASS access |
| **Step 5** | Privileged Access Management (PAM) with MFA |

---

# Scenario 2: Internal — "The Quiet Exit"

## Title

**The Quiet Exit**

### Threat Actor

**Malicious Insider (Billing Department)**  
*Reference: Task 3 Profile*

### Motivation

Financial Gain (Black Market PHI Sales)

### Initial Vector

Legitimate Access (Internal / Human Surface)

### Attack Surface Exploited

- Human (Employee)
- Internal (Workstation / Database)

---

## Attack Sequence

| Step | Action | MITRE ATT&CK |
|------|--------|--------------|
| **1** | Employee plans data theft during the final three weeks of employment. | Reconnaissance (Internal Planning) |
| **2** | Authorized EHR access is used to export approximately **200 patient records per day** under the guise of billing activities. | **Collection** – Data from Local System (**T1005**) |
| **3** | Patient data and database configuration files are copied to unauthorized USB media. | **Exfiltration** (**T1048.002**) |
| **4** | Local files and logs are deleted to hide evidence. | **Defense Evasion** (**T1070.001**) |
| **5** | Following termination, the employee's account remains active for five days and is reused through VPN access. | **Persistence** – Valid Accounts (**T1078**) |

---

## STRIDE Categories Triggered

- **Repudiation** – Insufficient logging prevents attribution
- **Information Disclosure** – More than **2,800 patient records** exposed

---

## MedDefense Assets Impacted

- **file-srv-01**
- **ehr-db-01**
- VPN infrastructure

---

## Business Impact

### Financial

- Approximately **$700K** in breach response costs

### Regulatory

- Mandatory HIPAA breach notification

### Reputational

- Regional media coverage
- Loss of public confidence

---

## Gaps Exploited

- **GAP-016:** No Data Loss Prevention (DLP)
- **GAP-014:** Weak Account Lifecycle Management
- **GAP-003:** Insufficient Audit Log Monitoring
- **GAP-012:** No Endpoint Detection for USB usage

---

## Detection Opportunities

| Step | Detection Opportunity |
|------|------------------------|
| **Step 2** | DLP and User Behavior Analytics |
| **Step 3** | Group Policy to block USB storage |
| **Step 5** | Automated HR-to-Active Directory account deprovisioning |

---

# Scenario 3: Third Party — "Vendor Shadow"

## Title

**Vendor Shadow**

### Threat Actor

**Organized Crime (Compromised MedTech Solutions Environment)**  
*Reference: Task 5 Profile*

### Motivation

- Espionage
- Ransomware

### Initial Vector

Supply Chain Compromise (Trusted Vendor Access)

### Attack Surface Exploited

- External (Vendor Tunnel)
- Internal (EHR Maintenance Environment)

---

## Attack Sequence

| Step | Action | MITRE ATT&CK |
|------|--------|--------------|
| **1** | Attacker compromises MedTech Solutions and steals RDP credentials used for MedDefense maintenance. | **Initial Access** – Vendor Phishing (**T1566**) |
| **2** | Attacker connects through RDP using trusted vendor credentials permitted by existing firewall rules. | **Resource Development** (**T1586**) |
| **3** | From the EHR server, the attacker pivots to **ad-dc-01** and creates a hidden administrative account. | **Lateral Movement** (**T1570**) |
| **4** | Persistent scheduled tasks are created while patient records are quietly exfiltrated over 30 days. | **Persistence** (**T1053.005**) + **Exfiltration** (**T1567.001**) |
| **5** | Ransomware is deployed using the hidden administrator account. | **Impact** (**T1486**) |

---

## STRIDE Categories Triggered

- **Spoofing** – Impersonation of trusted vendor personnel
- **Information Disclosure** – Theft of PHI during maintenance
- **Repudiation** – Disputes regarding breach responsibility

---

## MedDefense Assets Impacted

- **ehr-srv-01**
- **ad-dc-01**
- **ehr-db-01**
- More than **50,000 patient records**

---

## Business Impact

### Financial

- Litigation
- Contract penalties

### Regulatory

- "Willful Neglect" penalties due to inadequate vendor oversight

### Reputational

- Loss of confidence in third-party partnerships

---

## Gaps Exploited

- **GAP-004:** No MFA for vendor access
- **GAP-001:** Flat Network
- **GAP-017:** Weak Change Management

---

## Detection Opportunities

| Step | Detection Opportunity |
|------|------------------------|
| **Step 2** | Bastion Host with MFA for all vendor access |
| **Step 3** | Internal network segmentation |
| **Step 4** | Behavioral monitoring of outbound EHR traffic |

---

# Summary Comparison

| Feature | Scenario 1 (Ransomware) | Scenario 2 (Insider) | Scenario 3 (Supply Chain) |
|---------|-------------------------|----------------------|---------------------------|
| **Primary Risk** | Operational Survival | Privacy Liability | Stealth Espionage |
| **Most Critical Gap** | **GAP-001** (Flat Network) | **GAP-014** (IAM) | **GAP-004** (MFA) |
| **Time to Impact** | Hours | Weeks | Months |
| **Board Priority** | **CRITICAL** | **HIGH** | **HIGH** |
