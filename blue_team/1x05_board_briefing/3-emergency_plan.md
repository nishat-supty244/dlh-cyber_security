# 3. The 72-Hour Emergency Response Plan

## Tier 1 – Tonight (0–12 Hours)

| **Action** | **Phase Blocked** | **Owner** | **Prerequisites** | **Risk of Action** | **Risk of Inaction** |
|------------|-------------------|-----------|-------------------|--------------------|----------------------|
| **Physical Backup Isolation (NAS-01)** | **Phase 5 – Backup Destruction** | Sarah Park (with 1 IT staff member) | None | Temporary suspension of automated overnight backups; manual verification will be required. | NAS-01 remains connected to the flat network and is vulnerable to encryption or deletion by Crimson Tide. |
| **External Administrative Access Lockdown** | **Phase 1 – Initial Access** | Sarah Park | Access to the FortiGate management console | Remote administration is temporarily restricted; local or out-of-band console access may be required if credentials fail. | Attackers retain an exploitable path through **CVE-2023-27997**, enabling compromise of the perimeter firewall. |
| **Critical Account Password Resets & MFA Enforcement Check** | **Phase 2 – Internal Reconnaissance**<br>**Phase 3 – Lateral Movement** | Security Analyst & Sarah Park | Active Directory administrative privileges | Users may experience temporary authentication issues requiring desktop support assistance. | Compromised or weak domain credentials enable unrestricted lateral movement using tools such as PsExec and WMI. |

---

# Tier 2 – Tomorrow (12–36 Hours)

| **Action** | **Phase Blocked** | **Owner** | **Prerequisites** | **Risk of Action** | **Risk of Inaction** |
|------------|-------------------|-----------|-------------------|--------------------|----------------------|
| **Emergency Board Budget Authorization & Support Contract Renewal ($2,400)** | **Phase 1 – Initial Access** | James Chen (Executive presentation at the 9:00 AM Board Meeting) | Executive advisory briefing | Emergency financial expenditure without the normal procurement review process. | Expired Fortinet support prevents firmware updates, leaving the firewall exposed indefinitely. |
| **FortiGate Firmware Emergency Patching (portal.meddefense.local)** | **Phase 1 – Initial Access** | Sarah Park (supported by Fortinet Support if required) | Board approval, renewed support contract, emergency change authorization | Temporary VPN and internet service interruption affecting approximately 800 daily patient portal interactions. | Continued exposure to **CVE-2023-27997**, significantly increasing the likelihood of ransomware compromise. |
| **Endpoint Detection and Response (EDR) Force Deployment** | **Phase 6 – Ransomware Deployment** | Sarah Park & IT Staff | EDR management console access | Slight increase in resource usage on older clinical endpoints. | Unprotected endpoints remain unable to detect or prevent ransomware execution and malicious process termination. |

---

# Tier 3 – This Week (36–72 Hours)

| **Action** | **Phase Blocked** | **Owner** | **Prerequisites** | **Risk of Action** | **Risk of Inaction** |
|------------|-------------------|-----------|-------------------|--------------------|----------------------|
| **Network Micro-Segmentation Rollout (Phase 1 VLANs)** | **Phase 2 – Internal Reconnaissance**<br>**Phase 3 – Lateral Movement** | Sarah Park & External Network Vendor | Updated switch configurations and scheduled testing window | Misconfigured ACLs could temporarily disrupt communication between non-critical network segments. | Flat network architecture continues to permit unrestricted lateral movement across clinical and administrative environments. |
| **Database Encryption Deployment Validation (PostgreSQL/MySQL)** | **Phase 4 – Data Exfiltration** | Security Analyst & Database Administrator | Successful LUKS/AES-256-XTS validation testing | Temporary application performance degradation during encryption initialization. | Database files remain readable if stolen from production storage. |
| **Active Directory Kerberos Hardening (RC4 Deprecation)** | **Phase 3 – Lateral Movement** | Sarah Park | Maintenance window and backup Domain Controller snapshot | Legacy medical applications using RC4 authentication may experience temporary authentication failures. | Active Directory remains vulnerable to Kerberos ticket-forging and Golden Ticket attacks. |

---

# Resource Conflict Assessment

## Identified Conflicts

Sarah Park is the primary resource bottleneck throughout both **Tier 1** and **Tier 2** activities.

Major scheduling conflicts include:

- Simultaneous responsibility for **physical backup isolation (NAS-01)** and **FortiGate administrative lockdown** during the first 12 hours.
- Coordination of the **FortiGate emergency firmware upgrade** while also overseeing enterprise-wide **EDR deployment** with only two available IT staff members.
- Limited maintenance capacity due to overlapping **FortiGate firmware updates** and **Active Directory hardening activities**.

---

# Resolution Strategy

## 1. Delegate and Triangulate

Assign routine, lower-risk operational tasks—such as EDR deployment verification and endpoint health checks—to the two available IT staff members. This allows Sarah Park to focus exclusively on high-impact infrastructure activities, including:

- FortiGate emergency patching
- Backup isolation and protection
- Critical network security changes

---

## 2. Sequence the Timeline

Separate major infrastructure changes into distinct maintenance windows to reduce operational risk.

| **Timeframe** | **Primary Activities** |
|---------------|------------------------|
| **Tier 2 (12–36 Hours)** | Complete perimeter security improvements, including Board approval, FortiGate firmware updates, and EDR deployment. |
| **Tier 3 (36–72 Hours)** | Perform internal security enhancements, including Active Directory hardening, network micro-segmentation, and encryption validation. |

This phased approach minimizes the likelihood of simultaneous failures affecting both network connectivity and enterprise authentication services while ensuring that the highest-risk vulnerabilities are addressed first.
