# The Data Classification Matrix

## Part 1 - Data Type Inventory

| Data Type | Definition / Scope | Example Assets |
|---|---|---|
| **Regulated (HIPAA / PHI)** | Protected Health Information (PHI) containing individually identifiable medical information. | Electronic Health Records (EHR), diagnostic imaging, patient treatment records |
| **PII (Personally Identifiable Information)** | Information that can identify an individual directly or indirectly. | Social Security Numbers (SSNs), personal phone numbers, addresses |
| **Financial** | Data related to transactions, payments, and accounting activities. | Primary Account Numbers (PANs), payroll ledgers, billing records |
| **Intellectual Property (IP)** | Proprietary technology, research, and business-critical information. | Telemedicine source code, R&D treatment algorithms, system configurations |
| **Legal** | Documentation required for legal, compliance, and regulatory activities. | Litigation records, audit findings, compliance incident reports |
| **Operational** | Routine administrative and facility management information. | Hospital cafeteria menus, staff directories, internal schedules |

---

# Part 2 - Classification Levels

| Classification Level | Access Scope | Encryption Requirements | Business Impact |
|---|---|---|---|
| **Public** | Unrestricted access; information approved for external sharing. | No encryption required at rest; optional encryption in transit. | Negligible |
| **Internal** | Available to authenticated employees and authorized staff members. | Standard file/volume encryption; TLS encryption for data in transit. | Low |
| **Confidential** | Accessible only to authorized business units on a need-to-know basis. | AES-256 database/file encryption; TLS 1.2/1.3 for data transmission. | Moderate |
| **Restricted** | Strictly limited to clinical, billing, security, and privileged administrative roles. | AES-256 Transparent Data Encryption (TDE), record-level encryption, strict TLS 1.3, and VPN protection. | Severe |

---

# Part 3 - The Classification Decision Tree

```text
Start: Classify New Data Asset
│
├──> Is it PHI or medical records?
│        └── YES ──> [RESTRICTED]
│
├──> Does it contain payment data (PANs) or SSNs?
│        └── YES ──> [RESTRICTED]
│
├──> Is it financial reports, executive strategy,
│    or legal findings?
│        └── YES ──> [CONFIDENTIAL]
│
├──> Is it internal organizational data
│    (schedules, policies)?
│        └── YES ──> [INTERNAL]
│
└──> Otherwise
         └──> [PUBLIC]
# Part 4 - Sovereignty and Geolocation

Healthcare data sovereignty is critical because healthcare organizations must comply with strict jurisdictional laws that control where patient information can be stored, processed, and accessed.

Regulations such as **HIPAA** impose requirements around the handling of **Protected Health Information (PHI)**. Moving backups or workloads to external cloud regions, especially foreign locations, can introduce risks involving:

- Cross-border data transfer restrictions
- Different privacy regulations
- Government access or subpoena risks
- Loss of control over physical data locations
- Legal conflicts regarding encryption keys

---

## Encryption and Sovereignty Risks

Encryption provides strong protection against unauthorized access, but it does **not completely eliminate sovereignty risks**.

Legal authorities may still have jurisdiction over:

- Data storage locations
- Cloud provider infrastructure
- Encryption key management systems
- Administrative access endpoints

---

## Data Sovereignty Protection Measures

Healthcare organizations must combine encryption controls with additional governance measures, including:

- Data residency policies
- Careful cloud region selection
- Contractual agreements with service providers
- Regulatory compliance assessments

These controls ensure that healthcare data remains protected while meeting legal, privacy, and jurisdictional requirements.
