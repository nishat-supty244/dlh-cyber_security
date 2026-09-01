# Learning Objectives

By the end of this project, you should be able to explain the following concepts without the help of Google.

---

# Evidence Engineering

## 1. What is an evidence pipeline?

**Answer:**  
An evidence pipeline is a repeatable process that takes raw security evidence, such as Windows logs, Linux logs, and network-device logs, and transforms it into clean, structured, searchable, and validated data. The main stages are **intake, parse, normalize, clean, enrich, index, and validate**. Each stage prepares the evidence for the next stage. The goal is to make different types of security logs usable for investigation and detection.

---

## 2. What are the main stages of an evidence pipeline?

**Answer:**  
The main stages are:

1. **Intake** – Collect and inventory the incoming evidence.
2. **Parse** – Read the different source formats and extract individual events and fields.
3. **Normalize** – Convert different sources into a common event structure.
4. **Clean** – Fix or handle bad data such as malformed timestamps, duplicates, and encoding problems.
5. **Enrich** – Add useful context such as hostname, asset information, IP ownership, and network zone.
6. **Index** – Organize the processed events so they can be searched efficiently.
7. **Validate** – Check that the pipeline produced complete, consistent, and trustworthy output.

---

## 3. Why is each stage of the evidence pipeline necessary?

**Answer:**  
Each stage solves a different problem. Intake establishes what evidence was received, parsing makes raw evidence understandable, and normalization makes different sources comparable. Cleaning improves data quality, while enrichment adds operational context. Indexing makes investigation faster, and validation ensures that the final evidence can be trusted. Skipping a stage can create gaps or misleading results during an investigation.

---

## 4. How do Windows, Linux, and network-device logs differ?

**Answer:**  
Windows logs commonly use structured **Event IDs**, channels, providers, and Windows-specific fields. Linux logs often use **syslog-style text, journald records, or application-specific formats**. Network devices may produce syslog messages, firewall records, flow data, or vendor-specific formats. Because these sources describe events differently, their fields, timestamps, severity values, and identifiers may not match.

---

## 5. Why must different log structures be reconciled before analysis?

**Answer:**  
Without reconciliation, the same type of activity may appear completely different depending on the source. For example, a failed login on Windows and a failed login on Linux may use different field names and formats. Normalizing them allows an analyst to search for concepts such as **authentication failure** across all systems using one consistent structure. This makes correlation, detection, and timeline analysis much easier.

---

## 6. What is a unified event schema?

**Answer:**  
A unified event schema is a common structure used to represent security events from different sources. Instead of every log having its own structure, important information is mapped into consistent fields.

Typical fields include:

- Timestamp
- Event ID or event type
- Hostname
- Source IP
- Destination IP
- Source port
- Destination port
- Username
- Process or command
- Action
- Result/outcome
- Severity
- Log source
- Network zone
- Asset information

---

## 7. Which fields should be required in a unified event schema?

**Answer:**  
Required fields should contain information that is essential for identifying and investigating an event. For example, **timestamp, event type, source, and event/source attribution** are generally important. Other fields, such as username, process name, or destination IP, should be optional when they are not available from a particular source. A field should be required only when the pipeline can reasonably provide it for the events it processes.

---

## 8. Why should some fields be optional?

**Answer:**  
Different log sources do not provide the same information. A Windows process event may contain a username and process ID, while a network device event may contain source and destination IP addresses but no username. Making every field mandatory would result in large amounts of meaningless empty data. Optional fields preserve flexibility while still allowing the common schema to work across different sources.

---

## 9. What is the trade-off between fidelity and searchability during normalization?

**Answer:**  
**Fidelity** means preserving the original information exactly as it appeared in the source. **Searchability** means converting information into a consistent structure that is easy to query and correlate. Normalization improves searchability, but excessive normalization can remove source-specific details. Therefore, a good pipeline keeps important original information while creating common normalized fields for investigation.

---

## 10. What can be lost when source-specific fields are collapsed into a common format?

**Answer:**  
Source-specific information can be lost when different fields are forced into one generic field. Vendor-specific identifiers, detailed error codes, original message text, or special metadata may disappear. This can make the normalized data easier to search but less detailed for forensic analysis. Therefore, important raw or source-specific fields should be preserved alongside the normalized representation when possible.

---

# Data Quality and Enrichment

## 11. What is dirty data in a security context?

**Answer:**  
Dirty data is security evidence that is incomplete, inconsistent, corrupted, duplicated, or incorrectly formatted. Examples include **malformed timestamps, duplicate events, encoding errors, inconsistent timezones, and missing hostnames**. Dirty data can cause analysts to misunderstand what happened or when it happened.

---

## 12. Why does dirty data occur in production logging?

**Answer:**  
Production environments contain many different systems, applications, operating systems, vendors, and logging configurations. Devices may use different timezone settings, formats, encodings, or retention mechanisms. Logs can also be duplicated during collection or become incomplete because of network failures or misconfiguration. As a result, raw evidence rarely arrives in perfectly consistent form.

---

## 13. What are some common examples of dirty security data?

**Answer:**  
Common examples include:

- Incorrect or malformed timestamps
- Duplicate events
- Missing hostnames
- Incorrect timezones
- Corrupted characters or encoding
- Missing fields
- Inconsistent IP or username formats
- Truncated log messages
- Different severity naming conventions

---

## 14. Why are timezone inconsistencies dangerous during an investigation?

**Answer:**  
Timezone inconsistencies can make events appear to happen in the wrong order. An authentication event from one system might appear to happen before an attack even though it actually occurred afterward. This can lead to incorrect conclusions about attacker behavior. Converting timestamps to a consistent timezone, usually while preserving the original timestamp information, makes chronological analysis more reliable.

---

## 15. Why are duplicate events a problem?

**Answer:**  
Duplicates can make an activity appear more frequent or severe than it actually was. For example, one failed login recorded three times might incorrectly look like three separate attacks. Deduplication helps prevent false conclusions while preserving the original evidence where necessary for auditability.

---

## 16. What is enrichment in an evidence pipeline?

**Answer:**  
Enrichment means adding useful context to an event that was not present in the original log. For example, an IP address can be associated with a hostname, an asset can be assigned to a network zone, or a system can be identified as a critical server. Enrichment helps analysts understand **what the event means operationally**, not just what technically happened.

---

## 17. How does asset context change the meaning of an event?

**Answer:**  
The same event can have very different importance depending on the affected asset. For example, a failed login on a normal workstation may be relatively low priority, while the same failed login against a **domain controller or critical database server** could be highly suspicious. Asset context allows analysts to prioritize events based on business and security impact.

---

## 18. How does network-zone information change the meaning of an event?

**Answer:**  
Network zones describe where systems are located and what security role they have. An unexpected connection from a user workstation to a restricted server zone may be suspicious, while the same connection from an authorized application server may be normal. Network-zone context therefore helps analysts distinguish expected communication from potentially malicious lateral movement.

---

## 19. Why is a chronological timeline important to a SOC analyst?

**Answer:**  
A chronological timeline gives the analyst a single view of **what happened, when it happened, and where it happened**. It allows events from multiple systems to be placed in the correct order. During an incident, this helps reconstruct the attack path, identify the initial access, track lateral movement, and understand the sequence of attacker actions.

---

## 20. Why must a timeline include source attribution?

**Answer:**  
Source attribution tells the analyst where each event came from. An event might originate from a Windows Security log, Linux authentication log, firewall, or another network device. Without knowing the source, an analyst cannot properly validate or interpret the event. Source attribution also allows the analyst to go back to the original evidence when deeper investigation is required.

---

# Operational Reproducibility

## 21. Why must an evidence pipeline be runnable from a single command?

**Answer:**  
A single-command pipeline makes the process **repeatable, predictable, and easy to hand off**. Another engineer should not need to manually perform several undocumented steps to reproduce the results. It also reduces human error and makes it easier to rerun the pipeline when new evidence arrives.

---

## 22. What does it mean for a pipeline to generalize to unseen data?

**Answer:**  
It means the pipeline should work on new evidence that follows the defined input rules rather than being specially written for one particular dataset. It should process new timestamps, hosts, users, and events without requiring manual code changes. A professional pipeline handles **data according to its specification, not according to assumptions about one sample dataset**.

---

## 23. What is a bounded technical specification?

**Answer:**  
A bounded technical specification clearly defines what the pipeline **must do, what inputs it accepts, what outputs it produces, and what limitations apply**. It prevents ambiguity between engineers. For example, it can specify supported log formats, required fields, timestamp handling, normalization rules, output filenames, validation requirements, and error-handling behavior.

---

## 24. Why is a technical specification important for rebuilding a pipeline?

**Answer:**  
A specification provides enough detail for another engineer to reproduce the pipeline without relying on the original developer's memory. It documents the expected behavior, inputs, outputs, transformations, and validation rules. This makes the pipeline maintainable and auditable.

---

## 25. What does operational reproducibility mean?

**Answer:**  
Operational reproducibility means that another engineer can take the same inputs, follow the documented process, run the pipeline, and obtain equivalent outputs. It requires consistent processing rules, clear dependencies, defined inputs and outputs, and minimal manual intervention.

---

# Evidence Handoff & Downstream Work

## 26. Why is the evidence handoff package important?

**Answer:**  
The evidence handoff package becomes the trusted foundation for later security work. Detection, triage, threat hunting, and incident investigation all depend on reliable and well-structured evidence. If the evidence is incomplete or inconsistent, every downstream analysis can be affected.

---

## 27. How does the evidence pipeline support detection?

**Answer:**  
Detection rules need consistent fields to identify suspicious behavior. A normalized event schema allows detection logic to search across different sources without creating completely separate rules for every log format. For example, authentication failures from Windows and Linux can be compared using common normalized fields.

---

## 28. How does the evidence pipeline support triage?

**Answer:**  
Triage requires analysts to quickly determine **what happened, how serious it is, and what should be investigated first**. Clean, enriched, searchable evidence provides the context needed to prioritize alerts. Asset criticality, network zones, timestamps, and event sources can all help determine severity.

---

## 29. How does the evidence pipeline support investigation?

**Answer:**  
Investigation depends on reconstructing events accurately. A normalized and chronological evidence set allows analysts to correlate activity across hosts, users, and network devices. Source attribution and preserved raw information also allow analysts to verify important findings against the original evidence.

---

## 30. Why is the evidence handoff considered a foundation for the rest of the security module?

**Answer:**  
Because every downstream security activity depends on trustworthy evidence. Detection needs searchable events, triage needs contextualized events, and investigation needs accurate timelines and source attribution. If the evidence foundation is weak, later security conclusions may also be unreliable. Therefore, the handoff package is not just a final report—it is the **reusable evidence foundation for the entire security workflow**.
