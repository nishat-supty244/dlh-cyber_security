**4\. URL and Attachment Autopsy**

**Indicator 1**

- **Source email: E2**
- **Original value: <https://meddefense-portal.com/verify/staff?id=dmarsh&token=a8f3e2d1>**
- **Defanged value: hxxps://meddefense-portal\[.\]com/verify/staff?id=dmarsh&token=a8f3e2d1**
- **Domain or IP: meddefense-portal.com**
- **Indicator type: URL / domain**
- **Evidence from email:**
  - **The URL is presented as a MedDefense staff portal verification link.**
  - **The email addresses Diane Marsh by name.**
  - **It claims portal access will be suspended within 24 hours.**
  - **The domain is meddefense-portal.com, rather than the organization's normal meddefense.com domain.**
  - **E2 was clicked by Diane Marsh according to the evidence.**
  - **The sending IP was 91.234.99.107.**
  - **SPF failed, DKIM was absent and DMARC failed.**
- **Safe investigation method:**
  - **Extract and defang the URL without opening it.**
  - **whois meddefense-portal.com**
  - **dig meddefense-portal.com**
  - **nslookup meddefense-portal.com**
  - **Search the exact defanged URL in VirusTotal or urlscan.io.**
  - **If HTTP headers must be examined, use an isolated analysis environment and a controlled request such as curl -I only when permitted by the lab.**
- **Finding: The URL is a strong phishing indicator. It uses a look-alike domain, a personalized path containing dmarsh, and a tokenized verification URL. The email's authentication failures and 24-hour lockout threat further increase suspicion.**
- **Risk rating: HIGH**

**Indicator 2**

- **Source email: E3**
- **Original value: <https://outlook-protection.com/verify>**
- **Defanged value: hxxps://outlook-protection\[.\]com/verify**
- **Domain or IP: outlook-protection.com**
- **Indicator type: URL / domain**
- **Evidence from email:**
  - **The email claims to be from "Microsoft Account Protection."**
  - **The URL is hosted on outlook-protection.com.**
  - **The message claims an unusual Microsoft account sign-in occurred.**
  - **It gives a 48-hour deadline before account lockout.**
  - **The email uses a Microsoft logo hosted from the same suspicious domain.**
  - **The sender address is <security@outlook-protection.com>.**
  - **The sending IP was 51.38.42.17.**
  - **SPF, DKIM and DMARC all passed for outlook-protection.com, but this only authenticates that domain. It does not prove that the message came from Microsoft.**
- **Safe investigation method:**
  - **Defang and record the URL.**
  - **whois outlook-protection.com**
  - **dig outlook-protection.com**
  - **nslookup outlook-protection.com**
  - **Search the URL/domain in VirusTotal or urlscan.io.**
  - **Compare the domain with legitimate Microsoft domains without visiting the suspicious URL.**
- **Finding: The URL is suspicious because the message impersonates Microsoft while using outlook-protection.com. The authentication results are valid for that domain, not for Microsoft. This is an important example of why SPF/DKIM/DMARC passing does not automatically make an email legitimate.**
- **Risk rating: HIGH**

**Indicator 3**

- **Source email: E5**
- **Original value: <https://medequip-supplies.net/invoices/pay?id=INV-2026-04891>**
- **Defanged value: hxxps://medequip-supplies\[.\]net/invoices/pay?id=INV-2026-04891**
- **Domain or IP: medequip-supplies.net**
- **Indicator type: URL / domain**
- **Evidence from email:**
  - **The URL is presented as an invoice payment portal.**
  - **The email requests payment of USD 24,716.38.**
  - **The payment deadline is seven days.**
  - **The message threatens suspension of future deliveries and a 2% late fee.**
  - **The URL contains the invoice number INV-2026-04891.**
  - **The sender is <invoices@medequip-supplies.net>.**
  - **The sending IP was 185.176.43.22.**
  - **SPF softfailed, DKIM was absent and DMARC failed.**
  - **Angela Rivera reported that the invoice looked wrong.**
- **Safe investigation method:**
  - **Extract and defang the URL.**
  - **whois medequip-supplies.net**
  - **dig medequip-supplies.net**
  - **nslookup medequip-supplies.net**
  - **Search the domain and exact URL in VirusTotal or urlscan.io.**
  - **Do not visit the payment page from the normal workstation.**
- **Finding: The URL is suspicious because it requests payment through an external domain while the email has authentication failures. The large payment amount, deadline and late-fee threat create financial pressure.**
- **Risk rating: HIGH**

**Indicator 4**

- **Source email: E5**
- **Original value: <https://medequip-supplies.net/portal/login>**
- **Defanged value: hxxps://medequip-supplies\[.\]net/portal/login**
- **Domain or IP: medequip-supplies.net**
- **Indicator type: URL / credential-harvesting URL**
- **Evidence from email:**
  - **The email says recipients should log in if the attached invoice cannot be viewed.**
  - **The URL points to a /portal/login path.**
  - **The same suspicious domain is used for the payment URL.**
  - **The email contains an invoice attachment named INV-2026-04891.pdf.**
  - **The email requests payment of USD 24,716.38.**
- **Safe investigation method:**
  - **Defang the URL.**
  - **whois medequip-supplies.net**
  - **dig medequip-supplies.net**
  - **nslookup medequip-supplies.net**
  - **Search the domain/path in VirusTotal or urlscan.io.**
  - **Do not submit credentials or interact with the login page.**
- **Finding: The login URL provides an additional possible credential-harvesting path alongside the payment request.**
- **Risk rating: HIGH**

**Indicator 5**

- **Source email: E5**
- **Original value: INV-2026-04891.pdf**
- **Defanged value: Not applicable**
- **Domain or IP: Not applicable**
- **Indicator type: Attachment**
- **Evidence from email:**
  - **Filename: INV-2026-04891.pdf**
  - **MIME type: application/pdf**
  - **Content type: PDF attachment**
  - **The attachment is presented as an invoice for USD 24,716.38.**
  - **The email also contains an external payment URL and a portal login URL.**
  - **The raw email contains PDF metadata/base64 content.**
  - **No validated SHA-256 file hash is available from the supplied evidence.**
- **Safe investigation method:**
  - **Do not open the PDF on the workstation.**
  - **Extract only metadata from a controlled copy if the lab permits it.**
  - **Calculate a SHA-256 hash without opening the document:  
    sha256sum INV-2026-04891.pdf**
  - **Submit the hash or file to an approved malware-analysis service such as VirusTotal or another sandbox, following lab rules.**
  - **Inspect PDF metadata with a safe metadata tool such as:  
    pdfinfo INV-2026-04891.pdf**
- **Finding: The PDF is a suspicious attachment because it is part of a payment lure and is combined with suspicious payment and login URLs. The supplied email evidence does not prove that the PDF itself contains malware.**
- **Risk rating: HIGH**

**Indicator 6**

- **Source email: E7**
- **Original value: <https://meddefense-benefits.org/enroll>**
- **Defanged value: hxxps://meddefense-benefits\[.\]org/enroll**
- **Domain or IP: meddefense-benefits.org**
- **Indicator type: URL / credential-harvesting URL**
- **Evidence from email:**
  - **The email claims to be from MedDefense HR Benefits.**
  - **It tells Linda Patterson that benefits re-enrollment is incomplete.**
  - **It says open enrollment closes at midnight the next day.**
  - **It threatens loss of current coverage and default enrollment into a basic plan.**
  - **The link uses meddefense-benefits.org, a look-alike domain.**
  - **The sending IP was 164.90.218.73.**
  - **SPF failed, DKIM was absent and DMARC failed.**
- **Safe investigation method:**
  - **Defang the URL.**
  - **whois meddefense-benefits.org**
  - **dig meddefense-benefits.org**
  - **nslookup meddefense-benefits.org**
  - **Search the URL/domain in VirusTotal or urlscan.io.**
  - **Do not enter benefits or account information into the site.**
- **Finding: The URL is suspicious because it impersonates the organization's HR benefits process and uses a look-alike domain with a direct enrollment path.**
- **Risk rating: HIGH**

**Indicator 7**

- **Source email: E3**
- **Original value: <https://outlook-protection.com/img/ms_logo.png>**
- **Defanged value: hxxps://outlook-protection\[.\]com/img/ms_logo.png**
- **Domain or IP: outlook-protection.com**
- **Indicator type: External image / infrastructure indicator**
- **Evidence from email:**
  - **The image is presented as a Microsoft logo.**
  - **The image is hosted on outlook-protection.com, the same domain used for the verification URL.**
  - **This helps the email visually impersonate Microsoft.**
- **Safe investigation method:**
  - **Record the URL without loading it.**
  - **whois outlook-protection.com**
  - **dig outlook-protection.com**
  - **Search the domain in VirusTotal or urlscan.io.**
- **Finding: The image URL supports the impersonation theme. It is useful as an infrastructure indicator but should not be treated as malicious by itself.**
- **Risk rating: MEDIUM**

**Indicator 8**

- **Source email: E3**
- **Original value: 41.203.72.188**
- **Defanged value: 41\[.\]203\[.\]72\[.\]188**
- **Domain or IP: 41.203.72.188**
- **Indicator type: IP address mentioned inside email content**
- **Evidence from email:**
  - **E3 claims that an unusual Microsoft account sign-in came from this IP.**
  - **The email associates it with Lagos, Nigeria.**
  - **This IP is part of the attacker's story inside the message.**
  - **It is different from the actual sending IP 51.38.42.17.**
- **Safe investigation method:**
  - **Record the IP as a content indicator.**
  - **whois 41.203.72.188**
  - **dig -x 41.203.72.188**
  - **Search the IP in VirusTotal or other approved threat-intelligence sources.**
- **Finding: This IP should be treated as a contextual indicator, not automatically as attacker infrastructure. The email only claims that this was the source of the alleged sign-in.**
- **Risk rating: LOW / CONTEXT ONLY**

**Indicator 9**

- **Source email: E2**
- **Original value: 91.234.99.107**
- **Defanged value: 91\[.\]234\[.\]99\[.\]107**
- **Domain or IP: 91.234.99.107**
- **Indicator type: Sending IP**
- **Evidence from email:**
  - **E2 was received from this external IP.**
  - **The IP was not authorized for meddefense-portal.com according to SPF.**
  - **E2 also had no DKIM signature and failed DMARC.**
- **Safe investigation method:**
  - **whois 91.234.99.107**
  - **dig -x 91.234.99.107**
  - **Search the IP in VirusTotal or approved threat-intelligence services.**
- **Finding: This is a strong infrastructure indicator associated with the suspicious E2 message.**
- **Risk rating: HIGH**

**Indicator 10**

- **Source email: E3**
- **Original value: 51.38.42.17**
- **Defanged value: 51\[.\]38\[.\]42\[.\]17**
- **Domain or IP: 51.38.42.17**
- **Indicator type: Sending IP**
- **Evidence from email:**
  - **E3 was received from this external IP.**
  - **The IP was authorized for outlook-protection.com, explaining the SPF pass.**
  - **The domain is nevertheless being used to impersonate Microsoft.**
- **Safe investigation method:**
  - **whois 51.38.42.17**
  - **dig -x 51.38.42.17**
  - **Search the IP in VirusTotal or approved threat-intelligence services.**
- **Finding: The IP is useful for campaign investigation, but the evidence does not by itself prove that the IP is exclusively malicious.**
- **Risk rating: MEDIUM**

**Indicator 11**

- **Source email: E5**
- **Original value: 185.176.43.22**
- **Defanged value: 185\[.\]176\[.\]43\[.\]22**
- **Domain or IP: 185.176.43.22**
- **Indicator type: Sending IP**
- **Evidence from email:**
  - **E5 was received from this external IP.**
  - **SPF softfailed for medequip-supplies.net.**
  - **DKIM was absent.**
  - **DMARC failed.**
  - **The email contains a suspicious invoice and payment/login URLs.**
- **Safe investigation method:**
  - **whois 185.176.43.22**
  - **dig -x 185.176.43.22**
  - **Search the IP in VirusTotal or approved threat-intelligence services.**
- **Finding: The IP is a useful infrastructure indicator connected to the suspicious invoice lure.**
- **Risk rating: HIGH**

**Indicator 12**

- **Source email: E7**
- **Original value: 164.90.218.73**
- **Defanged value: 164\[.\]90\[.\]218\[.\]73**
- **Domain or IP: 164.90.218.73**
- **Indicator type: Sending IP**
- **Evidence from email:**
  - **E7 was received from this external IP.**
  - **SPF failed for meddefense-benefits.org.**
  - **DKIM was absent.**
  - **DMARC failed.**
  - **The email uses a look-alike HR benefits domain and an urgent enrollment pretext.**
- **Safe investigation method:**
  - **whois 164.90.218.73**
  - **dig -x 164.90.218.73**
  - **Search the IP in VirusTotal or approved threat-intelligence services.**
- **Finding: The IP is a strong infrastructure indicator associated with the suspicious benefits lure.**
- **Risk rating: HIGH**

**Indicator 13**

- **Source email: E6 / HC3 context**
- **Original value: 203.0.113.228**
- **Defanged value: 203\[.\]0\[.\]113\[.\]228**
- **Domain or IP: 203.0.113.228**
- **Indicator type: IP address / URL infrastructure**
- **Evidence from email:**
  - **E6 contains the URL <http://203.0.113.228/shop?ref=pwhite>.**
  - **The email is a bulk pharmaceutical spam message.**
  - **It has a spam score of 9.8.**
  - **The IP is therefore present as a suspicious URL indicator in the evidence.**
- **Safe investigation method:**
  - **whois 203.0.113.228**
  - **dig -x 203.0.113.228**
  - **Search the IP in VirusTotal or approved threat-intelligence sources.**
  - **Do not browse directly to the URL from the workstation.**
- **Finding: This is a suspicious IP-based URL found in the email evidence. It is not one of the E2/E3/E5/E7 phishing lures, so it should be kept separate from the main campaign indicators.**
- **Risk rating: MEDIUM / CONTEXT**

**Summary of Findings**

| **Email** | **Main URL/domain**             | **Main purpose**                   | **Risk**             |
| --------- | ------------------------------- | ---------------------------------- | -------------------- |
| **E2**    | **meddefense-portal\[.\]com**   | **Account verification**           | **HIGH**             |
| **E3**    | **outlook-protection\[.\]com**  | **Microsoft account verification** | **HIGH**             |
| **E5**    | **medequip-supplies\[.\]net**   | **Payment and login**              | **HIGH**             |
| **E5**    | **INV-2026-04891.pdf**          | **Invoice lure**                   | **HIGH**             |
| **E7**    | **meddefense-benefits\[.\]org** | **Benefits enrollment**            | **HIGH**             |
| **E6**    | **203\[.\]0\[.\]113\[.\]228**   | **Bulk-spam shopping URL**         | **MEDIUM / CONTEXT** |

**Safe Investigation Principles**

1. **Never click the suspicious URLs from the normal workstation.**
2. **Defang URLs before placing them in reports or chat.**
3. **Use whois, dig, nslookup and approved threat-intelligence platforms for passive investigation.**
4. **Do not enter credentials into suspicious login or verification pages.**
5. **Do not open suspicious attachments on the workstation.**
6. **Extract attachment metadata and calculate hashes only from a controlled copy.**
7. **Treat an IP mentioned inside an email as contextual until there is evidence connecting it to attacker infrastructure.**
8. **Do not treat a tool such as PHPMailer as malicious by itself. It is an email-sending technology that can be used by both legitimate and malicious senders.**

**Conclusion**

**E2, E3, E5 and E7 contain suspicious URLs that support account verification, Microsoft impersonation, payment/login activity and benefits enrollment lures. E5 also contains a PDF invoice attachment that should be handled as potentially unsafe without opening it. The strongest evidence comes from the combination of look-alike domains, suspicious URLs, authentication failures in E2/E5/E7, and the social-engineering content of the messages. E3 is an important exception because its SPF, DKIM and DMARC checks pass for outlook-protection.com, but the domain itself is being used to impersonate Microsoft.**
