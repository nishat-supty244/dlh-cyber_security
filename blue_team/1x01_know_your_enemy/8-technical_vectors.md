# Technical Vector Assessment

---

## Vector Category: Vulnerable Software

**MedDefense Evidence:**
- Apache 2.4.29 running on **billing-srv-01**
- Ubuntu 18.04 LTS (End-of-Life)

**Affected Asset(s):**
- billing-srv-01
- Internal management servers

**Actor Most Likely to Exploit:**
- Unskilled / Opportunistic Attacker

**Exploitation Scenario:**

An attacker exploits known CVEs associated with the outdated Apache version to achieve remote code execution. After gaining access, the attacker uses the compromised server as a foothold to pivot toward the billing database.

**Current Protection:**
- Basic firewall rules

**Gap Reference:**
- VULN-01

---

# Vector Category: Unsupported Systems

**MedDefense Evidence:**
- Windows XP MRI workstation
- Windows Server 2012 R2 (print-srv-01)

**Affected Asset(s):**
- MRI scanner workstation
- print-srv-01

**Actor Most Likely to Exploit:**
- Nation-State APT

**Exploitation Scenario:**

An attacker exploits unpatched kernel vulnerabilities present in end-of-life operating systems to escalate privileges. This enables long-term, stealthy persistence within the network.

**Current Protection:**
- None

**Gap Reference:**
- VULN-02

---

# Vector Category: Open Service Ports

**MedDefense Evidence:**
- MySQL accessible on port **3306**
- PostgreSQL accessible on port **5432**
- RDP enabled on workstations

**Affected Asset(s):**
- billing-srv-01
- ehr-db-01
- Various endpoints

**Actor Most Likely to Exploit:**
- Ransomware Groups

**Exploitation Scenario:**

Attackers scan the flat network for exposed database services and use brute-force attacks or injection techniques to access sensitive patient information. Exposed RDP services also provide opportunities for lateral movement between systems.

**Current Protection:**
- None (Internal traffic is unmonitored)

**Gap Reference:**
- NET-01

---

# Vector Category: Default Credentials

**MedDefense Evidence:**
- Shared PACS **"raduser"** account
- BD Alaris pump web interfaces using factory default settings

**Affected Asset(s):**
- PACS workstations
- Infusion pumps

**Actor Most Likely to Exploit:**
- Ransomware Groups

**Exploitation Scenario:**

After gaining initial network access, attackers attempt commonly used default password lists against medical IoT devices and PACS systems. Successful authentication provides direct access to clinical equipment or diagnostic information.

**Current Protection:**
- Minimal Security Awareness Training

**Gap Reference:**
- IAM-01

---

# Vector Category: Unsecure Networks

**MedDefense Evidence:**
- Flat **10.10.0.0/16** network architecture
- Unauthorized Westside consumer router connected to the environment

**Affected Asset(s):**
- Entire corporate and clinical network

**Actor Most Likely to Exploit:**
- Ransomware Groups

**Exploitation Scenario:**

Due to the absence of internal network segmentation, the unauthorized consumer router creates an unmanaged entry point that attackers can use to bypass traditional perimeter defenses. Once connected, attackers can move laterally throughout the flat network without restriction.

**Current Protection:**
- Perimeter Firewall

**Gap Reference:**
- NET-01 / ASSET-02

---

# Vector Category: Removable Devices / Unmanaged Endpoints

**MedDefense Evidence:**
- No USB restriction Group Policy Object (GPO)
- Unmanaged personal iPads connected to the clinical network

**Affected Asset(s):**
- Clinical workstations
- Staff iPads

**Actor Most Likely to Exploit:**
- Insider (Negligent)

**Exploitation Scenario:**

A staff member unintentionally introduces malware through a USB device used for file transfer. Without endpoint protection controls, the malware executes on the workstation and can spread throughout the flat network.

**Current Protection:**
- None

**Gap Reference:**
- SEC-04
