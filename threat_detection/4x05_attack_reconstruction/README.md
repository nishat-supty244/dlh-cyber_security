**Objective**

**To reconstruct a complete cyberattack by correlating evidence from email, network, endpoint, threat intelligence, and SIEM sources, building an accurate attack timeline, mapping attacker techniques to MITRE ATT&CK, assessing the impact, and producing an evidence-based investigation report.**

**Learning Objectives of the project:**

**1\. Cross-Evidence Correlation**

**Q1. What is cross-evidence correlation?**  
**A:** Cross-evidence correlation means combining evidence from different investigation sources, such as email, network traffic, endpoint logs, threat intelligence, and SIEM, to build one complete picture of an attack.

**Q2. Why is cross-evidence correlation important?**  
**A:** One source may only show part of an attack. By comparing multiple sources, we can confirm what really happened and reduce the risk of relying on incomplete or misleading evidence.

**Q3. What is convergence in cybersecurity evidence?**  
**A:** Convergence happens when multiple independent sources support the same finding. For example, an email shows a phishing link was clicked, endpoint logs show a process started afterward, and network logs show communication with the same malicious domain.

**Q4. What is divergence in cybersecurity evidence?**  
**A:** Divergence happens when evidence sources disagree or when a finding from one source is not supported by another source. This does not automatically mean one source is wrong; there may be collection gaps, timing differences, or missing logs.

**Q5. How do you decide which evidence source is more reliable?**  
**A:** It depends on what we are trying to prove. For example, network capture may be authoritative for network communication, while endpoint logs may be more authoritative for process execution. We should use the source that directly observes the event we are investigating.

**Q6. Why might network timestamps and SIEM timestamps be different for the same event?**  
**A:** They can differ because of timezone settings, clock skew, log forwarding delays, processing time, or differences in how each system records timestamps.

**Q7. How do you resolve contradictions between evidence sources?**  
**A:** I would check the timezone, clock synchronization, collection and forwarding delays, missing logs, source reliability, and how the evidence was preserved. Then I would determine whether the contradiction can be explained or whether the event must remain uncertain.

**2\. Attack Timeline Reconstruction**

**Q8. What is attack timeline reconstruction?**  
**A:** It is the process of taking fragmented evidence from different sources and putting the events into chronological order to understand how the attack developed.

**Q9. Why is timeline reconstruction important?**  
**A:** It helps us understand the attack from initial access to execution, persistence, lateral movement, data access, and possible exfiltration.

**Q10. What is a temporal anchor?**  
**A:** A temporal anchor is a high-confidence event with a reliable timestamp that can be used as a fixed point when organizing other events around it.

**Q11. Give an example of a temporal anchor.**  
**A:** A confirmed phishing email delivery time, a recorded login event, or a network packet showing a connection at a specific timestamp can act as a temporal anchor.

**Q12. What is a confirmed sequence?**  
**A:** A confirmed sequence is when there is direct evidence showing that one event occurred and was followed by another event, with enough correlation to establish the relationship.

**Q13. What is an inferred sequence?**  
**A:** An inferred sequence is when we believe one event probably happened before another based on evidence and attack logic, but there is no direct evidence proving the exact relationship.

**Q14. What is dwell time?**  
**A:** Dwell time is the amount of time an attacker remains inside an environment before being detected or removed.

**Q15. What is breakout time?**  
**A:** Breakout time is the time it takes an attacker to move from the initially compromised system to other systems or resources within the environment.

**Q16. What is operational tempo?**  
**A:** Operational tempo describes how quickly and frequently an attacker performs actions during an attack.

**3\. ATT&CK Mapping at Scale**

**Q17. What is MITRE ATT&CK mapping?**  
**A:** It is the process of mapping observed attacker behaviors to techniques and tactics in the MITRE ATT&CK framework.

**Q18. Why should ATT&CK techniques have confidence levels?**  
**A:** Because not every technique is equally proven. Confidence levels show how strong the evidence is behind each technique.

**Q19. What does "confirmed" mean in ATT&CK mapping?**  
**A:** Confirmed means there is direct evidence that the attacker used the technique.

**Q20. What does "probable" mean?**  
**A:** Probable means there is strong circumstantial evidence supporting the technique, but direct evidence is missing.

**Q21. What does "possible" mean?**  
**A:** Possible means the technique fits the attack behavior, but the available evidence is indirect or insufficient to confirm it.

**Q22. What is an ATT&CK coverage gap?**  
**A:** It is an area where we do not have sufficient detection or visibility for a particular technique.

**Q23. Are all ATT&CK coverage gaps genuine security blind spots?**  
**A:** No. Some gaps may exist because the organization does not collect the necessary logs or telemetry. This is a collection limitation rather than necessarily a detection failure.

**Q24. Why can ATT&CK coverage percentages give a false sense of security?**  
**A:** A high percentage does not necessarily mean the organization can detect the techniques that matter most. An organization might have broad coverage but still miss critical techniques used in a real attack.

**Q25. Why is attack reconstruction important alongside ATT&CK coverage?**  
**A:** Reconstruction shows which techniques actually mattered during the attack, rather than simply showing how many ATT&CK techniques the organization theoretically covers.

**4\. Impact Assessment**

**Q26. What is impact assessment in an investigation?**  
**A:** Impact assessment determines what systems, data, users, and business operations were affected or potentially affected by the attack.

**Q27. How do you determine the impact of compromised systems?**  
**A:** I would identify the compromised systems, compare them with the asset inventory, determine what data they contain, and check the classification and sensitivity of that data.

**Q28. What is confirmed data exposure?**  
**A:** Confirmed data exposure means there is evidence that the attacker actually accessed or obtained the data.

**Q29. What is potential data exposure?**  
**A:** Potential data exposure means the attacker had access to a system or data, so exposure was possible, but there is no evidence confirming that the data was actually accessed or taken.

**Q30. What is prevented data exposure?**  
**A:** Prevented data exposure means suspicious activity was detected and stopped before the attacker could access or exfiltrate the targeted data.

**Q31. How do you assess HIPAA implications?**  
**A:** I would first establish what happened using evidence, determine whether protected health information was accessed or acquired, and then assess whether the incident meets the applicable HIPAA breach-notification requirements. We should not assume a notification is required simply because a healthcare system was compromised.

**5\. Professional Reporting**

**Q32. What is the purpose of an attack reconstruction report?**  
**A:** The purpose is to clearly explain what happened, how the attacker operated, what was affected, what evidence supports the findings, and what remains unknown.

**Q33. How should a report serve both technical and executive audiences?**  
**A:** It should provide technical evidence and detailed analysis for security teams while also presenting the key impact, risk, timeline, and recommendations in clear language for executives.

**Q34. What is evidence traceability?**  
**A:** Evidence traceability means every important claim in the report can be traced back to a specific evidence source, finding, and timestamp.

**Q35. Why are evidence citations important?**  
**A:** They allow another investigator to verify the conclusion and understand exactly how the conclusion was reached.

**Q36. How should unknown information be documented?**  
**A:** It should be explicitly stated as unknown or unconfirmed, along with the reason, such as missing logs, insufficient telemetry, or conflicting evidence.

**Q37. Why is documenting what is unknown important?**  
**A:** Because it prevents investigators from presenting assumptions as facts. Being transparent about uncertainty makes the investigation more credible and defensible.

**Q38. What is the main principle of professional incident reporting?**  
**A:** **Separate facts from assumptions.** Clearly explain what is confirmed, what is probable, what is possible, and what cannot currently be determined.

**⭐ Easy way to remember the whole project**

**Correlate → Reconstruct → Map → Assess → Report**

- **Correlate:** Combine evidence from different sources.
- **Reconstruct:** Build the attack timeline.
- **Map:** Map attacker behavior to MITRE ATT&CK.
- **Assess:** Determine systems, data, and organizational impact.
- **Report:** Explain findings, evidence, uncertainty, and recommendations.
