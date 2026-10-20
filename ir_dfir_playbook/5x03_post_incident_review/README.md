**Learning Objectives**

**Technical Learning Objectives**

Q1. What is a security control effectiveness audit?

Answer: It checks whether existing security controls actually worked during a real incident. We compare the incident timeline with security logs, alerts, and control responses to identify what worked, failed, or was missing.

Q2. What is a Sigma detection rule?

Answer: Sigma is a standard YAML-based format for writing security detection rules. It helps identify suspicious activities such as unusual logins, credential theft, privilege escalation, and lateral movement from security logs.

Q3. What are TTPs?

Answer: TTPs stand for Tactics, Techniques, and Procedures. They describe why attackers act, how they attack, and the specific methods they use.

Q4. How do we test detection rules?

Answer: We test rules using two types of samples:

- Positive samples: Known malicious activities that should trigger alerts.
- Negative samples: Normal activities that should not trigger alerts.

This helps measure detection accuracy and false positives.

Q5. What is a false positive rate?

Answer: It measures how often a detection rule incorrectly identifies normal activity as malicious.

Formula:

\\\[ FPR = \\frac{FP}{FP+TN}\\times100 \\\]

Where FP = False Positives and TN = True Negatives.

Q6. What is threat intelligence enrichment?

Answer: It means adding information from open-source threat intelligence platforms to existing IOCs and TTPs to better understand threats, attackers, and possible future attacks.

Examples: VirusTotal, AlienVault OTX, and MITRE ATT&CK.

Q7. What are IOCs?

Answer: Indicators of Compromise (IOCs) are pieces of evidence that may indicate a cyberattack, such as malicious IP addresses, suspicious domains, file hashes, and unusual URLs.

Q8. What is security hardening?

Answer: Security hardening means improving system security by reducing vulnerabilities and unnecessary access.

Examples include enabling MFA, restricting administrative privileges, patching vulnerabilities, and improving logging.

**Conceptual Learning Objectives**

Q9. What is the difference between controls in place and controls that work?

Answer: A control in place means a security measure exists. A control that works means it successfully prevents, detects, or responds to threats.

For example, having an SIEM does not guarantee security if it fails to detect suspicious activities.

Q10. What is the detection engineering lifecycle?

Answer: Detection engineering follows four main steps:

1. Write: Create detection rules for suspicious activities.
2. Test: Check rules against malicious and normal samples.
3. Tune: Reduce false positives and improve accuracy.
4. Deploy: Implement validated rules in the security monitoring system.

The process repeats as threats and systems change.

Q11. Why is threat intelligence forward-looking?

Answer: Threat intelligence is not only about understanding past attacks. It also helps predict potential threats, identify emerging attack techniques, and improve defenses before another incident happens.

Q12. What is a risk register?

Answer: A risk register is a document that records identified security risks, their likelihood, impact, mitigation actions, responsible owners, and status.

Q13. Why is a risk register called a living document?

Answer: Because it must be continuously updated based on new vulnerabilities, incidents, security findings, and changes in the organization's environment.

**Transversal Learning Objectives**

Q14. Why must every security improvement have an owner, deadline, and validation method?

Answer: To ensure accountability and successful implementation.

- Owner: Person responsible for the improvement.
- Deadline: Date by which the action must be completed.
- Validation: Method used to confirm that the improvement works.

Q15. What does "bound conclusions to evidence" mean?

Answer: It means every conclusion must be supported by actual evidence, such as logs, alerts, incident timelines, or forensic findings. We should not make assumptions without proof.

Q16. What does "bound recommendations to findings" mean?

Answer: It means every security recommendation should address a specific problem discovered during the investigation.

For example, if an incident revealed that suspicious logins were not detected, the recommendation should be to implement and test appropriate login detection rules.

Q17. Why should security artifacts be written clearly?

Answer: Security artifacts must contain clear instructions, technical details, responsible owners, and validation steps so other engineers can implement them without needing additional explanations.

**Quick Revision – Important Exam Questions**

| **Question**                           | **Short answer**                                              |
| -------------------------------------- | ------------------------------------------------------------- |
| What is a control effectiveness audit? | Checking whether security controls worked during an incident. |
| What is Sigma?                         | YAML-based security detection rule format.                    |
| What are TTPs?                         | Tactics, Techniques, and Procedures.                          |
| What are IOCs?                         | Indicators of Compromise.                                     |
| What is a false positive?              | Normal activity incorrectly detected as malicious.            |
| What is threat intelligence?           | Information used to understand and anticipate cyber threats.  |
| What is security hardening?            | Reducing vulnerabilities and improving system protection.     |
| What is detection engineering?         | Writing, testing, tuning, and deploying detection rules.      |
| What is a risk register?               | A document tracking risks and mitigation actions.             |
| Why update the risk register?          | To reflect new findings and changing risks.                   |
| Why assign an owner?                   | To ensure accountability.                                     |
| Why validate improvements?             | To confirm security fixes actually work.                      |
| Why use evidence?                      | To support accurate conclusions and recommendations.          |

Most important concept to remember: Security improvement is not just about having tools and policies. It is about proving they work through evidence, testing, and continuous improvement.
