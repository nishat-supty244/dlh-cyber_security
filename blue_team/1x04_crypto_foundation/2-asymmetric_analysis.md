# The Asymmetric Engine

## Overview
As a security analyst hardening MedDefense's infrastructure, establishing an asymmetric cryptographic foundation is critical for secure key exchange, entity authentication, and session negotiation. While symmetric encryption serves as the high-throughput workhorse for bulk electronic health records (EHR), asymmetric algorithms solve the fundamental key distribution problem. This document details the implementation, experimentation, performance/size constraints, and algorithmic governance across MedDefense's systems.

---

## Part 1: RSA Key Generation and Encryption

### Commands and Workflow
To establish our RSA asymmetric baseline, we generate a 2048-bit RSA key pair using OpenSSL, extract the public key, and perform trial encryption/decryption on a small patient test record (`patient_test.txt`):

```bash
# 1. Generate RSA-2048 private key
openssl genrsa -out rsa_private.pem 2048

# 2. Extract the public key
openssl rsa -in rsa_private.pem -pubout -out rsa_public.pem

# 3. Encrypt a small patient record using public key with OAEP padding
openssl pkeyutl -encrypt -in patient_test.txt -out patient_encrypted.rsa -pubin -inkey rsa_public.pem -pkeyopt rsa_padding_mode:oaep

# 4. Decrypt the ciphertext back using the private key
openssl pkeyutl -decrypt -in patient_encrypted.rsa -out patient_decrypted.txt -inkey rsa_private.pem -pkeyopt rsa_padding_mode:oaep
```

### Experimentation: Encrypting the 100MB Test File with RSA
When attempting to apply direct RSA encryption to our 100MB bulk test file (`testfile`), OpenSSL halts execution and outputs the following error:

```text
Error: Data greater than mod len
```

### Analysis & Real-World Implications
RSA cannot encrypt large files directly because its mathematical operations are strictly bounded by the key's modulus size (2048 bits / 256 bytes, minus padding overhead which leaves roughly 190–214 bytes of payload capacity). Because asymmetric ciphers rely on complex modular exponentiation rather than fast bitwise operations, encrypting gigabytes or megabytes of data directly is mathematically impossible and computationally prohibitive. In real-world enterprise infrastructure, this limitation mandates that RSA is never used for bulk data encryption; instead, its usage is strictly restricted to digital signatures, entity authentication, and securely exchanging temporary symmetric keys.

---

## Part 2: ECC Key Generation and Efficiency

### Commands and Workflow
To support low-power and resource-constrained medical endpoints, we generate an Elliptic Curve Cryptography (ECC) key pair utilizing the NIST P-256 curve (`prime256v1`):

```bash
# 1. Generate ECC P-256 private key
openssl ecparam -genkey -name prime256v1 -out ecc_private.pem

# 2. Extract the ECC public key
openssl ec -in ecc_private.pem -pubout -out ecc_public.pem
```

### File Size Comparison
Checking our generated private key file sizes via `ls -l rsa_private.pem ecc_private.pem` yields:
- `-rw------- 1 nishat nishat  302 Jul 27 13:44 ecc_private.pem`
- `-rw------- 1 nishat nishat 1708 Jul 27 13:40 rsa_private.pem`

- **RSA-2048 Private Key Size:** 1,708 bytes (~1.7 KB)
- **ECC P-256 Private Key Size:** 302 bytes (~0.3 KB)
- **Size Ratio:** Approximately **5.6:1** (scaling up to 7:1 depending on key format and container headers).

### Analysis: Why ECC Matters for MedDefense IoT & Medical Devices
ECC achieves cryptographic security equivalent to a traditional 2048-bit RSA key using a key size of only 256 bits, scaling exponentially better due to the mathematical hardness of the Elliptic Curve Discrete Logarithm Problem. Because the keys, signatures, and ciphertexts are drastically smaller, ECC requires significantly less CPU overhead, memory allocation, and battery power. This efficiency is vital for MedDefense's constrained medical IoT infrastructure—such as bedside Philips patient monitors and BD Alaris infusion pumps—which operate on restricted embedded processors.

---

## Part 3: The Hybrid Model

In modern enterprise architecture, TLS and secure communication protocols implement a hybrid encryption model that combines the strengths of both asymmetric and symmetric cryptography. The handshake phase utilizes asymmetric algorithms (such as ECDHE or RSA) to securely authenticate endpoints and exchange a temporary, random symmetric session key over an untrusted network. Once this secure channel is established, the connection switches entirely to symmetric encryption (such as AES-GCM) to handle all bulk data transfer efficiently. 

This combination is superior to using either approach alone because it eliminates the massive performance bottleneck and size constraints of pure asymmetric encryption while solving the insecure key distribution problem inherent in pure symmetric encryption. When a patient connects securely to MedDefense's patient portal via HTTPS, the TLS handshake phase (handled by ECDSA/ECDHE) negotiates the secure key exchange, while the bulk data transmission of sensitive EHR records is encrypted and authenticated via AES-256-GCM.

---

## Part 4: The Key Length and Algorithm Comparison Table

| Algorithm | Type | Key Lengths | Equivalent Security | Status | MedDefense Healthcare Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AES** | Symmetric | 128, 192, 256 bits | Matches key size (128/192/256-bit) | Approved | **Active Use** (Bulk EHR storage, database encryption, PACS archives) |
| **RSA** | Asymmetric | 2048, 3072, 4096 bits | 2048-bit $\approx$ 112-bit; 4096-bit $\approx$ 128-bit | Approved (2048+ bits) | **Active Use** (Legacy TLS server certificates, digital signatures) |
| **ECC** | Asymmetric | P-256, P-384, P-521 | P-256 $\approx$ 128-bit; P-384 $\approx$ 192-bit | Approved | **Preferred Use** (Patient portal TLS, medical IoT devices, smart pumps) |
| **DES** | Symmetric | 56 bits | 56 bits (Trivially brute-forced) | **Deprecated / Prohibited** | **Prohibited** (Active regulatory non-compliance violation) |
| **3DES** | Symmetric | 112 or 168 bits | 80 to 112 bits (Vulnerable to Sweet32 attack) | **Deprecated** (Phased out by NIST in 2023) | **Prohibited** (Scheduled for immediate decommissioning) |
| **ChaCha20-Poly1305** | Symmetric (AEAD) | 256 bits | 256-bit | Approved | **Active Use** (Mobile patient companion app, low-power TLS cipher suites) |
| **RC4** | Symmetric | 40 to 2048 bits | Broken (Vulnerable to severe stream bias attacks) | **Prohibited** | **Prohibited** (Strictly blocked and audited across all endpoints) |
