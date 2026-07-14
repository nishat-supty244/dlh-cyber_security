# Shadow IT Risk Assessment

This assessment evaluates unauthorized or unmanaged technology assets discovered within **MedDefense Health Systems**. Shadow IT introduces significant security risks because these assets operate outside established security controls, monitoring capabilities, backup processes, and compliance requirements.

---

# 1. Dr. Patel’s Personal NAS

## Risk Assessment

### Sensitive Data
- Likely contains **Restricted-level data**, including:
  - Patient medical records
  - Cardiology diagnostic studies
  - Research-related healthcare information

### Missing Controls
The device is not covered by existing enterprise security controls, including:

- **O365 E3 Licensing (C-010)**
- **Sophos Endpoint Protection (C-002)**
- **Centralized Backup Solution (C-003)**

### Worst-Case Scenario
A ransomware infection affecting the unmanaged NAS could result in:

- Permanent loss of patient data
- Inability to recover critical cardiology information
- HIPAA compliance violations
- Significant operational and reputational damage

### Recommended Response
**Decommission**

The device introduces a significant security risk that cannot be effectively managed compared with enterprise-approved storage solutions. All data should be migrated to authorized systems, including:

- EHR platforms
- PACS storage systems
- Approved enterprise file storage solutions

---

## Asset Registry Update

| Field | Details |
|-------|---------|
| **Asset ID** | A-021 |
| **Name** | Dr. Patel's NAS |
| **Type** | Data Store |
| **Location** | Cardiology |
| **Owner** | Dr. Patel |
| **OS / Platform** | Proprietary |
| **Critical Services** | Storage |
| **Segment** | 10.10.0.0/16 |
| **Status** | Shadow IT |
| **Notes** | Unmanaged device containing cardiology research and patient records |

---

# 2. Marketing Team’s Google Drive

## Risk Assessment

### Sensitive Data
Contains potentially sensitive organizational information, including:

- Confidential vendor contracts
- Strategic internal communications
- Business planning documents
- Internal marketing materials

### Missing Controls
The Google Drive environment operates outside MedDefense’s approved security framework and lacks:

- Active Directory Domain Policies (C-011)
- Enterprise access management
- Centralized monitoring
- Compliance controls
- Managed data sharing restrictions

### Worst-Case Scenario
A compromised Google account could allow unauthorized external access to:

- Strategic business plans
- Vendor information
- Internal communications

This could result in:

- Reputation damage
- Competitive disadvantage
- Exposure of confidential company information

### Recommended Response
**Migrate**

Move all data into the approved **O365 E3 environment**, allowing IT teams to manage:

- Access permissions
- Data sharing policies
- Compliance requirements
- Security monitoring

---

## Asset Registry Update

| Field | Details |
|-------|---------|
| **Asset ID** | A-022 |
| **Name** | Marketing G-Drive |
| **Type** | Application |
| **Location** | Cloud |
| **Owner** | Marketing Team |
| **OS / Platform** | Cloud-SaaS |
| **Critical Services** | Media Storage |
| **Segment** | Internet |
| **Status** | Shadow IT |
| **Notes** | Linked to personal Gmail account |

---

# 3. Abandoned Raspberry Pi

## Risk Assessment

### Sensitive Data
As a former network monitoring device, it may contain:

- Network traffic logs
- Monitoring configurations
- Stored credentials
- Internal network information

### Missing Controls
The device lacks:

- Security patching
- Endpoint protection
- Centralized logging
- Security monitoring
- Ownership accountability

### Worst-Case Scenario
An attacker could exploit the unmanaged Raspberry Pi as a hidden persistence mechanism to:

- Monitor sensitive network traffic
- Capture credentials
- Access PII/PHI data
- Pivot into internal systems

### Recommended Response
**Decommission**

Because the device is abandoned, unmanaged, and potentially vulnerable, it should be removed immediately to eliminate unnecessary attack surface.

---

## Asset Registry Update

| Field | Details |
|-------|---------|
| **Asset ID** | A-023 |
| **Name** | Abandoned Pi |
| **Type** | Network Device |
| **Location** | 2nd Floor |
| **Owner** | Unknown |
| **OS / Platform** | Linux (Unknown Version) |
| **Critical Services** | None |
| **Segment** | 10.10.0.0/16 |
| **Status** | Shadow IT |
| **Notes** | Unmonitored device; potentially used as a legacy network monitor |

---

# Shadow IT Policy Recommendation

## Recommended Policy Change

The most effective approach to reducing future Shadow IT incidents is implementing an:

**Acceptable Use Policy (AUP)** combined with a formal **IT Procurement and Service Provisioning Process**.

---

## Policy Objectives

The policy should:

### 1. Restrict Unauthorized Technology
- Prohibit employees from connecting unauthorized hardware to the corporate network.
- Prevent storage of company data on unmanaged personal devices or accounts.

### 2. Establish IT Approval Requirements
- Require all business-critical applications, devices, and storage solutions to be reviewed and approved by IT.
- Ensure security, compliance, and operational requirements are evaluated before deployment.

### 3. Provide Approved Alternatives
IT should provide secure, managed solutions such as:

- Enterprise cloud storage
- Approved NAS platforms
- Managed collaboration tools
- Secure research data repositories

### 4. Improve Governance and Visibility
The policy should enable:

- Asset inventory management
- Security monitoring
- Access control enforcement
- Regulatory compliance tracking

---

# Conclusion

The identified Shadow IT assets represent significant security and compliance risks because they bypass MedDefense’s established security controls. The highest-risk findings are the unmanaged NAS containing potential patient data and the abandoned Raspberry Pi that could provide attackers with network access.

By enforcing an Acceptable Use Policy and centralized IT provisioning process, MedDefense can reduce unauthorized technology adoption while ensuring employees have access to secure, approved solutions.
