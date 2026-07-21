#  The Legacy Systems 

This section evaluates legacy systems within the MedDefense environment that represent significant long-term security risks due to unsupported operating systems, unavailable vendor patches, and exposure to actively exploited vulnerabilities.

---

# System 1: Windows XP SP3 (10.10.1.70 — MRI Workstation)

## System Overview

| Field | Details |
|---|---|
| **System** | Windows XP SP3 |
| **Host Address** | 10.10.1.70 |
| **Asset Name** | WS-RAD-01 — MRI Workstation |
| **Asset Role** | Medical device workstation controlling MRI scanner operations |
| **Business Function** | Clinical imaging and diagnostic workflow support |
| **Asset Criticality** | Confidentiality: High \| Integrity: Critical \| Availability: Critical |

---

# End-of-Life (EOL) Research

## Operating System Support Status

Windows XP reached **End-of-Life (EOL)** status in **2014**.

Unlike a standard unpatched operating system, an EOL system presents a permanent security exposure because:

- The vendor no longer provides security updates.
- Newly discovered vulnerabilities will not receive official patches.
- Security weaknesses in operating system components remain permanently exploitable.
- Traditional patch management cannot eliminate the risk.

A search of vulnerability databases, including NVD records, reveals numerous historical and component-level vulnerabilities affecting Windows XP systems. However, because official Microsoft support has ended, these vulnerabilities cannot be remediated through normal patch deployment.

---

# Critical Historical Vulnerabilities

## CVE-2017-0144 — EternalBlue

### Description

EternalBlue is a critical SMBv1 remote code execution vulnerability affecting Windows systems.

Attackers can exploit the vulnerability through:
