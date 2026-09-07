
## The Quick Wins 


---

# Quick Win Portfolio

## Quick Win #1: Enforce MFA on All Domain Administrator Accounts

| **Category** | **Details** |
|-------------|-------------|
| **Risk Addressed** | **RISK-001:** Credential Stuffing & Remote Access Compromise |
| **Action** | - Audit Azure AD / Active Directory to identify all accounts with Global Administrator or Domain Administrator privileges.<br>- Enable mandatory Multi-Factor Authentication (MFA) through Microsoft Entra ID Conditional Access policies.<br>- Force immediate session revocation for all privileged accounts to require MFA upon next login. |
| **Owner** | Sarah Park – IT Infrastructure Manager |
| **Timeline** | 2 Days |
| **Cost** | **$0** (Covered by existing Microsoft 365 E3 licensing) |
| **Risk Reduction** | Disrupts **Kill Chain #1 (Credential Stuffing → Administrative Account Compromise)** by rendering stolen or brute-forced passwords ineffective without a second authentication factor. |
| **Verification** | Review Microsoft Entra ID sign-in logs and confirm **100% of privileged account logins require and successfully complete MFA.** |

---

## Quick Win #2: Disable Unused Remote Desktop Protocol (RDP) & SMBv1 Services

| **Category** | **Details** |
|-------------|-------------|
| **Risk Addressed** | **RISK-001:** Remote Access Compromise<br>**RISK-009:** Unpatched Vulnerabilities |
| **Action** | - Deploy a Group Policy Object (GPO) disabling SMBv1 across all Windows servers and workstations.<br>- Restrict inbound Remote Desktop Protocol (RDP) traffic at the firewall.<br>- Permit RDP access only through MFA-protected VPN connections. |
| **Owner** | Systems Administrator |
| **Timeline** | 3 Days |
| **Cost** | **$0** (Native Windows administration tools) |
| **Risk Reduction** | Disrupts **Kill Chain #4 (External RDP Exposure & Brute Force Exploitation)** by eliminating exposed RDP services and legacy SMB attack vectors. |
| **Verification** | Conduct vulnerability and port scans confirming:<br>- TCP Port **3389** is inaccessible from the internet.<br>- SMBv1 services are **Disabled/Stopped** on all managed endpoints. |

---

## Quick Win #3: Revoke Terminated Employee and Inactive Vendor Accounts

| **Category** | **Details** |
|-------------|-------------|
| **Risk Addressed** | **RISK-008:** Unauthorized Privilege Abuse |
| **Action** | - Compare HR termination records from the previous 12 months with Active Directory and Microsoft 365 user accounts.<br>- Disable all inactive employee and contractor accounts.<br>- Review vendor accounts to ensure access remains time-limited and follows least-privilege principles. |
| **Owner** | HR Director & IT Support Lead |
| **Timeline** | 5 Days |
| **Cost** | **$0** (Internal administrative effort) |
| **Risk Reduction** | Removes dormant accounts commonly exploited for persistence, privilege abuse, and unauthorized access. |
| **Verification** | Generate an Active Directory disabled-account report and validate against current HR personnel records with formal HR sign-off. |

---

## Quick Win #4: Implement External Link Rewriting & Email Anti-Spoofing Protections

| **Category** | **Details** |
|-------------|-------------|
| **Risk Addressed** | **RISK-010:** Phishing & Business Email Compromise |
| **Action** | - Enable Microsoft Defender for Office 365 Safe Links and Safe Attachments policies.<br>- Configure SPF, DKIM, and DMARC email authentication records for the corporate domain.<br>- Enforce spoof protection for inbound email traffic. |
| **Owner** | Security Analyst |
| **Timeline** | 4 Days |
| **Cost** | **$0** (Included within existing Microsoft licensing) |
| **Risk Reduction** | Interrupts phishing, credential harvesting, and email impersonation attacks before malicious messages reach end users. |
| **Verification** | Review Microsoft 365 Security Center message traces to confirm:<br>- Safe Links rewriting is enabled.<br>- Safe Attachments scanning is active.<br>- DMARC validation is passing for inbound messages. |

---

## Quick Win #5: Enforce Automatic Workstation Screen Lock Policies

| **Category** | **Details** |
|-------------|-------------|
| **Risk Addressed** | **RISK-008:** Unauthorized Access / Physical Tailgating |
| **Action** | - Configure Group Policy to automatically lock workstations after **5 minutes** of inactivity.<br>- Disable unauthenticated guest sessions on shared clinical terminals and nursing stations. |
| **Owner** | Sarah Park – IT Infrastructure Manager |
| **Timeline** | 2 Days |
| **Cost** | **$0** (Native Windows Group Policy configuration) |
| **Risk Reduction** | Reduces the risk of unauthorized physical access to unattended clinical workstations and sensitive patient information. |
| **Verification** | Audit a representative sample of clinical workstations to confirm automatic screen locking and credential prompts after five minutes of inactivity. |

---

# Organizational Purpose of Quick Wins

Quick wins provide immediate improvements to MedDefense's cybersecurity posture while requiring no additional financial investment. Their value extends beyond technical risk reduction by demonstrating early progress, strengthening governance, and establishing confidence in the organization's security program.

During the first month of implementation, these initiatives deliver visible, measurable security improvements that build credibility with executive leadership, department managers, and clinical personnel. Early successes help reduce organizational resistance to future security initiatives by showing that meaningful protection can be achieved through existing technologies and operational processes rather than expensive infrastructure projects.

By focusing on low-cost, high-impact controls such as multi-factor authentication, removal of dormant accounts, secure email protections, disabling legacy services, and enforcing workstation security policies, MedDefense significantly reduces its exposure to credential theft, phishing, remote exploitation, insider threats, and unauthorized physical access. These foundational improvements also support future phases of the cybersecurity roadmap by creating a stronger baseline upon which more advanced security capabilities can be deployed.

Ultimately, the Quick Win Program establishes operational momentum, demonstrates effective security governance, and reinforces a culture of proactive cybersecurity across the organization.
