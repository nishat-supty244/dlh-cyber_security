
# After-Action Report: Nexus Supply Chain Compromise Tabletop

**Exercise date:** 2026-10-26  
**Report date:** 2026-10-26  
**Facilitator:** Exercise Designer (Self-Simulation)  
**Participants:** James Chen, Sarah Park, Robert Kim, Helena Reyes, Marcus Webb, Dr. Patricia Morales, Clinical Director Representative  
**Classification:** Internal - Exercise Use Only  
**Exercise type:** Simulated Tabletop Exercise  
**Organization:** MedDefense

---

## Executive Summary

The Nexus Supply Chain Compromise Tabletop Exercise evaluated MedDefense's ability to respond to a simulated cybersecurity incident involving a compromised software update from Nexus Health Technologies.

The exercise included seven injects (INJ-00 through INJ-06), covering incident detection, supply chain risk, vendor communication, business continuity, patient safety, protected health information (PHI), HIPAA obligations, crisis communications and executive reporting.

The simulated team demonstrated effective incident declaration, evidence preservation, clinical coordination, PHI exposure assessment and executive briefing. Of 28 evaluation criteria, 26 passed and two failed.

Two P2 findings were identified:

1. **Vendor communication ownership:** During INJ-01, the team contacted Nexus SecOps but did not assign a liaison or establish a follow-up deadline.
2. **Crisis communication follow-up:** During INJ-05, the team prepared an approved holding statement but did not establish ownership or timing for subsequent public updates.

No P1 findings were observed.

**Most important recommended action:** Update the vendor incident-response runbook to require a named primary liaison, backup liaison and scheduled follow-up communication whenever a critical third-party provider is involved in a security incident.

Both findings have assigned owners, 14-day remediation deadlines and measurable validation methods.

This report reflects a fictional self-simulation, not an actual MedDefense security incident.

---

## Findings Table

| Finding ID | Inject | Capability Tested | Gap Description | Severity | Recommended Action | Owner Role | Deadline (Days) | Validation Method |
|---|---|---|---|---|---|---|---|---|
| F-001 | INJ-01 | CAP-02 - Vendor Communication | Vendor contact was initiated, but no primary liaison, backup or next contact deadline was assigned. | P2 | Update the vendor incident-response runbook to require named communication owners and scheduled vendor updates. | IT Director - Sarah Park | 14 | Review the updated runbook and repeat INJ-01; verify that the liaison, backup and next update time are recorded within 10 minutes. |
| F-002 | INJ-05 | CAP-07 - Crisis Communications | An approved holding statement was prepared, but no owner or time was established for future public updates. | P2 | Update the crisis communications checklist to require a follow-up owner, next review time and approval authority. | Communications Lead - Marcus Webb | 14 | Review the updated checklist and repeat INJ-05; verify that all required communication fields are completed before the media deadline. |

---

## P1 Finding Narratives

No P1 findings were identified during the simulation.

Both observed failures were classified as P2 because they represent important coordination and process weaknesses requiring remediation, but the simulation did not demonstrate immediate uncontrolled patient harm, confirmed PHI disclosure or a complete failure of incident command.

No additional P1 findings have been created without supporting exercise evidence.

---

## Finding Traceability

### F-001: Vendor Communication Ownership Gap

**Inject:** INJ-01  
**Capability:** CAP-02 - Vendor Communication  
**Failed evaluation criterion:** A named MedDefense vendor liaison and next communication deadline must be recorded during the inject window.

**Observed evidence:**

James Chen contacted Nexus SecOps and requested technical information. However, Sarah Park acknowledged that no liaison had been assigned and no next vendor update had been scheduled.

**Finding:** Vendor communication was initiated without documented follow-up ownership.

**Owner:** Sarah Park - IT Director  
**Remediation deadline:** 14 days  
**Closure evidence:** Updated vendor-response runbook and successful INJ-01 retest.

### F-002: Crisis Communication Follow-up Gap

**Inject:** INJ-05  
**Capability:** CAP-07 - Crisis Communications  
**Failed evaluation criterion:** A responsible communication owner and next public update review time must be established.

**Observed evidence:**

Marcus Webb prepared a holding statement and coordinated legal approval. The statement was approved within the required media response window. However, the team did not schedule a subsequent communication review.

**Finding:** The crisis communications process did not establish a documented follow-up communication cycle.

**Owner:** Marcus Webb - Communications Lead  
**Remediation deadline:** 14 days  
**Closure evidence:** Updated communications checklist and successful INJ-05 retest.

---

## What Worked

### 1. Incident Detection and Evidence Preservation

**Inject:** INJ-00  
**Capability:** CAP-01 - Supply Chain Detection

James Chen declared a provisional SEV2 incident at T+2 minutes and explained the reasoning behind the classification.

The team requested EDR telemetry, network evidence and Nexus agent update history before taking disruptive containment actions.

This demonstrated that the participants could recognize suspicious activity, establish incident command and preserve evidence without prematurely assuming a confirmed breach.

### 2. Business Continuity and Patient Safety Coordination

**Inject:** INJ-02  
**Capability:** CAP-03 - Business Continuity Decision

The Technical Lead recommended isolation of the affected scheduling server, while the Clinical Director raised concerns about delayed patient appointments.

Sarah Park authorized temporary selective network restrictions, and clinical leadership prepared manual priority scheduling.

The decision included an owner, a time limit and a reassessment checkpoint.

This demonstrated effective coordination between technical containment requirements and patient safety responsibilities.

### 3. Executive Reporting Under Uncertainty

**Inject:** INJ-06  
**Capability:** CAP-08 - Executive Briefing Under Pressure

James Chen coordinated the executive briefing, which was delivered at T+205, before the T+210 deadline.

The briefing distinguished confirmed facts from unresolved questions, including possible PHI exfiltration and appointment record manipulation.

The team assigned responsible owners for outstanding investigations rather than presenting the incident as fully resolved.

This demonstrated an ability to communicate risk and uncertainty to executive leadership.

---

## Exercise Design Feedback

### DF-01: Strengthen Vendor Communication Requirements

The simulation showed that INJ-01 did not sufficiently force participants to assign responsibility for ongoing vendor communication.

**Design change:** Revise INJ-01 and its evaluation criteria to explicitly require a primary vendor liaison, backup liaison and next scheduled vendor update.

### DF-02: Add a Crisis Communication Follow-up Trigger

INJ-05 tested the immediate media response but did not explicitly challenge the team to manage continuing external communication.

**Design change:** Add a journalist's request for the next official update and require the facilitator to evaluate follow-up ownership, timing and approval authority.

### DF-03: Standardize the Executive Briefing

INJ-06 required a board-quality briefing but did not define a standard format, potentially creating inconsistent evaluation between facilitators.

**Design change:** Add a one-page executive briefing template covering confirmed facts, uncertainties, patient safety, service availability, vendor status, PHI risk, notification posture, decisions and action owners. Clarify that the briefing deadline is T+210.

**Implementation status:** These three changes were identified and specified during Task 7. They must still be applied to the relevant exercise files and verified before the live tabletop.

---

## Corrective Action Tracking

| Action ID | Related Finding or Feedback | Responsible Owner | Deadline | Status |
|---|---|---|---|---|
| CA-001 | F-001 | Sarah Park - IT Director | 14 days | Open |
| CA-002 | F-002 | Marcus Webb - Communications Lead | 14 days | Open |
| CA-003 | DF-01 | Exercise Designer | Before live exercise | Planned |
| CA-004 | DF-02 | Exercise Designer | Before live exercise | Planned |
| CA-005 | DF-03 | Exercise Designer | Before live exercise | Planned |

A corrective action should be closed only after the updated documentation is reviewed and the relevant validation method succeeds.

---

## Conclusion

The Nexus Supply Chain Compromise Tabletop Exercise successfully simulated a complex third-party cybersecurity incident affecting MedDefense's patient scheduling operations.
The simulated participants demonstrated effective incident declaration, evidence preservation, patient safety coordination, PHI risk assessment and executive communication. Two actionable coordination weaknesses were identified in vendor follow-up and ongoing public communication. The highest-priority improvement is establishing clear ownership and follow-up deadlines for communications with critical third-party vendors during incidents. Three additional exercise design changes were identified to improve future tabletop delivery and evaluation consistency.

