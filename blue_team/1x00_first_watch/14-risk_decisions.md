# 14. The Risk Decisions

This strategy session defines the risk treatment plans for the **top seven prioritized security gaps** identified within MedDefense Health Systems. The objective is to reduce the highest-impact risks while ensuring all remediation activities remain within the allocated **$120,000 security budget**.

---

# Risk Treatment Decisions

## GAP-001: Lack of Network Segmentation for Critical Clinical Assets

**Risk Level:** Critical

**Treatment Strategy:** Mitigate

### Justification
Network segmentation is essential to prevent lateral movement and protect critical healthcare systems, including the EHR environment and Medical IoT devices. This provides significant risk reduction with high implementation feasibility.

### Proposed Control(s)
- Technical Preventive Controls:
  - Network VLAN segmentation
  - Internal firewall rules
  - Clinical asset isolation

### Estimated Cost
**$10,000 - $50,000**

### Implementation Effort
**Long-term (> 1 month)**

### Expected Risk Reduction
**High**

- Restricts attacker movement
- Limits the blast radius of endpoint compromise
- Protects critical clinical systems

### Trade-offs
- Requires significant network redesign
- May introduce temporary service interruptions during implementation

---

# GAP-007: Lack of Centralized Audit Logging

**Risk Level:** Critical

**Treatment Strategy:** Mitigate

### Justification
Centralized logging is required for effective incident detection, investigation, and response. A cost-effective open-source SIEM solution is selected to avoid expensive commercial SIEM costs.

### Proposed Control(s)
- Technical Detective Controls:
  - Open-source SIEM deployment
  - Centralized log collection
  - Security alert monitoring

### Estimated Cost
**$1,000 - $10,000**

### Implementation Effort
**Long-term (> 1 month)**

### Expected Risk Reduction
**High**

- Enables threat detection
- Improves incident investigation
- Reduces attacker dwell time

### Trade-offs
- Requires ongoing maintenance
- Requires skilled personnel for log analysis

---

# GAP-003: Legacy Device Vulnerability (Windows XP MRI Scanner)

**Risk Level:** Critical

**Treatment Strategy:** Mitigate

### Justification
The MRI scanner cannot be immediately replaced. Network isolation and virtual patching provide the only practical method to reduce exposure while maintaining clinical functionality.

### Proposed Control(s)
- Technical Compensating Controls:
  - Protocol-aware gateway firewall
  - Device isolation
  - Traffic filtering

### Estimated Cost
**$10,000 - $50,000**

### Implementation Effort
**Short-term (< 1 month)**

### Expected Risk Reduction
**High**

- Quarantines vulnerable legacy equipment
- Prevents unauthorized access
- Reduces exploitation opportunities

### Trade-offs
- Incorrect DICOM filtering may disrupt clinical workflows

---

# GAP-004: Lack of Incident Response and Recovery Planning

**Risk Level:** Critical

**Treatment Strategy:** Mitigate

### Justification
Developing incident response and recovery procedures requires limited investment but significantly improves organizational resilience during cyber incidents.

### Proposed Control(s)
- Administrative Corrective Controls:
  - Formal Incident Response Plan
  - Disaster Recovery Plan
  - Tabletop exercises

### Estimated Cost
**$1,000 - $10,000**

### Implementation Effort
**Short-term (< 1 month)**

### Expected Risk Reduction
**High**

- Provides structured response procedures
- Improves recovery speed after incidents
- Reduces operational downtime

### Trade-offs
- Requires continuous updates and maintenance

---

# GAP-005: Unmanaged Shadow IT (Dr. Patel's NAS)

**Risk Level:** Critical

**Treatment Strategy:** Avoid

### Justification
The risk of patient data loss and unauthorized disclosure outweighs the operational convenience provided by the unmanaged NAS. A secure enterprise-managed alternative already exists.

### Avoidance Action
- Remove the NAS from the environment
- Migrate all data to approved centralized storage solutions
- Enforce IT governance policies

### Business Impact
- Temporary workflow disruption for the Cardiology department
- Requires user adaptation to new storage processes

### Trade-offs
- Requires strict enforcement of security policies

---

# GAP-012: Insufficient Human-Factor / Security Awareness Training

**Risk Level:** High

**Treatment Strategy:** Mitigate

### Justification
Security awareness training is one of the lowest-cost methods to reduce common healthcare breach causes, including phishing and accidental data exposure.

### Proposed Control(s)
- Administrative Preventive Controls:
  - Security awareness program
  - Cyber hygiene training
  - Phishing awareness exercises

### Estimated Cost
**$0 - $1,000**

### Implementation Effort
**Quick Win (< 1 week)**

### Expected Risk Reduction
**Medium**

- Reduces human-error-based incidents
- Improves employee security behavior

### Trade-offs
- Requires continuous employee engagement and periodic training

---

# GAP-006: Insecure Management of Employee HR Records

**Risk Level:** High

**Treatment Strategy:** Transfer

### Justification
Moving HR records to existing managed cloud infrastructure reduces internal security responsibilities while benefiting from enterprise security controls.

### Transfer Mechanism
- Migrate HR records to approved encrypted cloud storage (e.g., O365 environment)
- Apply managed access controls and compliance policies

### Residual Risk
- Remaining risk depends on cloud provider security configuration and internal access management

### Trade-offs
- Reduced direct control over infrastructure
- Dependency on cloud provider security practices

---

# Budget Summary

| Item | Estimated Cost |
|------|---------------|
| GAP-001: Network Segmentation | $35,000 |
| GAP-007: SIEM / Centralized Logging | $8,000 |
| GAP-003: MRI Gateway Protection | $45,000 |
| GAP-004: Incident Response / Disaster Recovery Planning | $5,000 |
| GAP-012: Security Awareness Training | $500 |
| **Total Estimated Cost** | **$93,500** |

---

# Budget Status

**Allocated Security Budget:** $120,000

**Total Planned Investment:** $93,500

**Remaining Budget:** $26,500

---

# Final Risk Treatment Decision

The remediation plan remains **within budget**, with **$26,500 reserved** for unexpected implementation costs, particularly those associated with network segmentation and clinical system changes.

No prioritized security improvements are deferred.

The selected strategy focuses on:

1. Reducing lateral movement risk through segmentation
2. Increasing visibility through centralized monitoring
3. Protecting vulnerable medical equipment
4. Improving organizational resilience through response planning
5. Eliminating unmanaged data exposure
6. Strengthening employee security awareness

These actions provide the highest security improvement while maintaining operational continuity for patient care.
