
# Tabletop Exercise: Nexus Supply Chain Compromise

**Date:** 2026-10-26

**Classification:** Internal - Exercise Use Only  

**Facilitator:** Nishat Sultana Supty

**Scenario Version:** 1.1  

**Organization:** MedDefense Health Systems  

**Exercise Type:** Cybersecurity Tabletop Exercise (TTX)

---

## 1. Organization Background

MedDefense Health Systems operates three healthcare sites: West Campus, Main Campus, and North Site. The organization relies on Nexus Patient Scheduling for approximately 3,500 patient-facing interactions each week, including outpatient scheduling, pre-registration, and insurance eligibility checks.

MedDefense handles electronic protected health information (ePHI) and must comply with HIPAA privacy, security, and applicable breach notification requirements. Disruption or compromise of its scheduling systems could affect patient care, appointment accuracy, and regulatory compliance.

## 2. Vendor Background

Nexus Patient Scheduling is a cloud-hosted SaaS platform provided by Nexus Health Technologies, Inc., based in Austin, Texas. MedDefense has used the platform since August 14, 2023, across all three healthcare sites.

Nexus processes patient demographic information, appointment details, insurance information, and scheduling-related staff information. It does not provide clinical charting services.

### Technical Integration

Nexus integrates with MedDefense's Epic electronic health record environment using HL7 FHIR R4 over HTTPS.

- **Outbound data:** Scheduling requests, patient demographics, and insurance eligibility queries.
- **Inbound data:** Confirmed appointments, wait-list notifications, and automated scheduling updates.
- **Authentication:** OAuth2 client credentials using short-lived access tokens associated with `svc-nexus-prod`.
- **Nexus API:** `https://fhir.nexushealth.io/v1/`
- **MedDefense inbound endpoint:** `https://ehr-ingest.meddefense.local/nexus-inbound/`
- **Network connection:** Site-to-site IPsec tunnel.
- **Local agent:** `nexus-agent` installed on `SCHED-SVR-01` at Main Campus.
- **Software updates:** Automatically distributed signed updates from Nexus.

### Contractual and Regulatory Obligations

MedDefense has an active Business Associate Agreement (BAA) with Nexus, effective August 1, 2023, and last amended May 20, 2025.

The agreement requires:

- Nexus to notify MedDefense within 24 hours of discovering a breach.
- Nexus to provide an annual SOC 2 Type II report.
- Nexus to return or destroy protected health information upon termination.

The exact service availability and recovery targets under the Service Level Agreement (SLA) must be verified against the current vendor contract.

Nexus uses AWS, Twilio, and SendGrid as disclosed subprocessors.

### Previous Vendor Security Review

The last vendor security review was completed on November 14, 2025, by MedDefense Vendor Risk.

The review identified several residual risks:

- The signed software update process relies on code-signing certificate validation without independent client-side hash verification.
- A software bill of materials for third-party npm dependencies in the on-premises agent was unavailable.
- Vendor incident communication procedures were documented but had not been tested through a joint tabletop exercise.

These findings were documented for follow-up during the next vendor risk review.

## 3. Opening Situation

It is the morning of April 14, 2026.

Approximately 45 minutes ago, MedDefense's Security Operations Center (SOC) detected unusual outbound network traffic originating from the patient scheduling server at Main Campus.

The affected server, `SCHED-SVR-01`, hosts the Nexus scheduling agent used to exchange appointment information between MedDefense and Nexus Patient Scheduling.

Initial Endpoint Detection and Response (EDR) telemetry indicates periodic outbound connections to an unfamiliar external IP address. Available logs show a recurring connection pattern approximately every four hours.

The destination is not currently recognized as an approved Nexus endpoint.

At this stage, the SOC has not established whether the traffic represents legitimate vendor activity, a configuration issue, or malicious communication.

The full scope and cause remain unknown.

## 4. Known Facts at Exercise Start

The following information is available to participants:

1. **Initial alert:** The SOC flagged unusual outbound traffic from `SCHED-SVR-01` approximately 45 minutes before the exercise began.

2. **Affected host:** The identified server is `SCHED-SVR-01`, located at Main Campus and running the Nexus scheduling agent.

3. **Network behavior:** EDR telemetry shows periodic outbound connections to an unknown external IP address at approximately four-hour intervals.

4. **Vendor dependency:** Nexus supports scheduling operations across all three MedDefense sites and integrates with Epic through HL7 FHIR R4.

5. **Investigation status:** The source, purpose, and authorization of the external communications have not been confirmed.

No additional technical findings or evidence of data theft have been established at exercise start.

## 5. Organizational Uncertainties

The initial situation creates several difficult decisions without an immediately clear answer.

### 5.1 Trust in Vendor Software

Nexus distributes software updates automatically using digitally signed packages.

A valid digital signature normally helps establish the publisher and integrity of a software package. However, it does not independently guarantee that the software is free from malicious functionality.

If vendor-related activity becomes suspicious, MedDefense must decide whether continued trust in the vendor's software and update process is justified.

### 5.2 Security Versus Clinical Availability

Disconnecting the Nexus scheduling agent or restricting its network access may reduce potential cybersecurity exposure.

However, doing so could interrupt appointment confirmations, pre-registration, and scheduling updates across MedDefense's three sites.

Leadership must balance containment against operational continuity and patient safety.

### 5.3 Incomplete Evidence and Escalation

The SOC has identified suspicious behavior but has not confirmed a compromise.

The organization must determine whether to escalate immediately, continue investigating, or apply precautionary restrictions while evidence is incomplete.

## 6. Patient Safety Considerations

The scheduling platform is used for patient appointments and related administrative workflows across all three sites.

If appointment information has been modified during a potential compromise window, patients could receive incorrect appointment dates, experience delays, or miss necessary care.

At exercise start, no unauthorized appointment modifications have been confirmed.

The clinical team may need to determine how appointment accuracy can be verified and whether temporary manual scheduling procedures are necessary.

## 7. HIPAA and Legal Considerations

Nexus is a Business Associate of MedDefense and handles electronic protected health information, including patient demographics and insurance information.

A confirmed compromise involving protected health information could require MedDefense and Nexus to assess their respective obligations under HIPAA and the Business Associate Agreement.

Under the BAA, Nexus must notify MedDefense within 24 hours of discovering a breach.

However, suspicious network activity alone does not establish that a reportable breach has occurred.

Legal and incident response leadership must determine what evidence is required to assess possible unauthorized access, acquisition, use, or disclosure of protected health information.

## 8. Exercise Starting Point

The SOC has escalated the suspicious network activity for initial review.

The incident response team and relevant organizational stakeholders must now assess the available information and determine appropriate next steps.

At this point:

- The cause of the suspicious traffic is unknown.
- No patient data exfiltration has been confirmed.
- No unauthorized appointment modifications have been confirmed.
- The impact on other MedDefense sites is unknown.
- Nexus has not provided a confirmed explanation for the observed traffic.
- No final containment decision has been made.

Participants should respond using their existing organizational roles, incident response procedures, contractual obligations, and clinical safety responsibilities.


---

**End of Participant Scenario Briefing**

**Classification:** Internal - Exercise Use Only  
**Scenario Version:** 1.1
