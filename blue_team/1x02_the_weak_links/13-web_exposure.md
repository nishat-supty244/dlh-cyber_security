# 13. The Web Exposure 

This analysis evaluates externally and internally exposed web-facing systems within the MedDefense environment. The assessment focuses on exposure level, identified vulnerabilities, attack scenarios, combined risk, and remediation priority.

---

# Host 1: web-srv-01 — Patient Portal

## Host Information

| Field | Details |
|---|---|
| **Host** | web-srv-01 |
| **IP Address** | 10.10.2.50 |
| **Asset Role** | Patient Portal Web Server |
| **Exposure Level** | Internet-facing |
| **Priority Ranking** | 1 (Highest Priority) |

---

# Identified Findings

| Finding ID | Vulnerability | Severity |
|---|---|---|
| Finding 005 | TLS 1.0 Support / BEAST & POODLE Vulnerabilities | CVSS 7.5 |
| Finding 012 | Missing Security Headers (CSP, X-Frame-Options) | Medium |
| Finding 013 | SSL Certificate Expiration in 23 Days Without Auto-Renewal | Medium |
| Finding 021 | HTTP TRACE Method Enabled | Medium |

---

# Combined Risk Assessment

## Risk Level: High

The patient portal is directly exposed to the public internet.

The combination of:

- Weak TLS configuration.
- Missing browser security protections.
- Expiring certificate management.
- Enabled unnecessary HTTP methods.

creates a significant risk to:

- Patient session confidentiality.
- User authentication security.
- Trust in online healthcare services.

---

# Attack Scenario

An external attacker could:

1. Perform a TLS downgrade attack.
2. Force communication to weaker TLS 1.0 encryption.
3. Exploit BEAST or POODLE weaknesses to compromise encrypted traffic.
4. Utilize missing security headers to:
   - Inject malicious scripts.
   - Perform clickjacking attacks.
   - Hijack authenticated user sessions.

Potential impacts include:

- Patient account compromise.
- Unauthorized access to healthcare information.
- Loss of patient trust.
- Regulatory compliance issues.

---

# Priority Justification

## Priority: 1 — Immediate Remediation

The patient portal receives direct internet traffic, making it the most exposed asset.

Recommended immediate actions:

- Disable TLS 1.0 and TLS 1.1.
- Enforce TLS 1.2+.
- Implement security headers:
  - Content Security Policy (CSP).
  - X-Frame-Options.
  - Strict-Transport-Security (HSTS).
- Remove HTTP TRACE support.
- Enable automated certificate renewal.

---

<br>

# Host 2: nas-01 — Backup Storage System

## Host Information

| Field | Details |
|---|---|
| **Host** | nas-01 |
| **IP Address** | 10.10.2.41 |
| **Asset Role** | Enterprise Backup Repository |
| **Exposure Level** | Internal but accessible through flat network |
| **Priority Ranking** | 2 |

---

# Identified Findings

| Finding ID | Vulnerability | Severity |
|---|---|---|
| Finding 015 | Synology DSM Web Interface Exposure on Ports 5000/5001 | Critical |

---

# Combined Risk Assessment

## Risk Level: Critical

The backup storage system represents a critical recovery asset.

The management interface is accessible from the internal network without:

- Network segmentation.
- Dedicated management VLAN.
- Restricted administrative access.

This allows compromised internal hosts to directly target backup infrastructure.

---

# Attack Scenario

An attacker who gains an initial foothold inside the MedDefense network could:

1. Scan internal systems for DSM management interfaces.
2. Access exposed Synology administration services.
3. Exploit authentication weaknesses or command injection vulnerabilities.
4. Obtain privileged access.
5. Delete, encrypt, or corrupt backup repositories.

Potential consequences:

- Loss of disaster recovery capability.
- Permanent data availability impact.
- Increased ransomware pressure.
- Extended hospital downtime.

---

# Priority Justification

## Priority: 2 — Critical Internal Target

Although not internet-facing, the NAS is highly valuable because it controls recovery capability.

Recommended actions:

- Remove direct access to DSM management ports.
- Place NAS devices in isolated backup VLANs.
- Restrict administrative access through jump hosts.
- Enable MFA for management accounts.
- Monitor backup integrity continuously.

---

<br>

# Host 3: ehr-srv-01 — EHR Application Server

## Host Information

| Field | Details |
|---|---|
| **Host** | ehr-srv-01 |
| **IP Address** | 10.10.2.10 |
| **Asset Role** | Electronic Health Record Application Server |
| **Exposure Level** | Internal but accessible through flat network |
| **Priority Ranking** | 3 |

---

# Identified Findings

| Finding ID | Vulnerability | Severity |
|---|---|---|
| Finding 017 | Apache Tomcat Version Disclosure Through Error Pages | Information Disclosure |
| Finding 022 | System Clock Skew (47 seconds ahead) | Low |
| Finding 030 | TLS Certificate Common Name Mismatch Using IP Address | Medium |
| Finding 031 | Apache Tomcat AJP Connector Vulnerability (Ghostcat CVE-2020-1938) | CVSS 9.8 Critical |

---

# Combined Risk Assessment

## Risk Level: Critical

The EHR application server contains multiple information disclosure weaknesses combined with an actively exploitable middleware vulnerability.

The most significant issue is:
