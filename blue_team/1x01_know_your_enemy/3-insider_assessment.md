# Insider Threat Analysis

---

## Scenario 1: The Shared Login

- **Classification:** Negligent (Systemic organizational failure resulting in poor credential hygiene)
- **Behavioral Indicators:**
  - Multiple concurrent sessions from a single account
  - Inconsistent typing patterns
  - Lack of individual accountability for workstation activity
- **Existing Control:** User Access Policy (Access Control Policy)
- **Gap Exploited:** Inadequate identity management/Lack of individual accountability (**Gap ID: IAM-01**)
- **Recommended Mitigation:** Enforce individual user accounts for all workstations with mandatory logouts or inactivity timeouts.

---

## Scenario 2: The Ghost Account

- **Classification:** Negligent (Failure of the offboarding process)
- **Behavioral Indicators:**
  - VPN logins outside of normal business hours
  - Access attempts from accounts belonging to terminated personnel
  - Anomalies in account status compared with contract end dates
- **Existing Control:** User Lifecycle Management
- **Gap Exploited:** Lack of automated offboarding/Account lifecycle management (**Gap ID: IAM-03**)
- **Recommended Mitigation:** Integrate HR and contractor management systems with Active Directory to automatically deactivate accounts immediately upon employee termination.

---

## Scenario 3: The Personal NAS

- **Classification:** Negligent (Unauthorized convenience-seeking)
- **Behavioral Indicators:**
  - Unrecognized MAC addresses on the network
  - Sudden large traffic spikes to or from an unknown device
  - Unauthorized hardware discovered through network scanning
- **Existing Control:** Network Access Control (NAC)
- **Gap Exploited:** Lack of network visibility/Shadow IT (**Gap ID: ASSET-02**)
- **Recommended Mitigation:** Implement strict **802.1X Network Access Control (NAC)** to prevent unauthorized devices from connecting to office network ports.

---

## Scenario 4: The Curious Employee

- **Classification:** Malicious (Intentional unauthorized access for personal gain or gossip)
- **Behavioral Indicators:**
  - Accessing records outside the employee's assigned patient cohort
  - Frequent access to high-profile or VIP patient records
  - Unusual login times for a registration employee
- **Existing Control:** Audit Logging and User Behavior Analytics (UBA)
- **Gap Exploited:** Absence of behavioral monitoring/Data Loss Prevention (DLP) (**Gap ID: MON-01**)
- **Recommended Mitigation:** Deploy User Activity Monitoring (UAM) with alerts configured to detect unauthorized access to sensitive or high-profile patient records.

---

## Scenario 5: The Overworked Admin

- **Classification:** Negligent (Intentional bypassing of security protocols due to workload pressure)
- **Behavioral Indicators:**
  - Unusual file transfer patterns (emailing sensitive files)
  - Plaintext credential files stored on user desktops
  - Execution of unapproved scripts
- **Existing Control:** Security Awareness Training/Credential Management Policy
- **Gap Exploited:** Lack of Endpoint Detection and Response (EDR) or Data Loss Prevention (DLP) (**Gap ID: SEC-04**)
- **Recommended Mitigation:** Implement a secure, automated privileged password management solution (e.g., CyberArk or HashiCorp) to eliminate manual script-based credential handling.

---

# Pattern Assessment

The primary systemic weakness at **MedDefense** is the lack of visibility and accountability for user activity. This stems from an organizational culture that prioritizes operational convenience over security controls.

Key evidence includes:

- The absence of automated offboarding (**IAM-03**), allowing former employees and contractors to retain access after leaving the organization.
- The lack of granular monitoring (**MON-01**), preventing the timely detection of malicious insider activity, unauthorized access, and negligent user behavior.

Without these foundational controls, MedDefense cannot reliably distinguish between legitimate clinical access and malicious data exfiltration. As a result, the broad access required for patient care becomes a persistent security risk and increases the organization's exposure to insider threats.
