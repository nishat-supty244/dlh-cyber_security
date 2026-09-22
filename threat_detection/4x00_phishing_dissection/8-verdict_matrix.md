# Verdict Matrix

| Email | Initial Class | Final Class | Confidence | Key Evidence | Recommended Action |
|---|---|---|---|---|---|
| E1 | SPAM | SPAM | HIGH | SPF, DKIM and DMARC all pass. Bulk/newsletter-style content with no strong credential-harvesting indicators. | Keep as spam and monitor for similar messages. |
| E2 | SUSPICIOUS | PHISHING-TARGETED | HIGH | Lookalike domain `meddefense-portal.com`; SPF FAIL, DKIM NONE, DMARC FAIL; impersonates MedDefense IT Security; personalized `dmarsh` URL; 24-hour deadline and lockout threat; Diane Marsh clicked the link. | Investigate the click, reset password if credentials may have been entered, revoke sessions, review MFA, and monitor the account. |
| E3 | SUSPICIOUS | PHISHING-OPPORTUNISTIC | HIGH | SPF, DKIM and DMARC pass for `outlook-protection.com`, but the domain is not Microsoft's domain. Claims to be Microsoft Account Protection and directs the user to a suspicious verification site. | Do not visit the link. Block/report the domain and monitor for similar messages. |
| E4 | LEGITIMATE | LEGITIMATE | HIGH | Internal `meddefense.com` sender, internal `10.10.1.15` source, SPF/DKIM/DMARC PASS, and Microsoft Exchange Server 2019 headers. | No security action required. |
| E5 | SUSPICIOUS | PHISHING-TARGETED | HIGH | External `medequip-supplies.net` sender; SPF SOFTFAIL, DKIM NONE, DMARC FAIL; $24,716.38 invoice; payment/login links; PDF attachment; recipient reported the invoice looked wrong. | Do not pay or open the attachment. Verify the invoice through a trusted supplier contact. |
| E6 | SPAM | SPAM | HIGH | SPF SOFTFAIL, DKIM NONE, DMARC FAIL with quarantine; spam score 9.8; marked as spam; suspicious pharmaceutical promotion and IP-based URL. | Keep quarantined/blocked and monitor for related spam. |
| E7 | SUSPICIOUS | PHISHING-TARGETED | HIGH | Lookalike `meddefense-benefits.org`; SPF FAIL, DKIM NONE, DMARC FAIL; HR/benefits impersonation; deadline and coverage threat; Linda Patterson reported she never signed up. | Block/report the sender and domain, warn affected users, and monitor for account activity. |
| E8 | LEGITIMATE | LEGITIMATE | HIGH | HC3/HHS security alert with SPF, DKIM and DMARC all passing and no phishing indicators identified in the evidence. | No phishing containment required. |

## Deeper Analysis — Changes From Initial Triage

### E2 — SUSPICIOUS → PHISHING-TARGETED

The initial triage correctly identified E2 as suspicious. Deeper analysis shows stronger evidence for targeted phishing.

The message impersonates MedDefense IT Security and uses the lookalike domain `meddefense-portal.com` instead of `meddefense.com`. SPF failed, DKIM was absent, and DMARC failed.

The URL contains the recipient identifier `dmarsh`, and the evidence confirms that Diane Marsh clicked the link from `WS-NURSE-04`.

The click confirms user interaction with the phishing link, but it does **not** by itself prove that Diane entered credentials or that the account was compromised.

### E3 — SUSPICIOUS → PHISHING-OPPORTUNISTIC

The initial suspicious classification remains consistent with the deeper analysis.

SPF, DKIM and DMARC pass, but they authenticate `outlook-protection.com`, not Microsoft. The message claims to be Microsoft Account Protection while directing the recipient to a non-Microsoft verification domain.

The available evidence supports phishing, but does not show the same level of MedDefense-specific targeting seen in E2, E5, or E7. Therefore it is classified as opportunistic phishing.

### E5 — SUSPICIOUS → PHISHING-TARGETED

Deeper analysis shows several indicators consistent with targeted phishing.

The message contains a specific invoice number, `$24,716.38` amount, payment deadline, late-payment threat, payment/login URLs, and a PDF attachment. Angela Rivera also reported that the invoice looked wrong.

Authentication evidence is suspicious: SPF softfail, no DKIM signature, and DMARC failure.

These indicators support a targeted phishing classification.

### E7 — SUSPICIOUS → PHISHING-TARGETED

Deeper analysis identifies targeted phishing characteristics.

The message impersonates HR/benefits using the lookalike domain `meddefense-benefits.org`. It contains a deadline and threatens a coverage/default-plan change.

Linda Patterson reported that she never signed up for the enrollment message, adding evidence that the request was suspicious.

## Triage Accuracy Assessment

The initial triage correctly identified the broad classification of all 8 emails:

| Email | Initial Triage | Final Verdict | Broad Triage Correct? |
|---|---|---|---|
| E1 | SPAM | SPAM | YES |
| E2 | SUSPICIOUS | PHISHING-TARGETED | YES |
| E3 | SUSPICIOUS | PHISHING-OPPORTUNISTIC | YES |
| E4 | LEGITIMATE | LEGITIMATE | YES |
| E5 | SUSPICIOUS | PHISHING-TARGETED | YES |
| E6 | SPAM | SPAM | YES |
| E7 | SUSPICIOUS | PHISHING-TARGETED | YES |
| E8 | LEGITIMATE | LEGITIMATE | YES |

**Initial triage accuracy: 8/8 (100%)**

The deeper analysis did not reverse any broad initial decision. Instead, it made the malicious classifications more specific and evidence-based.

## Final Verdict Summary

| Final Class | Emails | Count |
|---|---|---:|
| SPAM | E1, E6 | 2 |
| PHISHING-OPPORTUNISTIC | E3 | 1 |
| PHISHING-TARGETED | E2, E5, E7 | 3 |
| LEGITIMATE | E4, E8 | 2 |
| **Total** | **E1–E8** | **8** |

Final result: **2 SPAM, 1 PHISHING-OPPORTUNISTIC, 3 PHISHING-TARGETED, and 2 LEGITIMATE.**
