# The Crypto Inventory

| Data Category | At Rest (Stored on disk, database, NAS, backup) | In Transit (Moving between systems over the network) | In Use (Actively being processed or displayed) |
|---------------|-------------------------------------------------|------------------------------------------------------|------------------------------------------------|
| **Patient Medical Records (EHR data in PostgreSQL)** | **Protection:** None (PostgreSQL data directory stored on unencrypted ext4 filesystem) <br> **Evidence:** EHR System audit section <br> **Status:** ❌ Absent | **Protection:** Partial (pg_hba.conf allows non-SSL connections from 10.10.0.0/16) <br> **Evidence:** EHR System audit section <br> **Status:** ⚠️ Weak | **Protection:** None (Decrypted in memory on `ehr-srv-01`; nurse station screensaver timeout set to "Never") <br> **Evidence:** EHR System audit section <br> **Status:** ❌ Absent |
| **Financial/Billing Data (MySQL on billing-srv-01)** | **Protection:** None (MySQL data directory on unencrypted ext4 filesystem) <br> **Evidence:** Financial Data audit section <br> **Status:** ❌ Absent | **Protection:** Weak (Plaintext MySQL protocol over flat network; SSL not enforced) <br> **Evidence:** Financial Data audit section <br> **Status:** ⚠️ Weak | **Protection:** None (Plaintext visible in database files / local processing) <br> **Evidence:** Financial Data audit section <br> **Status:** ❌ Absent |
| **Medical Images (DICOM on PACS)** | **Protection:** None (Local disk storage without encryption; headers contain plaintext identifiers) <br> **Evidence:** Medical Images audit section <br> **Status:** ❌ Absent | **Protection:** None (Cleartext DICOM protocol on ports 4242 and 11112; DICOM TLS not configured) <br> **Evidence:** Medical Images audit section <br> **Status:** ❌ Absent | **Protection:** None (Unencrypted rendering on diagnostic workstations) <br> **Evidence:** Medical Images audit section <br> **Status:** ❌ Absent |
| **Credentials (Active Directory, application passwords)** | **Protection:** NT Hash (MD4) by default for NTLM compatibility; RC4 and DES enabled <br> **Evidence:** Credentials audit section, Finding 018 <br> **Status:** ⚠️ Weak | **Protection:** LDAP signing not required <br> **Evidence:** Credentials audit section, Finding 007 <br> **Status:** ⚠️ Weak | **Protection:** Plaintext/reversible caching in memory <br> **Evidence:** Credentials audit section <br> **Status:** ⚠️ Weak |
| **Backup Data (NAS-01)** | **Protection:** None (RAID-5 array with no encryption layer; plaintext database dumps) <br> **Evidence:** Backup Data audit section <br> **Status:** ❌ Absent | **Protection:** None (Unencrypted network transfers/SMB access over flat network) <br> **Evidence:** Backup Data audit section <br> **Status:** ❌ Absent | **Protection:** N/A (Passive storage state) <br> **Evidence:** Backup Data audit section <br> **Status:** ✅ Adequate |
| **Email (Microsoft 365)** | **Protection:** BitLocker on Microsoft datacenter disks + per-mailbox encryption (Microsoft-managed keys) <br> **Evidence:** Email audit section <br> **Status:** ✅ Adequate | **Protection:** TLS 1.2 for all Exchange Online connections <br> **Evidence:** Email audit section <br> **Status:** ✅ Adequate | **Protection:** Cloud-managed session state <br> **Evidence:** Email audit section <br> **Status:** ✅ Adequate |
| **VPN Traffic (Site-to-Site Tunnels)** | **Protection:** N/A (In-transit state only) <br> **Evidence:** VPN Traffic audit section <br> **Status:** ✅ Adequate | **Protection:** IPSec (AES-256 with SHA-256, IKEv2, DH Group 14); note potential risk from consumer router endpoint at Westside <br> **Evidence:** VPN Traffic audit section <br> **Status:** ✅ Adequate | **Protection:** N/A <br> **Evidence:** VPN Traffic audit section <br> **Status:** ✅ Adequate |

---

# Gap Summary

## Protection Status Overview

| Metric | Count |
|--------|------:|
| ✅ Adequate Protection | 4 primary cells *(Email: At Rest, In Transit, In Use; VPN: In Transit)* |
| ⚠️ Weak Protection | 5 cells |
| ❌ Absent Protection | 12 cells |

> **Note:** Backup Data (In Use) is classified as **N/A / Adequate** because it represents passive storage rather than active processing.

---

## Weak Protection Areas

- EHR data (In Transit)
- Financial/Billing data (In Transit)
- Credentials (At Rest)
- Credentials (In Transit)
- Credentials (In Use)

---

## Missing Protection Areas

- Patient Medical Records (At Rest)
- Patient Medical Records (In Use)
- Financial/Billing Data (At Rest)
- Financial/Billing Data (In Use)
- Medical Images (At Rest)
- Medical Images (In Transit)
- Medical Images (In Use)
- Backup Data (At Rest)
- Backup Data (In Transit)
- Additional unencrypted portal elements

---

## Overall Cryptographic Coverage

**Overall Crypto Coverage:** **~19%**

Approximately **19% of the 21 primary data protection matrix cells** demonstrate **adequate cryptographic protection**, indicating that the majority of MedDefense's critical operational data remains either **unencrypted** or **protected using weak cryptographic controls**.

### Key Finding

The assessment reveals significant deficiencies in cryptographic protections across the organization, particularly for:

- Electronic Health Records (EHR)
- Financial and billing databases
- Medical imaging systems (PACS/DICOM)
- Backup repositories
- Authentication credentials

These weaknesses substantially increase the organization's exposure to unauthorized disclosure, ransomware attacks, credential theft, and regulatory non-compliance (e.g., HIPAA), making encryption and secure communication protocols a high-priority remediation effort.
