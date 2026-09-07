# Human Vector Social Engineering Analysis

---

## Scenario 1

- **Vector Type:** Phishing
- **Target:** IT Director (Sarah Park)
- **Vulnerability:** Responsible for infrastructure maintenance and pressured by the critical nature of the alert.
- **Psychological Lever:** Urgency / Fear

### Red Flags
- Mismatched sender domain (**fortinet-support.net** vs. **fortinet.com**)
- High-pressure timeline
- Request to download a file from an external link instead of using the official vendor portal

### Technical Control
Implement an email security gateway with advanced threat protection capabilities to detect and block look-alike domains and malicious attachments.

### Administrative Control
Establish a strict policy requiring all firmware updates to be obtained exclusively through verified vendor management consoles.

---

# Scenario 2

- **Vector Type:** Business Email Compromise (BEC)
- **Target:** CFO (Robert Kim)
- **Vulnerability:** Has authority to process wire transfers, and the request impersonates his direct superior.
- **Psychological Lever:** Authority

### Red Flags
- Request for secrecy
- Attempt to bypass standard financial approval procedures
- Subtle spoofing of the sender's email address

### Technical Control
Implement **DMARC, DKIM, and SPF** email authentication protocols to reduce domain spoofing risks.

### Administrative Control
Require mandatory **out-of-band verification** (such as verbal confirmation through a known phone number) for all wire transfer requests.

---

# Scenario 3

- **Vector Type:** Vishing
- **Target:** Nurse at MedDefense Central
- **Vulnerability:** Clinical staff are trained to be helpful and cooperate with IT support requests to maintain patient care.
- **Psychological Lever:** Helpfulness / Authority

### Red Flags
- Unsolicited nature of the audit
- Request for sensitive credentials
- Urgent pressure applied by the caller

### Technical Control
Implement **Multi-Factor Authentication (MFA)** to ensure stolen passwords alone are insufficient for system access.

### Administrative Control
Create and enforce a policy stating that IT personnel will never request user passwords through phone calls, emails, or text messages.

---

# Scenario 4

- **Vector Type:** Smishing
- **Target:** All employees
- **Vulnerability:** The message appears related to a routine parking task and creates a stressful deadline.
- **Psychological Lever:** Fear

### Red Flags
- Unexpected request for credentials through SMS
- Link directing users to a non-official domain
- Threat of vehicle towing as a consequence

### Technical Control
Deploy **Mobile Device Management (MDM)** solutions configured to detect, filter, and flag malicious URLs on corporate-managed devices.

### Administrative Control
Provide regular security awareness training emphasizing that sensitive credentials should never be entered through SMS links.

---

# Scenario 5

- **Vector Type:** Watering Hole Attack
- **Target:** MedDefense Physicians
- **Vulnerability:** Physicians trust industry-specific professional websites for career-critical Continuing Medical Education (CME) resources.
- **Psychological Lever:** Familiarity

### Red Flags
- Unexplained browser redirects
- Unexpected security warnings when accessing trusted websites
- Abnormal website performance issues

### Technical Control
Deploy **Endpoint Detection and Response (EDR)** solutions on all workstations to detect and block malicious scripts and browser-based exploits.

### Administrative Control
Require users to operate with standard, non-privileged accounts for daily browsing activities to reduce malware impact.

---

# Scenario 6

- **Vector Type:** Typosquatting (Brand Impersonation)
- **Target:** Patients and Employees
- **Vulnerability:** Users may trust search engine results and overlook small spelling differences in URLs.
- **Psychological Lever:** Familiarity

### Red Flags
- Spelling mistake in the domain name (**defence** vs. **defense**)
- Unexpected credential prompts on a landing page
- Access through a misleading advertisement

### Technical Control
Implement proactive domain monitoring services to identify and request takedowns of registered typosquatting domains.

### Administrative Control
Launch awareness campaigns encouraging users to access services through bookmarked and verified URLs instead of search engine results.

---

# Scenario 7

- **Vector Type:** Impersonation (Tailgating)
- **Target:** IT Staff
- **Vulnerability:** Attackers use social engineering cues, such as wearing scrubs or carrying a stethoscope, to appear legitimate and bypass physical security checks.
- **Psychological Lever:** Helpfulness

### Red Flags
- Tailgating behavior
- Expired physical identification badge
- Excuse used to bypass required badge-in procedures

### Technical Control
Implement physical access controls such as high-security turnstiles or mantrap doors to prevent unauthorized multi-person entry.

### Administrative Control
Establish a **"See Something, Say Something"** policy encouraging employees to challenge unidentified individuals in restricted areas.
