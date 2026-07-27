# 14. Hardware Security and Key Management

---

# Part 1 - Technology Comparison

| Technology | What It Is | What It Protects | Typical Cost | Typical Deployment |
|---|---|---|---|---|
| **TPM (Trusted Platform Module)** | A dedicated cryptographic microcontroller physically secured on a motherboard designed to secure hardware through integrated cryptographic keys. | Platform integrity measurements, boot states, full-disk encryption keys (e.g., BitLocker), and platform authentication credentials. | Low (typically embedded directly onto enterprise hardware motherboard chips). | Client endpoints, employee laptops, and medical workstation motherboards. |
| **HSM (Hardware Security Module)** | A physical computing device or cloud-managed appliance purpose-built for high-performance cryptographic key generation, processing, and secure storage. | Enterprise root keys, Certificate Authority (CA) private keys, database master encryption keys, and high-value transaction signatures. | High (ranging from thousands of dollars for on-premises appliances to subscription-based cloud HSM services). | Centralized data centers, cloud enterprise key management infrastructure, and core financial/healthcare processing environments. |
| **Secure Enclave** | An isolated, hardware-secured processing execution environment within a main CPU that protects code and data loaded inside it. | In-memory cryptographic keys, session tokens, biometric data, and sensitive application code during active runtime execution. | Moderate (built directly into modern enterprise CPU architectures like Intel SGX or ARM TrustZone). | Mobile clinician tablets, mobile EHR companion apps, and specialized high-security microservices. |
| **KMS (Key Management Software)** | A software-defined application or service layer that manages, provisions, and rotates cryptographic keys across enterprise data stores. | Application-tier encryption keys, database column keys, and cloud storage bucket secrets. | Low to Moderate (often licensed per service tier or included natively within cloud platforms). | Cloud environments, application server tiers, and distributed microservices architectures. |

---

# Part 2 - MedDefense Key Management Design

## 1. Key Storage Locations

| Key Type | Storage Location |
|---|---|
| **Patient Database TDE Master Key** | Stored within a dedicated Cloud HSM service (or on-premises HSM appliance) to isolate master encryption keys from the database instance itself. |
| **Backup Storage Encryption Key** | Managed via cloud storage service KMS or enterprise backup server hardware vault (NAS-01). |
| **Portal TLS Private Key** | Stored within the secure web server local file directory with restricted root read-only permissions and backed up in an encrypted offline key vault. |
| **VPN Tunnel Pre-Shared Keys / Certificates** | Maintained within the enterprise firewall and VPN gateway secure non-volatile memory and configuration storage. |

---

## 2. Role-Based Access Control (RBAC)

| Role | Authorized Responsibilities |
|---|---|
| **Lead Security Engineer / CISO** | Authorized to manage HSM administrative policies, execute emergency key revocations, and authorize key lifecycle rotations. |
| **Database Administrator (DBA)** | Has operational access to use encrypted database tables via TDE bindings but has zero access to unwrap or view raw cryptographic master keys. |
| **Systems Administrator** | Manages TLS certificate file deployment and backup storage volume mounts without direct visibility into underlying secret key material. |

---

## 3. Key Rotation Lifecycle & Process

### Rotation Frequency

| Key Type | Rotation Schedule |
|---|---|
| **TLS Private Keys** | Rotated every 90 days (aligned with short-lived certificate lifecycles). |
| **Database Master Encryption Keys** | Rotated annually or immediately following any suspected personnel transition. |
| **Backup Encryption Keys** | Rotated annually. |

### Rotation Process

Automated through key management orchestration scripts that:

1. Generate a new key version.
2. Re-encrypt data encryption keys or storage targets incrementally.
3. Safely archive older key versions.
4. Maintain older keys for decryption-only fallback during data retention periods.

---

## 4. Key Compromise Incident Response

If an encryption key is compromised:

| Step | Action |
|---|---|
| **1. Immediate Revocation** | Deactivate and revoke the compromised key within the KMS or HSM immediately to halt further unauthorized decryption operations. |
| **2. Emergency Key Generation** | Provision a fresh cryptographic key pair or master key across all affected data tiers. |
| **3. Data Re-encryption** | Execute bulk re-encryption pipelines for affected database tables, storage volumes, or TLS endpoints using the new key. |
| **4. Forensic Audit** | Review access logs to determine the blast radius and duration of the key exposure, satisfying regulatory breach reporting requirements. |

---

## 5. Key Loss & Disaster Recovery

### Recovery Procedure

If a key is lost due to hardware failure or administrative error without a valid backup:

- Restore key material from encrypted, air-gapped hardware key backups stored in offsite secure vaults.
- Utilize multi-person quorum authorization through a split-knowledge ceremony.

### Key Escrow

For enterprise database and backup keys:

- A strict key escrow policy is enforced.
- Administrative key shards are divided among multiple senior security officers.
- Shamir's Secret Sharing scheme is used to prevent permanent catastrophic data loss if a single administrator becomes unavailable.

---

# Part 3 - The HSM Decision

## 1. Cost Estimation

Using a cloud-based HSM-as-a-Service model:

- Estimated cost: **$1 - $2 per key per month**
- Core enterprise keys managed:
  - Database master keys
  - Backup encryption keys
  - Internal PKI root keys

Estimated operational cost:

> **Approximately $24 - $50 per month total**

---

## 2. Risk Evaluation & Comparison

According to the MedDefense Risk Register (1x03):

- Unmanaged software key storage or plaintext key exposure carries a **high severity rating**.
- Potential impacts include:
  - Catastrophic multi-tenant patient data exposure.
  - Regulatory penalties under HIPAA.
  - Severe reputational damage.
  - Large-scale financial losses.

The **Annualized Loss Expectancy (ALE)** of a complete database compromise caused by exposed software keys can easily reach **hundreds of thousands of dollars**.

---

## 3. Final Recommendation

The investment in HSM technology is fully justified.

For a relatively small recurring cost:

> **~$300/year**

Cloud HSM-as-a-Service provides:

- Elimination of software-level key theft risks on database servers.
- Stronger separation between encrypted data and encryption keys.
- A hardened hardware-based trust boundary.
- Better compliance alignment with healthcare security frameworks.

**Recommendation:**  
Deploy cloud HSM-backed key management for all critical MedDefense encryption keys, especially database master keys, backup encryption keys, and internal PKI root keys.
