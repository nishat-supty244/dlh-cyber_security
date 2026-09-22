**3\. Social Engineering Analysis**

**Email 2 — Portal re-verification lure**

- **Psychological lever:** Urgency, fear, authority and impersonation
- **Pretext:** The email pretends to be MedDefense IT Security and claims that Diane Marsh's staff portal access must be re-verified because of a recent security policy update.
- **Requested action:** Click the verification link and verify the account.
- **Targeting level:** TARGETED
- **Content red flags:**
  - Uses the recipient's full name: Diane Marsh.
  - Claims the action is required immediately.
  - Creates a 24-hour deadline.
  - Threatens suspension of portal access.
  - Mentions specific MedDefense systems: scheduling system, EHR gateway and shift-swap requests.
  - Uses a look-alike MedDefense domain: meddefense-portal\[.\]com.
  - Uses a fake-looking IT Security identity and ticket number to appear legitimate.
  - The message tells the recipient not to reply.
- **Attacker knowledge required:** The attacker likely needed Diane Marsh's name, email address and knowledge of MedDefense staff systems/workflows. The specific systems mentioned suggest some knowledge of the organization's environment.
- **Conclusion:** The email uses a targeted IT-security pretext. Its main goal is to create fear of losing access and push Diane to click the verification link quickly.

**Email 3 — Microsoft account security lure**

- **Psychological lever:** Fear, urgency and authority/impersonation
- **Pretext:** The email pretends to be Microsoft Account Protection and claims that an unusual sign-in was detected on Rafael Mendez's Microsoft account.
- **Requested action:** Click the verification link and verify the account.
- **Targeting level:** SEMI-TARGETED
- **Content red flags:**
  - Impersonates Microsoft.
  - Uses the recipient's name and company email address.
  - Claims an unknown sign-in came from Lagos, Nigeria.
  - Provides a specific IP address, device and time to make the story appear credible.
  - Says the account may have been compromised.
  - Creates a 48-hour deadline.
  - Threatens that the account will be locked.
  - Uses outlook-protection\[.\]com instead of an actual Microsoft domain.
  - Uses a Microsoft logo hosted from the suspicious domain.
- **Attacker knowledge required:** The attacker needed Rafael Mendez's name and email address and likely knew that the address was associated with a Microsoft 365 account. The evidence does not show that the attacker needed deeper knowledge of Rafael's role or internal workflow.
- **Conclusion:** The email uses a common account-security pretext. It combines Microsoft impersonation, a believable sign-in story and a 48-hour deadline to make the recipient act quickly.

**Email 5 — Invoice lure**

- **Psychological lever:** Financial pressure, urgency and authority/impersonation
- **Pretext:** The email pretends to be the billing department of MedEquip Supplies and claims that MedDefense received medical supplies and now owes an invoice for USD 24,716.38.
- **Requested action:** Pay the invoice through the provided payment portal or log in to retrieve the invoice. The email also includes a PDF attachment.
- **Targeting level:** TARGETED
- **Content red flags:**
  - Addresses the recipient's business function as Accounts Payable.
  - Uses a specific invoice number: INV-2026-04891.
  - Gives a large payment amount: USD 24,716.38.
  - Creates a seven-day payment deadline.
  - Threatens suspension of future deliveries and a 2% late fee.
  - Provides payment and login URLs.
  - Includes a PDF invoice attachment.
  - Uses the suspicious domain medequip-supplies\[.\]net.
  - The recipient, Angela Rivera, reported that the invoice looked wrong.
- **Attacker knowledge required:** The attacker likely needed Angela Rivera's name/email address and some knowledge that she was involved with Accounts Payable. The lure also uses realistic medical-supply purchasing language, but the evidence does not prove how the attacker obtained these details.
- **Conclusion:** This is a financially focused lure designed to make the recipient process a fraudulent payment or visit a suspicious portal. The combination of a large amount, payment deadline, late-fee threat and invoice attachment increases pressure on the recipient.

**Email 7 — Benefits enrollment lure**

- **Psychological lever:** Urgency, fear, authority and scarcity
- **Pretext:** The email pretends to be MedDefense HR Benefits and claims that Linda Patterson has not completed her 2026 benefits re-enrollment.
- **Requested action:** Click the enrollment link and complete or verify benefits enrollment.
- **Targeting level:** TARGETED
- **Content red flags:**
  - Uses the recipient's first name: Linda.
  - Claims to be from MedDefense HR Benefits.
  - Creates an immediate deadline: midnight on April 17.
  - Threatens loss of current coverage.
  - Says the recipient will be moved to a basic plan if they do not act.
  - Uses a prominent "COMPLETE ENROLLMENT" button.
  - Tells the recipient to verify even if they believe they already enrolled.
  - Uses the look-alike domain meddefense-benefits\[.\]org.
  - The email is specifically addressed to Linda's MedDefense email address.
- **Attacker knowledge required:** The attacker likely needed Linda Patterson's name, email address and some knowledge of the organization's benefits/open-enrollment process. The evidence does not prove whether the attacker had access to actual HR records.
- **Conclusion:** The lure combines fear of losing health benefits with a very short deadline. Its HR-specific pretext makes the message more believable to the intended recipient.

**Summary**

| **Email** | **Main lever**                             | **Pretext**                            | **Targeting** |
| --------- | ------------------------------------------ | -------------------------------------- | ------------- |
| E2        | Urgency, fear, authority, impersonation    | MedDefense IT security re-verification | TARGETED      |
| E3        | Fear, urgency, authority, impersonation    | Microsoft account security alert       | SEMI-TARGETED |
| E5        | Financial pressure, urgency, impersonation | Medical-supply invoice/payment request | TARGETED      |
| E7        | Urgency, fear, authority, scarcity         | HR benefits re-enrollment              | TARGETED      |

**Overall Conclusion**

E2, E5 and E7 use organization-specific roles or workflows to make their stories believable. E3 uses a more common Microsoft account-security scenario but still personalizes the message with the recipient's name, email address and a specific sign-in story. Across the four emails, the main strategy is to create pressure and reduce the time available for the recipient to question the message before clicking, logging in or paying.
