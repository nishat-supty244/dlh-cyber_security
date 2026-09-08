**Detection Engineering Fundamentals**

**Q1. What are the four main types of detection?**

**Answer:** The four main detection types are:

1. **Signature detection** – looks for known malicious patterns or indicators.
2. **Anomaly detection** – looks for activity that is unusual compared with normal behavior.
3. **Behavioral detection** – looks for suspicious sequences or patterns of actions.
4. **Correlation detection** – combines multiple related events or data sources to identify suspicious activity.

**Q2. What is signature detection?**

**Answer:** Signature detection looks for a **specific, known pattern** associated with malicious activity.

For example, detecting a known malicious file name, IP address, hash, or command.

IF process_name = "mimikatz.exe"

THEN alert

It works well for known threats but may miss new or modified attacks.

**Q3. What is anomaly detection?**

**Answer:** Anomaly detection identifies activity that is **different from what is normally expected**.

For example, if a server normally runs:

nginx

sshd

cron

but suddenly starts running:

powershell.exe

that could be an anomaly.

**Q4. What is behavioral detection?**

**Answer:** Behavioral detection looks for a **suspicious pattern or sequence of actions** rather than one specific indicator.

For example:

Word document opens

↓

PowerShell starts

↓

PowerShell downloads a file

↓

The file executes

The complete sequence may indicate malicious behavior.

**Q5. What is correlation detection?**

**Answer:** Correlation detection combines **multiple related events** to identify a larger suspicious activity pattern.

For example:

Many failed logins

-

Successful login

-

Privileged access

-

Suspicious process

Together, these events provide stronger evidence of a possible compromise.

**Q6. What is a True Positive?**

**Answer:** A **True Positive (TP)** happens when the detection alerts and the activity is actually malicious.

**Example:**  
An attacker performs credential dumping and the detection correctly generates an alert.

**Q7. What is a False Positive?**

**Answer:** A **False Positive (FP)** happens when the detection alerts but the activity is actually legitimate.

**Example:**  
An administrator runs PowerShell for a legitimate maintenance task, but the detection generates an alert.

Too many false positives increase SOC workload and cause **alert fatigue**.

**Q8. What is a True Negative?**

**Answer:** A **True Negative (TN)** happens when the detection does not alert and the activity is actually benign.

**Example:**  
A normal user logs in successfully and no alert is generated.

**Q9. What is a False Negative?**

**Answer:** A **False Negative (FN)** happens when malicious activity occurs but the detection fails to generate an alert.

**Example:**  
An attacker performs credential theft, but the detection does not identify it.

False negatives are dangerous because real attacks can go unnoticed.

**Q10. Why are TP, FP, TN, and FN important?**

**Answer:** They help us understand how well a detection works.

- **TP:** Correctly detected malicious activity.
- **FP:** Incorrectly alerted on legitimate activity.
- **TN:** Correctly ignored legitimate activity.
- **FN:** Failed to detect malicious activity.

They help SOC teams measure detection confidence and manage analyst workload.

**Q11. Why must a detection rule be expressed as a precise predicate?**

**Answer:** A detection rule should clearly define **exactly what conditions cause an alert**.

For example:

event_id = 4625

AND

logon_type = 10

AND

user = administrator

This is precise and can be tested, automated, measured, and tuned.

**Q12. Why is free-text matching a last resort?**

**Answer:** Free-text matching is less reliable because log messages can vary between systems and vendors.

Structured fields are better because they are:

- More consistent
- Easier to query
- Easier to test
- Easier to tune
- Less dependent on wording

**Sigma Rule Authoring**

**Q13. What is Sigma?**

**Answer:** Sigma is a **vendor-neutral format for writing detection rules**.

It allows security teams to write a detection once and then convert it for different SIEM platforms.

**Q14. Why is Sigma vendor-neutral?**

**Answer:** Sigma separates the **detection logic** from the specific SIEM technology.

For example, the same detection idea can be used with:

- Splunk
- Microsoft Sentinel
- Elastic
- Other SIEM platforms

This makes detection rules more portable and reusable.

**Q15. What are the main parts of a Sigma rule?**

**Answer:** Important Sigma fields include:

title

id

status

logsource

detection

condition

falsepositives

level

tags

Each field provides different information about the detection.

**Q16. What is title in a Sigma rule?**

**Answer:** title gives the rule a clear, human-readable name.

Example:

title: Suspicious PowerShell Execution

**Q17. What is id in a Sigma rule?**

**Answer:** id gives the rule a **unique identifier** so it can be tracked and distinguished from other rules.

**Q18. What is status in a Sigma rule?**

**Answer:** status shows the current maturity or state of the rule.

For example:

status: experimental

means the rule is still being tested.

**Q19. What is logsource?**

**Answer:** logsource identifies **where the events come from**.

For example:

logsource:

product: windows

service: security

This tells us the rule is designed for Windows Security logs.

**Q20. What is the detection section?**

**Answer:** The detection section contains the **actual logic used to identify suspicious activity**.

Example:

detection:

selection:

EventID: 4625

condition: selection

**Q21. What is a selection in Sigma?**

**Answer:** A selection defines the **specific fields and values that the rule should look for**.

Example:

selection:

EventID: 4625

This selects Windows events with Event ID 4625.

**Q22. What is the condition field?**

**Answer:** condition defines **how the selections should be evaluated**.

For example:

condition: selection

means the rule alerts when the selection matches.

Conditions can also use:

AND

OR

NOT

**Q23. How does boolean logic work in Sigma?**

**Answer:** Boolean logic allows multiple conditions to be combined.

**AND:**

PowerShell

AND

Encoded command

Both conditions must be true.

**OR:**

PowerShell

OR

cmd.exe

Either condition can be true.

**NOT:**

PowerShell

AND NOT

Approved script

PowerShell must occur, but the approved script condition must not match.

**Q24. What are count and timeframe used for?**

**Answer:** They are used to detect events that occur **a certain number of times within a specific period**.

For example:

10 failed logins

within 5 minutes

This is useful for detecting brute-force attacks.

**Q25. What is falsepositives?**

**Answer:** falsepositives documents **known legitimate activities that may trigger the rule**.

For example:

falsepositives:

\- Administrative scripts

\- Software deployment

This helps SOC analysts understand possible legitimate causes of an alert.

**Q26. What is level?**

**Answer:** level indicates the severity of the detection.

Common levels are:

informational

low

medium

high

critical

**Q27. What are Sigma tags?**

**Answer:** Tags provide additional classification information about the rule.

They can also map the detection to **MITRE ATT&CK techniques**.

**Q28. Why should a Sigma rule be mapped to MITRE ATT&CK?**

**Answer:** MITRE ATT&CK mapping shows **which attacker technique the detection is designed to identify**.

It helps organizations:

- Measure detection coverage
- Identify gaps
- Organize detections
- Understand which attacker behaviors are monitored

So ATT&CK mapping is not just documentation; it helps measure actual security coverage.

**Q29. Why did Sigma become an industry reference?**

**Answer:** Sigma became widely useful because it provides a **common, vendor-neutral way to describe detection logic**.

A detection can therefore be shared and adapted across different SIEM platforms instead of being tied to one vendor.

**Detection Quality and Tuning**

**Q30. What is precision?**

**Answer:** Precision tells us:

**Of all the alerts generated, how many were actually malicious?**

Formula:

Precision = TP / (TP + FP)

High precision means most alerts are useful.

**Q31. What is recall?**

**Answer:** Recall tells us:

**Of all the actual malicious activity, how much did the detection catch?**

Formula:

Recall = TP / (TP + FN)

High recall means the detection misses fewer attacks.

**Q32. What is False Positive Rate?**

**Answer:** False Positive Rate measures how often benign activity is incorrectly detected as malicious.

Formula:

FPR = FP / (FP + TN)

A lower FPR generally means less unnecessary SOC workload.

**Q33. Why are precision and recall both important?**

**Answer:** Because a detection can be accurate but miss many attacks, or catch many attacks while generating too many false positives.

For example:

High precision + low recall

means the alerts are accurate, but many attacks are missed.

Low precision + high recall

means many attacks are caught, but the SOC receives lots of false alerts.

A good detection balances both according to organizational needs.

**Q34. How do you tune a detection that fires too often?**

**Answer:** First identify why legitimate activity is triggering the rule.

Then you can:

- Add more specific conditions
- Add context
- Add appropriate exclusions
- Use thresholds
- Use timeframes
- Use baselines
- Restrict the rule to relevant hosts or users

The goal is:

**Reduce false positives without losing the behavior the rule is supposed to detect.**

**Q35. What is detection coverage?**

**Answer:** Detection coverage means **which attacker techniques and behaviors an organization can detect**.

MITRE ATT&CK can be used to map these detections.

For example:

T1059.001 → PowerShell → Covered

T1078 → Valid Accounts → Covered

T1562.001 → Impair Defenses → Not Covered

The missing techniques represent potential detection gaps.

**Q36. How do you identify detection gaps?**

**Answer:** Map existing detections to MITRE ATT&CK techniques and compare them with the techniques relevant to the organization's threats and environment.

If an important technique has no detection, that represents a **coverage gap**.

**Q37. Why should detection prioritization be based on organizational risk?**

**Answer:** Because not every attack technique has the same importance to every organization.

Detection priorities should consider:

- Critical assets
- Business impact
- Threat likelihood
- Regulatory requirements
- Important attack paths
- Known threats to the organization

The priority should be:

**What could cause the most damage to our organization?**

rather than:

**What is the newest or most technically interesting attack?**

**Cross-Source Detection**

**Q38. Why do multi-source correlation rules produce higher-confidence findings?**

**Answer:** Because they combine **multiple pieces of evidence**.

For example:

Windows Security

↓

Successful login

Sysmon

↓

Suspicious process

DNS

↓

Suspicious domain

One event could be legitimate. When several related events occur together, the activity becomes more suspicious.

**Q39. What is a correlation rule?**

**Answer:** A correlation rule connects multiple events or detections based on relationships such as:

- Same user
- Same host
- Same IP
- Same process
- Same session
- Same time period

For example:

Failed login

-

Successful login

-

Privileged activity

-

Suspicious process

can produce a higher-confidence alert than any individual event.

**Q40. What are the limitations of pure Sigma correlation?**

**Answer:** Sigma can describe many correlation ideas, but complex correlation may require capabilities from the underlying SIEM or detection platform.

Complex correlation can require:

- Stateful tracking
- Large-scale joins
- Long time windows
- Session reconstruction
- Entity resolution
- Statistical analysis
- Advanced aggregation

Therefore, Sigma is not a replacement for the full correlation capabilities of a SIEM.

**Q41. What are correlation primitives?**

**Answer:** Correlation primitives are **normalized pieces of evidence that are easier to combine and correlate**.

For example:

AUTH_FAILURE

AUTH_SUCCESS

PRIVILEGE_ESCALATION

PROCESS_CREATE

DNS_REQUEST

NETWORK_CONNECTION

Instead of repeatedly processing different raw log formats, detections can work with these standardized events.

**Q42. When should evidence be preprocessed into correlation primitives?**

**Answer:** Evidence should be preprocessed when raw data is:

- Very large
- Inconsistent
- From multiple sources
- Difficult to query
- In need of normalization

Preprocessing makes later correlation faster, more consistent, and easier to manage.

**Quick Questions to Memorize**

**Q: Four detection types?**  
**A:** Signature, anomaly, behavioral, correlation.

**Q: TP?**  
**A:** Alert + malicious activity.

**Q: FP?**  
**A:** Alert + benign activity.

**Q: TN?**  
**A:** No alert + benign activity.

**Q: FN?**  
**A:** No alert + malicious activity.

**Q: Precision?**  
**A:** How many alerts were actually malicious.

**Q: Recall?**  
**A:** How much actual malicious activity was detected.

**Q: Sigma?**  
**A:** Vendor-neutral detection rule format.

**Q: MITRE ATT&CK mapping?**  
**A:** Shows which attacker techniques a detection covers.

**Q: Detection tuning?**  
**A:** Reduce false positives without losing the intended detection capability.

**Q: Detection coverage?**  
**A:** The attacker techniques and behaviors an organization can detect.

**Q: Correlation?**  
**A:** Combining multiple related events to increase detection confidence.

**Q: Correlation primitive?**  
**A:** A normalized event or piece of evidence prepared for correlation.
