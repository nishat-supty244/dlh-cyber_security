# IOC Extraction Report

## 1. Structured IOC Table

| IOC Type | IOC Value | Source | Context | Confidence | Recommended Action |
|---|---|---|---|---|---|
| Domain | `meddefense-portal[.]com` | E2 | Lookalike MedDefense portal domain used for account verification | HIGH | Block |
| IP | `91.234.99.107` | E2 | External sending IP for the phishing email | HIGH | Block |
| URL | `hxxps://meddefense-portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1` | E2 | Credential verification link clicked by Diane Marsh | HIGH | Block |
| Email address | `noreply@meddefense-portal[.]com` | E2 | Sender used for fake MedDefense IT Security message | HIGH | Block |
| Tool | `PHPMailer 6.6.0` | E2 | Mail-sending software used by the suspicious sender | MEDIUM | Alert |
| Domain | `outlook-protection[.]com` | E3 | Lookalike domain impersonating Microsoft/Outlook | HIGH | Block |
| IP | `51.38.42.17` | E3 | External sending IP for the suspicious Microsoft impersonation email | HIGH | Block |
| URL | `hxxps://outlook-protection[.]com/verify` | E3 | Account verification / credential-harvesting URL | HIGH | Block |
| Email address | `security@outlook-protection[.]com` | E3 | Sender claiming to be Microsoft Account Protection | HIGH | Block |
| Tool | `PHPMailer 6.6.0` | E3 | Mail-sending software used by the suspicious sender | MEDIUM | Alert |
| Domain | `medequip-supplies[.]net` | E5 | External domain used for suspicious invoice and payment request | HIGH | Block |
| IP | `185.176.43.22` | E5 | External sending IP for the suspicious invoice email | HIGH | Block |
| URL | `hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891` | E5 | Payment URL included in the invoice email | HIGH | Block |
| URL | `hxxps://medequip-supplies[.]net/portal/login` | E5 | Login URL used to retrieve the invoice | HIGH | Block |
| Email address | `invoices@medequip-supplies[.]net` | E5 | Sender used for the suspicious invoice | HIGH | Block |
| File | `INV-2026-04891.pdf` | E5 | PDF attachment associated with the suspicious invoice | HIGH | Alert |
| Embedded URL | `hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891` | E5 attachment | PDF contains an embedded payment URL | HIGH | Block |
| Tool | `PHPMailer 6.6.0` | E5 | Mail-sending software used by the suspicious sender | MEDIUM | Alert |
| Domain | `meddefense-benefits[.]org` | E7 | Lookalike MedDefense HR/benefits domain | HIGH | Block |
| IP | `164.90.218.73` | E7 | External sending IP for the suspicious benefits email | HIGH | Block |
| URL | `hxxps://meddefense-benefits[.]org/enroll` | E7 | Benefits enrollment URL used in the phishing message | HIGH | Block |
| Email address | `hr-notifications@meddefense-benefits[.]org` | E7 | Sender used for fake MedDefense HR Benefits message | HIGH | Block |
| Tool | `PHPMailer 6.6.0` | E7 | Mail-sending software used by the suspicious sender | MEDIUM | Alert |
| Domain pattern | Newly registered `.com`, `.net`, `.org` domains | E8 / HC3 | HC3 reports newly registered domains used in healthcare phishing | MEDIUM | Monitor |
| Domain pattern | Domains containing `portal`, `benefits`, `supplies`, or `login` | E8 / HC3 | HC3 observed these terms in phishing domains | MEDIUM | Alert |
| Tool / infrastructure | PHPMailer-based sending infrastructure | E8 / HC3 | HC3 reports PHPMailer-based infrastructure in the campaign | MEDIUM | Alert |
| Infrastructure | Budget VPS hosting | E8 / HC3 | HC3 reports budget VPS infrastructure associated with the campaign | LOW | Context only |
| Social engineering | 24–48 hour deadlines | E8 / HC3 | HC3 reports urgency-based phishing pretexts | MEDIUM | Alert |
| Social engineering | Account lockout threats | E8 / HC3 | HC3 reports account-lockout threats | MEDIUM | Alert |
| Social engineering | Open-enrollment deadlines | E8 / HC3 | HC3 reports benefits/open-enrollment lures | MEDIUM | Alert |
| Targeting pattern | Role-specific targeting | E8 / HC3 | Clinical, billing, and HR recipients receive different lures | MEDIUM | Alert |
| Attack objective | Credential harvesting | E8 / HC3 | HC3 identifies credential harvesting as the primary reported objective | MEDIUM | Monitor |

---

# 2. IOC Categorization by Attack Phase

## 2.1 Delivery

These indicators can help identify and stop delivery of the phishing emails.

### Email 2

- `meddefense-portal[.]com`
- `91.234.99.107`
- `noreply@meddefense-portal[.]com`
- `hxxps://meddefense-portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1`

### Email 3

- `outlook-protection[.]com`
- `51.38.42.17`
- `security@outlook-protection[.]com`

### Email 5

- `medequip-supplies[.]net`
- `185.176.43.22`
- `invoices@medequip-supplies[.]net`

### Email 7

- `meddefense-benefits[.]org`
- `164.90.218.73`
- `hr-notifications@meddefense-benefits[.]org`

These are useful delivery-stage indicators because they identify the external senders and infrastructure associated with the suspicious emails.

---

# 2.2 Credential Harvesting

The following indicators are associated with requests for credentials or account verification.

### Email 2

`hxxps://meddefense-portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1`

Purpose:

- Fake MedDefense portal verification
- Requests immediate account verification
- Uses a 24-hour lockout threat

### Email 3

`hxxps://outlook-protection[.]com/verify`

Purpose:

- Fake Microsoft account verification
- Uses unusual sign-in activity as the pretext
- Uses a 48-hour account-lockout threat

### Email 5

`hxxps://medequip-supplies[.]net/portal/login`

Purpose:

- Requests the recipient to log in to retrieve an invoice
- Supports the suspicious invoice/payment lure

### Email 7

`hxxps://meddefense-benefits[.]org/enroll`

Purpose:

- Fake benefits enrollment
- Uses an urgent open-enrollment deadline
- Attempts to make the recipient take action through an external domain

---

# 2.3 Attachment or Lure Artifact

## Email 5 PDF

**Filename:**

`INV-2026-04891.pdf`

**MIME type:**

`application/pdf`

**Related invoice:**

`INV-2026-04891`

**Amount:**

`USD 24,716.38`

The attachment is part of the suspicious invoice lure.

The evidence also shows an embedded payment URL:

`hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891`

The available evidence does not provide a complete validated SHA-256 hash for the extracted PDF file. Therefore, no file hash should be treated as a confirmed IOC at this stage.

The PDF should be preserved and hashed independently before a file hash is shared as an IOC.

---

# 2.4 Infrastructure

## Confirmed Sending Infrastructure

| Email | Sending IP | Mailer |
|---|---|---|
| E2 | `91.234.99.107` | PHPMailer 6.6.0 |
| E3 | `51.38.42.17` | PHPMailer 6.6.0 |
| E5 | `185.176.43.22` | PHPMailer 6.6.0 |
| E7 | `164.90.218.73` | PHPMailer 6.6.0 |

The repeated use of `PHPMailer 6.6.0` across E2, E3, E5, and E7 is useful for correlation.

However, `PHPMailer 6.6.0` is a legitimate and widely used mail-sending tool. It should therefore **not** be treated as a standalone malicious IOC.

A detection based only on the presence of PHPMailer could create false positives.

---

# 2.5 Context-Only Indicators

The HC3 alert in E8 contains several campaign patterns that are useful for investigation but should not automatically be treated as blockable IOCs.

### Newly Registered Domains

HC3 reports that the campaign uses newly registered `.com`, `.net`, and `.org` domains.

**Recommended action:** Monitor / Alert

This is a useful detection feature, but newly registered domains are not automatically malicious.

### Budget VPS Hosting

HC3 reports the use of budget VPS hosting, including hosting associated with providers such as Hostinger and DigitalOcean pricing tiers.

**Recommended action:** Context only

Hosting providers should not be blocked based only on this information because legitimate organizations also use these services.

### PHPMailer

HC3 reports PHPMailer-based sending infrastructure.

**Recommended action:** Alert / Monitor

PHPMailer alone should not be blocked because it is legitimate software.

### Urgency-Based Social Engineering

Examples include:

- 24–48 hour deadlines
- Account lockout threats
- Open-enrollment deadlines
- Payment deadlines

**Recommended action:** Alert

These are useful detection signals when combined with suspicious domains, URLs, authentication failures, or external sender infrastructure.

### Role-Specific Targeting

HC3 reports that attackers target:

- Clinical staff
- Billing staff
- HR recipients

**Recommended action:** Alert / Monitor

This is useful for campaign correlation but is not a standalone IOC.

---

# 3. IOC Quality Assessment

## 3.1 High-Confidence IOCs

The following are high-confidence indicators because they are directly associated with suspicious messages in this evidence batch.

### Domains

- `meddefense-portal[.]com`
- `outlook-protection[.]com`
- `medequip-supplies[.]net`
- `meddefense-benefits[.]org`

### Sending IPs

- `91.234.99.107`
- `51.38.42.17`
- `185.176.43.22`
- `164.90.218.73`

### Suspicious URLs

- `hxxps://meddefense-portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1`
- `hxxps://outlook-protection[.]com/verify`
- `hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891`
- `hxxps://medequip-supplies[.]net/portal/login`
- `hxxps://meddefense-benefits[.]org/enroll`

### Sender Addresses

- `noreply@meddefense-portal[.]com`
- `security@outlook-protection[.]com`
- `invoices@medequip-supplies[.]net`
- `hr-notifications@meddefense-benefits[.]org`

These can generally be used for blocking or alerting, subject to normal organizational change-control procedures.

---

## 3.2 Indicators That Should Be Monitored

Some indicators are useful for detection but should not automatically be blocked.

Examples:

- Newly registered domains
- Domains containing `portal`
- Domains containing `benefits`
- Domains containing `supplies`
- Domains containing `login`
- PHPMailer
- Urgency-based language
- Role-specific targeting

These become much stronger signals when combined.

For example:

> External sender + lookalike domain + DMARC failure + credential URL + urgent deadline

is a much stronger detection pattern than any single feature by itself.

---

## 3.3 Indicators That Should Not Be Used Alone

The following should **not** be used as standalone blocking indicators:

### PHPMailer

PHPMailer is legitimate software. Blocking every message sent using PHPMailer could block legitimate mail.

### Budget VPS Providers

A hosting provider is not itself malicious. Attackers and legitimate organizations can use the same hosting providers.

### Newly Registered Domains

A newly registered domain can be legitimate. It should increase monitoring or risk scoring rather than automatically result in blocking.

### Urgency Language

Words such as:

- `urgent`
- `tomorrow`
- `verify`
- `deadline`
- `locked`

are common in legitimate emails as well.

They become more useful when correlated with suspicious sender domains or credential requests.

### Role-Based Targeting

Targeting HR, billing, or clinical staff is suspicious in this campaign context, but legitimate organizations also send role-specific messages.

---

# 4. Recommended Detection Logic

The strongest detection approach is to combine multiple indicators.

## High-Risk Phishing Pattern

Raise the alert priority when an external email contains several of the following:

1. Lookalike domain resembling `meddefense.com`
2. SPF failure or softfail
3. DKIM missing
4. DMARC failure
5. External credential or login URL
6. Urgent deadline
7. Account-lockout language
8. Role-specific lure
9. Suspicious external sending IP
10. PHPMailer-based infrastructure

A message does not need every indicator to be suspicious.

---

# 5. HC3-Ready IOC Summary

## Confirmed Suspicious Domains

- `meddefense-portal[.]com`
- `outlook-protection[.]com`
- `medequip-supplies[.]net`
- `meddefense-benefits[.]org`

## Confirmed Sending IPs

- `91.234.99.107`
- `51.38.42.17`
- `185.176.43.22`
- `164.90.218.73`

## Suspicious Sender Addresses

- `noreply@meddefense-portal[.]com`
- `security@outlook-protection[.]com`
- `invoices@medequip-supplies[.]net`
- `hr-notifications@meddefense-benefits[.]org`

## Confirmed Suspicious URLs

- `hxxps://meddefense-portal[.]com/verify/staff?id=dmarsh&token=a8f3e2d1`
- `hxxps://outlook-protection[.]com/verify`
- `hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891`
- `hxxps://medequip-supplies[.]net/portal/login`
- `hxxps://meddefense-benefits[.]org/enroll`

## Attachment

- `INV-2026-04891.pdf`
- MIME type: `application/pdf`
- Associated with E5
- Embedded payment URL: `hxxps://medequip-supplies[.]net/invoices/pay?id=INV-2026-04891`
- File hash: **Not confirmed from the available evidence**

## Campaign Patterns Reported by HC3

- Newly registered `.com`, `.net`, and `.org` domains
- Lookalike domains using terms such as `portal`, `benefits`, `supplies`, and `login`
- PHPMailer-based infrastructure
- Budget VPS hosting
- 24–48 hour urgency
- Account-lockout threats
- Open-enrollment deadlines
- Role-specific targeting
- Credential harvesting as the reported primary objective

## HC3 Reporting Note

The HC3 alert states that these campaign patterns were **not yet IOC-confirmed** and that HC3 would publish a formal advisory with IOCs after receiving sufficient reports.

Therefore, the confirmed IOCs from Emails 2, 3, 5, and 7 should be reported separately from the broader HC3 campaign patterns.

---

# Final Assessment

The highest-confidence actionable IOCs are the suspicious domains, sending IP addresses, sender addresses, and credential/payment URLs directly observed in Emails 2, 3, 5, and 7.

PHPMailer, newly registered domains, urgency language, role-specific targeting, and budget VPS hosting are useful correlation and detection signals, but they should not be treated as standalone malicious indicators.

The Email 5 PDF is a relevant lure artifact, but its file hash should not be shared as a confirmed IOC until the original attachment is independently extracted and hashed.

The HC3 patterns strengthen the campaign investigation because several observed characteristics match the suspicious emails, but those patterns should remain separated from confirmed IOCs until independently confirmed.
