**Digital Forensics – Learning Objectives (Questions & Answers)**

**1\. Technical Learning Objectives**

**Q1. Why do we verify forensic artifact integrity before and after analysis?**

Answer: To make sure the evidence has not been changed, damaged, or manipulated during the investigation.

We calculate a cryptographic hash (usually SHA-256) before and after analysis. If both hashes match, the file has remained unchanged.

Example: A disk image has the same SHA-256 hash before and after examination, confirming its integrity.

**Q2. What is filesystem timeline analysis using The Sleuth Kit?**

Answer: Filesystem timeline analysis helps investigators understand when files were created, modified, accessed, or deleted.

The Sleuth Kit (TSK) is a forensic toolkit used to examine disk images and extract filesystem metadata.

Important commands:

- fls – Lists files and directories, including deleted entries.
- mactime – Creates a chronological timeline from filesystem metadata.
- icat – Extracts file content using its inode or metadata address.

Example: Investigators discover that a suspicious executable was created shortly before a malware infection.

**Q3. What are Windows persistence artifacts, and why are they important?**

Answer: Windows persistence artifacts show how attackers or malware maintain access to a system after a restart.

Common examples include:

- Registry Run Keys: Automatically launch programs at login.
- Scheduled Tasks: Execute programs at specified times.
- Windows Services: Run programs in the background.
- Startup Folder: Automatically starts programs when a user logs in.

Example: Malware creates a Registry Run Key to execute itself whenever Windows starts.

**Q4. What is Volatility 3, and how is it used to analyze a Windows memory dump?**

Answer: Volatility 3 is a memory forensic framework used to investigate information captured from a computer's RAM.

It helps investigators identify running processes, network connections, suspicious code, and other memory artifacts.

Important commands:

vol -f memory.raw windows.info

vol -f memory.raw windows.pslist

vol -f memory.raw windows.pstree

vol -f memory.raw windows.netscan

vol -f memory.raw windows.malfind

Example: Investigators find a suspicious PowerShell process and an unusual network connection in the memory dump.

**Q5. Why do we correlate evidence from different artifacts into one incident timeline?**

Answer: Because one artifact cannot always explain the complete attack. Combining disk, memory, registry, and log evidence helps reconstruct what happened.

Example:

| **Time** | **Evidence**       | **Finding**                   |
| -------- | ------------------ | ----------------------------- |
| 10:00    | Authentication log | Suspicious login              |
| 10:05    | Disk image         | Malware file created          |
| 10:07    | Registry           | Persistence entry added       |
| 10:10    | Memory dump        | Suspicious process identified |
| 10:15    | Network log        | Connection to suspicious IP   |

This timeline helps investigators understand the attack sequence.

**2\. Conceptual Learning Objectives**

**Q6. What is chain of custody, and why is it a continuous process?**

Answer: Chain of custody is the documented record of who collected, handled, transferred, accessed, and stored digital evidence.

It is continuous because every interaction with evidence must be recorded throughout the investigation.

Example: When an investigator transfers a disk image to another analyst, the transfer time, person, purpose, and integrity checks are documented.

Main goal: Maintain evidence integrity, accountability, and reliability.

**Q7. What is the order of volatility in digital forensics?**

Answer: The order of volatility describes which types of digital evidence disappear or change most quickly.

Investigators generally prioritize collecting the most volatile evidence first, when safe and practical.

Typical order:

1. CPU registers and cache
2. RAM (running processes and active connections)
3. Temporary system and network information
4. Disk data
5. Archived logs and backups

Example: If a computer is powered off before RAM is collected, investigators may lose valuable information about running malware.

**Q8. What is the difference between confirmed, probable, and possible findings?**

Answer: These terms describe the level of confidence investigators have in their conclusions.

| **Finding** | **Meaning**                                                                 | **Example**                                     |
| ----------- | --------------------------------------------------------------------------- | ----------------------------------------------- |
| Confirmed   | Direct, reliable evidence supports the conclusion                           | A verified log records a successful login       |
| Probable    | Strong evidence suggests something happened, but confirmation is incomplete | Multiple artifacts suggest credential theft     |
| Possible    | Limited evidence indicates something may have happened                      | An unusual connection could indicate data theft |

Important: Investigators must not present assumptions as confirmed facts.

**Q9. What is HIPAA breach scope determination in digital forensics?**

Answer: HIPAA breach scope determination involves investigating whether protected health information (PHI) was accessed, acquired, used, or disclosed without authorization, and identifying which records and patients may have been affected.

Forensic investigators examine:

- Which systems and accounts were compromised.
- What patient information was accessible.
- Whether unauthorized access or data transfer occurred.
- How many patient records may have been affected.

Example: If an attacker compromises a hospital account, investigators examine access and network logs to determine whether patient records were viewed or exported.

Important: Forensic evidence supports the assessment, but a HIPAA breach determination also requires legal and regulatory risk assessment. Lack of evidence of exfiltration does not automatically prove that no breach occurred.

**3\. Transversal Learning Objectives**

**Q10. Why should a forensic report be written for two audiences?**

Answer: A forensic report should be understandable to both technical investigators and non-technical decision-makers.

- Technical audience: Needs detailed evidence, timestamps, hashes, commands, and findings.
- Management or legal audience: Needs a clear explanation of the incident, business impact, risks, and recommended actions.

Example:

Technical: "Volatility 3 identified a suspicious PowerShell process with PID 4520."

Management: "Investigators identified a potentially malicious program running on the affected computer."

Both statements should be linked to supporting evidence.

**Q11. Why must every assertion in a forensic report have an evidence reference?**

Answer: Evidence references make findings traceable, verifiable, and defensible.

Every important claim should identify the supporting artifact, such as a log entry, memory analysis result, disk image, or file hash.

Example:

"An unauthorized login occurred at 10:00 UTC (Evidence: AUTH-001, log entry 245)."

This allows another investigator to independently verify the finding.

**Q12. What does it mean to bound conclusions to what the evidence supports?**

Answer: It means investigators must only make conclusions supported by the available evidence and clearly explain any uncertainties or limitations.

Example:

Incorrect: "The attacker stole all patient records."

Correct: "Network logs show an outbound transfer of 500 MB, but the available evidence does not confirm what data was transferred."

Main principle: Never exaggerate findings or claim something happened without sufficient evidence.

**Quick Revision – Most Important Points**

| **Topic**            | **Remember**                                     |
| -------------------- | ------------------------------------------------ |
| Evidence integrity   | SHA-256 hashes before and after analysis         |
| Sleuth Kit           | Disk analysis and filesystem timelines           |
| Windows persistence  | Run Keys, Scheduled Tasks, Services              |
| Volatility 3         | RAM and running process analysis                 |
| Timeline correlation | Combine evidence to reconstruct attacks          |
| Chain of custody     | Document every evidence-handling action          |
| Order of volatility  | Collect volatile evidence first                  |
| Finding confidence   | Confirmed, probable, possible                    |
| HIPAA                | Determine possible PHI exposure and breach scope |
| Two audiences        | Technical details + management summary           |
| Evidence references  | Every important claim needs proof                |
| Bounded conclusions  | Never claim more than the evidence proves        |

Exam tip: Remember this investigation workflow:

Preserve evidence → Verify hashes → Analyze disk and memory → Correlate findings → Build timeline → Assess impact → Write evidence-based report.
