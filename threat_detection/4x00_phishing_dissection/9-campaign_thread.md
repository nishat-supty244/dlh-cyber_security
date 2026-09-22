## Campaign Thread Analysis

### Shared Indicators

Emails E2, E5, and E7 use different sender domains and different business pretexts, but they share several important characteristics:

| Indicator | E2 | E5 | E7 |
|---|---|---|---|
| Lookalike / deceptive domain | `meddefense-portal.com` | `medequip-supplies.net` | `meddefense-benefits.org` |
| PHPMailer | Yes, 6.6.0 | Yes, 6.6.0 | Yes, 6.6.0 |
| High priority | X-Priority 1 | X-Priority 1 | X-Priority 1 |
| Urgency | 24-hour deadline | 7-day payment deadline | Enrollment closes tomorrow |
| Role-based lure | Clinical/staff portal | Accounts Payable/invoice | HR/benefits |
| Credential or sensitive action | Portal verification | Payment/login | Benefits enrollment |
| Authentication problems | SPF fail, DKIM none, DMARC fail | SPF softfail, DKIM none, DMARC fail | SPF fail, DKIM none, DMARC fail |

The strongest common technical indicator is the use of **PHPMailer 6.6.0** together with **high-priority email headers**.

The three messages also use different domains that fit the same general phishing pattern: they appear legitimate at first glance but are not the normal MedDefense domain.

The social-engineering pattern is also similar. Each message creates pressure to perform an important action quickly:

- E2: re-verify access within 24 hours.
- E5: pay an invoice within 7 days and avoid a late fee.
- E7: complete benefits enrollment before the deadline.

These similarities support a common campaign pattern, although they do not independently prove that the same person or infrastructure created all three emails.

### Targeting Map

| Email | Target | Business Process | Lure |
|---|---|---|---|
| E2 | Diane Marsh / clinical staff | Staff portal, scheduling and EHR access | Security re-verification |
| E5 | Angela Rivera / Accounts Payable | Supplier invoice and payment | Medical supplies invoice |
| E7 | Linda Patterson / benefits-related recipient | HR benefits/open enrollment | Benefits re-enrollment |

The targeting pattern is significant because the attackers did not use one generic message for everyone.

Instead, the lures match different healthcare business functions:

**Clinical staff → portal/EHR access**

**Accounts Payable → invoice/payment**

**HR/benefits → open enrollment**

This is consistent with role-based phishing.

### Timing Map

| Date | Email | Target | Main Lure |
|---|---|---|---|
| April 14, 2026 | E2 | Diane Marsh / clinical staff | Portal re-verification |
| April 15, 2026 | E3 | Rafael Mendez / Microsoft 365 | Unusual sign-in |
| April 16, 2026 | E5 | Angela Rivera / Accounts Payable | Invoice payment |
| April 16, 2026 | E7 | Linda Patterson / benefits | Open enrollment |

The evidence batch shows E2 arriving on **April 14**, E5 on **April 16**, and E7 on **April 16**.

There is **no need to invent an April 15 delivery for E2, E5, or E7**. E3 is the separate phishing email documented on April 15.

The complete evidence collection window runs from **April 14 to April 16, 2026**, covering approximately 57 hours.

This close timing, combined with the shared PHPMailer tooling and similar social-engineering approach, strengthens the case that E2, E5, and E7 may belong to the same campaign.

### Comparison With HC3 Alert

Email 8 is a legitimate HC3/HHS alert received by MedDefense on April 16, 2026.

The HC3 alert describes an active phishing campaign targeting healthcare organizations and specifically identifies patterns that closely match the observed MedDefense emails:

| HC3 Pattern | MedDefense Evidence |
|---|---|
| Lookalike domains | E2, E5 and E7 use deceptive domains |
| `portal`, `benefits`, `supplies`, or `login` themes | E2 uses `portal`, E7 uses `benefits`, E5 uses `supplies` and `login` |
| PHPMailer infrastructure | E2, E5 and E7 use PHPMailer 6.6.0 |
| 24–48 hour urgency | E2 has a 24-hour deadline; E7 has an enrollment deadline |
| Account lockout threats | E2 threatens portal/EHR access suspension |
| Open-enrollment cutoffs | E7 uses an open-enrollment deadline |
| Role-based targeting | E2 targets clinical staff, E5 targets billing/AP, E7 targets benefits/HR |
| Healthcare-sector targeting | All three messages target MedDefense Health Systems |

The HC3 alert also states that reports from multiple healthcare organizations showed lookalike domains impersonating patient portals, pharmacy benefit managers, and internal HR communications.

This is closely consistent with E2, E5, and E7.

However, HC3 explicitly states that its observed patterns were **not yet IOC-confirmed**. Therefore, the HC3 alert should be treated as strong contextual evidence rather than proof that the MedDefense emails were definitely created by the same actor.

Email 8 itself is legitimate: it comes from `hhs.gov`, and SPF, DKIM and DMARC all pass.

### Attribution Assessment

The available evidence supports the assessment that E2, E5, and E7 are **likely related at the campaign-pattern level**.

Evidence supporting this assessment includes:

1. All three were delivered during the same short April 14–16 collection window.
2. All three use PHPMailer 6.6.0.
3. All three use X-Priority 1 / Highest.
4. All three use deceptive or lookalike domains.
5. All three contain role-specific business lures.
6. All three use urgency or deadline-based social engineering.
7. The lures correspond closely to the role-based phishing patterns described in the HC3 alert.

However, the evidence does **not** prove:

- That the same individual created all three emails.
- That the same VPS or IP infrastructure was used.
- That the same domain registrar or hosting provider was used.
- That the same phishing kit was used.
- The identity of the attacker or threat group.
- That E2, E5 and E7 share the same backend credential-harvesting infrastructure.

The sender IPs are different:

- E2: `91.234.99.107`
- E5: `185.176.43.22`
- E7: `164.90.218.73`

Therefore, the shared PHPMailer/tooling and campaign characteristics are stronger evidence of a common campaign pattern than the network infrastructure itself.

No specific threat actor should be attributed from this evidence alone.

### Conclusion

The evidence **supports the conclusion that E2, E5, and E7 are likely part of a coordinated phishing campaign targeting different MedDefense business roles**.

The strongest evidence is the combination of:

- common PHPMailer 6.6.0 tooling,
- high-priority headers,
- closely timed delivery,
- deceptive domains,
- urgency-based social engineering,
- role-specific lures, and
- strong similarity to the campaign pattern described by HC3.

E2 targets clinical access, E5 targets Accounts Payable, and E7 targets HR/benefits processes. This shows a campaign approach in which different employees receive different lures based on their job function.

The evidence is sufficient to treat the three emails as **related campaign activity for defensive purposes**, but it is not sufficient to identify a specific attacker or prove that the same backend infrastructure was used.

Email 8 provides important external context: HC3 reported an active healthcare phishing campaign with the same major characteristics observed in the MedDefense evidence. This makes the campaign connection more credible, while HC3's own warning that its indicators were not yet IOC-confirmed means the attribution should remain cautious.
