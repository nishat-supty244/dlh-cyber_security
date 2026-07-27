# Task Report: Cryptographic Infrastructure Hardening — Asymmetric Engines and Hash Laboratories

## Overview

As part of the infrastructure hardening initiative for **MedDefense**, this report consolidates the findings, experimental implementations, and security evaluations performed across asymmetric cryptographic systems and hashing laboratories.

The work establishes secure key management foundations, analyzes key size and computational limitations, and introduces automated file integrity verification mechanisms to strengthen the organization's cryptographic posture.

---

# 1. Asymmetric Engine Findings (Task 2)

## RSA-2048 vs. ECC P-256 Keys

- **RSA-2048 private key size:** **1,708 bytes**
- **ECC P-256 private key size:** **302 bytes**
- **Size ratio:** **5.6 : 1**

ECC provides equivalent security while requiring significantly smaller keys because its security relies on the computational hardness of the **Elliptic Curve Discrete Logarithm Problem (ECDLP)**.

### Security Implication

ECC is particularly well suited for resource-constrained healthcare devices, including:

- Bedside patient monitors
- BD Alaris infusion pumps
- IoT medical devices
- Mobile healthcare equipment

Its smaller keys reduce:

- Storage requirements
- Network bandwidth usage
- CPU utilization
- Power consumption

---

## RSA Modulus Limitations

A direct attempt to encrypt a **100 MB** test file using RSA resulted in the following error:

```text
Error: Data greater than mod len
```

### Explanation

RSA cannot encrypt large datasets directly because:

- The plaintext must be smaller than the RSA modulus.
- Encryption is computationally expensive.
- RSA is designed for small amounts of data such as encryption keys or digital signatures.

Consequently, RSA is unsuitable for protecting bulk medical records or database backups.

---

## The Hybrid Cryptographic Model

Modern secure communication protocols (e.g., TLS) solve RSA's limitations using a **hybrid cryptographic model**.

### TLS Workflow

1. Client and server authenticate using asymmetric cryptography.
2. A secure session key is exchanged.
3. The connection switches to a high-speed symmetric cipher.
4. Bulk application data is encrypted using symmetric encryption.

### Common Algorithms

| Stage | Algorithm |
|--------|-----------|
| Authentication | RSA or ECC |
| Key Exchange | ECDHE / RSA |
| Bulk Encryption | AES-GCM |

### Security Benefit

This model provides:

- Secure authentication
- Perfect Forward Secrecy (when ECDHE is used)
- High-speed encryption
- Efficient protection of Electronic Health Records (EHR)

---

# 2. Hash Laboratory Findings (Task 3)

## The Avalanche Effect

Two nearly identical strings were hashed:

```text
MedDefense
MedDefense1
```

### Results

| Algorithm | Characters Changed | Percentage |
|-----------|-------------------:|-----------:|
| SHA-256 | 62 / 64 | 97% |
| MD5 | 30 / 32 | 94% |

### Observation

Changing only a single character produced dramatically different hash outputs.

This demonstrates the **Avalanche Effect**, one of the defining characteristics of secure cryptographic hash functions.

---

## Collision Vulnerability & Birthday Problem

### Hash Sizes

| Algorithm | Output Length |
|-----------|--------------:|
| MD5 | 128 bits |
| SHA-256 | 256 bits |

### Birthday Attack Complexity

A hash with **N** output bits typically requires approximately:

```text
2^(N/2)
```

operations to discover a collision.

Therefore:

| Algorithm | Approximate Collision Work |
|-----------|---------------------------:|
| MD5 | 2^64 |
| SHA-256 | 2^128 |

### Security Implication

Legacy protocols relying on weak hash algorithms (such as **MD5**) face substantially increased collision risk.

Examples include:

- Older Kerberos implementations
- RC4/MD5 authentication mechanisms
- Legacy enterprise authentication protocols

---

## Rainbow Table Defense Through Salting

### Unsalted Password

```text
password123
```

This password is easily cracked using publicly available rainbow tables such as those maintained by CrackStation.

### Salted Password

```text
s4lt9xQ2:password123
```

Introducing a unique random salt ensures that:

- Every password hash is unique.
- Precomputed rainbow tables become ineffective.
- Bulk credential compromise is significantly more difficult.

### Security Benefit

Salting protects against:

- Rainbow table attacks
- Mass password cracking
- Duplicate password identification

---

## Key Stretching

Modern password hashing algorithms intentionally increase computational cost to slow brute-force attacks.

### Common Algorithms

- bcrypt
- PBKDF2
- Argon2id (memory-hard)

These algorithms employ configurable:

- Cost factors
- Iteration counts
- Memory requirements

to significantly increase resistance to GPU-accelerated password cracking.

### Active Directory Consideration

Active Directory's legacy **NTLM** authentication stores password hashes using **MD4**, which no longer provides adequate protection without additional hardening controls.

---

# 3. Automation and Repository Status

## Integrity Verification Script

**Script Name**

```text
3-hash_verify.sh
```

**Repository Location**

```text
blue_team/1x04_crypto_foundation/
```

### Features

The script:

- Validates input file paths.
- Computes SHA-256 checksums.
- Compares expected and calculated hashes.
- Reports verification status.
- Returns accurate exit codes for automation.

### Output

```text
INTEGRITY OK
```

or

```text
INTEGRITY FAILED
```

### Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| 0 | Verification successful |
| 1 | Verification failed |

---

## Git Synchronization

Local tracking branches have been synchronized with the remote repository:

```text
dlh-cyber_security
```

All laboratory reports, scripts, and supporting documentation are now:

- Version controlled
- Backed up remotely
- Traceable through commit history
- Ready for collaborative development

---

# Summary

## Key Findings

- ECC P-256 provides equivalent security to RSA-2048 while using keys approximately **5.6× smaller**, making it ideal for constrained healthcare devices.
- RSA cannot efficiently encrypt large datasets, reinforcing the need for hybrid cryptographic architectures.
- TLS combines asymmetric and symmetric cryptography to achieve both strong authentication and efficient bulk data encryption.
- Cryptographic hash functions exhibit a strong Avalanche Effect, ensuring even minimal input changes produce significantly different outputs.
- MD5 remains vulnerable to collision attacks, whereas SHA-256 offers substantially stronger resistance.
- Salting and key stretching effectively mitigate rainbow table attacks and GPU-accelerated password cracking.
- The `3-hash_verify.sh` automation script provides reliable SHA-256 integrity verification with standardized exit codes.
- All cryptographic laboratory artifacts have been synchronized to the remote Git repository, ensuring secure version control and reproducibility.

---

# Conclusion

The asymmetric cryptography and hashing laboratories demonstrate the practical foundations of modern cryptographic security within the MedDefense environment. Experimental validation confirms the advantages of ECC for constrained systems, the necessity of hybrid encryption for large-scale healthcare data, and the importance of robust password protection through salting and key stretching. Automated integrity verification and disciplined version control further enhance the organization's ability to maintain trustworthy, reproducible, and secure cryptographic operations.
