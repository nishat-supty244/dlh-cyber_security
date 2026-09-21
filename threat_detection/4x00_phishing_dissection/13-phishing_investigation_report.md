**Phishing Campaign Investigation Report**

**Organization:** MedDefense Health Systems  
**Evidence batch:** Email Evidence Batch  
**Collection date:** 2026-04-17 09:15 CDT  
**Collected by:** Mike Torres, Network Engineer  
**Investigation scope:** 8 raw SMTP emails received between 2026-04-14 and 2026-04-16

**1\. Executive Summary**

The investigation identified four suspicious emails, two spam messages, and two legitimate messages in the eight-email evidence batch. Emails 2, 5, and 7 show similar phishing characteristics, including lookalike domains, urgency-based requests, weak or failed email authentication, and role-specific targeting. Email 3 also uses a lookalike domain and phishing-style content, although SPF, DKIM, and DMARC all pass because the attacker appears to control the sending domain. Email 8 is a legitimate HC3 alert describing an active healthcare phishing campaign with patterns that closely match several emails in this batch. Diane Marsh clicked the link in Email 2, but the evidence batch alone does not prove that credentials were entered or that the workstation was compromised.

**2\. Investigation Timeline**

**Collection Window**

The evidence batch covers approximately **57 hours**:

- **Start:** 2026-04-14 07:22 CDT
- **End:** 2026-04-16 15:22 CDT
- **Collection:** 2026-04-17 09:15 CDT
- **Total emails:** 8
- **6 emails:** reported through the helpdesk
- **2 emails:** pulled from Proofpoint quarantine

**Relevant Email Events**

| **Date / Time**         | **Event**                       |
| ----------------------- | ------------------------------- |
| 2026-04-14 07:22 CDT    | E1 received                     |
| 2026-04-14 14:47 CDT    | E2 received by Diane Marsh      |
| 2026-04-14 15:02:33 CDT | Diane Marsh clicked the E2 link |
| 2026-04-15 09:13 CDT    | E3 received                     |
| 2026-04-15 10:00 CDT    | E4 received                     |
| 2026-04-16 11:28 CDT    | E5 received                     |
| 2026-04-16 13:04 CDT    | E6 received                     |
| 2026-04-16 15:22 CDT    | E7 received                     |
| 2026-04-16 08:47 CDT    | E8 received from HC3            |

**Investigation Scope**

The investigation examined:

- Raw SMTP headers
- Received chains
- Sending IP addresses
- SPF, DKIM, and DMARC results
- Sender and Reply-To addresses
- Message content
- URLs
- Attachment metadata
- Mailer software
- Spam indicators
- User reports
- The HC3 threat-intelligence message included in the batch

The investigation did **not** include direct interaction with suspicious URLs or execution of email attachments.

**3\. Email-by-Email Analysis**

**Email 1 — healthcare-education-weekly.com**

**Classification:** SPAM  
**Confidence:** High

**Key Evidence**

- Sender: <newsletter@healthcare-education-weekly.com>
- Sending IP: 198.51.100.42
- SPF: PASS
- DKIM: PASS
- DMARC: PASS
- X-Mailer: MailChimp Mailer v12.4
- Precedence: bulk
- List-Unsubscribe header present
- Newsletter content and subscription language are present

**Assessment**

The authentication results support the claimed sending domain. The message appears to be a legitimate bulk newsletter rather than a phishing message. Its classification as spam is based on its bulk-mail characteristics and the user report, not on authentication failure.

**Email 2 — meddefense-portal.com**

**Classification:** SUSPICIOUS  
**Confidence:** High

**Key Evidence**

- Sender: <noreply@meddefense-portal.com>
- Sending IP: 91.234.99.107
- SPF: FAIL
- DKIM: NONE
- DMARC: FAIL
- X-Mailer: PHPMailer 6.6.0
- Lookalike domain: meddefense-portal.com
- Urgent 24-hour verification request
- Account-lockout threat
- Credential verification URL
- Target: Diane Marsh
- Diane Marsh clicked the link

**Assessment**

The message claims to be MedDefense IT Security but uses a separate lookalike domain. SPF and DMARC fail and DKIM is absent. The urgency and credential request are consistent with phishing.

This is the highest-priority email in the batch because a user confirmed that the link was clicked.

**Email 3 — outlook-protection.com**

**Classification:** SUSPICIOUS  
**Confidence:** High

**Key Evidence**

- Sender: <security@outlook-protection.com>
- Sending IP: 51.38.42.17
- SPF: PASS
- DKIM: PASS
- DMARC: PASS
- X-Mailer: PHPMailer 6.6.0
- Claims to be Microsoft Account Protection
- Uses outlook-protection.com
- Contains Microsoft branding
- Requests account verification
- Contains a 48-hour account-lockout threat

**Assessment**

All three authentication checks pass, but they authenticate outlook-protection.com, not Microsoft.

outlook-protection.com is not microsoft.com or outlook.com.

This demonstrates that successful SPF, DKIM, and DMARC authentication does not prove that the claimed organization is genuine. A sender can authenticate a lookalike domain that they control.

**Email 4 — meddefense.com**

**Classification:** LEGITIMATE  
**Confidence:** High

**Key Evidence**

- Sender: <it-announcements@meddefense.com>
- Internal sending IP: 10.10.1.15
- SPF: PASS
- DKIM: PASS
- DMARC: PASS
- X-Mailer: Microsoft Exchange Server 2019
- Internal MedDefense domain
- Internal password-change instructions
- Explicit warning that IT will never email password-change links

**Assessment**

The message originated from the internal MedDefense infrastructure and authentication results support the sender domain. The content also directs users to the normal internal portal rather than an external credential page.

**Email 5 — medequip-supplies.net**

**Classification:** SUSPICIOUS  
**Confidence:** High

**Key Evidence**

- Sender: <invoices@medequip-supplies.net>
- Sending IP: 185.176.43.22
- SPF: SOFTFAIL
- DKIM: NONE
- DMARC: FAIL
- X-Mailer: PHPMailer 6.6.0
- Invoice amount: USD 24,716.38
- Payment deadline: 7 days
- Payment and login URLs
- PDF attachment: INV-2026-04891.pdf
- Angela Rivera reported that the invoice looked wrong

**Assessment**

The authentication results provide weak support for the sender. The email also requests a large financial payment and provides both payment and login mechanisms. The user report adds further evidence that the invoice should not be trusted.

**Email 6 — canadian-pharma-discount.org**

**Classification:** SPAM  
**Confidence:** High

**Key Evidence**

- Sender: <deals@canadian-pharma-discount.org>
- Sending IP: 203.0.113.228
- SPF: SOFTFAIL
- DKIM: NONE
- DMARC: FAIL with action=quarantine
- X-Spam-Score: 9.8
- X-Spam-Status: Yes
- X-Mailer: XPedia Bulk Mailer 4.2
- Bulk pharmaceutical advertising
- Direct IP-based shopping URL

**Assessment**

The message is clearly consistent with unsolicited bulk advertising and has multiple spam indicators. The authentication results are weak and the receiving mail system already marked it as spam.

**Email 7 — meddefense-benefits.org**

**Classification:** SUSPICIOUS  
**Confidence:** High

**Key Evidence**

- Sender: <hr-notifications@meddefense-benefits.org>
- Sending IP: 164.90.218.73
- SPF: FAIL
- DKIM: NONE
- DMARC: FAIL
- X-Mailer: PHPMailer 6.6.0
- Lookalike HR/benefits domain
- Urgent enrollment deadline
- Threat of coverage lapse
- Credential/enrollment URL
- Linda Patterson reported that she never signed up

**Assessment**

The email impersonates MedDefense HR benefits using a separate lookalike domain. Authentication fails, while the content uses urgency and a benefits-related pretext. These characteristics strongly support a phishing classification.

**Email 8 — hhs.gov / HC3**

**Classification:** LEGITIMATE  
**Confidence:** High

**Key Evidence**

- Sender: <HC3@hhs.gov>
- Sending IP: 134.174.47.82
- SPF: PASS
- DKIM: PASS
- DMARC: PASS
- X-Mailer: HHS Secure Mail Gateway
- HC3 advisory reference: HC3-2026-PRELIM-001
- TLP: CLEAR
- Message describes an active healthcare phishing campaign

**Assessment**

The authentication results support the hhs.gov sender domain. The message provides threat intelligence about phishing patterns affecting healthcare organizations and is consistent with a legitimate HC3 communication.

**4\. Campaign Analysis**

**4.1 Relationship Between Emails 2, 5, and 7**

Emails 2, 5, and 7 are likely connected because they share several characteristics:

| **Feature**                  | **E2**      | **E5**  | **E7**      |
| ---------------------------- | ----------- | ------- | ----------- |
| External lookalike domain    | Yes         | Yes     | Yes         |
| PHPMailer                    | Yes         | Yes     | Yes         |
| Weak/failed authentication   | Yes         | Yes     | Yes         |
| Urgency                      | 24 hours    | 7 days  | Tomorrow    |
| Role-specific lure           | IT/security | Billing | HR/benefits |
| External action URL          | Yes         | Yes     | Yes         |
| Targeted MedDefense employee | Yes         | Yes     | Yes         |

The domains and sending IPs are different, so the evidence does **not** prove that the same infrastructure directly sent all three messages.

However, the repeated use of role-specific lures, lookalike domains, urgency, PHPMailer infrastructure, and weak authentication provides a strong basis for treating them as potentially related campaign activity.

**4.2 How Email 8 Supports the Campaign Hypothesis**

Email 8 is a legitimate HC3 alert that describes an active healthcare phishing campaign.

HC3 reports the following observed patterns:

- Newly registered .com, .net, and .org domains
- Hostnames containing terms such as portal, benefits, supplies, and login
- PHPMailer-based infrastructure
- Budget VPS hosting
- 24–48 hour deadlines
- Account-lockout threats
- Open-enrollment deadlines
- Role-specific targeting of clinical, billing, and HR staff
- Credential harvesting as the primary reported objective

Several of these characteristics appear directly in Emails 2, 5, and 7.

Therefore, Email 8 provides independent threat-intelligence context that supports the campaign hypothesis.

It does **not**, by itself, prove that Emails 2, 5, and 7 belong to the exact campaign described by HC3. HC3 explicitly states that its observed patterns were not yet IOC-confirmed.

**4.3 Interpretation of Email 3**

Email 3 should be considered part of the broader phishing pattern, but it must be analyzed differently from Emails 2, 5, and 7.

Its SPF, DKIM, and DMARC results all pass because the authentication is valid for outlook-protection.com.

The problem is the identity being authenticated.

The message claims to represent Microsoft, but the authenticated domain is:

outlook-protection.com

This is different from:

- microsoft.com
- outlook.com

Therefore, Email 3 demonstrates why authentication results must be combined with domain and content analysis.

The evidence supports a suspicious classification, but it does not prove that the same infrastructure or operator used in Emails 2, 5, and 7 was responsible for E3.

**5\. Click Incident Assessment**

**Known Facts**

- User: Diane Marsh
- Email: <dmarsh@meddefense.com>
- Workstation: WS-NURSE-04
- Workstation IP: 10.10.2.15
- Clicked email: E2
- Email received: 2026-04-14 14:47:51 CDT
- Click timestamp: **2026-04-14 15:02:33 CDT**
- Reported approximately 15 minutes after email receipt

The clicked URL in E2 was:

hxxps://meddefense-portal\[.\]com/verify/staff?id=dmarsh&token=a8f3e2d1

The URL should be treated as suspicious and should not be opened directly.

**What Can Be Concluded**

The evidence confirms that Diane Marsh clicked the phishing URL.

The email itself contains:

- A lookalike MedDefense domain
- Failed SPF
- No DKIM
- Failed DMARC
- A credential verification request
- A 24-hour account-lockout threat

**What Cannot Be Concluded**

The evidence batch alone does **not** prove:

- That Diane entered credentials
- That credentials were successfully harvested
- That malware was downloaded
- That malware executed
- That the workstation was compromised
- That the attacker successfully authenticated using Diane's credentials
- That other systems were accessed after the click

**Recommended Immediate Actions**

1. Preserve evidence from WS-NURSE-04.
2. Review browser history around 2026-04-14 15:02:33 CDT.
3. Review DNS, proxy, firewall, and EDR telemetry for the workstation.
4. Check authentication logs for Diane's account after the click.
5. Revoke active sessions if credential exposure cannot be ruled out.
6. Reset the account password through the normal internal process.
7. Confirm MFA is enabled and functioning.
8. Search for additional messages containing the same domain and URL pattern.
9. Preserve the original email and related logs for incident handling.

**6\. IOC Summary**

The following indicators were extracted directly from the evidence batch.

**6.1 Suspicious Domains**

| **Domain**                       | **Related Email** | **Notes**                            |
| -------------------------------- | ----------------- | ------------------------------------ |
| meddefense-portal\[.\]com        | E2                | Lookalike MedDefense portal domain   |
| outlook-protection\[.\]com       | E3                | Lookalike Microsoft/Outlook domain   |
| medequip-supplies\[.\]net        | E5                | Suspicious invoice/payment domain    |
| meddefense-benefits\[.\]org      | E7                | Lookalike MedDefense benefits domain |
| canadian-pharma-discount\[.\]org | E6                | Spam domain                          |

**6.2 Sending IP Addresses**

| **IP Address** | **Email** | **Classification** |
| -------------- | --------- | ------------------ |
| 91.234.99.107  | E2        | Suspicious         |
| 51.38.42.17    | E3        | Suspicious         |
| 185.176.43.22  | E5        | Suspicious         |
| 203.0.113.228  | E6        | Spam               |
| 164.90.218.73  | E7        | Suspicious         |

**6.3 Suspicious URLs**

URLs are shown defanged to prevent accidental access.

**E2**

hxxps://meddefense-portal\[.\]com/verify/staff?id=dmarsh&token=a8f3e2d1

**E3**

hxxps://outlook-protection\[.\]com/verify

hxxps://outlook-protection\[.\]com/img/ms_logo.png

**E5**

hxxps://medequip-supplies\[.\]net/invoices/pay?id=INV-2026-04891

hxxps://medequip-supplies\[.\]net/portal/login

**E6**

hxxp://203\[.\]0\[.\]113\[.\]228/shop?ref=pwhite

**E7**

hxxps://meddefense-benefits\[.\]org/enroll

**6.4 Sender Addresses**

- <noreply@meddefense-portal.com>
- <security@outlook-protection.com>
- <invoices@medequip-supplies.net>
- <deals@canadian-pharma-discount.org>
- <hr-notifications@meddefense-benefits.org>

**6.5 Attachment Indicators**

E5 contains:

- Filename: INV-2026-04891.pdf
- MIME type: application/pdf
- Attachment contains a payment URL

The evidence contains a hash-like SHA-256 indicator embedded in the PDF data, but it is not presented as a complete validated file hash. Therefore, it should **not** be treated as a confirmed file-hash IOC until the original attachment is extracted and hashed independently.

**7\. Detection and Control Gaps**

**7.1 Controls That Did Not Prevent the Activity**

The evidence shows that multiple suspicious emails reached employee mailboxes.

The following gaps are visible from the batch:

- Lookalike domains were delivered to users.
- Failed SPF/DMARC messages were not consistently blocked.
- Messages using PHPMailer infrastructure reached users.
- Role-specific phishing emails reached clinical, billing, and HR users.
- External credential links were delivered.
- At least one user clicked a phishing link.
- Authentication alone did not identify Email 3 because its authentication results were technically valid.

Email 6 demonstrates that some spam controls were working: the message had a high spam score and was marked as spam.

**7.2 Detection Improvements**

Detection should combine multiple signals instead of relying on a single authentication result.

**Authentication-Based Detection**

Alert or increase the risk score when:

- SPF fails
- DKIM is absent
- DMARC fails
- Multiple authentication checks fail together

However, authentication should not be treated as a complete phishing detector.

**Lookalike-Domain Detection**

Detect external domains that:

- Resemble meddefense.com
- Use terms such as portal, benefits, security, supplies, or login
- Appear in messages claiming to represent internal departments

**Urgency Detection**

Increase suspicion when messages contain combinations such as:

- within 24 hours
- tomorrow
- account locked
- verify immediately
- coverage will lapse
- payment required

**Role-Based Detection**

Compare the lure with the recipient's role.

Examples:

- IT/security message → clinical employee
- Invoice/payment message → billing employee
- Benefits message → HR employee

Role-specific targeting should increase the investigation priority.

**URL Detection**

Detect external URLs in messages that:

- Use lookalike domains
- Request credentials
- Contain verification or enrollment paths
- Use newly observed domains
- Use raw IP addresses instead of domain names

**Campaign Correlation**

Group emails when they share:

- Sending infrastructure
- Domain patterns
- IP addresses
- URL structures
- Attachment hashes
- Message templates
- Sender behavior
- Social-engineering themes

A single suspicious email may appear low-risk, while several related messages can reveal a broader campaign.

**8\. Recommendations**

**Immediate — Next 24 Hours**

1. Treat E2 as an active phishing incident because a user clicked the link.
2. Investigate WS-NURSE-04 using browser, DNS, proxy, firewall, EDR, and authentication logs.
3. Reset Diane Marsh's credentials if credential exposure cannot be ruled out.
4. Revoke active sessions and verify MFA status.
5. Block the confirmed suspicious domains and URLs at the appropriate mail, DNS, proxy, and web controls.
6. Search the mail environment for E2, E3, E5, and E7 indicators.
7. Preserve the original emails, headers, URLs, and workstation evidence.
8. Submit relevant confirmed IOCs to HC3 through the appropriate reporting channel.
9. Warn employees about the observed portal, Microsoft, invoice, and benefits phishing themes.

**Short-Term — Next 7 Days**

1. Create mail detections for failed SPF/DMARC combined with external credential links.
2. Create lookalike-domain detections for domains resembling meddefense.com.
3. Detect role-specific phishing patterns involving IT, billing, HR, and clinical staff.
4. Correlate sender IP, domain, URL, attachment, and message-template indicators.
5. Review Proofpoint quarantine and mail logs for additional related messages.
6. Add detections for urgency phrases combined with account, payment, or benefits actions.
7. Improve alerting for external messages that impersonate internal departments.
8. Establish a repeatable phishing IOC extraction process.

**Medium-Term — Next 30 Days**

1. Improve email security controls for domain impersonation and lookalike domains.
2. Review SPF, DKIM, and DMARC enforcement for MedDefense-owned domains.
3. Move appropriate DMARC policies toward stronger enforcement after monitoring and validation.
4. Integrate phishing indicators into centralized detection and monitoring systems.
5. Develop automated campaign correlation using domains, IPs, URLs, hashes, sender infrastructure, and message templates.
6. Establish a standard workflow for reported phishing clicks.
7. Improve user reporting and rapid containment procedures.
8. Measure detection performance using true positives, false positives, response time, and confirmed user interactions.
9. Coordinate with HC3 and relevant healthcare-sector intelligence sources for future campaign indicators.
10. Conduct phishing-awareness training focused on urgency, lookalike domains, credential requests, and role-specific social engineering.

**Final Assessment**

The evidence supports a **coordinated phishing campaign hypothesis** involving Emails 2, 5, and 7, with Email 3 showing a related impersonation technique. The strongest supporting evidence is the repeated use of lookalike domains, role-specific lures, urgency, external action links, PHPMailer infrastructure, and weak authentication across multiple messages. Email 8 provides independent HC3 threat intelligence describing the same general phishing patterns against healthcare organizations, but it does not prove that every suspicious email in this batch belongs to the exact same campaign. The confirmed click on E2 requires endpoint and account investigation because the email evidence alone cannot establish whether credentials or systems were compromised.
