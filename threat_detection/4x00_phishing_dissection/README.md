**Email Security Architecture**

**Q1. What information do SMTP headers provide?**

**Answer:**  
SMTP headers show the **routing path of an email** from the sender to the recipient. They contain information such as:

- From — visible sender address
- To — recipient
- Subject — email subject
- Date — when it was sent
- Received — mail servers the email passed through
- Message-ID — unique identifier for the message

The **Received headers** are especially useful because they can show which mail servers handled the email and in what order.

**Q2. What is SPF?**

**Answer:**  
**SPF (Sender Policy Framework)** checks whether the server that sent an email is **authorized to send email for that domain**.

For example, if an email claims to come from example.com, SPF checks the sending IP against the SPF record published by example.com.

**Q3. What does SPF Pass mean?**

**Answer:**  
**Pass** means the sending IP address is authorized by the domain's SPF record.

It means the message came from an **authorized sending server for that domain**.

**Q4. What does SPF Fail mean?**

**Answer:**  
**Fail** means the sending IP is **not authorized** to send email for that domain.

This can be a strong indication of spoofing, but it does not automatically prove that the entire email is malicious.

**Q5. What does SPF Softfail mean?**

**Answer:**  
**Softfail** means the sending IP is probably **not authorized**, but the domain owner is not asking receiving servers to reject the email.

It is usually represented as:

~all

So, the message should be treated with suspicion, but not necessarily rejected automatically.

**Q6. What does SPF None mean?**

**Answer:**  
**None** means there is **no valid SPF record** available for the domain, or no usable SPF information was found.

It does not mean the email is malicious. It simply means SPF could not provide an authorization result.

**Q7. What is DKIM?**

**Answer:**  
**DKIM (DomainKeys Identified Mail)** uses **cryptography** to sign parts of an email.

The sending mail server creates a digital signature using a **private key**. The receiving server uses the corresponding **public key** published in DNS to verify it.

**Q8. What does a valid DKIM signature prove?**

**Answer:**  
A valid DKIM signature proves that:

1. The message was signed by a server that had access to the private key for that DKIM domain.
2. The signed parts of the email have **not been changed** since they were signed.

**Q9. What does DKIM NOT prove?**

**Answer:**  
DKIM does **not prove that the sender is trustworthy**.

A malicious person can have a valid DKIM signature if they control a legitimate domain or a compromised email system.

So:

**DKIM Pass ≠ Safe email**

**Q10. What is DMARC?**

**Answer:**  
**DMARC (Domain-based Message Authentication, Reporting and Conformance)** helps protect the visible From domain against spoofing.

It works with **SPF and DKIM** and checks whether their authenticated domains are aligned with the domain shown in the visible From address.

**Q11. What does DMARC do?**

**Answer:**  
DMARC can tell the receiving mail server what to do when authentication fails.

Common policies are:

- p=none → monitor/report
- p=quarantine → treat suspicious messages as spam or suspicious
- p=reject → reject messages that fail DMARC

**Q12. How are SPF, DKIM and DMARC different?**

**Answer:**

| **Technology** | **Main purpose**                                                        |
| -------------- | ----------------------------------------------------------------------- |
| **SPF**        | Checks whether the sending IP is authorized                             |
| **DKIM**       | Checks message integrity and cryptographic signing                      |
| **DMARC**      | Connects SPF/DKIM results to the visible From domain and applies policy |

Easy way to remember:

**SPF = Who is allowed to send?**  
**DKIM = Was the signed message changed?**  
**DMARC = Does authentication match the visible sender and what should we do?**

**Q13. Can an email pass SPF, DKIM and DMARC and still be malicious?**

**Answer:**  
**Yes.**

Authentication proves things about the **email's infrastructure and identity**, not necessarily the sender's intentions.

For example, an attacker could:

- Compromise a legitimate account.
- Send phishing emails from a legitimate domain.
- Register their own domain and configure SPF/DKIM correctly.
- Send a malicious link from a properly authenticated domain.

Therefore:

**Authentication ≠ maliciousness detection.**

**Threat Investigation Methodology**

**Q14. How should you safely investigate a suspicious URL?**

**Answer:**  
Do **not click or open the URL directly**.

Instead, investigate it using safe methods such as:

- Extracting the URL as text.
- Examining the domain.
- Checking the URL structure.
- Looking at DNS information.
- Checking domain registration information.
- Using safe reputation/intelligence services when appropriate.
- Comparing the URL with known legitimate domains.

The goal is to gather information **without interacting with the potentially malicious website**.

**Q15. Why should you avoid directly opening a suspicious URL?**

**Answer:**  
Opening the URL could:

- Download malware.
- Execute malicious scripts.
- Track your IP address.
- Steal browser information.
- Redirect you to another malicious website.
- Trigger an exploit.

So investigation should start with **passive analysis** whenever possible.

**Q16. How should you investigate a suspicious email attachment?**

**Answer:**  
Do not open or execute it normally.

Instead:

1. Preserve the original attachment.
2. Calculate its hash, such as SHA-256.
3. Identify the file type.
4. Inspect its metadata.
5. Examine its contents safely.
6. Scan it using appropriate security tools.
7. Analyze it in an isolated sandbox if deeper analysis is required.

**Q17. Why is hashing an attachment useful?**

**Answer:**  
A hash provides a **unique fingerprint** for a file.

For example:

SHA256 = abc123...

You can use the hash to:

- Identify the same file later.
- Search threat-intelligence databases.
- Compare copies of the file.
- Track the attachment during an investigation.

**Q18. What is social engineering?**

**Answer:**  
**Social engineering** is manipulating people into performing an action that benefits the attacker.

Instead of attacking only the computer, the attacker tries to **trick the person**.

**Q19. What are common social engineering techniques in phishing emails?**

**Answer:**  
Common techniques include:

- **Urgency** — "Act within 10 minutes!"
- **Authority** — pretending to be a manager, bank, police, etc.
- **Fear** — "Your account will be closed."
- **Impersonation** — pretending to be someone trusted.
- **Curiosity** — using an interesting document or message.
- **Reward** — promising money, gifts, or benefits.

**Q20. How can you identify impersonation in an email?**

**Answer:**  
Look for differences between:

- Display name
- Actual email address
- From domain
- Reply-To address
- Links
- Email signature

For example:

**Display name:** Microsoft Support  
**Actual address:** <support@micr0soft-example.com>

The display name looks legitimate, but the actual domain is suspicious.

**Q21. How can you distinguish a coordinated phishing campaign from unrelated phishing emails?**

**Answer:**  
Look for **shared infrastructure and indicators**.

For example, several emails may use:

- The same domain.
- The same IP address.
- The same URL pattern.
- The same attachment hash.
- The same sender infrastructure.
- Similar email templates.
- The same redirector.

Multiple shared indicators can show that emails may be connected to the **same campaign or infrastructure**.

**Q22. Why is infrastructure analysis useful in phishing investigations?**

**Answer:**  
Attackers often reuse infrastructure.

If several suspicious emails point to the same domain or IP address, investigators can connect them and understand that they may be part of the same activity.

**Q23. What is an IOC?**

**Answer:**  
**IOC = Indicator of Compromise.**

An IOC is a piece of information that can help identify potentially malicious activity.

Examples:

- Malicious IP address
- Malicious domain
- URL
- File hash
- Email address
- Suspicious filename
- Malware signature

**Q24. How do you correlate multiple phishing emails?**

**Answer:**  
Compare their indicators and infrastructure.

For example:

**Email 1**  
→ suspicious domain A  
→ IP X  
→ attachment hash H

**Email 2**  
→ suspicious domain B  
→ IP X  
→ attachment hash H

The shared **IP and attachment hash** provide evidence that the two emails may be connected.

**Evidence-Based Analysis**

**Q25. How do you extract IOCs from an investigation?**

**Answer:**  
Collect indicators from all relevant evidence, such as:

- Email headers
- Email body
- URLs
- Attachments
- DNS information
- Network logs
- Security alerts
- File analysis

Then organize them into categories such as:

**IP | Domain | URL | Hash | Email | Filename**

**Q26. Why should IOCs be categorized?**

**Answer:**  
Categorizing IOCs makes the investigation easier to understand and allows security teams to use them for:

- Detection rules.
- SIEM searches.
- Blocking.
- Threat hunting.
- Incident response.

**Q27. What makes an IOC strong?**

**Answer:**  
A strong IOC is highly specific and has a low chance of being legitimate.

For example, a known malicious **SHA-256 hash** can be a strong IOC because it uniquely identifies a particular file.

**Q28. What makes an IOC weak?**

**Answer:**  
A weak IOC is common or can easily appear in legitimate activity.

For example, a common IP address or generic keyword may have many legitimate uses.

So it could produce **false positives**.

**Q29. What is confidence level in IOC analysis?**

**Answer:**  
Confidence describes **how certain we are that an indicator is related to malicious activity**.

For example:

- **High confidence** → strong evidence of malicious activity.
- **Medium confidence** → suspicious but needs more evidence.
- **Low confidence** → possible indicator but could easily be legitimate.

**Q30. What is a false positive?**

**Answer:**  
A **false positive** happens when a security system identifies something as malicious when it is actually legitimate.

Example:

A detection rule alerts on a particular IP address, but that IP belongs to a legitimate company service.

**Q31. What should a professional investigation report contain?**

**Answer:**  
A professional report should clearly explain:

1. **What happened**
2. **When it happened**
3. **Who/what was affected**
4. **Evidence found**
5. **IOCs identified**
6. **How the evidence was analyzed**
7. **Whether emails appear connected**
8. **Level of confidence**
9. **Potential impact**
10. **Recommended detection or response actions**

The report should be **evidence-based**, not based on assumptions.

**Q32. Why is evidence important in an investigation report?**

**Answer:**  
Evidence allows another analyst to **verify your conclusions**.

Instead of saying:

"This is definitely a phishing campaign."

You should explain:

"Three emails shared the same URL infrastructure, attachment hash, and sending IP, which provides evidence that they may be related."

**Q33. How do investigation findings become detection rules?**

**Answer:**  
First identify a reliable pattern in the investigation.

For example:

**Investigation finds:**

- Malicious domain
- Suspicious URL pattern
- Known attachment hash

Then create detection rules that look for those indicators.

Example:

IF email contains known malicious domain → generate alert

Or:

IF attachment SHA-256 matches known malicious hash → alert

**Q34. Why should detection rules be based on investigation findings?**

**Answer:**  
Because real investigations reveal **actual attacker behavior and indicators**.

The findings can be converted into detections that help the SOC identify similar activity in the future.

**⭐ Super Short Revision**

If you need to remember everything for an oral exam, remember these:

**SPF** → Is the sending IP authorized?

**DKIM** → Was the signed email changed?

**DMARC** → Does SPF/DKIM align with the visible From domain, and what policy should apply?

**Authentication pass** → Does **not** mean the email is safe.

**Suspicious URL** → Don't click it; analyze it safely.

**Attachment** → Don't execute it; hash and analyze it safely.

**Social engineering** → Manipulating people.

**Campaign correlation** → Look for shared domains, IPs, URLs, hashes and infrastructure.

**IOC** → Evidence that can help identify malicious activity.

**Strong IOC** → Specific, high confidence, low false-positive potential.

**Weak IOC** → Generic, lower confidence, higher false-positive potential.

**Investigation report** → Evidence + analysis + findings + IOCs + confidence + recommendations.

**Detection rule** → Turn reliable investigation patterns into something the SOC can automatically detect.
