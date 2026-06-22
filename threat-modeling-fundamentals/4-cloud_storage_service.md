# Cloud Storage Service — Threat Modeling & Risk Analysis

---

## 1. Attack Surface Analysis

The cloud storage system exposes multiple entry points that can be exploited by attackers.

---

### 1.1 Entry Points

| Entry Point | Description | Risk Level |
|------------|-------------|------------|
| File Upload API | Users upload files to cloud storage | **High** |
| File Download API | Users retrieve stored files | High |
| Public Share Links | Unauthenticated file access via links | **Very High** |
| Authentication API | Login / token issuance | High |
| File Sharing API | Share files with other users | High |
| Versioning API | Access previous file versions | Medium |
| Admin Panel | System management interface | **Very High** |
| Encryption Key Management | Key storage and retrieval system | **Very High** |

---

### 1.2 High-Risk Entry Points Summary

Most critical attack surfaces:
- Public share links (unauthenticated access)
- Admin panel (privileged access)
- Key management system (cryptographic security boundary)

---

## 2. Threat Modeling — Storing Encryption Keys in Database

### 2.1 Proposed Design (Problematic)

Developer suggestion:
> Store encryption keys in the same database as encrypted files for convenience.

---

### 2.2 Why This is a Security Problem

If encryption keys and encrypted data are stored together:

- A single database breach exposes both data AND keys
- Encryption becomes effectively useless
- Attackers can decrypt all files immediately

---

### 2.3 STRIDE Threats Introduced

| STRIDE Category | Explanation |
|----------------|-------------|
| **Information Disclosure** | Attackers gain both encrypted data and keys, enabling full decryption |
| **Tampering** | Attackers can modify files and re-encrypt them using stolen keys |
| **Elevation of Privilege** | Access to keys enables full control over encryption system |
| **Repudiation** | No reliable audit of who accessed or used keys |
| **Spoofing** | Attackers can impersonate legitimate encryption services |

---

### 2.4 Real Attack Scenario

1. Attacker exploits SQL injection or database breach  
2. Gains access to database dump  
3. Retrieves encrypted files + encryption keys  
4. Decrypts all user data offline  
5. Optionally modifies and re-encrypts files  

---

### 2.5 Correct Approach (Mitigation)

- Store keys in a **dedicated Key Management Service (KMS)**  
- Use hardware security modules (HSMs)  
- Apply envelope encryption (data key + master key separation)  
- Restrict key access using IAM policies  

---

## 3. Risk Matrix (Top 5 Threats)

Risk score formula:
Risk = Likelihood (1–5) × Impact (1–5)

---

---

### 3.1 Risk Table

| Threat | Likelihood | Impact | Risk Score | Risk Level |
|--------|------------|--------|------------|------------|
| Public Link Exposure | 5 | 5 | 25 | Critical |
| File Upload Malware Injection | 4 | 5 | 20 | Critical |
| Compromised Authentication | 4 | 5 | 20 | Critical |
| Encryption Key Exposure (DB stored keys) | 4 | 5 | 20 | Critical |
| Unauthorized File Sharing Abuse | 3 | 4 | 12 | High |

---

### 3.2 Threat Breakdown

---

## Threat 1 — Public Link Exposure

- **Likelihood:** 5 (easy to guess/leak links)  
- **Impact:** 5 (full file access)  
- **Risk:** 25 (Critical)  

**Mitigation:**
- Expiring signed URLs  
- Token-based access control  
- Rate limiting  

---

## Threat 2 — Malicious File Upload

- **Likelihood:** 4  
- **Impact:** 5  

**Mitigation:**
- File type validation  
- Antivirus scanning  
- Sandbox execution environment  

---

## Threat 3 — Authentication Compromise

- **Likelihood:** 4  
- **Impact:** 5  

**Mitigation:**
- MFA  
- Secure session management  
- Login anomaly detection  

---

## Threat 4 — Encryption Key Exposure

- **Likelihood:** 4  
- **Impact:** 5  

**Mitigation:**
- Use external KMS/HSM  
- Never store keys in DB  
- Key rotation policies  

---

## Threat 5 — File Sharing Abuse

- **Likelihood:** 3  
- **Impact:** 4  

**Mitigation:**
- Access control checks  
- Sharing audit logs  
- User-level permissions  

---

## 4. Conclusion

The cloud storage system has a large attack surface, with **public links, file uploads, and key management being the most critical risks**.

Key security principles:

- Never store encryption keys with encrypted data  
- Use centralized key management systems (KMS/HSM)  
- Secure public link access with expiration and tokens  
- Validate and sandbox all uploaded content  

---
