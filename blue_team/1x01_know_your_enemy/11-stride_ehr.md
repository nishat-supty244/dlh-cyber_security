# STRIDE Analysis on the EHR System

---

# Spoofing

## Threat ID: EHR-S1

- **Category:** Spoofing
- **Description:**  
  An attacker clones the EHR login portal or steals session cookies to impersonate an authenticated physician.

- **Attack Vector:**  
  Phishing / Spear Phishing

- **Impact:**  
  Unauthorized access to patient medical records and the ability to enter fraudulent diagnostic information.

- **Existing Control:**  
  None

- **Gap:**  
  IAM-01

---

## Threat ID: EHR-S2

- **Category:** Spoofing
- **Description:**  
  A malicious actor spoofs an internal IP address to bypass network-level access controls when connecting to the PostgreSQL database.

- **Attack Vector:**  
  Unsecure Networks (Flat Network)

- **Impact:**  
  Ability to execute direct SQL commands against the EHR database without proper authentication.

- **Existing Control:**  
  None

- **Gap:**  
  NET-01

---

# Tampering

## Threat ID: EHR-T1

- **Category:** Tampering
- **Description:**  
  An attacker modifies laboratory result values within the PostgreSQL database, causing incorrect clinical decisions or unnecessary treatments.

- **Attack Vector:**  
  Vulnerable Software Exploit

- **Impact:**  
  Severe patient harm or potential death due to incorrect medical treatment.

- **Existing Control:**  
  None

- **Gap:**  
  VULN-01

---

## Threat ID: EHR-T2

- **Category:** Tampering
- **Description:**  
  A malicious insider alters patient medication history or allergy information to hide previous administrative mistakes.

- **Attack Vector:**  
  Insider (Malicious)

- **Impact:**  
  Incorrect medication administration and compromised patient safety.

- **Existing Control:**  
  User Access Logs

- **Gap:**  
  MON-01

---

# Repudiation

## Threat ID: EHR-R1

- **Category:** Repudiation
- **Description:**  
  A user performs unauthorized actions on patient records and denies responsibility due to insufficient granular and immutable logging.

- **Attack Vector:**  
  Insider (Malicious)

- **Impact:**  
  Inability to establish forensic accountability after a patient privacy breach.

- **Existing Control:**  
  None

- **Gap:**  
  MON-01

---

## Threat ID: EHR-R2

- **Category:** Repudiation
- **Description:**  
  An attacker deletes or modifies system logs after data exfiltration to remove evidence of compromise.

- **Attack Vector:**  
  Vulnerable Software Exploit

- **Impact:**  
  Legal and regulatory challenges in determining the scope of a HIPAA violation.

- **Existing Control:**  
  None

- **Gap:**  
  MON-01

---

# Information Disclosure

## Threat ID: EHR-I1

- **Category:** Information Disclosure
- **Description:**  
  Unauthorized users access patient records by exploiting unpatched vulnerabilities in the EHR application server (**ehr-srv-01**).

- **Attack Vector:**  
  Vulnerable Software Exploit

- **Impact:**  
  Large-scale exposure of PHI resulting in regulatory fines, legal consequences, and loss of patient trust.

- **Existing Control:**  
  None

- **Gap:**  
  VULN-01

---

## Threat ID: EHR-I2

- **Category:** Information Disclosure
- **Description:**  
  Sensitive patient data is intercepted during communication between the database and web server through network sniffing on the flat network.

- **Attack Vector:**  
  Unsecure Networks

- **Impact:**  
  Unauthorized access to private medical information by internal attackers.

- **Existing Control:**  
  None

- **Gap:**  
  NET-01

---

# Denial of Service

## Threat ID: EHR-D1

- **Category:** Denial of Service
- **Description:**  
  Ransomware encrypts the entire EHR database, making patient information unavailable to clinical staff.

- **Attack Vector:**  
  Phishing / Spear Phishing

- **Impact:**  
  Immediate disruption of healthcare operations and potential patient safety risks during emergencies.

- **Existing Control:**  
  None

- **Gap:**  
  DATA-02

---

## Threat ID: EHR-D2

- **Category:** Denial of Service
- **Description:**  
  A malicious actor floods the PostgreSQL database service with excessive requests, consuming resources and causing the EHR application to become unavailable.

- **Attack Vector:**  
  Unsecure Networks

- **Impact:**  
  Clinical staff cannot access patient charts during active procedures.

- **Existing Control:**  
  None

- **Gap:**  
  NET-01

---

# Elevation of Privilege

## Threat ID: EHR-E1

- **Category:** Elevation of Privilege
- **Description:**  
  An attacker uses a low-privileged account to exploit system misconfigurations and gain Domain Admin privileges.

- **Attack Vector:**  
  Default / Shared Credentials

- **Impact:**  
  Complete control over the MedDefense healthcare environment.

- **Existing Control:**  
  None

- **Gap:**  
  IAM-01

---

## Threat ID: EHR-E2

- **Category:** Elevation of Privilege
- **Description:**  
  A third-party maintenance contractor uses temporary access privileges to escalate from the EHR application server to the underlying operating system.

- **Attack Vector:**  
  Supply Chain Compromise

- **Impact:**  
  Ability to install persistent rootkits or backdoors at the operating system level.

- **Existing Control:**  
  Vendor Access Logs

- **Gap:**  
  VEND-01

---

# STRIDE Summary for EHR

The **Information Disclosure** category represents the greatest risk to the MedDefense EHR system.

The primary threat facing healthcare organizations is the theft and exposure of **Protected Health Information (PHI)**, which can result in:

- Severe regulatory penalties
- Financial losses
- Legal consequences
- Long-term reputational damage

Unlike financial data such as credit card numbers, medical records cannot be replaced or canceled. Exposure of a patient's medical history represents a permanent privacy violation.

When combined with MedDefense's:

- Flat network architecture
- Lack of internal monitoring
- Weak access controls

Information Disclosure becomes a highly likely outcome once an attacker gains even minimal access to the environment. The EHR therefore represents a high-value, insufficiently protected repository of sensitive patient information.
