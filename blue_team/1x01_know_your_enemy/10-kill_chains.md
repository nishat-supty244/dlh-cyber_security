# Kill Chain Analysis

---

# Kill Chain #1: The Ransomware Siege

## Threat Actor
**Ransomware Groups (Organized Crime)**

## Target Asset
**EHR Database (ehr-db-01)**

## Expected Impact
- Total operational paralysis of clinical services
- Loss of Availability and Confidentiality

---

## Step 1 - Initial Access

**Vector:** VPN Exploit  
**Surface:** External

**Details:**

The attacker exploits unpatched vulnerabilities in the FortiGate gateway to gain remote network access.

---

## Step 2 - Establish Foothold

**Action:**
- Deploy lightweight Cobalt Strike beacon

**MedDefense Weakness:**
- Lack of EDR/Monitoring (**MON-01**)

---

## Step 3 - Lateral Movement / Escalation

**Action:**
- Pivot to Domain Controller using Pass-the-Hash techniques

**MedDefense Weakness:**
- Flat Network Architecture (**NET-01**)

---

## Step 4 - Objective Execution

**Action:**
- Execute ransomware payload across the server environment

**Data/System Affected:**
- EHR database
- Application servers

---

## Step 5 - Impact

**Business Impact:**
- Clinical downtime
- Emergency care diversion
- Significant HIPAA fines

**CIA Pillars:**
- Availability (Primary)
- Confidentiality (Data exfiltration)

**Gaps Exploited:**
- NET-01
- MON-01
- VULN-01

**Break Points:**
- Step 1: Strong MFA enforcement on VPN access
- Step 3: Network segmentation

---

# Kill Chain #2: The Malicious Insider Exfiltration

## Threat Actor
**Insider (Malicious)**

## Target Asset
**EHR Database**

## Expected Impact
- Large-scale data breach
- Loss of Confidentiality

---

## Step 1 - Initial Access

**Vector:** Insider (Malicious)  
**Surface:** Human

**Details:**

An employee uses legitimate credentials to access the patient portal during unauthorized off-hours activity.

---

## Step 2 - Establish Foothold

**Action:**
- Uses authorized administrative tools to bypass basic access monitoring

**MedDefense Weakness:**
- Absence of User Behavior Analytics (UBA) (**MON-01**)

---

## Step 3 - Lateral Movement / Escalation

**Action:**
- Connects directly to PostgreSQL database port **5432**

**MedDefense Weakness:**
- Flat Network Architecture (**NET-01**)

---

## Step 4 - Objective Execution

**Action:**
- Performs bulk queries and exports patient records

**Data/System Affected:**
- Complete patient PHI database

---

## Step 5 - Impact

**Business Impact:**
- Severe reputational damage
- Loss of patient trust
- Regulatory lawsuits

**CIA Pillars:**
- Confidentiality

**Gaps Exploited:**
- MON-01
- NET-01

**Break Points:**
- Step 2: User Behavior Analytics
- Step 4: Data Loss Prevention (DLP) and egress filtering

---

# Kill Chain #3: The Supply Chain Pivot

## Threat Actor
**Nation-State APT**

## Target Asset
**Active Directory**

## Expected Impact
- Long-term espionage
- Stealth control of systems
- Loss of Confidentiality and Integrity

---

## Step 1 - Initial Access

**Vector:** Supply Chain Compromise  
**Surface:** External

**Details:**

The attacker compromises a third-party IT vendor maintenance account used by MedDefense.

---

## Step 2 - Establish Foothold

**Action:**
- Installs a persistent remote management tool

**MedDefense Weakness:**
- Lack of Vendor Access Monitoring (**VEND-01**)

---

## Step 3 - Lateral Movement / Escalation

**Action:**
- Compromises AD synchronization services to gain Domain Admin privileges

**MedDefense Weakness:**
- Flat Network Architecture (**NET-01**)

---

## Step 4 - Objective Execution

**Action:**
- Accesses corporate email and research documents

**Data/System Affected:**
- Executive O365 account data

---

## Step 5 - Impact

**Business Impact:**
- Intellectual property theft
- Strategic disadvantage

**CIA Pillars:**
- Confidentiality

**Gaps Exploited:**
- VEND-01
- NET-01
- IAM-01

**Break Points:**
- Step 2: Privileged Access Management (PAM) and session recording
- Step 3: Least privilege access and network segmentation

---

# Kill Chain #4: The Negligent Shadow IT Breach

## Threat Actor
**Insider (Negligent)**

## Target Asset
**Billing Server (billing-srv-01)**

## Expected Impact
- Accidental data exposure
- Loss of Confidentiality and Integrity

---

## Step 1 - Initial Access

**Vector:** Insider (Negligent)  
**Surface:** Human

**Details:**

A physician connects an unencrypted personal NAS device to the network for convenience.

---

## Step 2 - Establish Foothold

**Action:**
- NAS device exposes services openly across the network

**MedDefense Weakness:**
- Lack of Network Access Control (NAC) (**ASSET-02**)

---

## Step 3 - Lateral Movement / Escalation

**Action:**
- Attackers discover the NAS device and locate stored credentials used to access the billing server

**MedDefense Weakness:**
- Flat Network Architecture (**NET-01**)

---

## Step 4 - Objective Execution

**Action:**
- Exfiltrate sensitive billing exports

**Data/System Affected:**
- Billing exports
- Financial information

---

## Step 5 - Impact

**Business Impact:**
- Financial loss
- Compliance violations

**CIA Pillars:**
- Confidentiality

**Gaps Exploited:**
- ASSET-02
- NET-01
- SEC-04

**Break Points:**
- Step 1: Network Access Control (802.1X)
- Step 3: Data encryption at rest

---

# Kill Chain #5: The Public Web Exploit

## Threat Actor
**Unskilled Attacker**

## Target Asset
**Patient Portal (web-srv-01)**

## Expected Impact
- Website defacement
- Patient data theft
- Loss of Integrity and Confidentiality

---

## Step 1 - Initial Access

**Vector:** Vulnerable Software Exploit  
**Surface:** External

**Details:**

The attacker exploits outdated Apache software on the web server (**VULN-01**).

---

## Step 2 - Establish Foothold

**Action:**
- Uploads a web shell to maintain persistent access

**MedDefense Weakness:**
- Improper patch management (**VULN-01**)

---

## Step 3 - Lateral Movement / Escalation

**Action:**
- Moves from the compromised web server to backend application databases

**MedDefense Weakness:**
- Flat Network Architecture (**NET-01**)

---

## Step 4 - Objective Execution

**Action:**
- Accesses and dumps patient laboratory results

**Data/System Affected:**
- Laboratory results database

---

## Step 5 - Impact

**Business Impact:**
- Public loss of trust
- Medical malpractice claims

**CIA Pillars:**
- Integrity (Medical records)
- Confidentiality

**Gaps Exploited:**
- VULN-01
- NET-01

**Break Points:**
- Step 1: Patch Management Policy
- Step 3: Internal Firewall Controls and Network Segmentation
