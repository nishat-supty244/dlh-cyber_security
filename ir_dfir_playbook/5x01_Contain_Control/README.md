**Learning Objectives**

Topic: Incident Response – Triage, Evidence Preservation, Containment, Eradication, and Recovery

**Technical Learning Objectives**

Q1. How do you perform initial triage on progressively revealed alert and log evidence?

Answer: Initial triage involves reviewing security alerts, system logs, and network activity to identify suspicious behavior. As new evidence appears, analysts update the incident's severity, scope, and priority. They distinguish confirmed facts from assumptions before making decisions.

Q2. Why should volatile and non-volatile evidence be preserved before containment?

Answer: Evidence must be preserved to support investigation and prevent data loss.

- Volatile evidence: RAM, running processes, active network connections, and logged-in sessions.
- Non-volatile evidence: Disk files, event logs, registry entries, and stored malware.

Volatile evidence should be collected first when safe because it can disappear after shutdown or isolation. However, urgent containment may take priority if an active threat is causing serious damage.

Q3. How do you select containment strategies based on operational trade-offs?

Answer: Containment strategies should balance security risks with business operations. For example, isolating an infected server may stop an attack but interrupt critical services. Analysts can choose network segmentation, blocking malicious IPs, disabling compromised accounts, or full isolation depending on the threat and operational impact.

Q4. How do you eradicate threats and verify Windows persistence mechanisms?

Answer: Eradication involves removing malware, malicious processes, compromised accounts, and persistence mechanisms. Analysts should inspect Windows Registry Run keys, scheduled tasks, services, startup folders, and WMI subscriptions. After removal, they verify that malicious processes do not restart and no suspicious activity remains.

Q5. How do you validate service recovery with evidence rather than assumptions?

Answer: Recovery is validated by checking system functionality, reviewing security logs, testing network connectivity, and confirming that critical applications work normally. Analysts also monitor for reinfection and obtain confirmation from service owners before closing the incident.

**Conceptual Learning Objectives**

Q6. What is the correct order between evidence preservation and containment?

Answer: The normal order is to identify the incident, preserve critical evidence, and then contain the threat. Evidence preservation helps investigators understand the attack. However, if the attack is actively spreading or threatening critical systems, immediate containment may be necessary, with the reason documented.

Q7. Why should incident severity be reassessed when the scope changes?

Answer: Incident severity depends on the impact, affected systems, and potential damage. For example, malware on one workstation may initially be classified as medium severity. If it spreads to critical hospital servers or exposes patient information, severity should be increased and the response escalated.

Q8. Why must eradication address process, credential, and network persistence?

Answer: Removing malware files alone may not eliminate an attacker. Attackers can maintain access through running processes, stolen credentials, scheduled tasks, remote connections, or backdoors. Complete eradication requires removing all identified access methods, resetting compromised credentials, closing unauthorized connections, and verifying that the threat cannot return through known persistence mechanisms.

Q9. Why is handoff quality considered a measurable outcome rather than a courtesy?

Answer: A proper handoff ensures the next analyst understands the incident without repeating the investigation. It should include the incident timeline, evidence, actions taken, current system status, remaining risks, and next steps. Handoff quality can be measured through completeness, accuracy, and whether the receiving team can continue the response effectively.

**Transversal Learning Objectives**

Q10. How do you maintain an accurate incident timeline under pressure?

Answer: Analysts should record important events in chronological order, including alert times, suspicious activities, evidence collection, containment actions, and recovery steps. Timestamps should use a consistent time zone and identify the evidence source. This helps reconstruct the attack and prevents confusion during investigations.

Q11. Why must every incident response decision be justified when it is taken?

Answer: Documenting decisions provides accountability and explains why specific actions were chosen. For example, if an analyst isolates a server, they should record the threat, supporting evidence, expected impact, and reason for isolation. This helps future reviews and improves incident response procedures.

Q12. How do you separate known facts from assumptions during an investigation?

Answer: Known facts are supported by verified evidence, while assumptions are possibilities that require further investigation.

Example:

- Known fact: Security logs show a suspicious login from an unfamiliar IP address.
- Assumption: The attacker has stolen the user's credentials.
- Next step: Review authentication logs, MFA events, and user activity to confirm or reject the assumption.

Separating facts from assumptions prevents incorrect conclusions and unnecessary containment actions.

Key takeaway: Effective incident response follows a structured process of Triage → Evidence Preservation → Containment → Eradication → Recovery → Verification → Handoff, with continuous documentation and severity reassessment throughout.
