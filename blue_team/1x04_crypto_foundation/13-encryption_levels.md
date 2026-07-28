# 13. The Encryption Levels (Corrected & Refined)

## Part 1 - Encryption Level Comparison Table

| Encryption Level | Scope | Performance Impact | Key Management | Use Case |
|---|---|---|---|---|
| **Full-disk** | Entire physical or virtual disk | Low (transparent hardware/OS acceleration) | Low (single master key per disk) | Best choice when protecting entire hardware assets from physical theft or loss, such as employee laptops. |
| **Partition** | One logical partition | Low-to-moderate | Low-to-moderate | Best choice when isolating a specific operating system or data partition on shared physical storage media. |
| **Volume** | Logical volume (may span disks) | Low-to-moderate (e.g., AES-256-XTS) | Moderate (managed via volume manager or LUKS) | Best choice when securing multi-disk storage pools or backup arrays like NAS-01 against offline media theft without application modification. |
| **File** | Individual files | Moderate (per-file overhead during I/O operations) | Moderate-to-high (per-file keys or centralized file system keys) | Best choice when protecting individual sensitive documents or shared home directories on multi-user systems. |
| **Database** | Entire database or tablespace | Moderate (transparent data encryption overhead on reads/writes) | High (database master key wrapping data encryption keys) | Best choice when securing entire structured database instances (TDE) against unauthorized file-level extraction while preserving application query compatibility. |
| **Record** | Individual fields or records | High (application-level crypto processing per field/row) | Very High (granular key management or tokenization vaults) | Best choice when protecting highly sensitive individual elements like SSNs or specific medical identifiers against database administrators. |

---

# Part 2 - MedDefense Encryption Level Map (Corrected Architecture)

## Patient Records in PostgreSQL (`ehr-db-01`)

**Recommended Level:** Database (Transparent Data Encryption - TDE)

**Justification:**

Database-level encryption avoids the performance bottlenecks associated with record-level encryption while ensuring that underlying database files are fully encrypted at rest to comply with HIPAA protection requirements.

---

## Backup Data on NAS-01

**Recommended Level:** Volume-level (LUKS)

**Justification:**

Volume-level encryption avoids the high I/O penalty of file-level encryption on large aggregated backup streams by securing the entire storage volume block-by-block.

---

## Financial Records in MySQL (`billing-srv-01`)

**Recommended Level:** Database-level (TDE) combined with selective field tokenization

**Justification:**

Database-level encryption prevents structural query failures in billing workflows by using TDE for bulk tablespace protection rather than applying complex record-level encryption to every database column.

---

## Medical Images on PACS (`pacs-srv-01`)

**Recommended Level:** Volume-level storage encryption

**Justification:**

Volume-level encryption prevents the heavy processing overhead that file-level or database encryption would introduce when handling massive, high-throughput DICOM medical image streaming operations.

---

## Email Data in O365

**Recommended Level:** Cloud Service Provider Native Application/Transport Encryption

**Justification:**

Using built-in Microsoft 365 enterprise security controls provides encryption for cloud-hosted mailboxes both in transit and at rest without requiring additional local infrastructure encryption layers.

---

## Employee Laptops

**Recommended Level:** Full-disk encryption (BitLocker / LUKS)

**Justification:**

Full-disk encryption secures the complete operating system, applications, and local user profiles against physical theft while avoiding vulnerabilities caused by encrypting only selected files or partitions.

---

## BD Alaris Pump Firmware/Configuration

**Recommended Level:** File-level or Embedded Storage Container Encryption

**Justification:**

File-level or embedded storage encryption protects individual configuration files and localized telemetry logs stored on medical IoT flash memory without requiring an active database or volume management layer.

---

# Summary: MedDefense Encryption Strategy

| Asset | Recommended Encryption Level | Security Objective |
|---|---|---|
| PostgreSQL Patient Records (`ehr-db-01`) | Database TDE | Encrypt PHI databases while maintaining application compatibility |
| NAS-01 Backup Storage | Volume-level LUKS | Protect backup storage blocks against offline theft |
| MySQL Financial Records (`billing-srv-01`) | Database TDE + Field Tokenization | Protect financial data while preserving billing workflows |
| PACS Medical Images (`pacs-srv-01`) | Volume-level Encryption | Secure large DICOM repositories with minimal performance impact |
| Microsoft 365 Email | Cloud Native Encryption | Protect SaaS email data in transit and at rest |
| Employee Laptops | Full-Disk Encryption | Prevent exposure from lost or stolen devices |
| BD Alaris Pump Firmware | File/Embedded Storage Encryption | Protect IoT configuration files and telemetry data |
