
# IR Activation — IR-2026-0420-01

## Incident Declaration

- **Incident ID:** IR-2026-0420-01
- **Declared At:** 2026-04-20T19:52:00Z (provisional)
- **Declared By:** On-call Incident Response Analyst
- **Organization:** MedDefense Health Systems
- **Initial Severity:** SEV1 — Critical
- **Incident Type:** Suspected ransomware, malware infection, credential compromise, and potential patient-data breach
- **Initial Alert Source:** Mike Torres / SIEM
- **Status:** Draft — pending transcript and action verification

## Severity Justification

The incident is classified as SEV1 because:

1. Multiple workstations show signs of compromise.
2. SIEM alerts indicate suspicious service installations on three hosts.
3. A nurse reported unusually slow workstation performance and changed desktop files.
4. The scheduling server is experiencing abnormal disk activity.
5. Suspected ransomware presents an immediate risk to clinical services.
6. Sensitive patient information may be exposed.

Immediate incident response is required to prevent further damage and protect patient care.

## Playbook Activation

**Primary Playbook:** Ransomware Incident Response Playbook

**Supporting Playbooks:**
- Malware and Endpoint Compromise
- Credential Compromise
- Clinical Service Degradation
- Potential PHI Exposure

**Reason:** The initial indicators suggest a possible ransomware incident affecting multiple systems, with potential consequences for clinical operations and patient information.

## Notifications

The following times are proposed and must be verified against actual communication records.

| Time (UTC) | Recipient | Purpose |
|---|---|---|
| 19:52 | James Chen — IR Commander | Declare incident and coordinate response |
| 19:54 | Sarah Park — IT Director | Coordinate technical containment |
| 19:56 | Clinical Director | Assess patient safety and service continuity |
| 19:58 | Helena Reyes — Legal Liaison | Initiate legal and HIPAA assessment |
| 20:00 | Marcus Webb — Communications Lead | Coordinate incident communications |
| 20:05 | Dr. Patricia Morales — Executive Sponsor | Provide initial executive update |

## First Communication

- **Type:** Executive Status Update
- **Recipient:** Dr. Patricia Morales
- **Proposed Time:** 20:05Z
- **Delivery Status:** Not yet verified

**Message (draft):**

MedDefense is investigating a suspected critical cybersecurity incident affecting multiple workstations and potentially clinical systems. Initial reports include unusual workstation behavior, abnormal disk activity, and suspicious service installation alerts. The incident has been classified as SEV1 due to the potential impact on patient care, system availability, and sensitive patient information. The Incident Response team is coordinating immediate containment, evidence preservation, and technical investigation with IT and clinical leadership. The full scope and any confirmed data exposure remain under investigation. Further updates will follow as findings are verified.

## Immediate Response Priorities

1. Confirm affected systems and incident scope.
2. Coordinate containment with clinical leadership.
3. Preserve volatile and non-volatile evidence.
4. Investigate suspicious processes and network activity.
5. Assess credential compromise and patient-data exposure.
6. Maintain incident communications and timeline updates.

## Verification Required

- Review `torres_call_transcript.md`.
- Confirm the incident date and declaration timestamp.
- Confirm the identity of the declaring analyst.
- Verify actual notification recipients and delivery times.
- Confirm that the selected playbooks match the approved IR program.
