
# Playbook Updates: IR-2026-0414-01

**Organization:** MedDefense

**Incident ID:** IR-2026-0414-01

**Playbook:** playbook_credential_exposure.yaml

**Status:** Proposed updates following incident review


## Objective

The updates cover:
- Suspicious VPN authentication and impossible travel
- Scope expansion after lateral movement
- Kerberos ticket compromise and krbtgt rotation
- HIPAA breach-risk assessment for ePHI exposure

---

### Change PB-UPD-001

**Playbook:** playbook_credential_exposure.yaml

**Section:** applies_to.triggers

**Gap closed:** GAP-002

**Finding reference:** control_effectiveness.yaml, Phase 2;
suspicious foreign authentication associated with 45.63.9.88.

**Before (abbreviated):**

```yaml
triggers:
  - "Alert: credential submitted to external domain"
  - "Alert: confirmed credential compromise"
```

**After:**

```yaml
triggers:
  - "Alert: credential submitted to external domain"
  - "Alert: confirmed credential compromise"
  - "Alert: successful VPN authentication from a country not observed for this account during the previous 30 days"
  - "Alert: impossible travel involving geographically inconsistent successful logins within 2 hours"
  - "Alert: high-risk foreign authentication followed by access to sensitive systems"
```

**Required response:**

1. Validate the authentication event using identity-provider
   and VPN gateway logs.
2. Check the source IP, country, timestamp, device,
   MFA result, and user activity.
3. Compare the location against the account's previous
   30 days of successful authentication history.
4. Investigate possible VPN, proxy, or legitimate travel
   explanations.
5. If compromise is suspected, revoke active sessions,
   restrict remote access, and initiate credential containment.
6. Escalate confirmed suspicious authentication to the
   Incident Commander.

**Reason:**

The existing playbook focused on direct credential compromise
alerts and lacked an independent trigger for unusual VPN
authentication.

The incident included suspicious foreign authentication,
demonstrating the need to investigate geographic anomalies
even without a confirmed credential-theft alert.

The suspicious foreign sign-in is documented, but successful
VPN access has not been independently confirmed.

---

### Change PB-UPD-002

**Playbook:** playbook_credential_exposure.yaml

**Section:** containment.scope_expansion

**Gap closed:** GAP-008

**Finding references:**
- ART-003-M01: Suspicious MSBuild network activity on WST-WS-017.
- Kerberos-authenticated movement from WST-WS-031.
- AD-LOG-01: Access to 14 PDF files on LIS-WSIDE-01.

**Before (abbreviated):**

```yaml
containment:
  - "Reset compromised account password"
  - "Revoke active sessions"
  - "Isolate initially affected workstation"
```

**After:**

```yaml
containment:
  scope_expansion_trigger:
    - "Suspected or confirmed lateral movement"
    - "Pass-the-Ticket indicators"
    - "Suspicious Kerberos authentication from a compromised host"
    - "Compromised account accessing additional hosts"

  scope_expansion_checklist:
    - "Identify all source and destination hosts"
    - "Review Kerberos authentication events and ticket activity"
    - "Identify accounts used on newly affected systems"
    - "Review EDR process and network telemetry"
    - "Check remote execution, SMB, RDP, WMI, and WinRM activity"
    - "Identify sensitive clinical systems in the expanded scope"
    - "Preserve evidence from newly identified hosts"
    - "Contain confirmed affected hosts with clinical approval where required"
    - "Revoke compromised sessions and credentials"
    - "Update the incident timeline and affected asset inventory"
    - "Notify the Incident Commander of scope changes"
```

**Required response:**

1. Begin with the initially compromised workstation.
2. Search authentication and EDR logs for movement to
   additional hosts.
3. Add every newly identified affected host to the
   incident scope.
4. Investigate suspicious accounts and Kerberos tickets.
5. Preserve forensic evidence before destructive actions
   whenever operationally safe.
6. Coordinate containment with clinical leadership if
   patient-facing systems are involved.
7. Continue expanding the investigation until no further
   suspicious movement is identified.

**Reason:**

The investigation identified suspicious activity beyond
the initial workstation, including WST-WS-017 and access
to LIS-WSIDE-01.

The original containment process did not explicitly require
the team to expand its investigation and containment scope
when lateral movement indicators appeared.

This update prevents the team from treating the first
compromised workstation as the complete incident scope.

---

### Change PB-UPD-003

**Playbook:** playbook_credential_exposure.yaml

**Section:** eradication.kerberos_ticket_compromise

**Gap closed:** GAP-009

**Finding references:**
- ART-002-M04: Credential material observed in LSASS memory.
- ART-003-M01: Suspicious Kerberos-authenticated activity
  involving WST-WS-017.

**Before (abbreviated):**

```yaml
eradication:
  - "Reset compromised account password"
  - "Revoke active authentication sessions"
```

**After:**

```yaml
eradication:
  kerberos_compromise:
    trigger:
      - "Confirmed Pass-the-Ticket activity"
      - "Confirmed forged Kerberos tickets"
      - "Confirmed compromise of the krbtgt account"

    actions:
      - "Preserve Kerberos and domain controller evidence"
      - "Identify affected accounts, tickets, hosts, and domain controllers"
      - "Reset compromised user and service account credentials"
      - "Revoke sessions and invalidate applicable Kerberos tickets"
      - "Investigate whether the krbtgt secret was compromised"
      - "For confirmed krbtgt compromise or forged ticket-granting tickets, perform two coordinated krbtgt password resets"
      - "Allow sufficient replication and ticket-lifetime intervals between resets"
      - "Coordinate with Active Directory administrators"
      - "Monitor domain authentication for continued malicious activity"
      - "Record reset timestamps and validation evidence"
```

**Required response:**

1. Confirm the type of Kerberos abuse using domain
   controller logs and forensic evidence.
2. Distinguish stolen legitimate tickets from forged
   tickets and confirmed krbtgt compromise.
3. Reset affected account passwords and invalidate
   compromised sessions or tickets.
4. If krbtgt compromise or forged ticket-granting
   tickets are confirmed, initiate the approved
   krbtgt double-reset procedure.
5. Coordinate the reset sequence with Active Directory
   administrators to avoid authentication outages.
6. Verify domain controller replication and monitor
   for continued unauthorized ticket use.

**Reason:**

The original playbook only required resetting the
compromised user's password.

That action may be insufficient when an attacker possesses
Kerberos tickets or has compromised the krbtgt secret.

A coordinated krbtgt double-reset is required for confirmed
krbtgt compromise or forged ticket-granting tickets.

However, Pass-the-Ticket activity alone does not establish
krbtgt compromise. The incident evidence does not confirm
that the krbtgt secret was stolen.

Therefore, the playbook must include an explicit
investigation and decision step before domain-wide
krbtgt rotation.

---

### Change PB-UPD-004

**Playbook:** playbook_credential_exposure.yaml

**Section:** assessment.ephi_breach_risk

**Gap closed:** GAP-010

**Finding reference:**
- AD-LOG-01: Access to 14 PDF files on LIS-WSIDE-01.
- Clinical data systems included in the investigated scope.
- Data access was observed; external exfiltration was
  not confirmed.

**Before (abbreviated):**

```yaml
assessment:
  - "Determine affected accounts and hosts"
  - "Identify potentially exposed information"
```

**After:**

```yaml
assessment:
  ephi_decision:
    trigger:
      - "Compromised account accessed a clinical system"
      - "Potential unauthorized access to electronic protected health information"
      - "Suspected disclosure or exfiltration of ePHI"

    actions:
      - "Notify Privacy Officer and Legal Liaison"
      - "Preserve clinical access and audit logs"
      - "Identify affected records and individuals"
      - "Determine whether ePHI was accessed, acquired, used, or disclosed"
      - "Perform the HIPAA four-factor breach-risk assessment"
      - "Document mitigation and evidence"
      - "Determine whether notification obligations apply"
      - "Record the decision and approval authority"

    hipaa_four_factors:
      - "Nature and extent of the PHI involved, including identifiers and re-identification risk"
      - "Identity of the unauthorized person who used or received the PHI"
      - "Whether the PHI was actually acquired or viewed"
      - "Extent to which the risk to the PHI was mitigated"
```

**Required response:**

1. Notify the Privacy Officer and Legal Liaison when
   ePHI may be involved.
2. Identify the clinical systems, records, accounts,
   and potentially affected individuals.
3. Preserve evidence of access, copying, transmission,
   and possible disclosure.
4. Conduct the HIPAA four-factor risk assessment.
5. Determine whether there is a low probability that
   the PHI was compromised, based on documented evidence.
6. Evaluate applicable breach-notification obligations,
   exceptions, and deadlines with Legal.
7. Document the final determination and supporting evidence.
8. Coordinate containment decisions with clinical
   leadership to protect patient safety.

**Reason:**

The incident investigation identified access to
14 PDF files on LIS-WSIDE-01.

Although external exfiltration was not confirmed,
the involvement of clinical information required
a structured privacy and breach-risk assessment.

The original credential exposure playbook did not
include a decision branch for ePHI involvement.

This update ensures potential HIPAA implications are
reviewed and documented rather than overlooked.

---

## Summary of Playbook Changes

| Change ID | Section Updated | Gap Addressed | Improvement |
|---|---|---|---|
| PB-UPD-001 | applies_to.triggers | GAP-002 | Adds suspicious VPN geography and impossible-travel triggers |
| PB-UPD-002 | containment.scope_expansion | GAP-008 | Requires investigation and containment of additional affected hosts |
| PB-UPD-003 | eradication.kerberos_ticket_compromise | GAP-009 | Adds Kerberos compromise response and conditional krbtgt double-reset |
| PB-UPD-004 | assessment.ephi_breach_risk | GAP-010 | Adds HIPAA four-factor breach-risk assessment |

## Validation and Approval

The Incident Commander, Technical Lead, Active Directory
administrators, Privacy Officer, and clinical representatives
must review applicable changes before approval.

The updated playbook should be tested through a tabletop
exercise covering:

1. Suspicious foreign authentication.
2. Lateral movement to additional hosts.
3. Kerberos ticket compromise.
4. Potential unauthorized access to ePHI.

The exercise should confirm that the updated triggers,
escalation paths, containment steps, and decision points
are clear and operationally practical.


