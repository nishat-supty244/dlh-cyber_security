**Threat Hunting Methodology**

**1\. What is the difference between alert-driven detection and hypothesis-driven threat hunting?**

**Answer:**  
Alert-driven detection starts when a security tool generates an alert. The analyst investigates that alert to determine whether it is malicious.

Hypothesis-driven threat hunting starts with a **question or hypothesis**, such as: _"Could an attacker be using PowerShell Remoting to move laterally?"_ The hunter then searches the available data to prove or disprove that hypothesis.

**In short:**

- Alert-driven = **Alert → Investigation**
- Hypothesis-driven = **Question → Search → Evidence → Conclusion**

**2\. How do you derive a threat-hunting hypothesis from a security advisory and ATT&CK gap analysis?**

**Answer:**  
First, understand what techniques or vulnerabilities the advisory describes. Then map those techniques to **MITRE ATT&CK** and compare them with the organization's existing detection coverage.

If an important technique has little or no detection coverage, create a hunting hypothesis around it.

**Example:**  
If an advisory describes attackers using WMI for lateral movement and the ATT&CK gap analysis shows weak WMI detection, a hypothesis could be:

"An attacker may be using WMI to move from a compromised workstation to another internal system."

**3\. What is a positive finding in threat hunting?**

**Answer:**  
A positive finding is the **specific evidence that would prove our hypothesis is true**.

Before running a query, we should define what we are looking for.

**Example:**  
Hypothesis: _An attacker may be using PsExec for lateral movement._

Positive finding could be:

A service account authenticates to an unusual workstation outside its normal schedule and creates or starts a remote service.

Defining this beforehand prevents us from changing the criteria after seeing the results.

**4\. Why does threat hunting require a documented baseline?**

**Answer:**  
Because we need to know what **normal behavior looks like** before we can identify abnormal behavior.

For example, if an administrator normally uses PowerShell every morning from an approved workstation, that activity may be normal.

Without a baseline, we might incorrectly classify legitimate activity as malicious—or miss suspicious activity because we don't know what is unusual.

**5\. Why does the absence of SIEM alerts not prove the absence of threat activity?**

**Answer:**  
Because SIEM alerts depend on **available logs, detection rules, data sources and correct configuration**.

An attacker may perform malicious activity that:

- is not covered by an existing detection rule,
- occurs in a data source that is not being monitored,
- generates logs but does not trigger an alert, or
- uses legitimate tools that appear normal.

Therefore:

**No alert ≠ No attack.**

Threat hunting helps identify activity that existing detections may have missed.

**Living Off the Land Detection**

**6\. Why are PsExec, WMI and PowerShell Remoting difficult to detect using static IOCs?**

**Answer:**  
Because these are legitimate administrative tools and are commonly used by system administrators.

An attacker can abuse the same tools without introducing a unique malicious file, domain or IP address.

Therefore, detecting them based only on static IOCs is difficult. We need to examine **behavior and context**.

**7\. How can legitimate tools become suspicious through context?**

**Answer:**  
A tool itself may be legitimate, but the surrounding activity can make it suspicious.

We should consider:

- **Source host:** Where did the activity originate?
- **User:** Who performed it?
- **Target:** Which system was accessed?
- **Time:** When did it happen?
- **Frequency:** How often does it happen?
- **Authorization:** Is the activity expected?

**Example:**  
PowerShell from an administrator's workstation during scheduled maintenance may be normal.

PowerShell from an unusual workstation using a service account at 2 AM against multiple servers could be suspicious.

**8\. How can service-account misuse reveal credential compromise?**

**Answer:**  
Service accounts normally have predictable behavior. They usually run specific services or authenticate to specific systems.

If a service account suddenly:

- logs in interactively,
- authenticates from an unusual host,
- accesses systems it normally doesn't access, or
- operates outside its normal schedule,

it may indicate that the account's credentials have been compromised.

**9\. How can off-hours activity help identify adversary operations?**

**Answer:**  
Attackers often operate outside normal business hours to reduce the chance of being noticed.

If an account normally performs administrative activity from 08:00–18:00 but suddenly performs remote logins, PowerShell commands or lateral movement at 02:00, that behavior deserves investigation.

However, **off-hours activity alone does not prove malicious activity**. It must be compared with the authorized schedule and other evidence.

**Baseline Analysis**

**10\. How do you profile legitimate administrator behavior?**

**Answer:**  
We examine historical activity to understand what administrators normally do.

We can profile:

- normal login times,
- source workstations,
- target servers,
- administrative tools,
- accounts used,
- frequency of activity, and
- common maintenance patterns.

This creates a baseline against which unusual behavior can be compared.

**11\. How can an authorized schedule be used as a false-positive filter?**

**Answer:**  
If maintenance is officially scheduled for a specific time, activity during that period is more likely to be legitimate.

For example:

Authorized patching: Saturday 02:00–04:00

A PowerShell or remote-management event during that window may be expected.

The same activity at **Tuesday 02:17** from an unauthorized host would be more suspicious.

The schedule therefore helps reduce false positives.

**12\. How do you validate a service-account authentication against an authorization matrix?**

**Answer:**  
We compare the observed authentication with the account's approved permissions and expected behavior.

We ask:

1. Is this account authorized to access the target?
2. Is the source host approved?
3. Is the authentication method expected?
4. Is the time within the approved schedule?
5. Is the activity associated with an approved service or maintenance task?

If several answers are **no**, the authentication becomes suspicious.

**13\. How do you separate normal maintenance from adversary lateral movement?**

**Answer:**  
We compare the activity against the documented baseline and authorization records.

Normal maintenance usually has:

- an approved account,
- an approved source,
- an approved target,
- a known purpose,
- an expected time,
- and often a scheduled change or ticket.

Adversary lateral movement may show:

- unusual source hosts,
- unexpected targets,
- compromised accounts,
- unusual times,
- multiple systems accessed,
- or behavior inconsistent with the account's normal role.

**Evidence Correlation**

**14\. How do you combine separate findings into a unified attack timeline?**

**Answer:**  
We place individual events in chronological order and connect them based on common identifiers such as:

- username,
- hostname,
- IP address,
- process,
- timestamp,
- destination system.

For example:

Credential theft → unusual authentication → reconnaissance → lateral movement → remote execution → staging

Individually, each event might look harmless. Together, they may reveal an attack.

**15\. How do you correlate credential theft, lateral movement, reconnaissance and staging?**

**Answer:**  
We look for relationships between the activities.

For example:

1. **Credential theft:** An attacker obtains administrator credentials.
2. **Reconnaissance:** The attacker discovers internal systems.
3. **Lateral movement:** The stolen credentials are used to access another server.
4. **Staging:** Data or tools are collected and prepared on an internal system.

Connecting these events helps us understand the attacker's progression rather than investigating each event separately.

**16\. How do you map threat-hunting findings to MITRE ATT&CK?**

**Answer:**  
We identify the behavior observed during the hunt and map it to the corresponding **MITRE ATT&CK technique or sub-technique**.

Examples:

| **Observed behavior**         | **ATT&CK**                                     |
| ----------------------------- | ---------------------------------------------- |
| PowerShell abuse              | T1059.001 – PowerShell                         |
| WMI for remote execution      | T1047 – Windows Management Instrumentation     |
| PsExec/service-based movement | T1569.002 – Service Execution: Windows Service |
| Network/system discovery      | T1018 – Remote System Discovery                |
| Credential dumping            | T1003 – OS Credential Dumping                  |

This helps us understand the attack technique and identify detection gaps.

**17\. How can threat-hunting findings be turned into new detection rules?**

**Answer:**  
If hunting discovers a suspicious behavior, we can convert the behavior into a repeatable detection rule.

For example, the hunt discovers:

A service account authenticating from an unauthorized workstation outside its approved schedule.

We can create a detection rule that alerts whenever:

**Service account + unusual source host + unusual time + remote authentication**

occurs.

This turns a one-time hunting discovery into **continuous security monitoring**.

**Reporting**

**18\. How do you write a threat-hunting report for a SOC audience?**

**Answer:**  
A SOC-focused report should contain enough technical detail for analysts to investigate and reproduce the findings.

It should include:

- Hunt hypothesis
- Data sources
- Query/methodology
- Baseline
- Positive findings
- Evidence
- Timeline
- MITRE ATT&CK mapping
- Detection recommendations
- Remaining gaps

The SOC needs to understand **what happened, how we found it, and how to detect it next time**.

**19\. How do you write a threat-hunting report for leadership?**

**Answer:**  
Leadership usually does not need every technical query or log field.

The report should explain:

- What was investigated?
- What was found?
- How serious is it?
- What systems or accounts were affected?
- What risk does it create?
- What has been done?
- What still needs to be fixed?

The focus should be on **risk, impact, business relevance and recommended actions**.

**20\. What is the "coverage illusion"?**

**Answer:**  
The coverage illusion is the false belief that an organization is fully protected simply because it has many security tools and SIEM alerts.

Having a SIEM, EDR and many detection rules does not mean every attacker technique is covered.

For example:

**Tool exists → Logs exist → But no detection rule → No alert**

The attacker may still be active even though the SOC sees no alert.

Therefore, threat hunting is important for testing whether our actual detection coverage matches the coverage we believe we have.

**21\. How should remaining gaps and next-step recommendations be documented?**

**Answer:**  
We should clearly document what was **not detected or could not be investigated** and explain why.

For example:

- No logs available for a particular endpoint
- WMI activity not currently monitored
- Service-account baseline incomplete
- No detection for unusual PowerShell Remoting
- Authorized maintenance schedule not centrally documented

Then provide specific recommendations, such as:

"Create a detection for service-account authentication from unauthorized source hosts outside the approved maintenance window."

**22\. What is the overall purpose of threat hunting?**

**Answer:**  
The purpose of threat hunting is to proactively search for malicious or suspicious activity that existing security controls may have missed.

A simple way to remember the process is:

**Hypothesis → Baseline → Query → Evidence → Correlation → ATT&CK Mapping → Detection → Report**

The goal is not only to **find attackers**, but also to improve the organization's ability to **detect them in the future**.
