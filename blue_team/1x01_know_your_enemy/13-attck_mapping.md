# ATT&CK Mapping Assessment

---

# Scenario Alpha: "Operation Flatline"

| Step | ATT&CK Tactic | Technique (MITRE ATT&CK ID) |
|------|---------------|-----------------------------|
| **Step 1** | Reconnaissance | Gather Victim Organization Information (**T1592**) |
| **Step 2** | Initial Access | Spearphishing Attachment (**T1566.001**) |
| **Step 3** | Persistence | Scheduled Task (**T1053.005**) |
| **Step 4** | Discovery | Network Service Discovery (**T1046**) |
| **Step 5** | Credential Access | LSASS Memory (**T1003.001**) |
| **Step 6** | Lateral Movement | Pass the Hash (**T1550.002**) |
| **Step 7** | Exfiltration | Exfiltration Over Web Service (**T1567**) |
| **Step 8** | Impact | Inhibit System Recovery (**T1490**) |
| **Step 9** | Impact | Data Encrypted for Impact (**T1486**) |

---

# Scenario Beta: "The Quiet Departure"

| Step | ATT&CK Tactic | Technique (MITRE ATT&CK ID) |
|------|---------------|-----------------------------|
| **Step 1** | Reconnaissance | Gather Victim Organization Information (**T1592**) |
| **Step 2** | Discovery | System Information Discovery (**T1082**) |
| **Step 3** | Collection | Data from Local System (**T1005**) |
| **Step 4** | Exfiltration | Exfiltration Over Physical Medium (**T1052.001**) |
| **Step 5** | Defense Evasion | File Deletion (**T1070.004**) |
| **Step 6** | Credential Access | Credentials in Files (**T1552.001**) |
| **Step 7** | Persistence | Valid Accounts (**T1078**) |
| **Step 8** | Exfiltration | Exfiltration Over Web Service (**T1567**) |

---

# ATT&CK Coverage Assessment

Both scenarios share several common MITRE ATT&CK tactics and techniques, including:

- **Reconnaissance**
- **Credential Access**
- **Exfiltration**

This overlap demonstrates that both external attackers and malicious insiders follow similar attack patterns before achieving their objectives.

As a result, **MedDefense** should prioritize implementing:

- Continuous internal network traffic monitoring
- User Behavior Analytics (UBA)
- Credential access monitoring
- Data exfiltration detection
- Centralized security monitoring through SIEM and EDR

Strengthening visibility across these attack stages will improve MedDefense's ability to detect and interrupt malicious activity before sensitive patient data is compromised.
