
# Incident Timeline — IR-2026-0420-01

## Incident Information

- **Incident ID:** IR-2026-0420-01
- **Organization:** MedDefense Health Systems
- **Severity:** SEV1 — Critical (provisional)
- **Time Standard:** UTC
- **Timeline Type:** Append-only
- **Status:** Open — pending verification

## Initial Timeline

| Timestamp (UTC) | Type | Actor | Description | Source | Certainty |
|---|---|---|---|---|---|
| Date to verify, 19:43Z | OBSERVATION | Mike Torres / On-call Nurse | Nurse reports slow workstation performance and changed desktop files. Torres reports unusually high disk activity on the scheduling server. | Initial scenario; `torres_call_transcript.md` pending | Reported, unverified |
| Date to verify, at or before 19:43Z | OBSERVATION | SIEM / Mike Torres | Suspicious service installation alerts are reported on three hosts. Exact event timestamps and affected hostnames require verification. | SIEM alert reported by Mike Torres | Alert reported; details unverified |
| 2026-04-20T19:52:00Z (proposed) | DECISION | On-call IR Analyst | Propose SEV1 declaration due to suspected ransomware, multiple potentially compromised systems, and possible clinical impact. Activate the ransomware response playbook. | Initial incident assessment | Proposed; not confirmed executed |

## Timeline Maintenance Rules

1. All timestamps must use UTC.
2. The timeline is append-only; existing entries must not be deleted or overwritten.
3. Each entry must contain:
   - Timestamp
   - Type
   - Actor
   - Description
   - Source
   - Certainty
4. Allowed event types:
   - OBSERVATION
   - DECISION
   - ACTION
   - COMMUNICATION
   - EVIDENCE
5. Record confirmed facts separately from assumptions.
6. Append corrections as new entries with references to the original entries.
7. Continue updating the timeline during all incident response phases.

## Next Steps

- Verify initial events using `torres_call_transcript.md`.
- Record actual incident declaration and notifications.
- Add evidence collection and containment activities.
- Continue documenting investigation findings.
- Record eradication, recovery, and incident closure decisions.

## Current Status

**Incident:** Suspected critical cybersecurity incident

**Immediate Priority:** Prevent ransomware execution, preserve evidence, protect clinical services, and determine the extent of compromise.

**Note:** The example incident date, 2026-04-20, is a Monday, whereas the scenario describes a Sunday. Confirm the correct date before final submission.
