# 13. The Encryption Levels

## Encryption Levels Comparison Table

| Level | Scope | Performance Impact | Key Management | Use Case |
|---|---|---|---|---|
| **Full-disk** | Entire physical or virtual disk (all sectors/blocks) | Lowest (hardware-assisted, transparent at OS block layer) | Low (single system-wide key or TPM-backed volume key) | Best choice when protecting data at rest against physical theft or unauthorized extraction of offline storage media. |
| **Partition** | One specific logical partition on a storage device | Very Low (operates below the file system level) | Low (managed via OS utilities like BitLocker or LUKS) | Best choice when separating operating system files from sensitive user or application data partitions on a single drive. |
| **Volume** | Logical volume (can span multiple physical disks or arrays) | Low to Moderate (transparent block-level encryption) | Moderate (managed at the logical volume manager level, e.g., LVM/RAID) | Best choice when securing large storage pools, storage area networks (SANs), or virtualized storage volumes spanning multiple drives. |
| **File** | Individual files within a file system | Moderate (overhead per file open/close and read/write operation) | Moderate (per-file or user-based keys managed via OS or application) | Best choice when protecting specific sensitive documents or configuration files while leaving non-sensitive files unencrypted. |
| **Database** | Entire database, schema, or tablespace files | Moderate (transparent data encryption engine handling pages) | Moderate to High (database master keys and data encryption keys managed by DB service) | Best choice when securing enterprise relational databases against file-system theft while maintaining application query performance. |
| **Record** | Individual fields (columns) or records (rows) within tables | Highest (significant CPU overhead for parsing, tokenizing, and decrypting individual values) | Complex (requires application-layer key management, granular access controls, and token vaults) | Best choice when protecting high-value, hyper-sensitive data elements (such as credit card numbers or SSNs) from privileged database administrators. |

---

# MedDefense Encryption Level Map

| Data Store / Asset | Recommended Encryption Level | Justification |
|---|---|---|
| **Patient records in PostgreSQL (ehr-db-01)** | **Database-level (Transparent Data Encryption - TDE)** | Protects core Electronic Health Records against unauthorized offline file access and disk removal while maintaining full relational query and indexing performance for clinical applications. |
| **Backup data on NAS-01** | **Volume-level** | Secures massive backup repositories across network storage arrays efficiently, ensuring that stolen backup media or discarded drives cannot be read. |
| **Financial records in MySQL (billing-srv-01)** | **Record-level (or Database-level with column masking)** | Isolates highly sensitive billing details and cardholder data fields so that even internal database administrators with broad query privileges cannot read unmasked financial strings. |
| **Medical images on PACS (pacs-srv-01)** | **Volume-level or File-level** | Balances the massive file size of DICOM medical images with high-throughput streaming requirements, protecting stored imaging studies on storage tiers without reducing clinical retrieval speeds. |
| **Email data in O365** | **Cloud Service Provider Native Encryption (Microsoft Purview Message Encryption / Service-Level)** | Uses cloud-managed keys and transport security to protect emails in transit and at rest across Microsoft's multi-tenant infrastructure while complying with healthcare privacy standards. |
| **Employee laptops** | **Full-disk encryption (BitLocker / FileVault)** | Secures mobile endpoints against physical loss, theft, or unauthorized forensic extraction when clinicians and administrators travel outside the secure facility. |
| **BD Alaris pump firmware/configuration** | **File-level / Device-level cryptographic signing and encryption** | Protects medical device firmware packages and configuration profiles from malicious tampering or unauthorized reverse engineering before deployment to bedside hardware. |

---
