# The Roadmap  
# MedDefense 6-Month Security Implementation Roadmap

---

# Month-by-Month Breakdown

## Month 1: Quick Wins & Baseline Hardening

### Specific Actions

- Enforce MFA on:
  - All VPN accounts
  - Domain administrator accounts

- Disable:
  - Legacy SMBv1 protocols
  - External RDP exposure

- Remove:
  - Stale employee accounts
  - Inactive vendor accounts

- Deploy:
  - Microsoft 365 Safe Links
  - DMARC anti-spoofing rules

- Enforce:
  - 5-minute workstation screen lock policy

### Responsible Owner

**IT Infrastructure Manager (Sarah Park) & Systems Administrator**

### Dependencies

None.

Utilizes:

- Existing Microsoft enterprise licensing
- Native Group Policy Objects (GPOs)

### Completion Criteria

- 100% administrative accounts enrolled in MFA
- External RDP closure verified through active port scans
- Zero terminated employee accounts remaining in Active Directory

---

# Month 2: Core Tool Procurement & Preparation

## Specific Actions

- Procure enterprise licenses for:

  - Sophos Intercept X Endpoint Detection and Response (EDR)

- Provision cloud infrastructure:

  - AWS S3 Glacier storage
  - Immutable backup storage buckets

- Perform network preparation:

  - Map existing switch ports
  - Document current VLAN architecture
  - Prepare segmentation design

---

## Responsible Owner

**IT Director (Sarah Park) & Procurement Lead**

---

## Dependencies

- Budget approval
- Vendor contract finalization

---

## Completion Criteria

- Security software licenses secured
- AWS backup storage provisioned and tested
- Complete network inventory map finalized

---

# Month 3: Network Segmentation & Perimeter Controls

## Specific Actions

Implement:

- Core VLAN segmentation:
  - Server Zone
  - Clinical Zone
  - Management Zone
  - Guest Zone

Deploy:

- Dedicated firewall for Westside Clinic

Configure:

- Inter-VLAN stateful firewall rules
- Default-deny security policy

---

## Responsible Owner

**Network Operations Lead & Systems Administrator**

---

## Dependencies

- Completion of Month 2 network inventory
- Hardware delivery

---

## Completion Criteria

- All core assets migrated into dedicated VLANs
- Unauthorized inter-VLAN traffic blocked
- Internal security testing successfully completed

---

# Month 4: SIEM Deployment & EDR Rollout

## Specific Actions

Deploy:

- Open-source Wazuh SIEM collectors
- Sophos EDR agents across:
  - Hospital workstations
  - Servers

Integrate:

- Network device logs
- Endpoint telemetry
- Security alerts

into centralized SIEM dashboard.

---

## Responsible Owner

**Security Analyst & Endpoint Support Lead**

---

## Dependencies

- Stable network segmentation
- VLAN operational readiness

---

## Completion Criteria

- 100% endpoint EDR coverage
- Centralized Wazuh log ingestion operational
- Real-time alerting enabled

---

# Month 5: Backup Immutability & Medical Device Isolation

## Specific Actions

Configure:

- Automated offsite backup replication
- AWS S3 Glacier object-lock immutability

Establish:

- Dedicated Medical Device VLAN 30
- IoMT device isolation

Implement:

- Biomedical engineering access restrictions

---

## Responsible Owner

**Systems Administrator & Biomedical Engineering Director**

---

## Dependencies

- Core Network Segmentation (Month 3)
- SIEM Logging (Month 4)

---

## Completion Criteria

- Daily backup immutability verification successful
- Medical devices isolated on VLAN 30
- No unauthorized external communication channels detected

---

# Month 6: Validation, Policy Rollout & Optimization

## Specific Actions

Conduct:

- Internal vulnerability scans
- Incident response tabletop simulation

Finalize:

- Employee Acceptable Use Policy (MED-POL-001) signatures

Optimize:

- Firewall rules
- SIEM alert thresholds
- False-positive reduction processes

---

## Responsible Owner

**Security Analyst & Compliance Officer**

---

## Dependencies

Completion of:

- Months 1–5 implementation phases

---

## Completion Criteria

- Zero critical vulnerabilities left unresolved
- 100% employee AUP acknowledgment
- Successful executive security review

---

# Dependency Chain

The execution of MedDefense's roadmap depends on the following critical path relationships.

---

## 1. Network Segmentation → Medical Device Isolation

**Dependency:**

Core network VLAN implementation in Month 3 must be completed before medical devices can safely migrate to VLAN 30 in Month 5.

**Reason:**

Medical device isolation requires:

- Stable VLAN architecture
- Firewall enforcement
- Controlled traffic pathways

---

## 2. SIEM Deployment → 24/7 Monitoring & Alert Tuning

**Dependency:**

Wazuh centralized logging deployment in Month 4 must be operational before advanced monitoring activities in Month 6.

Enables:

- Log auditing
- Insider threat detection
- Alert optimization

---

## 3. EDR Rollout → Incident Response Testing

**Dependency:**

Endpoint detection agents deployed in Month 4 are required before realistic incident response exercises in Month 6.

Enables:

- Malware detection simulation
- Endpoint investigation
- Response validation

---

# Project Milestones

| Milestone ID | Date | Accomplished Scope | Success Indicator |
|---|---|---|---|
| MS-1 | August 22, 2026 | Quick Wins & Baseline Hardening | 100% admin MFA enforcement and zero legacy SMBv1 protocols active |
| MS-2 | October 22, 2026 | Network Segmentation & Zoning | Complete isolation of server, clinical, and guest VLANs with stateful firewall controls |
| MS-3 | December 22, 2026 | Endpoint & SIEM Operationalization | EDR active on all workstations and centralized Wazuh log ingestion verified |
| MS-4 | February 22, 2027 | Program Validation & Policy Finalization | 100% AUP employee signatures and successful post-implementation vulnerability scan |

---

# Risk to Timeline & Contingency Plans

## Risk 1: Clinical Operational Disruption During Network Segmentation

### Timeline Impact

Month 3

### Cause

Restrictive firewall policies may unexpectedly block:

- Critical clinical applications
- Medical device communication flows

---

## Contingency Plan

Actions:

- Perform segmentation changes only during:
  - Scheduled maintenance windows
  - Weekend/evening periods

- Maintain:
  - Immediate rollback scripts

- Enable:

  - Temporary permissive firewall logging mode for 48 hours

Purpose:

- Identify legitimate clinical traffic
- Create appropriate firewall allow rules
- Transition safely to strict enforcement

---

# Risk 2: Staff Resistance or Delayed Policy Acknowledgment

### Timeline Impact

Month 6

### Cause

Clinical employees and physicians may delay:

- Security awareness completion
- Acceptable Use Policy acknowledgment

due to patient care responsibilities.

---

## Contingency Plan

Actions:

- Collaborate with Department Heads (e.g., Dr. Patel)
- Conduct 10-minute micro-training sessions during routine meetings
- Use automated IAM reminders beginning two weeks before deadline

Additional Enforcement:

- Link policy completion status with network access credentials

---

# END OF DOCUMENT
