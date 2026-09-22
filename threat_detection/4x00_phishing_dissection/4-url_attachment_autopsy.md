**Task 4 — URL and Attachment Autopsy**

**Purpose**

This task investigates suspicious URLs, IP addresses, and attachment indicators from the phishing emails.

The investigation must be done **without clicking suspicious links or opening suspicious attachments**.

The conclusions below are based on the email evidence provided in the lab. No live DNS, WHOIS, SIEM, Wazuh, or endpoint telemetry is required.

**Safe Investigation Rules**

- Do not click suspicious URLs.
- Do not open suspicious attachments on a normal workstation.
- Defang URLs before documenting them.
- Use the email headers and body as the primary evidence.
- Passive tools such as whois, dig, or nslookup may be used if the lab environment allows them.
- Do not make a live HTTP request to a suspicious URL.
- Do not depend on live lookup results to reach the conclusions in this task.
- If an external analysis service is used, submit the indicator only according to the lab's approved procedure.

**Indicator 1**

- Source email: E2 — MedDefense IT Security
- Original value: <https://meddefense-portal.com/verify/staff?id=dmarsh&token=a8f3e2d1>
- Defanged value: hxxps://meddefense-portal\[.\]com/verify/staff?id=dmarsh&token=a8f3e2d1
- Domain or IP: meddefense-portal.com
- Indicator type: Phishing URL
- Evidence from email:
  - The email was sent to Diane Marsh.
  - The sender claims to be MedDefense IT Security.
  - The URL uses meddefense-portal.com instead of the normal meddefense.com domain.
  - SPF failed.
  - DKIM was not present.
  - DMARC failed.
  - The sending IP was 91.234.99.107.
  - The email demanded verification within 24 hours.
  - Diane Marsh reported that she clicked the email.
- Safe investigation method:
  - Examine the URL without opening it.
  - Use passive WHOIS/DNS information if available.
  - Search the exact defanged domain in an approved threat-intelligence service.
- Finding:
  - The URL is suspicious because it uses a lookalike MedDefense-related domain and is combined with failed email authentication and an urgent verification request.
- Risk rating: HIGH

**Indicator 2**

- Source email: E3 — Microsoft Account Protection
- Original value: <https://outlook-protection.com/verify>
- Defanged value: hxxps://outlook-protection\[.\]com/verify
- Domain or IP: outlook-protection.com
- Indicator type: Phishing URL / Microsoft impersonation
- Evidence from email:
  - The sender claims to be Microsoft Account Protection.
  - The actual sender domain is outlook-protection.com.
  - The email claims to concern a Microsoft 365 account.
  - The email gives a 48-hour deadline.
  - It threatens account lockout.
  - The email contains an external IP address of 41.203.72.188 as part of the sign-in story.
  - SPF, DKIM, and DMARC all passed, but they authenticate outlook-protection.com, not Microsoft.
  - The sending IP was 51.38.42.17.
- Safe investigation method:
  - Inspect the domain name without visiting it.
  - Compare the claimed organization with the authenticated domain.
  - Use passive WHOIS/DNS or an approved URL-analysis service if available.
- Finding:
  - The authentication results do not prove that the email came from Microsoft. They only show that the sender was authenticated for outlook-protection.com.
  - The domain is therefore suspicious in the context of the Microsoft impersonation.
- Risk rating: HIGH

**Indicator 3**

- Source email: E5 — MedEquip Supplies Billing
- Original value: <https://medequip-supplies.net/invoices/pay?id=INV-2026-04891>
- Defanged value: hxxps://medequip-supplies\[.\]net/invoices/pay?id=INV-2026-04891
- Domain or IP: medequip-supplies.net
- Indicator type: Payment URL
- Evidence from email:
  - The email is addressed to Angela Rivera in Accounts Payable.
  - It requests payment of USD 24,716.38.
  - The invoice number is INV-2026-04891.
  - Payment is requested within 7 days.
  - The email threatens a 2% late fee and suspension of future deliveries.
  - SPF was softfail.
  - DKIM was not present.
  - DMARC failed.
  - The sending IP was 185.176.43.22.
  - Angela reported that the invoice looks wrong.
- Safe investigation method:
  - Do not open the payment URL.
  - Record the URL from the raw email.
  - Use passive domain information or an approved URL-analysis service if available.
- Finding:
  - The URL is suspicious because it is part of a payment request with failed authentication and a financial-pressure pretext.
- Risk rating: HIGH

**Indicator 4**

- Source email: E5 — MedEquip Supplies Billing
- Original value: <https://medequip-supplies.net/portal/login>
- Defanged value: hxxps://medequip-supplies\[.\]net/portal/login
- Domain or IP: medequip-supplies.net
- Indicator type: Credential/login URL
- Evidence from email:
  - The email says users can log in to retrieve the invoice.
  - The login URL uses the same suspicious domain as the payment URL.
  - SPF was softfail.
  - DKIM was not present.
  - DMARC failed.
  - The email requests payment of USD 24,716.38.
  - The recipient, Angela Rivera, reported that the invoice looks wrong.
- Safe investigation method:
  - Record and defang the URL.
  - Do not visit the login page.
  - Use passive domain or approved threat-intelligence analysis if available.
- Finding:
  - The login URL creates an additional credential-harvesting risk because it asks the recipient to log in through the same suspicious domain.
- Risk rating: HIGH

**Indicator 5**

- Source email: E5 — MedEquip Supplies Billing
- Original value: INV-2026-04891.pdf
- Defanged value: INV-2026-04891.pdf
- Domain or IP: medequip-supplies.net
- Indicator type: PDF attachment
- Evidence from email:
  - MIME type: application/pdf
  - Filename: INV-2026-04891.pdf
  - Invoice number: INV-2026-04891
  - Amount: USD 24,716.38
  - The PDF contains a link to the payment URL.
  - The raw evidence contains PDF data and a truncated hash-like value, but it does not provide a complete validated SHA-256 hash.
  - The email was authenticated with SPF softfail, no DKIM, and DMARC fail.
- Safe investigation method:
  - Do not open the PDF normally.
  - If the actual attachment file is available in a controlled lab, calculate its hash with sha256sum.
  - Use pdfinfo or another metadata-only tool in the controlled environment.
  - Submit the file to an approved malware-analysis sandbox if permitted.
- Finding:
  - The attachment is suspicious because it is part of a large payment request and contains an external payment link.
  - The evidence does not provide a complete validated file hash, so no complete SHA-256 IOC should be claimed from the email text alone.
- Risk rating: HIGH

**Indicator 6**

- Source email: E7 — MedDefense HR Benefits
- Original value: <https://meddefense-benefits.org/enroll>
- Defanged value: hxxps://meddefense-benefits\[.\]org/enroll
- Domain or IP: meddefense-benefits.org
- Indicator type: Phishing / credential-harvesting URL
- Evidence from email:
  - The email was sent to Linda Patterson.
  - The sender claims to be MedDefense HR Benefits.
  - Linda reported that she never signed up for anything.
  - The email says open enrollment closes at midnight on April 17, 2026.
  - It threatens loss of current coverage and defaulting to a basic plan.
  - SPF failed.
  - DKIM was not present.
  - DMARC failed.
  - The sending IP was 164.90.218.73.
- Safe investigation method:
  - Do not open the enrollment URL.
  - Defang and document the URL.
  - Use passive domain information or an approved threat-intelligence service if available.
- Finding:
  - The URL is suspicious because it combines a lookalike benefits domain, failed authentication, and an urgent enrollment deadline.
- Risk rating: HIGH

**Indicator 7**

- Source email: E6 — Canadian Pharma Discounts
- Original value: <http://203.0.113.228/shop?ref=pwhite>
- Defanged value: hxxp://203\[.\]0\[.\]113\[.\]228/shop?ref=pwhite
- Domain or IP: 203.0.113.228
- Indicator type: IP-based URL
- Evidence from email:
  - The URL points directly to an IP address instead of a normal domain.
  - The email advertises prescription drugs without a prescription.
  - The email has an X-Spam-Score of 9.8.
  - X-Spam-Status is Yes.
  - SPF was softfail.
  - DKIM was not present.
  - DMARC failed with quarantine action.
  - The sender used XPedia Bulk Mailer 4.2.
- Safe investigation method:
  - Do not visit the IP address.
  - Record the IP from the raw email.
  - If permitted, use passive IP reputation or WHOIS information.
- Finding:
  - The IP-based URL is an additional lab indicator associated with the spam email E6.
  - The email evidence already provides strong spam indicators, so live access to the IP is not required.
- Risk rating: MEDIUM

**Required Lab Indicators**

The required domains and IP address are covered above:

| **Indicator**           | **Source** | **Type**                    |
| ----------------------- | ---------- | --------------------------- |
| meddefense-portal.com   | E2         | Phishing URL                |
| outlook-protection.com  | E3         | Microsoft impersonation URL |
| medequip-supplies.net   | E5         | Payment/login URLs          |
| meddefense-benefits.org | E7         | Benefits phishing URL       |
| 203.0.113.228           | E6         | IP-based spam URL           |

**Evidence-Based Summary**

| **Email** | **Main Indicator**      | **Important Evidence**                                                                            | **Risk** |
| --------- | ----------------------- | ------------------------------------------------------------------------------------------------- | -------- |
| E2        | meddefense-portal.com   | SPF fail, DKIM none, DMARC fail, 24-hour deadline, Diane clicked                                  | HIGH     |
| E3        | outlook-protection.com  | Microsoft impersonation, 48-hour deadline, authenticated domain does not prove Microsoft identity | HIGH     |
| E5        | medequip-supplies.net   | \$24,716.38 payment request, SPF softfail, DKIM none, DMARC fail, suspicious PDF                  | HIGH     |
| E7        | meddefense-benefits.org | SPF fail, DKIM none, DMARC fail, enrollment deadline, Linda never signed up                       | HIGH     |
| E6        | 203.0.113.228           | Direct IP URL, spam score 9.8, SPF softfail, DKIM none, DMARC fail                                | MEDIUM   |

**Final Conclusion**

The suspicious indicators can be investigated safely using the information already present in the raw email evidence.

The investigation does **not** require:

- Clicking the URLs
- Opening the PDF
- Visiting the suspicious IP
- Live Wazuh telemetry
- SIEM data
- Sysmon data
- Suricata data
- Successful DNS or WHOIS lookups

The main evidence comes from:

- Raw email URLs
- Sender and recipient information
- Received headers
- Sending IP addresses
- SPF/DKIM/DMARC results
- Email content
- Attachment metadata
- The suspicious behavior described by the recipients

The strongest indicators are the lookalike domains, failed authentication results, urgent requests, payment/login actions, and the suspicious attachment in E5.
