**SOC Triage Operations**

**Q1. What is the full SOC triage workflow from receiving an alert to closing or escalating it?**

**Answer:**

The SOC triage workflow generally follows these steps:

1. **Receive the alert** — The alert enters the SOC queue from a SIEM, EDR, IDS, firewall, or other security tool.
2. **Validate the alert** — The Tier 1 analyst checks whether the alert contains enough information and whether it appears legitimate.
3. **Enrich the alert** — The analyst checks asset information, user context, IP addresses, domains, IOCs, threat intelligence, and historical activity.
4. **Check the baseline** — The analyst determines whether the activity is normal or unusual for that particular host, user, or environment.
5. **Determine the classification** — The alert is classified as a false positive, benign/authorized activity, or a true positive requiring further investigation.
6. **Assign priority** — Severity, asset criticality, and deviation from normal behavior are combined to determine how urgently the alert should be handled.
7. **Document the investigation** — The analyst records evidence, findings, actions, and reasoning in the SOC ticket.
8. **Close or escalate** — A benign/false-positive alert is closed with a documented reason. A suspicious or confirmed security event is escalated to Tier 2.
9. **Update and close the ticket** — After the investigation or incident response process is complete, the ticket is updated with the final disposition and closed.

This workflow maps mainly to the **Detection and Analysis** phase of incident response, while escalation can lead into **Containment, Eradication, and Recovery**.

**Q2. How do you determine the priority of a SOC alert?**

**Answer:**

Alert priority should not depend only on the rule's severity.

A practical triage priority considers three major factors:

- **Rule severity** — How dangerous is the behavior detected by the rule?
- **Asset criticality** — How important or sensitive is the affected system?
- **Baseline deviation** — How unusual is the activity compared with what is normally expected?

For example, a medium-severity alert on a critical medical server with highly unusual behavior may deserve higher priority than a high-severity alert on a low-value test machine performing expected activity.

A simplified model is:

**Triage Priority = Rule Severity + Asset Criticality + Baseline Deviation**

The exact scoring method depends on the SOC, but the principle is to prioritize alerts according to **risk and business impact**, not severity alone.

**Q3. What is the difference between closing and escalating an alert?**

**Answer:**

**Closing an alert** means the Tier 1 analyst has determined that the alert does not require further security investigation.

Examples include:

- False positive
- Authorized administrative activity
- Known vulnerability scanner
- Approved software behavior

The analyst must document why the alert was closed.

**Escalating an alert** means the activity appears to be a genuine security concern or cannot be safely resolved at Tier 1.

The alert is sent to **Tier 2** or the appropriate incident response team for deeper investigation.

**Q4. What should a structured SOC ticket contain?**

**Answer:**

A structured SOC ticket should normally contain:

- Alert ID
- Date and time
- Detection rule
- Alert severity
- Affected host or asset
- Asset criticality
- Username or account involved
- Source and destination IP addresses
- Relevant domains, hashes, or other IOCs
- Description of the activity
- Baseline/context information
- Investigation steps performed
- Evidence collected
- Analyst findings
- Classification
- Priority
- Actions taken
- Escalation information, if applicable
- Final disposition
- Timestamp and analyst information

Good documentation provides **traceability**. Another analyst should be able to understand what happened, what was checked, what evidence was found, and why the analyst reached the final decision.

Documentation discipline is a professional requirement because SOC investigations may later be reviewed during audits, incident reviews, legal investigations, or compliance assessments.

**Alert Classification Under Ambiguity**

**Q5. What are a true positive, false positive, true negative, and false negative?**

**Answer:**

These terms describe the relationship between a detection rule and the actual security situation.

| **Classification**      | **Meaning**                                                             |
| ----------------------- | ----------------------------------------------------------------------- |
| **True Positive (TP)**  | The rule detects malicious or unwanted activity that actually occurred. |
| **False Positive (FP)** | The rule alerts, but the detected activity is not a security threat.    |
| **True Negative (TN)**  | The rule does not alert, and there is no malicious activity.            |
| **False Negative (FN)** | Malicious activity occurs, but the rule fails to detect it.             |

For example, if a rule detects an actual malicious PowerShell execution, that is a **true positive**.

If the rule detects an ordinary administrative PowerShell command that is authorized and harmless, it is a **false positive**.

**Q6. Why can an alert be a false positive even when the rule correctly detects authorized activity?**

**Answer:**

Because a detection rule is designed to identify **suspicious patterns**, not necessarily to understand the complete business context.

For example, suppose a rule detects:

PowerShell executed with suspicious command-line parameters.

A system administrator may legitimately use exactly those parameters during approved maintenance.

The rule fired correctly because the activity matched its detection logic. However, the activity was **not actually malicious**.

Therefore, from an operational detection perspective, it is a **false positive**.

The important distinction is:

**"The rule detected what it was designed to detect" ≠ "the activity was malicious."**

**Q7. Can the same rule produce a false positive in one situation and a true positive in another?**

**Answer:**

Yes.

Classification is **context-dependent**.

For example, the same rule detects PowerShell downloading a file from an external website.

**Dataset A:**

An authorized administrator downloads an approved software update.

→ **False positive**

**Dataset B:**

An unknown compromised account downloads a malicious executable from an attacker-controlled domain.

→ **True positive**

The rule itself has not changed. The **context surrounding the activity** has changed.

Therefore, analysts must evaluate the alert using additional information such as:

- User identity
- Host role
- Asset criticality
- Time of activity
- Baseline behavior
- Process ancestry
- Destination reputation
- IOC information
- Authorization status

**Q8. How can baseline data help resolve an ambiguous alert?**

**Answer:**

A baseline represents what is considered **normal behavior** for a host, user, or environment.

When an alert is ambiguous, the analyst can compare the observed activity against the baseline.

For example:

- A server normally runs backup.exe every night.
- The same process appears at 02:00 every day.
- The process connects to the same approved backup server.

This activity is likely normal.

However:

- The process has never previously appeared on that server.
- It executes at an unusual time.
- It connects to an unfamiliar external IP.

This represents a stronger deviation from the baseline and may justify escalation.

Baseline information therefore provides **context without requiring the analyst to perform a complete investigation from scratch**.

**Q9. How does asset context help with alert classification?**

**Answer:**

Asset context tells the analyst what the affected system is used for and how important it is.

For example:

- An unusual login to a public test server may be lower priority.
- The same unusual login to a domain controller may be much more serious.
- An unexpected process on a medical device could be highly significant because of the potential operational and patient-safety impact.

Asset context helps determine both **whether activity is suspicious** and **how urgently it should be investigated**.

**Q10. How can IOC enrichment help resolve an ambiguous alert?**

**Answer:**

IOC enrichment provides additional information about indicators such as:

- IP addresses
- Domains
- URLs
- File hashes
- Email addresses
- Malware indicators

For example, an alert may show that a workstation communicated with an unfamiliar external IP.

The analyst can enrich the IP using available threat intelligence.

If the IP is associated with known malware infrastructure, the alert becomes more suspicious.

If the IP belongs to a legitimate cloud provider used by the organization, the activity may be benign.

IOC enrichment helps analysts make a better classification decision without unnecessarily repeating the entire investigation.

**Q11. Why should multiple alerts describing the same underlying activity be grouped into one incident?**

**Answer:**

Multiple security tools can generate several alerts for the same event.

For example, one attack could generate:

- A failed-login alert
- A successful-login alert
- A suspicious process alert
- An unusual network connection alert

Treating each alert as a separate incident can create duplicate work and make the SOC queue harder to manage.

Instead, analysts should **correlate related alerts** and group them into one incident when they represent the same underlying activity.

This provides:

- A clearer timeline
- Less duplicate investigation
- Better incident tracking
- More accurate metrics
- Easier escalation

**Operational Improvement**

**Q12. How can a SOC identify systemic false-positive problems?**

**Answer:**

Instead of examining false positives individually, analysts can look for **patterns across a shift or longer period**.

For example, suppose a particular rule generates 100 alerts and 90 are consistently caused by an approved backup process.

That suggests a systemic rule problem rather than 90 unrelated analyst mistakes.

The SOC can analyze:

- Which rules generate the most false positives
- Which assets generate them
- Which users or processes trigger them
- What time they occur
- Common reasons for closure
- False-positive rates by rule

This information can identify opportunities for **detection tuning**.

**Q13. What makes a good rule-tuning recommendation?**

**Answer:**

A good tuning recommendation should clearly specify:

1. **What should change**
2. **Why the change is necessary**
3. **Expected reduction in false positives**
4. **What risk the change introduces**
5. **How to monitor for false negatives**

For example:

Exclude the approved backup service account from the suspicious PowerShell rule because it generates repeated alerts during scheduled backups. This is expected to reduce false positives significantly. However, excluding the account could hide a compromised backup account, so activity from that account should continue to be monitored for unusual hosts, times, and command patterns.

A good tuning recommendation improves detection quality **without blindly weakening the rule**.

**Q14. What are common SOC KPIs?**

**Answer:**

Important SOC metrics include:

**MTTD — Mean Time to Detect**

The average time required to detect a security incident after it occurs.

**MTTR — Mean Time to Respond/Remediate**

The average time required to respond to or resolve an incident.

**False Positive Rate**

The percentage of alerts that turn out to be non-malicious.

**SLA Compliance**

The percentage of alerts or incidents handled within the required service-level timeframes.

**Q15. How does triage quality affect SOC KPIs?**

**Answer:**

Good triage improves SOC performance.

For example:

- **Accurate classification** reduces unnecessary investigation time.
- **Good prioritization** ensures critical alerts are handled first.
- **Fast triage** improves MTTD and helps prevent SLA violations.
- **Correct escalation** reduces the time required for Tier 2 to understand the incident.
- **Effective tuning recommendations** reduce recurring false positives.
- **Good documentation** reduces investigation and handoff time.

Poor triage can have the opposite effect by creating alert queues, delaying important incidents, increasing false positives, and causing SLA breaches.

**Q16. What should a SOC shift handoff report contain?**

**Answer:**

A shift handoff should provide enough information for the next analyst to continue operations without repeating completed work.

It should include:

- Open incidents
- Pending investigations
- High-priority alerts
- Alerts awaiting escalation
- Important findings
- Actions already performed
- Evidence collected
- Outstanding tasks
- Monitoring requirements
- Relevant rule or detection issues
- SLA deadlines
- Any important changes in the environment

A good handoff provides **operational continuity** between shifts.

**Incident Response Foundations**

**Q17. What are the NIST SP 800-61 incident response phases?**

**Answer:**

The traditional NIST SP 800-61 incident response lifecycle contains:

1. **Preparation**
2. **Detection and Analysis**
3. **Containment**
4. **Eradication**
5. **Recovery**
6. **Lessons Learned**

These phases provide a structured approach for handling security incidents.

**Q18. Where does Tier 1 SOC triage fit into the incident response lifecycle?**

**Answer:**

Tier 1 SOC triage primarily sits within **Detection and Analysis**.

Tier 1 receives alerts, validates them, gathers context, checks baselines and IOCs, determines priority, and decides whether to close or escalate.

If the investigation confirms a significant security incident, the case can move into the later response phases:

**Detection and Analysis → Containment → Eradication → Recovery → Lessons Learned**

Tier 1 therefore acts as an important gateway between automated detection and formal incident response.

**Q19. When should a triage finding trigger a formal incident declaration?**

**Answer:**

A formal incident should generally be declared when there is sufficient evidence that a security event has caused or is likely to cause a meaningful compromise, violation, or impact requiring coordinated response.

Examples include:

- Confirmed malware execution
- Confirmed account compromise
- Unauthorized privileged access
- Active attacker activity
- Data exfiltration
- Confirmed exploitation of a critical system
- Significant impact to critical infrastructure

The exact declaration criteria depend on the organization's incident response policy.

The key principle is that **Tier 1 should escalate when the evidence and potential impact exceed the scope of routine alert triage**.

**Q20. What should an escalation package contain?**

**Answer:**

An escalation package should provide Tier 2 or the incident response team with the information needed to continue the investigation efficiently.

It should contain:

- Alert details
- Incident summary
- Affected assets
- User/account information
- Relevant timestamps
- Source and destination IPs
- Domains, URLs, and hashes
- Detection rule that triggered
- Baseline comparison
- IOC enrichment
- Relevant logs or evidence
- Timeline of observed activity
- Investigation steps already performed
- Analyst findings
- Current classification
- Reason for escalation
- Recommended next steps

The goal is to prevent Tier 2 from having to repeat the work already completed by Tier 1.

**Q21. How does SOC triage documentation become evidence during a post-incident review?**

**Answer:**

SOC tickets create a chronological record of what analysts observed and did.

They can show:

- When the alert was received
- When it was investigated
- What evidence was examined
- What decisions were made
- Who performed the actions
- When the incident was escalated
- What actions were taken afterward

During a post-incident review, this documentation can help reconstruct the incident timeline and determine whether the SOC followed its procedures.

Therefore, accurate documentation is not just administrative work—it can become part of the organization's **incident evidence and audit trail**.

**Q22. What is chain of custody, and why does it matter to Tier 1 analysts?**

**Answer:**

**Chain of custody** is the documented history of how evidence was collected, handled, transferred, stored, and analyzed.

It helps demonstrate that evidence was:

- Properly collected
- Not improperly altered
- Handled by authorized personnel
- Stored appropriately
- Traceable throughout the investigation

Chain-of-custody discipline can begin at **Tier 1** because the first analyst may be the person who encounters and records important evidence.

For example, if an analyst exports a log, preserves a suspicious file hash, or records network evidence, the action should be documented appropriately.

This helps maintain the integrity and credibility of the investigation.

**Q23. What is the overall purpose of SOC Tier 1 triage?**

**Answer:**

The purpose of Tier 1 triage is to **quickly and accurately separate routine activity from genuine security threats**, prioritize what matters most, document the reasoning, and escalate incidents that require deeper investigation.

A good Tier 1 analyst does not simply ask:

**"Did the rule fire?"**

They ask:

**"What happened, is it actually suspicious, how unusual is it, how important is the affected asset, and does this require further action?"**

That mindset is what turns raw security alerts into useful security decisions.
