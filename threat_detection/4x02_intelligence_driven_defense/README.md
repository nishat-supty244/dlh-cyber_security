**Threat Intelligence **

**1\. Threat Intelligence Lifecycle**

**Q1. What is the Threat Intelligence Lifecycle?**

**Answer:**

The Threat Intelligence Lifecycle is a continuous process used to collect, process, analyze, share, and improve cyber threat information.

The main stages are:

1. **Collection** – Gather information from logs, threat feeds, reports, investigations, malware analysis, etc.
2. **Processing** – Clean, normalize, deduplicate, and organize the collected data.
3. **Analysis** – Determine what the information means and whether it represents a real threat.
4. **Dissemination** – Share useful intelligence with the people or systems that need it.
5. **Feedback** – Get feedback about whether the intelligence was useful and use it to improve the next cycle.

**Simple flow:**

Collection → Processing → Analysis → Dissemination → Feedback → Collection

**Q2. How does the intelligence cycle operate in practice?**

**Answer:**

Suppose a SOC discovers a suspicious IP address during an investigation.

- **Collection:** The SOC collects the IP from firewall logs and other sources.
- **Processing:** They remove duplicates and normalize the IP.
- **Analysis:** They investigate whether the IP is connected to malware or an attacker.
- **Dissemination:** If confirmed malicious, they share it with the SOC, firewall team, threat intelligence team, or trusted partners.
- **Feedback:** The team checks whether blocking the IP helped and whether more information is needed.

The result becomes useful intelligence instead of just raw data.

**Q3. How can internal investigation findings become intelligence that can be shared with partners?**

**Answer:**

An internal investigation may discover useful information such as:

- Malicious IP addresses
- Domains
- URLs
- File hashes
- Phishing techniques
- Malware behavior
- Attack methods
- Infrastructure relationships

The organization validates and analyzes these findings, removes unnecessary sensitive information, adds context, and creates an intelligence report or indicator package.

The useful information can then be shared with trusted partners, provided that legal, privacy, and sharing restrictions are followed.

**Q4. What is strategic intelligence?**

**Answer:**

Strategic intelligence provides a **high-level view of threats** and is mainly used by senior management and decision-makers.

It answers questions such as:

- What threats are affecting our industry?
- What risks are increasing?
- Where should we invest security resources?

**Example:**

A report explaining that ransomware targeting healthcare organizations is increasing and may require additional security investment.

**Q5. What is operational intelligence?**

**Answer:**

Operational intelligence focuses on **ongoing campaigns, attacks, and adversary activities**.

It helps security teams understand:

- Who may be attacking
- What campaign is occurring
- How the attacker operates
- What infrastructure is being used
- What may happen next

**Example:**

Information about a phishing campaign targeting hospitals and the infrastructure used by the attackers.

**Q6. What is tactical intelligence?**

**Answer:**

Tactical intelligence focuses on **technical details that defenders can use directly**.

Examples include:

- IP addresses
- Domains
- URLs
- File hashes
- Malware characteristics
- MITRE ATT&CK techniques

**Example:**

A malicious domain used in a phishing campaign that can be searched for in DNS logs.

**Q7. What is the difference between strategic, operational and tactical intelligence?**

**Answer:**

| **Type**    | **Focus**                           | **Main Users**                  |
| ----------- | ----------------------------------- | ------------------------------- |
| Strategic   | Big-picture threats and risks       | Management                      |
| Operational | Campaigns and attacker activity     | Threat intelligence / SOC teams |
| Tactical    | Technical indicators and techniques | Analysts / Detection engineers  |

**Simple way to remember:**

- **Strategic = Why it matters**
- **Operational = What the attacker is doing**
- **Tactical = How to detect it**

**Q8. Why must intelligence be operationalized?**

**Answer:**

Intelligence is useful only when defenders can **do something with it**.

It can be operationalized into:

- Detection rules
- SIEM searches
- Threat hunting queries
- Firewall blocks
- IDS/IPS rules
- YARA rules
- Incident response procedures
- Security decisions

For example, discovering a malicious domain is useful, but turning that domain into a DNS detection rule makes the intelligence actionable.

**Q9. Why is threat intelligence a cycle rather than a one-time report?**

**Answer:**

Threats continuously change.

Attackers can:

- Change domains
- Change IP addresses
- Modify malware
- Change techniques
- Use new infrastructure

Therefore, intelligence must continuously be updated.

Feedback from previous investigations helps determine what should be collected next.

**The cycle continues because the threat environment continuously changes.**

**2\. Source Assessment and Intelligence Quality**

**Q10. What is source assessment?**

**Answer:**

Source assessment is the process of determining **how reliable a source is** and how much confidence we should have in the information it provides.

For example, an established security organization with a strong history of accurate reporting may be considered more reliable than an unknown anonymous source.

However, source reliability and information credibility are evaluated separately.

**Q11. What is the Admiralty Code?**

**Answer:**

The Admiralty Code is a structured system for evaluating intelligence based on two separate factors:

1. **Reliability of the source**
2. **Credibility of the information**

Common source reliability ratings are:

- **A = Completely reliable**
- **B = Usually reliable**
- **C = Fairly reliable**
- **D = Not usually reliable**
- **E = Unreliable**
- **F = Reliability cannot be judged**

Common information credibility ratings are:

- **1 = Confirmed by other sources**
- **2 = Probably true**
- **3 = Possibly true**
- **4 = Doubtful**
- **5 = Improbable**
- **6 = Truth cannot be judged**

For example, an intelligence item might receive a rating such as **B2**.

**Q12. Why should source reliability and information credibility be assessed separately?**

**Answer:**

Because a reliable source can still provide incorrect information, and an unreliable source can sometimes provide correct information.

For example:

A trusted security company reports that an IP belongs to an attacker.

The source may be highly reliable, but if the claim has not yet been independently confirmed, the information itself may have lower confidence.

Therefore:

**Reliable source ≠ automatically true information.**

**Q13. Why is conflicting intelligence normal?**

**Answer:**

Different intelligence sources may have:

- Different visibility
- Different collection methods
- Different time periods
- Different definitions
- Incomplete information

For example, one source may attribute an attack to Group A while another attributes it to Group B.

This does not automatically mean that one source is lying. Analysts need to investigate the evidence behind each claim.

**Q14. How should conflicting attribution labels be reconciled?**

**Answer:**

An analyst should:

1. Identify exactly what each source claims.
2. Check the evidence supporting each claim.
3. Compare the reliability of the sources.
4. Check whether the sources refer to the same incident.
5. Look for independent supporting evidence.
6. Record uncertainty where attribution cannot be confirmed.

The analyst should **not simply choose the label from the most famous source**.

**Q15. What is the difference between a confirmed fact, analytical assessment and unsupported assumption?**

**Answer:**

**Confirmed fact:**  
Something directly supported by reliable evidence.

Example:

The IP 91.234.99.107 appeared in the firewall logs.

**Analytical assessment:**  
A conclusion based on available evidence.

Example:

The IP is likely part of the phishing infrastructure.

**Unsupported assumption:**  
A claim without sufficient evidence.

Example:

The IP definitely belongs to Group X.

A good intelligence report clearly separates these three.

**Q16. What is a confidence level?**

**Answer:**

A confidence level shows **how certain the analyst is about a conclusion**.

For example:

- **High confidence:** Strong evidence from multiple reliable sources.
- **Medium confidence:** Good evidence but some uncertainty remains.
- **Low confidence:** Limited or conflicting evidence.

Confidence should be based on evidence, not on how strongly the analyst feels about the conclusion.

**3\. Indicator Triage and Enrichment**

**Q17. What is an indicator?**

**Answer:**

An indicator is a piece of information that can help identify potentially malicious activity.

Examples:

- IP address
- Domain
- URL
- File hash
- Email address
- Malware filename

These are often called **IOCs — Indicators of Compromise**.

**Q18. Why should indicators be normalized and deduplicated?**

**Answer:**

Indicators often come from many different sources and may appear in different formats.

For example:

Example.COM

example.com

EXAMPLE.COM

These are essentially the same domain.

Normalization makes them consistent, while deduplication removes repeated indicators.

This improves:

- Searching
- Detection
- Reporting
- Blocking
- Analysis

**Q19. What does indicator triage mean?**

**Answer:**

Indicator triage means evaluating indicators and deciding how useful they are.

A simple classification is:

- **ACTIONABLE**
- **CONTEXTUAL**
- **NOISE**

**Q20. What is an ACTIONABLE indicator?**

**Answer:**

An actionable indicator has enough evidence to support a defensive action.

Examples:

- Confirmed malicious IP
- Confirmed phishing domain
- Malware hash confirmed by multiple sources

It may be suitable for:

- Blocking
- Detection rules
- Threat hunting
- Alerting

**Q21. What is a CONTEXTUAL indicator?**

**Answer:**

A contextual indicator provides useful information but is not necessarily strong enough to block.

For example:

A domain associated with suspicious infrastructure but without enough evidence to prove that it is currently malicious.

It can still be useful for:

- Investigation
- Hunting
- Correlation
- Understanding attacker infrastructure

**Q22. What is a NOISE indicator?**

**Answer:**

Noise is information that provides little or no useful security value.

Examples could include:

- Common legitimate domains
- Duplicate indicators
- Indicators with no supporting evidence
- Extremely broad indicators that would create many false positives

Noise should not automatically become a detection or block rule.

**Q23. Why are some indicators useful for blocking while others are only useful for analysis?**

**Answer:**

Because indicators have different confidence levels and different risks.

For example:

A confirmed malicious IP may be safe to block.

But a shared hosting IP may host both malicious and legitimate websites. Blocking the entire IP could disrupt legitimate services.

Therefore, an indicator's **context and confidence** determine whether it should be blocked or only investigated.

**Q24. What is enrichment?**

**Answer:**

Enrichment means adding additional information to an indicator to better understand it.

For example, for a domain we may investigate:

- WHOIS
- DNS records
- Passive DNS
- Certificate Transparency
- VirusTotal-style reputation
- Hosting information
- Registration information

Enrichment helps analysts understand whether an indicator is suspicious and how it connects to other infrastructure.

**Q25. How does WHOIS help in threat intelligence?**

**Answer:**

WHOIS can provide registration-related information about a domain or IP.

It may reveal:

- Registrar
- Registration date
- Expiration date
- Nameservers
- Registrant information, when publicly available

For example, a newly registered domain using suspicious infrastructure may deserve further investigation.

**Q26. How does DNS enrichment help?**

**Answer:**

DNS enrichment shows how domains and IP addresses are connected.

It can reveal:

- A domain's IP address
- Subdomains
- Nameservers
- Historical resolutions
- Multiple domains using the same infrastructure

This can help identify infrastructure relationships.

**Q27. What is Certificate Transparency and how can it help investigations?**

**Answer:**

Certificate Transparency records publicly logged TLS certificates.

Analysts can use certificate information to discover domains associated with a certificate.

For example, several suspicious domains may use certificates with related characteristics.

This can provide a pivot point for finding additional infrastructure.

**Q28. How can enrichment change an analyst's confidence?**

**Answer:**

Enrichment can provide additional evidence.

For example:

Initially:

example.com looks suspicious.

After enrichment:

- Domain was registered recently.
- It resolves to suspicious infrastructure.
- It shares certificate information with known malicious domains.
- Multiple threat intelligence sources identify it as malicious.

The additional evidence may increase confidence and support an actionable classification.

**4\. Infrastructure and Campaign Analysis**

**Q29. What is infrastructure clustering?**

**Answer:**

Infrastructure clustering means grouping indicators that appear to be related.

Analysts can compare:

- IP addresses
- Domains
- Registrars
- Hosting providers
- TLS certificates
- Nameservers
- Domain naming patterns
- Malware/tooling
- Timing

The goal is to determine whether different indicators may belong to the same infrastructure or campaign.

**Q30. How can registrar and hosting patterns suggest shared ownership?**

**Answer:**

If several suspicious domains:

- Were registered around the same time
- Use the same registrar
- Use the same nameservers
- Are hosted on related infrastructure

they may be connected.

However, these similarities are **not proof of common ownership** because many unrelated organizations can use the same registrar or hosting provider.

**Q31. How can TLS certificates help identify infrastructure relationships?**

**Answer:**

TLS certificates can contain information such as:

- Subject names
- Subject Alternative Names
- Issuer
- Validity dates
- Certificate fingerprints

If multiple suspicious domains share unusual certificate characteristics, this can provide a pivot for finding related infrastructure.

**Q32. What is a pivot point?**

**Answer:**

A pivot point is a piece of information that allows an analyst to move from one indicator or infrastructure item to another.

Example:

Domain → IP → Certificate → Other domains → New IP

A certificate shared by several suspicious domains could therefore become a useful pivot point.

**Q33. How can analysts determine whether similar indicators belong to the same campaign?**

**Answer:**

Analysts should compare multiple characteristics rather than relying on one similarity.

They can examine:

- Timing
- Infrastructure
- Certificates
- Hosting
- Domain naming
- Email targeting
- Malware
- Attack techniques
- Tooling
- Victims

The more independent evidence connects the indicators, the stronger the campaign relationship becomes.

**Q34. How can a multi-stage campaign be reconstructed from incomplete intelligence?**

**Answer:**

Analysts combine evidence from different sources and build a timeline.

For example:

Phishing Email

↓

Victim Click

↓

Malicious Domain

↓

Initial Access

↓

VPN Login

↓

Lateral Movement

↓

Data Collection

↓

Exfiltration

Even when some stages are missing, timestamps, logs, network traffic, indicators, and ATT&CK techniques can help connect the available evidence.

**5\. MITRE ATT&CK as an Analytical Framework**

**Q35. What is MITRE ATT&CK?**

**Answer:**

MITRE ATT&CK is a knowledge base describing **adversary tactics and techniques** based on observed real-world behavior.

It helps defenders understand:

- What attackers are trying to achieve
- How they perform activities
- How to detect those activities
- Where defensive gaps exist

**Q36. How can a campaign be mapped to ATT&CK techniques?**

**Answer:**

First, identify the actual behavior observed during the investigation.

Then map that behavior to the appropriate ATT&CK technique.

For example:

An attacker uses PowerShell to execute commands.

This behavior can be mapped to the relevant PowerShell technique in ATT&CK.

The important point is:

**Map observed behavior, not assumptions.**

**Q37. What is the difference between OBSERVED and INFERRED techniques?**

**Answer:**

**OBSERVED:**

There is direct evidence that the technique occurred.

Example:

PowerShell event logs show that the attacker executed PowerShell commands.

**INFERRED:**

The evidence suggests that the technique may have been used, but there is no direct proof.

Example:

The attacker probably used credential dumping because later activity requires credentials, but no credential-dumping event was observed.

Observed techniques should generally have stronger confidence than inferred techniques.

**Q38. What is an ATT&CK Navigator layer?**

**Answer:**

An ATT&CK Navigator layer is a visual representation of ATT&CK techniques used or relevant to an investigation.

It can show:

- Observed techniques
- Inferred techniques
- Detection coverage
- Defensive gaps

It helps analysts and security teams understand which attacker behaviors they can currently detect.

**Q39. How can ATT&CK mapping identify defensive gaps?**

**Answer:**

After mapping the attack techniques, analysts can compare them with existing detections.

For example:

| **Technique**      | **Observed?** | **Detection exists?** |
| ------------------ | ------------- | --------------------- |
| PowerShell         | Yes           | Yes                   |
| Credential Dumping | Yes           | No                    |
| Lateral Movement   | Yes           | Partial               |

This shows where additional detection engineering may be required.

**Q40. How should detection engineering be prioritized using ATT&CK?**

**Answer:**

Detection should focus on techniques that are:

1. Actually observed or strongly supported.
2. Relevant to the organization's environment.
3. Currently poorly detected.
4. Valuable for detecting important stages of the attack.

This turns ATT&CK mapping into practical defensive improvements.

**6\. YARA Rule Development**

**Q41. What is YARA?**

**Answer:**

YARA is a tool used to identify and classify files based on patterns.

A YARA rule normally contains:

- **Metadata**
- **Strings**
- **Conditions**

A simplified structure is:

rule ExampleRule

{

meta:

description = "Example detection"

strings:

\$text = "suspicious_text"

condition:

\$text

}

**Q42. What is the metadata section in a YARA rule?**

**Answer:**

Metadata provides information about the rule.

It can contain:

- Author
- Description
- Date
- Reference
- Version
- Threat name

Metadata helps analysts understand why the rule exists and who created it.

**Q43. What are strings in YARA?**

**Answer:**

Strings are patterns that YARA searches for in files.

They can be:

- Text
- Hexadecimal patterns
- Regular expressions

Example:

\$suspicious = "invoice"

The rule can then use that string in its condition.

**Q44. What is the condition section in YARA?**

**Answer:**

The condition determines **when the rule should trigger**.

For example:

condition:

\$suspicious

means the rule triggers when that string is found.

More complex conditions can combine multiple strings and other conditions.

**Q45. How can YARA be used to detect suspicious PDFs?**

**Answer:**

A YARA rule can look for combinations of suspicious PDF characteristics.

For example:

- PDF file structure
- Suspicious JavaScript
- Embedded objects
- Specific malicious strings
- Known exploit patterns

A good rule should combine multiple characteristics rather than relying on one common word.

**Q46. How can YARA be used with email headers?**

**Answer:**

YARA can search email-related data for suspicious patterns such as:

- Specific sender characteristics
- Suspicious domains
- Repeated campaign markers
- Header patterns
- Known phishing infrastructure

For example, a rule could detect a combination of a suspicious domain and a distinctive campaign string.

**Q47. How can YARA detect campaign patterns?**

**Answer:**

Instead of detecting only one IOC, a rule can search for multiple characteristics associated with a campaign.

For example:

Suspicious domain

-

Specific email pattern

-

Known campaign string

This can be more reliable than detecting only one generic indicator.

**Q48. Why should YARA rules be tested against benign and malicious samples?**

**Answer:**

Testing determines whether the rule actually works.

You need:

- Known malicious samples
- Known benign samples

The goal is to detect malicious files while avoiding legitimate files.

**Q49. What is a true positive?**

**Answer:**

A **true positive (TP)** occurs when the rule correctly identifies something malicious.

Example:

Malicious PDF → YARA detects it.

**Q50. What is a false positive?**

**Answer:**

A **false positive (FP)** occurs when the rule identifies something as malicious when it is actually benign.

Example:

Normal company PDF → YARA incorrectly triggers.

Too many false positives make a detection difficult to use operationally.

**Q51. What is a false negative?**

**Answer:**

A **false negative (FN)** occurs when malicious content exists but the rule fails to detect it.

Example:

Malicious PDF → YARA does not trigger.

False negatives are dangerous because malicious activity can go undetected.

**Q52. How do you evaluate whether a YARA rule is ready for deployment?**

**Answer:**

Test the rule against a representative dataset and measure:

- True positives
- False positives
- False negatives

Then decide:

**Deploy:**  
The rule reliably detects the intended threat with acceptable false positives.

**Tune:**  
The rule detects the threat but produces too many false positives or needs improvement.

**Monitor only:**  
The rule is useful for investigation but is not reliable enough for automatic alerting.

**Quick Revision Sheet**

**Threat Intelligence Lifecycle**

Collection → Processing → Analysis → Dissemination → Feedback

**Intelligence Types**

- **Strategic → Big picture**
- **Operational → Campaign/activity**
- **Tactical → Technical details**

**Source Assessment**

Source reliability ≠ Information credibility

**Indicator Triage**

- **ACTIONABLE → Can support defensive action**
- **CONTEXTUAL → Useful for investigation**
- **NOISE → Little useful value**

**Enrichment**

WHOIS + DNS + Certificate Transparency + Passive DNS + Reputation

**Infrastructure Analysis**

Domain → IP → Certificate → Hosting → Related Domains

**ATT&CK**

- **Observed = Direct evidence**
- **Inferred = Analytical conclusion without direct proof**

**YARA**

Metadata + Strings + Conditions

**YARA Testing**

- **True Positive = Correctly detects malicious**
- **False Positive = Benign detected as malicious**
- **False Negative = Malicious activity missed**
