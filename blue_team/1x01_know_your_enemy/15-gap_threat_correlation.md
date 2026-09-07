# Gap–Threat Correlation Matrix

| Gap ID | Description | Original Risk | Threat Actors | Related Kill Chains | Related Scenarios | New Risk | Justification |
|--------|-------------|---------------|---------------|--------------------|------------------|----------|---------------|
| **NET-01** | Flat Network Architecture | Critical | Ransomware, APT, Insider | 1, 2, 3, 4, 5 | 1, 2, 3 | **Critical** | Central to all lateral movement; exposure is absolute. |
| **IAM-01** | Lack of MFA / Shared Credentials | Critical | Ransomware, APT | 1, 3, 5 | 1, 3 | **Critical** | Primary enabler for unauthorized access and privilege escalation. |
| **VULN-01** | Patch / Vulnerability Management | High | Ransomware, Unskilled Attackers | 1, 3, 5 | 1, 3 | **Critical** | Directly exploited for initial access and long-term persistence. |
| **MON-01** | Lack of SIEM / Security Monitoring | High | APT, Insider | 2, 3, 5 | 1, 2, 3 | **Critical** | Prevents detection throughout all phases of an active attack. |
| **DATA-02** | Insecure Backup Storage | High | Ransomware | 1 | 1 | **High** | Essential for ransomware success by preventing system recovery. |
| **VEND-01** | Unmonitored Vendor Access | Medium | APT | 3 | 3 | **High** | Proven attack vector enabling persistent access through trusted vendors. |
| **SEC-04** | Missing DLP / Endpoint Controls | Medium | Insider | 2, 4 | 2 | **High** | Critical weakness allowing large-scale data theft and exfiltration. |
| **ASSET-02** | Lack of NAC / Shadow IT Controls | Medium | Ransomware, Insider | 4 | 2 | **Medium** | Enables unauthorized devices but remains a secondary attack vector. |

---

# Re-prioritized Gap List (By Risk)

## 1. NET-01 — Flat Network Architecture

- **Status:** Unchanged (**Critical**)
- Foundation of nearly every attack path.
- Enables unrestricted lateral movement across the environment.

---

## 2. IAM-01 — Lack of Multi-Factor Authentication (MFA)

- **Status:** Unchanged (**Critical**)
- Most common method for initial compromise and privilege escalation.
- Protects privileged and remote access accounts.

---

## 3. VULN-01 — Patch & Vulnerability Management

- **Status:** **Upgraded to Critical**
- Threat analysis confirms outdated software is the primary external entry point.
- Frequently exploited by ransomware and opportunistic attackers.

---

## 4. MON-01 — Lack of SIEM / Security Monitoring

- **Status:** **Upgraded to Critical**
- Threat analysis demonstrates that poor visibility allows attackers to remain undetected during:
  - Discovery
  - Persistence
  - Credential theft
  - Data exfiltration

---

## 5. DATA-02 — Insecure Backup Storage

- **Status:** **Upgraded to High**
- Represents a critical point of failure during ransomware incidents.
- Without isolated or immutable backups, recovery becomes extremely difficult.

---

## 6. VEND-01 — Vendor Access Management

- **Status:** **Upgraded to High**
- Supply chain analysis identifies trusted vendor access as a primary attack vector for Advanced Persistent Threats (APTs).

---

## 7. SEC-04 — Missing DLP / Endpoint Controls

- **Status:** **Upgraded to High**
- Essential for preventing insider-driven data theft and unauthorized data transfers.

---

## 8. ASSET-02 — Network Access Control (NAC) / Shadow IT

- **Status:** Stable (**Medium**)
- Although important, it represents a secondary attack vector compared to the higher-priority gaps.

---

# The Critical Three

These security gaps appear most frequently across the identified attack paths and threat scenarios.

## NET-01 — Flat Network Architecture

**Purpose**

Disrupts lateral movement by preventing attackers from moving freely between systems.

**Benefit**

Protects high-value assets such as:

- Active Directory
- EHR Database
- Critical Servers

---

## IAM-01 — Lack of MFA

**Purpose**

Stops unauthorized access and credential-based privilege escalation.

**Benefit**

Creates a strong barrier at the perimeter and significantly reduces successful account compromise.

---

## MON-01 — Lack of SIEM / Security Monitoring

**Purpose**

Detects attacker activity during the normally "silent" stages of an intrusion.

**Benefit**

Provides visibility into:

- Network discovery
- Credential harvesting
- Persistence
- Data exfiltration

allowing security teams to respond before significant damage occurs.

---

# The Surprise Finding

## SEC-04 — Missing DLP / Endpoint Controls

### Original Rating

**Medium**

### Updated Rating

**High**

### Reason for Re-prioritization

Initially considered a procedural weakness, threat analysis demonstrated that the absence of Data Loss Prevention (DLP), endpoint controls, and USB restrictions allows a low-effort insider attack to escalate into a major data breach.

The **"The Quiet Exit"** scenario showed that without endpoint protection:

- Patient records can be exported unnoticed.
- USB devices can remove sensitive data.
- Credential files can be copied.
- HIPAA-regulated information can leave the organization without detection.

This analysis confirms that strengthening endpoint controls is now a high-priority requirement for preventing insider-driven data loss.
