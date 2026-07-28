# The Encryption Levels

## Part 1 - Encryption Level Comparison Table

| Encryption Level | Scope | Performance Impact | Key Management | Use Case |
|---|---|---|---|---|
| **Full-disk** | Entire physical or virtual disk | Low-to-moderate (transparent hardware/OS acceleration) | Low (single master key per disk) | Best choice when protecting entire hardware assets from physical theft or loss, such as employee laptops. |
| **Partition** | One logical partition | Low-to-moderate | Low-to-moderate | Best choice when isolating a specific operating system or data partition on shared physical storage media. |
| **Volume** | Logical volume (may span disks) | Low-to-moderate (e.g., AES-256-XTS) | Moderate (managed via volume manager or LUKS) | Best choice when securing multi-disk storage pools or backup arrays like NAS-01 against offline media theft. |
| **File** | Individual files | Moderate (per-file overhead during I/O operations) | Moderate-to-high (per-file keys or centralized file system keys) | Best choice when protecting individual sensitive documents or shared home directories on multi-user systems. |
| **Database** | Entire database or tablespace | Moderate (transparent data encryption overhead on reads/writes) | High (database master key wrapping data encryption keys) | Best choice when securing entire structured database instances (TDE) against unauthorized file-level access. |
| **Record** | Individual fields or records | High (application-level crypto processing per field/row) | Very High (granular key management or tokenization vaults) | Best choice when protecting highly sensitive individual elements like SSNs or medical record tokens against database administrators. |

---

# Part 2 - MedDefense Encryption Level Map

## Patient Records in PostgreSQL (`ehr-db-01`)

**Recommended Encryption Level:** Database (Transparent Data Encryption - TDE)

**Justification:**

Database-level encryption protects underlying database files and tablespaces from physical theft or unauthorized storage access while maintaining transparent query performance for clinical applications.

---

## Backup Data on NAS-01

**Recommended Encryption Level:** Volume (LUKS)

**Justification:**

Volume-level encryption secures aggregated backup blocks and virtual disk archives efficiently without introducing high file-system or application overhead during bulk backup operations.

---

## Financial Records in MySQL (`billing-srv-01`)

**Recommended Encryption Level:** Database (TDE) / Record-level encryption for specific financial identifiers

**Justification:**

Database encryption ensures structured billing and financial data meets compliance requirements while preventing unauthorized extraction of database files. Record-level encryption can additionally protect highly sensitive identifiers such as payment information.

---

## Medical Images on PACS (`pacs-srv-01`)

**Recommended Encryption Level:** Volume-level or File-level storage encryption

**Justification:**

Volume or file-level encryption efficiently protects large DICOM medical image repositories while maintaining minimal performance impact during high-throughput imaging reads and writes.

---

## Email Data in O365

**Recommended Encryption Level:** Cloud Service Provider Native Encryption (Application/Transport Layer Encryption)

**Justification:**

Using built-in Microsoft 365 enterprise encryption mechanisms, including Office 365 Message Encryption and customer-managed keys, provides protection for email data both in transit and at rest within a SaaS environment.

---

## Employee Laptops

**Recommended Encryption Level:** Full-disk encryption (BitLocker / LUKS)

**Justification:**

Full-disk encryption mitigates the risk of sensitive data exposure from lost or stolen devices by protecting the entire operating system, applications, and local user data.

---

## BD Alaris Pump Firmware/Configuration

**Recommended Encryption Level:** File-level or Specialized Embedded Storage Encryption

**Justification:**

File-level or embedded storage encryption secures sensitive device configuration profiles and local telemetry logs stored on medical IoT flash memory against unauthorized extraction, modification, or tampering.

---

# Summary: MedDefense Encryption Strategy

| Asset | Recommended Encryption Level | Primary Security Objective |
|---|---|---|
| PostgreSQL Patient Records (`ehr-db-01`) | Database TDE | Protect PHI stored in database files |
| NAS-01 Backup Storage | Volume (LUKS) | Protect backup archives from offline theft |
| MySQL Financial Records (`billing-srv-01`) | Database TDE + Record Encryption | Protect billing data and financial identifiers |
| PACS Medical Images (`pacs-srv-01`) | Volume/File Encryption | Protect DICOM image repositories |
| Microsoft 365 Email | Cloud Provider Encryption | Protect SaaS-hosted communication data |
| Employee Laptops | Full-Disk Encryption | Protect devices against loss or theft |
| BD Alaris Pump Firmware | File/Embedded Storage Encryption | Protect medical IoT configurations |
