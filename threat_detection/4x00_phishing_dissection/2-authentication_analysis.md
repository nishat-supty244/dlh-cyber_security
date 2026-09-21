# Email Authentication Analysis

## Email 1 — healthcare-education-weekly.com

- **SPF:** PASS — The sending IP `198.51.100.42` is authorized for `healthcare-education-weekly.com`.
- **DKIM:** PASS — The message has a valid DKIM signature for `healthcare-education-weekly.com`.
- **DMARC:** PASS — DMARC passed for the visible `From:` domain `healthcare-education-weekly.com`, with policy action `none`.
- **Authentication verdict:** Authentication supports the legitimacy of the claimed sending domain.
- **Investigation meaning:** The authentication results are consistent with a genuine bulk newsletter from the claimed domain. The message also contains normal bulk-mail indicators such as `Precedence: bulk`, `List-Unsubscribe`, and MailChimp headers.
- **Final verdict:** **SPAM** — Authentication passes, but the message is still classified as spam because it is an unsolicited/bulk newsletter according to the triage evidence.

---

## Email 2 — meddefense-portal.com

- **SPF:** FAIL — The sending IP `91.234.99.107` is not authorized to send mail for `meddefense-portal.com`.
- **DKIM:** NONE — The message was not cryptographically signed with DKIM.
- **DMARC:** FAIL — DMARC failed for `meddefense-portal.com`. The header shows `action=none`.
- **Authentication verdict:** Authentication strongly contradicts the apparent legitimacy of the message.
- **Investigation meaning:** The sending infrastructure is not authorized for the claimed domain, there is no DKIM signature, and DMARC fails. The domain is also a lookalike of the legitimate `meddefense.com` domain.
- **Final verdict:** **SUSPICIOUS** — The authentication failures support the phishing indicators identified during triage.

---

## Email 3 — outlook-protection.com

- **SPF:** PASS — The sending IP `51.38.42.17` is authorized for `outlook-protection.com`.
- **DKIM:** PASS — The message has a valid DKIM signature for `outlook-protection.com`.
- **DMARC:** PASS — DMARC passed for the visible `From:` domain `outlook-protection.com`, with policy action `none`.
- **Authentication verdict:** Authentication supports the authenticity of the message as being sent by `outlook-protection.com`, but it does not prove that the sender is Microsoft.
- **Investigation meaning:** The email claims to be from Microsoft Account Protection, but the authenticated domain is `outlook-protection.com`. This is not the same domain as `microsoft.com` or `outlook.com`. Therefore, SPF, DKIM and DMARC only show that the sender controls or is authorized to send for `outlook-protection.com`; they do not prove that Microsoft sent the message.
- **Final verdict:** **SUSPICIOUS** — The authentication results pass, but the authenticated domain does not match the organization being impersonated.

---

## Email 4 — meddefense.com

- **SPF:** PASS — The sending IP `10.10.1.15` is identified as internal and authorized for `meddefense.com`.
- **DKIM:** PASS — The message has a valid DKIM signature for `meddefense.com`.
- **DMARC:** PASS — DMARC passed for the visible `From:` domain `meddefense.com`, with policy action `none`.
- **Authentication verdict:** Authentication supports the apparent legitimacy of the message.
- **Investigation meaning:** The message came from the internal MedDefense Exchange infrastructure, and SPF, DKIM and DMARC all pass for the legitimate `meddefense.com` domain.
- **Final verdict:** **LEGITIMATE** — The authentication results and internal sending infrastructure are consistent with the claimed sender.

---

## Email 5 — medequip-supplies.net

- **SPF:** SOFTFAIL — The sending IP `185.176.43.22` is not properly authorized for `medequip-supplies.net`, but the SPF result is a soft failure rather than a hard failure.
- **DKIM:** NONE — The message was not cryptographically signed with DKIM.
- **DMARC:** FAIL — DMARC failed for `medequip-supplies.net`. The header shows `action=none`.
- **Authentication verdict:** Authentication contradicts the apparent legitimacy of the message.
- **Investigation meaning:** SPF softfailed, DKIM was absent and DMARC failed. The message also requests payment of USD 24,716.38 and contains payment/login links and an invoice attachment. Angela Rivera reported that the invoice looked wrong.
- **Final verdict:** **SUSPICIOUS** — The authentication failures support the other suspicious indicators.

---

## Email 6 — canadian-pharma-discount.org

- **SPF:** SOFTFAIL — The header shows an SPF softfail for `canadian-pharma-discount.org`.
- **DKIM:** NONE — No DKIM signature is present.
- **DMARC:** FAIL — DMARC failed for `canadian-pharma-discount.org`, with policy action `quarantine`.
- **Authentication verdict:** Authentication does not support the legitimacy of the message.
- **Investigation meaning:** SPF softfailed, DKIM was absent and DMARC failed. The message is also identified by the mail system with `X-Spam-Score: 9.8` and `X-Spam-Status: Yes`.
- **Final verdict:** **SPAM** — The authentication results and spam indicators are consistent with unsolicited bulk advertising.

---

## Email 7 — meddefense-benefits.org

- **SPF:** FAIL — The sending IP `164.90.218.73` is not authorized to send mail for `meddefense-benefits.org`.
- **DKIM:** NONE — The message was not cryptographically signed with DKIM.
- **DMARC:** FAIL — DMARC failed for `meddefense-benefits.org`, with policy action `none`.
- **Authentication verdict:** Authentication strongly contradicts the apparent legitimacy of the message.
- **Investigation meaning:** The email claims to be from MedDefense HR Benefits but uses the lookalike domain `meddefense-benefits.org` instead of `meddefense.com`. SPF and DMARC fail and there is no DKIM signature.
- **Final verdict:** **SUSPICIOUS** — The authentication failures support the phishing indicators identified during triage.

---

## Email 8 — hhs.gov

- **SPF:** PASS — The sending IP `134.174.47.82` is authorized for `hhs.gov`.
- **DKIM:** PASS — The message has a valid DKIM signature for `hhs.gov`.
- **DMARC:** PASS — DMARC passed for the visible `From:` domain `hhs.gov`, with policy action `none`.
- **Authentication verdict:** Authentication supports the apparent legitimacy of the message.
- **Investigation meaning:** The message is from `HC3@hhs.gov`, and SPF, DKIM and DMARC all pass for the `hhs.gov` domain. The email is a sector cybersecurity alert from HC3.
- **Final verdict:** **LEGITIMATE** — The authentication results are consistent with the claimed HHS sender.

---

# Authentication Summary

| Email | SPF | DKIM | DMARC | Authentication Assessment | Final Verdict |
|---|---|---|---|---|---|
| E1 | PASS | PASS | PASS | Supports claimed domain | SPAM |
| E2 | FAIL | NONE | FAIL | Contradicts claimed sender | SUSPICIOUS |
| E3 | PASS | PASS | PASS | Authenticated domain does not prove Microsoft identity | SUSPICIOUS |
| E4 | PASS | PASS | PASS | Supports claimed sender | LEGITIMATE |
| E5 | SOFTFAIL | NONE | FAIL | Contradicts claimed sender | SUSPICIOUS |
| E6 | SOFTFAIL | NONE | FAIL | Does not support claimed sender | SPAM |
| E7 | FAIL | NONE | FAIL | Contradicts claimed sender | SUSPICIOUS |
| E8 | PASS | PASS | PASS | Supports claimed sender | LEGITIMATE |

## Overall Conclusion

SPF, DKIM and DMARC provide useful evidence about whether a message was authorized by the domain shown in the email authentication results.

E2, E5 and E7 have authentication failures that support their suspicious classification. E1, E4 and E8 have authentication results that support their claimed sending domains.

E3 demonstrates an important limitation of email authentication. SPF, DKIM and DMARC all pass, but they authenticate `outlook-protection.com`. That domain is not the same as `microsoft.com` or `outlook.com`. Therefore, the authentication results do not prove that Microsoft sent the email.

Authentication should therefore be treated as one part of the investigation rather than as a complete determination of whether an email is safe.
