# Initial Email Triage

## Triage Table

| Email | From | Subject | SPF | DKIM | DMARC | Class | Priority | Evidence |
|---|---|---|---|---|---|---|---|---|
| E1 | newsletter@healthcare-education-weekly.com | Your April newsletter: Medication reconciliation best practices | PASS | PASS | PASS | SPAM | P4-LOW | Bulk newsletter indicators are present: `Precedence: bulk`, `List-Unsubscribe`, MailChimp headers, and a normal newsletter format. The message says the recipient subscribed on 2024-08-11 and contains general healthcare education content. |
| E2 | noreply@meddefense-portal.com | ACTION REQUIRED: Portal re-verification needed within 24 hours | FAIL | NONE | FAIL | SUSPICIOUS | P1-URGENT | SPF failed because the sending IP was not authorized; DKIM was absent; DMARC failed. The sender uses the lookalike domain `meddefense-portal.com`, creates a 24-hour deadline and account-lockout threat, and contains a credential-verification link. Diane Marsh clicked the link, making this P1-URGENT. |
| E3 | security@outlook-protection.com | Unusual sign-in activity detected on your Microsoft 365 account | PASS | PASS | PASS | SUSPICIOUS | P2-HIGH | SPF, DKIM and DMARC all passed for `outlook-protection.com`, but the domain impersonates Microsoft/Outlook. The email uses urgency, a sign-in scare, a 48-hour lockout threat, and a verification link. Authentication proves the message was authenticated for that domain, not that it is genuinely from Microsoft. |
| E4 | it-announcements@meddefense.com | Reminder: Quarterly password change window opens April 20 | PASS | PASS | PASS | LEGITIMATE | P4-LOW | The message originated from the internal Exchange server, uses the `meddefense.com` domain, and SPF/DKIM/DMARC all pass. It directs users to the internal portal and explicitly states that IT will never email a password-change link. |
| E5 | invoices@medequip-supplies.net | Invoice INV-2026-04891 — Payment required within 7 days | SOFTFAIL | NONE | FAIL | SUSPICIOUS | P2-HIGH | SPF softfailed, DKIM was absent, and DMARC failed. The message requests USD 24,716.38, creates payment pressure, contains payment/login links and a PDF attachment. Angela Rivera reported that the invoice looks wrong, increasing suspicion. |
| E6 | deals@canadian-pharma-discount.org | 90% OFF Viagra, Cialis, Xanax — No prescription needed!!! | SOFTFAIL | NONE | FAIL | SPAM | P4-LOW | Clear unsolicited bulk advertising for prescription drugs. SPF softfailed, DKIM was absent, DMARC failed, and the message has an `X-Spam-Score` of 9.8 with `X-Spam-Status: Yes`. |
| E7 | hr-notifications@meddefense-benefits.org | Open Enrollment closes TOMORROW — action required | FAIL | NONE | FAIL | SUSPICIOUS | P2-HIGH | SPF failed, DKIM was absent, and DMARC failed. The sender uses a lookalike benefits domain, claims the recipient has not completed enrollment, and uses an urgent deadline and threat of coverage lapse. Linda Patterson says she never signed up for anything. |
| E8 | HC3@hhs.gov | [HC3 ALERT — TLP:CLEAR] Active phishing campaign targeting regional healthcare | PASS | PASS | PASS | LEGITIMATE | P3-MEDIUM | SPF, DKIM and DMARC all pass for `hhs.gov`. The message is from HHS Health Sector Cybersecurity Coordination Center (HC3), uses HHS Secure Mail Gateway, and provides a sector alert about an active healthcare phishing campaign. It is legitimate threat-intelligence communication, but it is operationally important. |

## Triage Summary

- **SPAM:** E1, E6
- **SUSPICIOUS:** E2, E3, E5, E7
- **LEGITIMATE:** E4, E8
- **Highest priority:** E2 — `P1-URGENT`, because Diane Marsh clicked the link.
