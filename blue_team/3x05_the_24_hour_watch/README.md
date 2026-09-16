**1\. Full-Chain Shift Operation**

**Q1. What is the Full-Chain Shift Operation?**  
**A:** It means performing the complete security detection process from start to finish: **pipeline → baseline → detection catalog → triage**.

**Q2. What should I be able to do with an unseen evidence pack?**  
**A:** I should be able to take new evidence that I have not seen before and run the **entire detection chain** against it without assistance.

**Q3. What are the main phases of the detection chain?**  
**A:** The main phases are:

1. **Pipeline** – process and prepare the evidence.
2. **Baseline** – understand what normal activity looks like.
3. **Detection catalog** – apply detection rules to identify suspicious activity.
4. **Triage** – investigate and classify the alerts.

**Q4. What does "recover from dirty data" mean?**  
**A:** It means the pipeline should be able to handle problems such as **missing fields, malformed records, duplicates, or inconsistent data** without me manually fixing every record.

**Q5. What does "without manual intervention inside the pipeline" mean?**  
**A:** The pipeline should automatically detect and handle expected data problems instead of stopping and requiring me to manually edit the evidence.

**Q6. What are countable artifacts?**  
**A:** They are measurable output files or results produced at each phase, such as **number of events processed, alerts generated, anomalies found, or incidents created**.

**Q7. Why are countable artifacts important?**  
**A:** They make the investigation **measurable, auditable, and easy to verify**. We can show exactly what happened at each stage.

**2\. Investigative Depth**

**Q8. What does Investigative Depth mean?**  
**A:** It means being able to investigate an attack deeply by connecting evidence from different sources and reconstructing what happened.

**Q9. What does it mean to reconstruct a multi-step intrusion?**  
**A:** It means putting separate pieces of evidence together to understand the attack sequence, for example:

**Initial access → authentication → privilege escalation → network activity → suspicious action**

**Q10. Why is fragmented evidence difficult?**  
**A:** Because one part of the attack may appear in **Windows logs**, another in **Linux logs**, and another in **network or Wazuh data**. I need to connect them to understand the complete incident.

**Q11. What does "disparate sources" mean?**  
**A:** It means different types of evidence sources, such as **Windows logs, Linux logs, firewall logs, Suricata alerts, PCAP data, and Wazuh exports**.

**Q12. How do I distinguish a true incident from approved activity?**  
**A:** I compare the evidence with **known approved activity, timestamps, users, assets, baseline behavior, and other supporting evidence**.

**Q13. What does "noise" mean in SOC investigations?**  
**A:** Noise is activity that looks suspicious but does not represent a real security incident, such as **normal administrative activity or expected system behavior**.

**Q14. What does "bounded, auditable reasoning" mean?**  
**A:** It means my conclusion should be based only on **available evidence and clearly defined criteria**, so another analyst can review the evidence and understand how I reached the conclusion.

**Q15. What does it mean to operate across CLI and Wazuh artifacts?**  
**A:** It means I should be able to use both **command-line investigation tools** and **pre-exported Wazuh evidence** during the same investigation.

**3\. Campaign Analysis**

**Q16. What is Campaign Analysis?**  
**A:** Campaign analysis means looking at multiple incidents and determining whether they are connected and part of the **same attack campaign**.

**Q17. How can I link different incidents together?**  
**A:** I can compare:

- **Shared indicators** – same IP, domain, hash, username, etc.
- **Temporal proximity** – activity happening close together in time.
- **Tactical consistency** – attackers using similar techniques or methods.

**Q18. What are shared indicators?**  
**A:** They are common pieces of evidence between incidents, such as the **same source IP, file hash, domain, account, or malware indicator**.

**Q19. What does temporal proximity mean?**  
**A:** It means two or more suspicious activities happened **close to each other in time**, suggesting they may be related.

**Q20. What does tactical consistency mean?**  
**A:** It means different incidents show **similar attacker techniques or behaviors**, suggesting they may belong to the same campaign.

**Q21. What is HC-RED7?**  
**A:** HC-RED7 is the **known threat actor/campaign identity used in this capstone scenario**. I need to compare observed evidence against the known characteristics and indicators of HC-RED7.

**Q22. How do I determine whether activity belongs to HC-RED7?**  
**A:** I compare the observed evidence with **HC-RED7's known indicators, timing, techniques, and behavioral patterns** and document the supporting evidence.

**Q23. What if the activity does not match HC-RED7?**  
**A:** I should not force the evidence to fit HC-RED7. I should document that the activity is **inconsistent with HC-RED7** and consider whether it represents an unrelated actor or activity.

**4\. Professional Handoff**

**Q24. What is a professional handoff?**  
**A:** A professional handoff is a complete package of investigation results that allows the **next analyst or shift** to understand what happened and continue the work.

**Q25. What is a locked report schema?**  
**A:** It is a **fixed report format** where required fields and structures must be followed exactly.

**Q26. Why must incident reports follow the locked schema?**  
**A:** So that reports are **consistent, machine-readable, complete, and easy for other analysts or systems to process**.

**Q27. What are tuning changes?**  
**A:** Tuning changes are modifications to detection rules or thresholds to **reduce false positives or improve detection quality**.

**Q28. How should I propose tuning changes?**  
**A:** I should support them with **counted evidence**, such as how many alerts were false positives, how often a pattern occurred, or how a threshold affected detection quality.

**Q29. What is a shift handoff package?**  
**A:** It is the complete collection of information the next SOC team needs, including **incident reports, evidence, investigation results, detection findings, tuning recommendations, and relevant artifacts**.

**Q30. What should a complete shift handoff allow the next analyst to do?**  
**A:** The next analyst should be able to **understand the incidents, verify the evidence, see what has already been investigated, understand outstanding work, and continue from where the previous shift stopped**.

**⭐ One-line summary to remember**

**Q: What is the overall goal of this capstone?**  
**A:** **Take unseen evidence → process it → understand normal behavior → detect suspicious activity → investigate and connect incidents → identify the campaign → document everything → hand it over professionally.**
