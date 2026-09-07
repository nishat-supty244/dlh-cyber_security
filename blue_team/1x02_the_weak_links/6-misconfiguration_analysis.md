# Misconfiguration Findings Analysis

Misconfigurations are security weaknesses caused by incorrect system configuration rather than software defects. Because they are administrative or deployment errors, they generally **do not receive CVE identifiers**, yet they can introduce risks equal to—or greater than—many software vulnerabilities.

---

# Finding 003

## Asset Information

| Field | Details |
|-------|---------|
| **Finding ID** | Finding 003 |
| **Host** | 10.10.2.11 (ehr-db-01) |
| **Component** | PostgreSQL Database Server |

### Misconfiguration

PostgreSQL is configured to accept connections from any IP address within the internal network.

Configuration includes:

- `listen_addresses = '*'`
- `pg_hba.conf` permits connections from `10.10.0.0/16`

No restrictive firewall rules or network ACLs are present.

---

### Why There Is No CVE

This issue results from an insecure database configuration rather than a flaw in PostgreSQL itself.

The software behaves as designed, but the administrator has configured it insecurely.

---

### Severity Assessment

**Critical**

Because the database stores Electronic Health Records (EHR), unrestricted internal access significantly increases the risk of unauthorized access to Protected Health Information (PHI).

---

### Cross-Reference

**1x00 T7 – Network Scan Finding**

---

### Comparable CVE Risk

Comparable to:

- **Finding 001**
- **CVE-2021-44790**
- **CVSS 9.8 (Critical)**

Although the Apache vulnerability requires exploitation, this database misconfiguration exposes sensitive information without requiring a complex exploit.

---

# Finding 006

## Asset Information

| Field | Details |
|-------|---------|
| **Finding ID** | Finding 006 |
| **Host** | 10.10.2.15 (billing-srv-01) |
| **Component** | MySQL Database |

### Misconfiguration

MySQL is configured with:

```
bind-address = 0.0.0.0
```

This allows connections from every interface across the internal network.

---

### Why There Is No CVE

The database software functions correctly.

The vulnerability arises from an insecure deployment configuration chosen by administrators.

---

### Severity Assessment

**High**

Any compromised internal system can directly attempt to access billing and financial records.

---

### Cross-Reference

**1x00 T7 – Network Scan Finding**

---

### Comparable CVE Risk

Comparable to:

- **Finding 002**
- **CVE-2019-0211**
- **CVSS 7.8**

Unlike privilege escalation vulnerabilities, this exposure removes the need for local code execution before attempting database access.

---

# Finding 007

## Asset Information

| Field | Details |
|-------|---------|
| **Finding ID** | Finding 007 |
| **Host** | 10.10.2.20 (ad-dc-01) |
| **Component** | Active Directory Domain Controller |

### Misconfiguration

The Domain Controller has:

- LDAP signing disabled
- SMBv1 enabled

---

### Why There Is No CVE

This is a security policy configuration issue rather than a software vulnerability.

Windows supports these settings for compatibility purposes.

---

### Severity Assessment

**High**

Attackers may exploit these settings to perform:

- LDAP relay attacks
- Credential theft
- Directory manipulation
- Lateral movement

---

### Cross-Reference

**1x00 T5 – Security Control Gap**

---

### Comparable CVE Risk

Comparable to:

- **CVE-2017-0144 (EternalBlue)**
- **CVSS 8.1**

Although the underlying cause differs, both issues enable enterprise-wide compromise.

---

# Finding 009

## Asset Information

| Field | Details |
|-------|---------|
| **Finding ID** | Finding 009 |
| **Host** | 10.10.2.15 (billing-srv-01) |
| **Component** | OpenSSH |

### Misconfiguration

SSH permits:

- Password-based authentication
- No account lockout policy

---

### Why There Is No CVE

OpenSSH is operating correctly.

The weakness results from missing security hardening and administrative policy.

---

### Severity Assessment

**High**

The configuration enables:

- Password guessing
- Brute-force attacks
- Credential stuffing

without automated lockout protection.

---

### Cross-Reference

**1x00 T3 – Server Hardening Observation**

---

### Comparable CVE Risk

Comparable to authentication bypass vulnerabilities because attackers may gain access without exploiting software flaws.

---

# Finding 015

## Asset Information

| Field | Details |
|-------|---------|
| **Finding ID** | Finding 015 |
| **Host** | 10.10.2.41 (NAS-01) |
| **Component** | Synology NAS Backup Storage |

### Misconfiguration

The NAS management interface is accessible throughout the internal network via:

- HTTP
- HTTPS

Additionally, backup data is stored without encryption.

---

### Why There Is No CVE

This issue results from storage architecture and deployment choices rather than software defects.

---

### Severity Assessment

**Medium**

Although exploitation is straightforward, the primary concern is exposure of centralized backup data containing sensitive organizational information.

---

### Cross-Reference

**1x00 T5 – Data Protection Control Gap**

---

### Comparable CVE Risk

Comparable to:

- **CVE-2020-1938 (Ghostcat)**
- **CVSS 9.8**

Both vulnerabilities can expose large volumes of sensitive organizational data.

---

# Finding 016

## Asset Information

| Field | Details |
|-------|---------|
| **Finding ID** | Finding 016 |
| **Host** | Multiple Philips IntelliVue Patient Monitors (10.10.3.10–10.10.3.32) |
| **Component** | Medical IoT Devices |

### Misconfiguration

Patient monitors expose:

- Web management interfaces
- HL7 communication ports

These services are accessible from the entire internal network without additional authentication controls beyond network connectivity.

---

### Why There Is No CVE

The weakness is caused by insecure deployment and insufficient network segmentation rather than a software defect.

---

### Severity Assessment

**Medium**

The broad exposure of medical device interfaces increases the risk of unauthorized access to clinical systems.

---

### Cross-Reference

**1x00 T7 – Medical IoT Network Exposure**

---

### Comparable CVE Risk

Comparable to:

- **Finding 010**
- **BD Alaris Infusion Pump Vulnerabilities**
- **CVSS 7.5**

Both expose critical medical devices to network-based attacks.

---

# Why Misconfigurations Matter

Many organizations mistakenly believe that a clean CVE scan means their environment is secure.

This assumption is incorrect.

Automated vulnerability scanners primarily detect **software vulnerabilities** that have assigned **CVE identifiers**. They typically do **not** identify many administrative or architectural weaknesses.

Examples include:

- Unrestricted database bindings
- Default administrative credentials
- Weak authentication policies
- Missing network segmentation
- Unencrypted backup storage
- Insecure protocol configurations

These issues often have **no CVE identifier**, yet they may be exploited just as easily as software vulnerabilities.

---

# Conclusion

The statement:

> **"Our CVE scan shows nothing critical, we are secure."**

provides a dangerous false sense of security.

While CVE-based vulnerability scanning is an important component of security assessment, it addresses only software defects. It does not identify many high-risk configuration errors, insecure deployment practices, or architectural weaknesses.

The MedDefense assessment demonstrates that critical risks—including unrestricted database access, weak authentication policies, exposed medical devices, and unencrypted backup storage—exist independently of CVE identifiers. These misconfigurations can significantly increase the organization's attack surface and should be managed with the same priority as software vulnerabilities through secure configuration management, hardening, segmentation, and continuous security reviews.
