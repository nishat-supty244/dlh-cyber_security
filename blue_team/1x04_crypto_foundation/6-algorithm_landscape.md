# 6. The Algorithm Landscape

## Algorithm Reference Table

| Algorithm | Type | Key / Output Size | Primary Use Case | Status | Why Deprecated / Broken | MedDefense Usage |
|---|---|---|---|---|---|---|
| AES-128 | Symmetric | 128 bits | Symmetric encryption for data at rest and in transit | Current | N/A | Standard EHR database column encryption and general internal data transport. |
| AES-192 | Symmetric | 192 bits | High-security symmetric encryption | Current | N/A | High-tier sensitive patient records and administrative configuration vaults. |
| AES-256 | Symmetric | 256 bits | Maximum security symmetric encryption for highly sensitive payloads | Current | N/A | Core EHR database encryption, backups, and secure TLS 1.3 tunnels. |
| DES | Symmetric | 56 bits (effective) | Legacy block cipher | Broken | Key size is far too small, making it trivial to brute-force on modern commodity hardware within minutes. | Legacy medical device interfaces (found in 1x02 legacy audit; scheduled for immediate retirement). |
| 3DES | Symmetric | 112 or 168 bits | Legacy block cipher | Deprecated | Suffers from small block size vulnerabilities (Sweet32 attack) and slow performance compared to AES. | Legacy billing gateway connectors; currently being phased out for AES-256. |
| ChaCha20-Poly1305 | Symmetric | 256 bits | High-speed authenticated encryption | Current | N/A | Mobile EHR companion apps on low-power mobile devices lacking hardware AES acceleration. |
| RC4 | Symmetric | 40 to 208 bits (typically 128) | Legacy stream cipher | Broken | Has severe cryptographic biases in its keystream generation that allow plaintext recovery. | Legacy Kerberos ticket exchange (Finding 018); disabled during hardening. |
| Blowfish | Symmetric | Variable (32 to 448 bits) | Symmetric block cipher | Deprecated | Small 64-bit block size makes it vulnerable to birthday attacks on large volumes of encrypted data. | Legacy password management utility scripts (replaced by bcrypt/Argon2). |
| RSA-2048 | Asymmetric | 2048 bits | Asymmetric encryption, digital signatures, and key exchange | Current | N/A | Legacy web portal certificates and standard TLS termination. |
| RSA-4096 | Asymmetric | 4096 bits | High-security long-term digital signatures and root certificates | Current | N/A | Root Certificate Authority (CA) and medical device firmware signing keys. |
| ECC P-256 | Asymmetric | 256 bits | Efficient asymmetric cryptography and key exchange | Current | N/A | IoT medical bedside monitors and mobile clinician tablets. |
| ECC P-384 | Asymmetric | 384 bits | High-assurance asymmetric cryptography | Current | N/A | Internal enterprise PKI and secure API gateways. |
| Diffie-Hellman | Asymmetric | 2048+ bits | Secure key exchange over insecure channels | Current | N/A | Legacy VPN tunnels and older TLS handshakes. |
| ECDHE | Asymmetric | 256/384 bits | Perfect Forward Secrecy (PFS) key exchange | Current | N/A | Modern TLS 1.3 connections across all web portals and EHR endpoints. |
| MD5 | Hash | 128 bits | Cryptographic hashing / checksums | Broken | Collision vulnerability is trivial due to the birthday paradox, allowing attackers to forge hashes. | Legacy file downloads and historical asset checksum tracking (replaced by SHA-256). |
| SHA-1 | Hash | 160 bits | Cryptographic hashing and legacy digital signatures | Broken | Collision attacks were successfully demonstrated (SHAttered), rendering it unsafe for integrity or signatures. | Legacy code-signing certificates and older audit log verification tools. |
| SHA-256 | Hash | 256 bits | Cryptographic hashing, file integrity, and certificate signing | Current | N/A | File integrity verification scripts (`3-hash_verify.sh`), backup checksums, and TLS certificates. |
| SHA-512 | Hash | 512 bits | High-security cryptographic hashing | Current | N/A | Long-term secure audit log integrity chains and backend compliance stores. |
| SHA-3 | Hash | 224/256/384/512 bits | Modern cryptographic hashing (Keccak sponge construction) | Current | N/A | Future-proofing next-generation cryptographic architectures and high-assurance logging. |
| PBKDF2 | KDF | Variable output | Password hashing and key derivation | Current | N/A | Legacy web application login portals and database connection string generation. |
| bcrypt | KDF | Variable output | Password hashing utilizing Blowfish cipher core | Current | N/A | Internal application user credential tables and legacy authentication databases. |
| Argon2 | KDF | Variable output | Memory-hard password hashing (PHC winner) | Current | N/A | Recommended standard for all primary MedDefense user credential and database stores. |
| scrypt | KDF | Variable output | Memory-hard key derivation function | Current | N/A | Advanced backup encryption passphrase generation and key expansion. |

---

# MedDefense Crypto Gap Analysis

Comparing MedDefense's current posture (derived from Task 0 baseline audits and Phase 1 Finding 018) against secure cryptographic standards reveals several critical vulnerabilities where deprecated or broken algorithms remain active.

---

## 1. Active Directory Kerberos Encryption (Finding 018)

### Current State

Active Directory supports and permits legacy RC4 encryption for Kerberos service tickets.

### Why Deficient

RC4 is a broken stream cipher with known statistical biases, and its internal reliance on MD4-based structures makes credentials vulnerable to immediate extraction and offline cracking.

### Recommended Replacement

- Enforce AES-256 exclusively for Kerberos ticket generation.
- Completely disable RC4 and DES across all domain controllers.

---

## 2. Legacy Medical Device Interface Ciphers

### Current State

Older infusion pumps and bedside monitoring hubs communicate via DES block ciphers.

### Why Deficient

DES has a 56-bit effective key length, which can be brute-forced on modern hardware in minutes, exposing patient telemetry to interception.

### Recommended Replacement

Upgrade all device firmware and communication middleware to utilize:

- AES-128
- AES-256

---

## 3. Application Password Storage Databases

### Current State

Certain legacy internal web applications store user passwords using unsalted, single-pass MD5/MD4 structures.

### Why Deficient

Unsalted hashes combined with weak algorithms allow:

- Rainbow table lookups
- High-speed GPU brute-force attacks
- Immediate password recovery

### Recommended Replacement

Migrate all credential storage tables to:

- Argon2id
- Calibrated memory cost
- Appropriate time cost factor
- Unique salts per password

---

## 4. Software Update and Firmware Verification

### Current State

Some legacy medical imaging workstations verify software patches using SHA-1 checksums.

### Why Deficient

SHA-1 is cryptographically broken due to proven collision attacks such as SHAttered. Attackers can create malicious firmware updates with identical SHA-1 hashes as legitimate software.

### Recommended Replacement

Transition all:

- Software distribution channels
- Patch validation scripts
- Firmware verification checks

to:

- SHA-256 cryptographic hashing

---

# Summary of Cryptographic Recommendations

| Area | Current Weak Algorithm | Risk | Recommended Standard |
|---|---|---|---|
| Kerberos Authentication | RC4 | Credential exposure and offline cracking | AES-256 |
| Medical Device Communication | DES | Brute-force attacks and data interception | AES-128/AES-256 |
| Password Storage | MD5/MD4 | Fast cracking and rainbow table attacks | Argon2id |
| Software Integrity Verification | SHA-1 | Collision attacks and firmware tampering | SHA-256 |
| Modern Encryption | AES-256, ChaCha20-Poly1305 | Secure | Continue usage |
| Key Exchange | ECDHE | Secure with Perfect Forward Secrecy | Continue usage |

---

# Conclusion

MedDefense's cryptographic environment requires immediate modernization by eliminating broken algorithms and enforcing current industry standards. Legacy algorithms such as DES, RC4, MD5, and SHA-1 introduce significant security risks that could compromise patient data confidentiality, integrity, and availability.

The recommended cryptographic baseline is:

- **AES-256** for sensitive data encryption.
- **ECDHE** for secure key exchange with Perfect Forward Secrecy.
- **SHA-256/SHA-512** for integrity verification.
- **Argon2id** for password protection.
- **RSA-4096/ECC P-384** for high-assurance PKI operations.

Implementing these controls will align MedDefense with modern cybersecurity standards and strengthen protection of electronic health records, medical devices, and critical healthcare infrastructure.
