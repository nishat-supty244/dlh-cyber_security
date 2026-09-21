# Email Authentication Analysis

## Email 1 — healthcare-education-weekly.com

- **SPF:** PASS — The sending IP is authorized by the SPF policy for `healthcare-education-weekly.com`.
- **DKIM:** PASS — The email contains a valid DKIM signature.
- **DMARC:** PASS — DMARC passed with `action=none`. The authentication results align with the visible From domain.
- **Authentication verdict:** Authentication supports the claimed sender domain.
- **Investigation meaning:** The authentication results do not show sender-domain spoofing. However, authentication does not prove that the message is wanted or safe. The bulk-mail indicators and newsletter context support the SPAM classification.
- **Final verdict:** **SPAM**

---

## Email 2 — meddefense-portal.com

- **SPF:** FAIL — The sending IP was not authorized by the SPF policy for `meddefense-portal.com`. This weakens the claim that the message was sent through an authorized mail server for the domain.
- **DKIM:** NONE — No DKIM signature was present. There is therefore no cryptographic authentication from the domain to support the message.
- **DMARC:** FAIL — DMARC failed with `action=none`. The visible From domain is not successfully authenticated by the available SPF/DKIM results.
- **Authentication verdict:** The authentication results contradict the apparent legitimacy of the sender.
- **Investigation meaning:** SPF failure and the absence of DKIM provide strong evidence that the message should not be trusted based on its claimed sender identity. Combined with the lookalike `meddefense-portal.com` domain, account-lockout urgency, and credential link, the email requires investigation.
- **Final verdict:** **SUSPICIOUS**

---

## Email 3 — outlook-protection.com

- **SPF:** PASS — The sending IP is authorized by the SPF policy for `outlook-protection.com`.
- **DKIM:** PASS — The email contains a valid DKIM signature for the sending domain.
- **DMARC:** PASS — DMARC passed with `action=none`. The authentication results are aligned with the visible From domain.
- **Authentication verdict:** Authentication confirms that the sender is authorized to send mail for `outlook-protection.com`, but it does **not** prove that the sender is Microsoft.
- **Investigation meaning:** This is the authentication paradox. All three authentication checks pass, so there is no obvious authentication failure. However, authentication only establishes trust in the domain that actually sent the message. The domain `outlook-protection.com` is not `microsoft.com` and is not `outlook.com`. Therefore, a malicious actor could register a lookalike domain, configure SPF/DKIM/DMARC correctly, and still send a fully authenticated phishing email. The claim that the message is from Microsoft is therefore not supported by the authentication results.
- **Final verdict:** **SUSPICIOUS**

---

## Email 4 — meddefense.com

- **SPF:** PASS — The sending IP is authorized by the SPF policy for `meddefense.com`.
- **DKIM:** PASS — The email has a valid DKIM signature.
- **DMARC:** PASS — DMARC passed with `action=none`, and the authentication results align with the visible From domain.
- **Authentication verdict:** Authentication supports the claimed internal sender.
- **Investigation meaning:** The authentication results are consistent with a legitimate message from the `meddefense.com` domain. The internal sending IP and Microsoft Exchange mail infrastructure provide additional support for the legitimate classification.
- **Final verdict:** **LEGITIMATE**

---

## Email 5 — medequip-supplies.net

- **SPF:** SOFTFAIL — The sending IP is not clearly authorized by the SPF policy. A softfail indicates that the domain owner does not fully authorize the sender, but the result is not an outright SPF rejection.
- **DKIM:** NONE — No DKIM signature was present, so there is no cryptographic authentication supporting the message.
- **DMARC:** FAIL — DMARC failed with `action=none`. The available authentication results do not successfully establish the visible From domain.
- **Authentication verdict:** The weak SPF result, missing DKIM, and failed DMARC contradict the apparent legitimacy of the message.
- **Investigation meaning:** The authentication evidence does not provide a reliable basis for trusting the sender. This is particularly important because the email requests action on a `$24,716.38` invoice and contains payment/login links and an attachment. The authentication failures increase the need for further investigation.
- **Final verdict:** **SUSPICIOUS**

---

## Email 6 — canadian-pharma-discount.org

- **SPF:** SOFTFAIL — The sending IP is not clearly authorized by the SPF policy. This does not provide strong sender authentication.
- **DKIM:** NONE — No DKIM signature was present, so there is no cryptographic authentication supporting the message.
- **DMARC:** FAIL — DMARC failed with `action=quarantine`. The policy indicates that messages failing DMARC should be treated as suspicious or isolated.
- **Authentication verdict:** The authentication results do not support the legitimacy of the sender.
- **Investigation meaning:** SPF softfail and missing DKIM provide weak sender authentication, while DMARC failure further reduces trust in the visible From identity. The `X-Spam-Score: 9.8` and `X-Spam-Status: Yes` headers provide additional evidence for the SPAM classification.
- **Final verdict:** **SPAM**

---

## Email 7 — meddefense-benefits.org

- **SPF:** FAIL — The sending IP is not authorized by the SPF policy for `meddefense-benefits.org`.
- **DKIM:** NONE — No DKIM signature was present, so the message has no cryptographic authentication from the sending domain.
- **DMARC:** FAIL — DMARC failed with `action=none`. The visible From domain is not successfully authenticated.
- **Authentication verdict:** The authentication results contradict the apparent legitimacy of the sender.
- **Investigation meaning:** SPF failure, missing DKIM, and DMARC failure provide multiple authentication weaknesses. The lookalike benefits domain and urgent deadline further increase suspicion. Linda Patterson also reported that she never signed up for the service mentioned in the email.
- **Final verdict:** **SUSPICIOUS**

---

## Email 8 — hhs.gov

- **SPF:** PASS — The sending IP is authorized by the SPF policy for `hhs.gov`.
- **DKIM:** PASS — The email contains a valid DKIM signature.
- **DMARC:** PASS — DMARC passed with `action=none`, and the authentication results align with the visible From domain.
- **Authentication verdict:** Authentication supports the claimed sender domain.
- **Investigation meaning:** The authentication results are consistent with a legitimate message from `hhs.gov`. The sender is `HC3@hhs.gov`, matching the Healthcare and Public Health Sector Cybersecurity Coordination Center context.
- **Final verdict:** **LEGITIMATE**

---

# Authentication Summary

| Email | SPF | DKIM | DMARC | Authentication Assessment | Final Verdict |
|---|---|---|---|---|---|
| E1 | PASS | PASS | PASS | Supports claimed domain | SPAM |
| E2 | FAIL | NONE | FAIL | Contradicts claimed sender | SUSPICIOUS |
| E3 | PASS | PASS | PASS | Authenticated domain, but domain itself is suspicious | SUSPICIOUS |
| E4 | PASS | PASS | PASS | Supports claimed internal sender | LEGITIMATE |
| E5 | SOFTFAIL | NONE | FAIL | Weak/failed authentication | SUSPICIOUS |
| E6 | SOFTFAIL | NONE | FAIL | Weak/failed authentication | SPAM |
| E7 | FAIL | NONE | FAIL | Contradicts claimed sender | SUSPICIOUS |
| E8 | PASS | PASS | PASS | Supports claimed sender | LEGITIMATE |

# Overall Conclusion

Email authentication answers an important question:

> **"Is this message authenticated by the domain it claims to come from?"**

It does **not** automatically answer:

> **"Is this email safe or legitimate?"**

E2, E5, E6, and E7 have failed or weak authentication results, which reduces trust in their claimed sender identities.

E3 demonstrates the important exception. Its SPF, DKIM, and DMARC results all pass, but they authenticate `outlook-protection.com` — not Microsoft. Because `outlook-protection.com` is different from both `microsoft.com` and `outlook.com`, successful authentication does not establish that the email is genuinely from Microsoft.

Therefore, authentication results must be interpreted together with the **actual sending domain, visible From address, message content, and other evidence**.
