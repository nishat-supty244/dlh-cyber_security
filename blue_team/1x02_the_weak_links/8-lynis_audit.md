# Security Audit Summary & MedDefense Projection Report

# Part 1: Local System Audit Results (Based on Actual Lynis Scan)

## 1. Hardening Index

| Metric | Result |
|--------|--------|
| **Hardening Index** | **59 / 100** |

### Interpretation

A score of **59/100** is below the recommended hardening baseline (typically **70 or higher**). This indicates that the system is only partially secured and still resembles a default installation with several important security controls either missing or disabled.

Key observations include:

- Missing or inactive host firewall
- No Host-Based Intrusion Detection System (HIDS)
- No malware or rootkit detection software
- Overall security posture requires significant improvement

---

## 2. Core Scan Metrics

| Metric | Value |
|--------|------:|
| **Tests Performed** | **253** |
| **Plugins Enabled** | **1** |

---

## 3. Software Components Flagged as Missing or Inactive

| Component | Status | Security Impact |
|-----------|--------|-----------------|
| **Firewall** | Inactive / Unconfigured | Leaves network services exposed to unauthorized access. |
| **Intrusion Detection System (HIDS)** | Not Installed | Prevents detection of suspicious system activity or attacks. |
| **Malware Scanner** | Not Installed | Malware, rootkits, and persistent threats may remain undetected. |

---

## 4. Operational Files Generated

| File | Purpose |
|------|---------|
| `/var/log/lynis.log` | Contains detailed test results, warnings, and debugging information. |
| `/var/log/lynis-report.dat` | Stores structured audit findings for reporting and analysis. |

---

# Part 2: MedDefense Environment Projection (billing-srv-01)

Applying the same Lynis audit methodology to **billing-srv-01** (Ubuntu 18.04, Apache 2.4.29, MySQL, and historical cryptominer compromise indicators) would likely reveal several critical security weaknesses.

---

## 1. Inactive or Unconfigured Host Firewall

| Item | Details |
|------|---------|
| **Lynis Test ID** | FIRE-4512 |
| **Risk Level** | High |

### Observation

Lynis would likely detect that host-level firewall rules are either missing or improperly configured.

### Security Impact

Without host-based filtering:

- Apache services remain directly accessible.
- MySQL services remain exposed.
- Attackers who gain internal network access can move laterally with minimal resistance.

---

## 2. Missing Malware and Rootkit Protection

| Item | Details |
|------|---------|
| **Lynis Test ID** | MLWR-3280 |
| **Risk Level** | Critical |

### Observation

No malware detection, rootkit scanning, or file integrity monitoring tools are present.

### Security Impact

Considering the server's previous cryptominer compromise:

- Persistent malware could remain undetected.
- Unauthorized processes may continue running.
- Rootkits could hide attacker activity.

---

## 3. Outdated Packages and End-of-Life Software

| Item | Details |
|------|---------|
| **Lynis Test ID** | PKGS-7394 |
| **Risk Level** | Critical |

### Observation

The server operates using:

- Ubuntu 18.04
- Apache HTTP Server 2.4.29

Both components are outdated and lack current security updates.

### Security Impact

End-of-life software significantly increases exposure to:

- Known CVEs
- Public exploit code
- Remote Code Execution (RCE)
- Privilege escalation attacks

---

## 4. Insecure Database Network Binding

| Item | Details |
|------|---------|
| **Lynis Test ID** | DB-2704 |
| **Risk Level** | High |

### Observation

MySQL is configured to listen on all network interfaces rather than restricting connections to localhost or trusted systems.

### Security Impact

This configuration allows:

- Unauthorized database access
- Increased attack surface
- Lateral movement within the internal network
- Exposure of sensitive financial information

---

## 5. Absence of System Auditing

| Item | Details |
|------|---------|
| **Lynis Test ID** | ACCT-9628 |
| **Risk Level** | High |

### Observation

System auditing tools such as **auditd** are not configured.

### Security Impact

Without audit logging:

- Administrative actions are not recorded.
- Privilege escalation attempts may go unnoticed.
- File modifications cannot be traced.
- Incident investigations become significantly more difficult.

---

# Overall Assessment

The projected Lynis assessment indicates that **billing-srv-01** would receive a relatively low hardening score due to multiple critical security weaknesses. The combination of outdated software, missing firewall protection, absent malware detection, insecure database configuration, and insufficient auditing creates multiple opportunities for attackers to compromise the system and maintain persistence.

Addressing these issues should be prioritized through:

- Enabling and configuring host-based firewalls
- Deploying malware and rootkit detection tools
- Updating operating systems and applications
- Restricting database network exposure
- Implementing comprehensive system auditing and log monitoring

These improvements would significantly strengthen the security posture of the MedDefense environment and reduce the likelihood of future compromise.
