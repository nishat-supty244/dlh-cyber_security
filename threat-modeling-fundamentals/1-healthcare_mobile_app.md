# Healthcare Mobile App — Threat Modeling & Security Analysis

---

## 1. Introduction

This document presents a threat modeling analysis for a healthcare mobile application that enables patients to:

- View medical records  
- Schedule appointments  
- Message healthcare providers  
- Request prescription refills  

The system handles highly sensitive medical data and must meet strict confidentiality, integrity, and availability requirements similar to HIPAA-grade systems.

The analysis uses:
- CIA Triad (asset criticality)
- STRIDE threat modeling
- Prioritized security controls
- Real-world constraints (cost, complexity, usability)

---

## 2. System Overview

### 2.1 Architecture Diagram

```text
+------------------------+
|   iOS / Android App    |
+-----------+------------+
            |
            | HTTPS (REST API)
            |
+-----------v------------+
|     API Backend        |
| (Auth + Business Logic)|
+-----------+------------+
            |
            | Secure DB Queries
            |
+-----------v------------+
|   Cloud Database       |
| (Medical Records,     |
|  Messages, Users)     |
+-----------+------------+
            |
            | Secure Integration
            |
+-----------v------------+
| Hospital Systems       |
| (EHR / Labs / Pharmacy)|
+------------------------+
```

---

## 3. Most Critical Asset (CIA Triad Analysis)

### 3.1 Critical Asset Identified

**Electronic Health Records (EHR) / Patient Medical Data**

---

### 3.2 CIA Evaluation

| CIA Component | Analysis |
|--------------|----------|
| **Confidentiality** | Highest priority. Medical records contain sensitive PHI. Exposure leads to privacy violations and legal penalties. |
| **Integrity** | Critical. Incorrect medical data (allergies, prescriptions) can cause life-threatening outcomes. |
| **Availability** | High importance. Doctors require real-time access for treatment decisions. |

---

### 3.3 Conclusion

The **EHR system is the most critical asset**, with **Confidentiality as the top priority**, followed by Integrity due to direct patient safety risks.

---

## 4. STRIDE Analysis — Messaging Feature

### 4.1 Feature Description

The messaging feature enables communication between patients and healthcare providers, including:

- Symptoms reporting  
- Prescription instructions  
- Medical advice  

This feature is high-risk due to sensitive data exchange and clinical dependency.

---

## Threat 1 — Spoofing (Impersonation of Provider)

### Description
An attacker impersonates a healthcare provider by stealing credentials.

### Attack Scenario
1. Attacker obtains provider login via phishing.
2. Logs into system as doctor.
3. Sends fake medical instructions to patients.

### Impact
- Incorrect treatment decisions  
- Patient harm  
- Legal liability  

### Likelihood
Medium (healthcare credentials are high-value targets)

### Mitigation
- Enforce MFA for providers  
- Use role-based identity verification (RBAC + license validation)  
- Device binding for provider accounts  

---

## Threat 2 — Tampering (Message Modification)

### Description
Messages are altered during transmission or storage.

### Attack Scenario
1. Patient sends message: “Take 5mg medication.”
2. Attacker intercepts API request.
3. Message is modified to “Take 50mg medication.”

### Impact
- Medical overdose risk  
- Incorrect treatment  
- Legal consequences  

### Likelihood
Low–Medium

### Mitigation
- End-to-end encryption (E2EE)  
- TLS 1.3 for transport  
- HMAC/message signing  
- Immutable message storage  

---

## Threat 3 — Repudiation (Denial of Action)

### Description
Users deny sending or receiving medical messages.

### Attack Scenario
1. Provider sends prescription update.
2. Patient denies receiving it.
3. No audit trail exists to verify.

### Impact
- Legal disputes  
- Loss of accountability  
- Clinical risk  

### Likelihood
Medium

### Mitigation
- Tamper-proof audit logs  
- Digital signatures for messages  
- Timestamped message hashing  

---

## Threat 4 — Information Disclosure

### Description
Unauthorized access to private medical messages.

### Attack Scenario
1. Attacker steals session token.
2. Accesses API endpoints.
3. Retrieves private patient-provider messages.

### Impact
- Privacy breach  
- Regulatory violations  
- Identity theft  

### Likelihood
Medium

### Mitigation
- Strong authentication + MFA  
- Strict API authorization (RBAC)  
- Encryption at rest  
- Token expiration policies  

---

## 5. Security Controls (Prioritized)

### Control 1 — Multi-Factor Authentication (MFA)

**Why first:** Prevents credential-based attacks (Spoofing).

- MFA for all users  
- OAuth2 / OpenID Connect  
- Device verification for providers  

---

### Control 2 — Role-Based Access Control (RBAC)

**Why second:** Ensures only authorized access to medical data.

- Patient / Doctor / Admin roles  
- API-level authorization checks  
- Least privilege enforcement  

---

### Control 3 — End-to-End Encryption (E2EE)

**Why third:** Protects sensitive messaging data.

- AES-256 encryption  
- Secure key exchange  
- Client-side encryption  

---

### Control 4 — Secure Audit Logging

**Why fourth:** Ensures accountability and legal compliance.

- Append-only logs  
- Hash-chained records  
- SIEM integration  

---

### Control 5 — API Security Controls

**Why fifth:** Prevents injection and abuse.

- Input validation  
- Rate limiting  
- Schema validation  
- WAF protection  

---

## 6. Conclusion

The healthcare application processes highly sensitive patient data where **Confidentiality and Integrity are critical** due to legal and safety implications.

The messaging system introduces serious STRIDE risks, particularly spoofing and tampering, which can directly affect patient health outcomes.

A layered security approach is required, prioritizing authentication, access control, encryption, and auditability while balancing usability and healthcare operational constraints.

---
