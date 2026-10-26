
# Exercise Execution Record: Nexus Supply Chain Compromise Tabletop

**Simulation date:** 2026-10-26  
**Simulated by:** Exercise designer (self-simulation)  
**Exercise type:** Fictional tabletop simulation  
**Reference files:** `nexus_vendor_profile.md`, `inject_schedule.yaml`, `capability_map.yaml`, `evaluation_criteria.yaml`

> This is a simulated exercise. No real hospital systems, patient records, or vendor services were involved.

---

## INJ-00 (T+0 min)

### Inject Delivered

> Forty-five minutes ago, the SOC detected unusual outbound traffic from SCHED-SVR-01, the Main Campus server running the Nexus scheduling agent. EDR telemetry shows connections to an unfamiliar external IP approximately every four hours. Nexus scheduling remains operational across West Campus, Main Campus and North Site. No data theft or appointment changes are confirmed.

**Capability tested:** CAP-01

### Participant Responses

- **James Chen (SOC Lead / IR Commander):** "I declare a provisional SEV2 incident at T+2 because these repeated connections are unexplained. Preserve EDR and network logs and review the Nexus agent update history."
- **Sarah Park (IT Director):** "I will notify Robert Kim and the Clinical Director. We should preserve evidence before making a disruptive isolation decision."

### Evaluation

- **Criterion 1 — PASS:** James declared a provisional SEV2 incident at T+2 and explained the reason.
- **Criterion 2 — PASS:** James assumed incident command, and Sarah named Robert Kim and the Clinical Director for notification.
- **Criterion 3 — PASS:** The team requested EDR logs, network evidence and Nexus update history before containment.

**Finding:** No failure recorded.

### Facilitator Note

**Question:** "Could this traffic originate from the vendor's software rather than a direct attack?"

**Observation:** The team considered the Nexus update history but did not yet assume the vendor was compromised.

---

## INJ-01 (T+20 min)

### Inject Delivered

> Nexus SecOps issues an urgent advisory: an attacker accessed the vendor's build infrastructure three days ago. A malicious update was signed with the Nexus Health Technologies certificate and automatically distributed. The update version installed on SCHED-SVR-01 matches the affected release. Nexus has not yet supplied a clean replacement. MedDefense's last vendor review noted that the agent validates the signing certificate but does not independently pin update hashes.

**Capabilities tested:** CAP-01, CAP-02

### Participant Responses

- **Robert Kim (Technical Lead):** "A valid digital signature does not guarantee that this update is safe. I will preserve the binary and installation logs and check affected versions."
- **James Chen (IR Commander):** "I will contact Nexus SecOps at +1 512 555 0184 and request indicators, affected systems, and containment guidance."
- **Sarah Park (IT Director):** "We need regular communication with Nexus, but I have not assigned a liaison or scheduled the next update."

### Evaluation

- **Criterion 1 — PASS:** Robert identified that a valid signature cannot guarantee software integrity and mentioned the missing independent hash verification.
- **Criterion 2 — PASS:** Robert requested preservation of binaries, installation logs and version information.
- **Criterion 3 — PASS:** James initiated contact with Nexus SecOps and requested technical information.
- **Criterion 4 — FAIL:** No MedDefense vendor liaison or next communication deadline was assigned.

### Finding F-01: Vendor Communication Ownership Gap

**Problem:** The team contacted Nexus but did not assign responsibility for future vendor communication.

**Corrective action:** Update the vendor-response runbook to require a primary liaison, backup liaison and scheduled vendor updates.

**Owner:** Sarah Park (IT Director)  
**Deadline:** 14 days  
**Validation:** Repeat INJ-01 and verify that a liaison and next contact time are recorded within 10 minutes.

### Facilitator Note

**Question:** "Who will contact Nexus again, and when?"

**Observation:** The team knew how to reach Nexus but had no assigned owner for follow-up.

---

## INJ-02 (T+40 min)

### Inject Delivered

> Technical analysis confirms the affected Nexus agent is making periodic external connections. Robert Kim recommends isolating SCHED-SVR-01 and suspending Nexus FHIR traffic. The Clinical Director objects: the three sites rely on Nexus for approximately 3,500 patient-facing interactions weekly, and abruptly stopping automated confirmations and updates may cause missed or delayed appointments. No clean vendor patch is available.

**Capability tested:** CAP-03

### Participant Responses

- **Robert Kim (Technical Lead):** "I recommend isolating the server, but selective network restrictions might reduce the threat while keeping some scheduling functions available."
- **Clinical Director:** "Stopping scheduling without a fallback could delay urgent appointments. I can arrange manual priority scheduling within 30 minutes."
- **Sarah Park (IT Director):** "I authorize selective network restrictions for 30 minutes, followed by a reassessment at T+70."
- **James Chen (IR Commander):** "I will document the decision, preserve evidence and monitor whether suspicious connections continue."

### Evaluation

- **Criterion 1 — PASS:** Sarah made an authorized, time-limited containment decision.
- **Criterion 2 — PASS:** Clinical leadership was consulted before the decision.
- **Criterion 3 — PASS:** The team compared isolation, selective restrictions and monitored operation while considering patient safety.
- **Criterion 4 — PASS:** Manual scheduling had an owner and activation deadline, with reassessment at T+70.

**Finding:** No failure recorded.

### Facilitator Note

**Question:** "What happens to an urgent patient appointment if Nexus is disconnected immediately?"

**Observation:** The team recognized the patient safety consequences and selected a temporary containment approach with a clinical fallback.

---

## INJ-03 (T+60 min)

### Inject Delivered

> Nexus reports that the compromised build pipeline served multiple customers. MedDefense's investigation identifies suspicious access to appointment-related API records through the Nexus integration service principal svc-nexus-prod. The available logs cannot yet distinguish legitimate synchronization from unauthorized retrieval. Nexus processes patient demographics, insurance information and appointment details.

**Capabilities tested:** CAP-04, CAP-05

### Participant Responses

- **Helena Reyes (Legal Liaison):** "We must assess whether protected health information was exposed. Nexus is a Business Associate, and its agreement requires notification within 24 hours of discovering a breach."
- **Robert Kim (Technical Lead):** "I will preserve FHIR logs and investigate the service account activity to identify possible unauthorized access."
- **James Chen (IR Commander):** "We should document possible exposure without declaring confirmed data theft."
- **Sarah Park (IT Director):** "I will coordinate with Nexus to obtain its discovery timeline and affected data categories."

### Evaluation

- **Criterion 1 — PASS:** The team identified demographics, insurance information and appointment data as potentially affected ePHI.
- **Criterion 2 — PASS:** Robert requested Nexus and MedDefense logs to determine the exposure scope.
- **Criterion 3 — PASS:** Helena identified the Business Associate Agreement and the 24-hour vendor breach-notification requirement.
- **Criterion 4 — PASS:** The team distinguished suspicious access from confirmed exfiltration and assigned further investigation.

**Finding:** No failure recorded.

### Facilitator Note

**Question:** "Does suspicious API access automatically mean patient information was stolen?"

**Observation:** The team correctly distinguished possible exposure from confirmed exfiltration and avoided prematurely declaring a reportable breach.

---

## INJ-04 (T+80 min)

### Inject Delivered

> A comparison of Nexus and Epic scheduling records identifies conflicting appointment times for several near-term outpatient visits. It is unclear whether the discrepancies are caused by malicious changes, synchronization delays or ordinary administrative edits. Clinical staff warn that blindly trusting either system could cause patients to miss time-sensitive care.

**Capabilities tested:** CAP-06, CAP-03

### Participant Responses

- **Clinical Director:** "We need to identify urgent appointments first and verify them with clinical staff before making corrections."
- **Robert Kim (Technical Lead):** "I will preserve Nexus and Epic audit logs and investigate which records changed and when."
- **James Chen (IR Commander):** "We cannot assume that every mismatch was caused by the attacker. We need evidence."
- **Sarah Park (IT Director):** "I will pause automatic updates in the affected workflow and assign a reconciliation checkpoint at T+110."

### Evaluation

- **Criterion 1 — PASS:** Clinical leadership prioritized urgent appointments and patient safety.
- **Criterion 2 — PASS:** Robert requested preservation of audit logs before modifying records.
- **Criterion 3 — PASS:** The team considered multiple explanations for the discrepancies instead of assuming malicious activity.
- **Criterion 4 — PASS:** Sarah established a controlled reconciliation process with an owner and deadline.

**Finding:** No failure recorded.

### Facilitator Note

**Question:** "Can we simply overwrite Epic with the Nexus appointment records?"

**Observation:** The team rejected uncontrolled bulk changes and prioritized evidence preservation and clinical verification.

---

## INJ-05 (T+100 min)

### Inject Delivered

> A local journalist emails MedDefense asking whether patient data has been stolen and whether appointments have been manipulated. A social media post claims that MedDefense is hiding a hospital cyberattack. Meanwhile, Nexus has not confirmed the number of affected patient records, and the legal team has not concluded whether a reportable HIPAA breach occurred.

**Capabilities tested:** CAP-07, CAP-05

### Participant Responses

- **Marcus Webb (Communications Lead):** "I will prepare a holding statement confirming that an investigation is ongoing without making unsupported claims about data theft."
- **Helena Reyes (Legal Liaison):** "Legal and privacy must approve the statement before publication. We cannot disclose patient information."
- **James Chen (IR Commander):** "The malicious vendor update is confirmed, but exfiltration and malicious appointment changes remain unconfirmed."
- **Sarah Park (IT Director):** "I will update the internal incident channel, but we have not scheduled the next public update."

### Evaluation

- **Criterion 1 — PASS:** Marcus was identified as the communications owner, with legal and privacy approval required.
- **Criterion 2 — PASS:** The team approved a holding statement at T+115, within the 30-minute media window.
- **Criterion 3 — PASS:** The statement distinguished confirmed facts from uncertainties and did not disclose PHI.
- **Criterion 4 — FAIL:** No owner or time was established for the next public communication review.

### Finding F-02: Crisis Communication Follow-up Gap

**Problem:** The team prepared an initial public statement but did not establish responsibility for future updates.

**Corrective action:** Add mandatory follow-up owner and next-update-time fields to the crisis communications checklist.

**Owner:** Marcus Webb (Communications Lead)  
**Deadline:** 14 days  
**Validation:** Repeat INJ-05 and confirm that the communication owner and next review time are recorded before the media deadline.

### Facilitator Note

**Question:** "What will we tell the journalist tomorrow if the investigation is still ongoing?"

**Observation:** The team had no defined follow-up communication schedule, revealing a gap in crisis communication planning.

---

## INJ-06 (T+120 min)

### Inject Delivered

> The executive sponsor requests a board-quality incident brief within 90 minutes of this request. Nexus says its investigation remains ongoing and cannot yet confirm whether appointment records were accessed or changed by the attacker. MedDefense has a partial reconciliation result, but some patient records remain unverified. The board wants an immediate recommendation on continued Nexus use, patient safety and notification.

**Capabilities tested:** CAP-08, CAP-04, CAP-05, CAP-06

### Participant Responses

- **James Chen (IR Commander):** "I will lead the executive briefing and deliver it by T+210. We must separate confirmed facts from unresolved questions."
- **Sarah Park (IT Director):** "I recommend maintaining selective restrictions and manual clinical fallback until a verified clean update or safe restoration process is available."
- **Dr. Patricia Morales (Executive Sponsor):** "The board needs a clear explanation of patient safety, service availability, vendor risks and decisions requiring executive approval."
- **Helena Reyes (Legal Liaison):** "I will explain the current HIPAA assessment, BAA obligations and unresolved notification questions."
- **Marcus Webb (Communications Lead):** "I will summarize the approved public statement and establish a communications review at T+240."
- **Clinical Director:** "I will oversee verification of urgent appointments and report confirmed patient impact by T+240."
- **Robert Kim (Technical Lead):** "I will continue log analysis and request additional evidence from Nexus regarding exfiltration and the compromised update."

### Evaluation

- **Criterion 1 — PASS:** James accepted responsibility for the board briefing and established the T+210 deadline.
- **Criterion 2 — PASS:** The simulated board briefing was delivered at T+205 and covered operations, patient safety, vendor status, containment, PHI and notification posture.
- **Criterion 3 — PASS:** The team distinguished confirmed vendor compromise from unresolved data theft and appointment modification.
- **Criterion 4 — PASS:** The team assigned owners and next steps for major unresolved questions.

**Finding:** No failure recorded.

### Facilitator Note

**Question:** "What happens if Nexus cannot confirm whether data was stolen or appointments were changed?"

**Observation:** The team accepted uncertainty, assigned investigation owners and avoided claiming that the incident was fully resolved.

---

# Overall Simulation Results

| Inject | Result | Main Observation |
|---|---|---|
| INJ-00 | PASS | Incident declared and evidence preserved |
| INJ-01 | FAIL | Vendor follow-up owner missing |
| INJ-02 | PASS | Security and clinical conflict managed |
| INJ-03 | PASS | PHI and HIPAA obligations assessed |
| INJ-04 | PASS | Patient safety and record integrity prioritized |
| INJ-05 | FAIL | Public communication follow-up missing |
| INJ-06 | PASS | Executive briefing delivered with unresolved questions documented |

**Summary:**

- Total injects delivered: 7
- Total evaluation criteria: 28
- Criteria passed: 26
- Criteria failed: 2
- Findings identified: 2
- Design improvements identified: 3

**Unresolved issues:**

- Whether patient information was exfiltrated.
- Whether appointment discrepancies were malicious.
- When Nexus will provide a verified clean software update.

These questions intentionally remain open to test the team's ability to manage uncertainty.

---

# Design Feedback

## DF-01: Vendor Communication Ownership Is Not Explicit Enough

**Problem discovered:**

During INJ-01, the team contacted Nexus SecOps but did not assign a person responsible for future communication.

The vendor profile already identified that joint incident communications had not been properly exercised. The simulation confirmed that this weakness was not sufficiently challenged by the original inject wording.

**Specific design change:**

Update the INJ-01 decision point in `inject_schedule.yaml` to require:

- A primary MedDefense vendor liaison.
- A backup vendor liaison.
- A specific time for the next Nexus status update.

Update `evaluation_criteria.yaml` to require all three items for a complete pass.

**Validation:** Repeat INJ-01 and confirm that the liaison, backup and next update time are recorded.

---

## DF-02: Crisis Communications Lacks a Follow-up Trigger

**Problem discovered:**

During INJ-05, the team prepared an approved holding statement but did not plan future public updates.

The original inject tested the immediate media response but did not sufficiently challenge the longer-term communication process.

**Specific design change:**

Add the following sentence to INJ-05 in `inject_schedule.yaml`:

> The journalist also asks when MedDefense will provide its next official update if the investigation remains unresolved.

Keep the evaluation requirement for a named communication owner and next review time.

Add fields to the facilitator observation checklist for:

- External communication owner.
- Next update time.
- Approval authority.

**Validation:** Repeat INJ-05 and confirm that all three items are documented.

---

## DF-03: Executive Briefing Format and Exercise End Time Are Unclear

**Problem discovered:**

INJ-06 requires a board-quality briefing within 90 minutes, but the original instructions do not specify a standard briefing format.

This could lead to inconsistent evaluation because different facilitators may interpret "board-quality" differently.

The inject schedule ends at T+120, but the board briefing is due at T+210.

**Specific design change:**

Add a one-page executive briefing template to the participant guide with the following sections:

1. Confirmed facts
2. Unresolved questions
3. Patient safety impact
4. Service availability
5. Vendor investigation status
6. PHI exposure and HIPAA/BAA assessment
7. Decisions required
8. Actions, owners and deadlines

Update the facilitator script to explicitly state:

> The final inject is delivered at T+120. Participants have 90 additional minutes to prepare the executive briefing. The simulation concludes at T+210.

**Validation:** Ask two evaluators to independently score the same board briefing using the four INJ-06 evaluation criteria.

---
