# Identity and Access Management (IAM) – Learning Objectives Q&A

## Part 1: Technical Learning Objectives

### Q1. What is SAML 2.0 SSO?

**Answer:**

SAML (Security Assertion Markup Language) 2.0 is a standard used to allow users to access multiple applications using one trusted identity provider.

SSO stands for Single Sign-On.

**Example:**
A hospital employee logs in using their hospital account and accesses approved applications without entering a separate password for each application.

SAML involves two main components:

- **Identity Provider (IdP):** Authenticates users, such as Microsoft Entra ID or Keycloak.
- **Service Provider (SP):** The application the user wants to access.

---

### Q2. How does SAML authentication work?

**Answer:**

1. The employee opens an application.
2. The application redirects the employee to the Identity Provider.
3. The employee authenticates.
4. The Identity Provider issues a signed SAML assertion.
5. The browser delivers the SAML response to the application.
6. The application validates the assertion and grants appropriate access.

**Key Point:** The application does not need to receive the employee's password.

---

### Q3. What is realm isolation in identity management?

**Answer:**

Realm isolation means keeping different groups of users, applications, and authentication configurations separate.

**Example:**

A hospital may use:

- One realm for hospital employees.
- Another realm for external contractors.

**Security Risk:**
Incorrect realm isolation could allow contractors to authenticate to employee-only applications.

**Remediation:**
Configure separate realms where appropriate and enforce access restrictions.

---

### Q4. What are SAML client settings?

**Answer:**

SAML client settings define how an application communicates with the Identity Provider.

Important settings include:

- **Entity ID:** Unique identifier for the application.
- **ACS URL:** Endpoint that receives SAML responses.
- **Signature validation:** Verifies trusted authentication information.
- **NameID format:** Determines how users are identified.
- **Assertion conditions:** Define restrictions such as audience and validity period.

**Security Risk:**
Incorrect client settings may cause authentication failures or security vulnerabilities.

---

### Q5. What is NameID in SAML?

**Answer:**

NameID (Name Identifier) identifies a user within a SAML assertion.

**Example:**

`employee123@hospital.com`

NameID can use:

- Email address
- Persistent identifier
- Transient identifier

**Security Risk:**
Incorrect NameID mapping could associate an authenticated user with the wrong application account.

---

### Q6. What is a SAML assertion?

**Answer:**

A SAML assertion is a security message issued by an Identity Provider containing information about an authenticated user.

It may include:

- User identity
- Authentication information
- User attributes
- Validity conditions

**Example:**
A hospital employee's assertion contains their identity and department information.

The application uses this information to make access decisions.

---

### Q7. Why are digital signatures important in SAML?

**Answer:**

Digital signatures help verify that SAML authentication information comes from a trusted Identity Provider and has not been modified.

**Security Risk:**
Improper signature validation could allow attackers to submit forged authentication assertions.

**Remediation:**

- Validate required signatures.
- Verify trusted signing certificates.
- Check the issuer and audience.
- Validate assertion expiration.
- Verify destination and recipient conditions.

---

### Q8. What are role attributes in SAML?

**Answer:**

Role attributes describe a user's role or group membership.

**Example:**

| Role | Access |
|------|--------|
| Doctor | Patient records |
| Nurse | Assigned patient information |
| Administrator | Application administration |
| Receptionist | Appointment management |

**Security Risk:**
Incorrect role mapping may give ordinary employees administrator privileges.

**Remediation:**
Review role mappings and enforce least privilege.

---

### Q9. What is AWS IAM?

**Answer:**

AWS Identity and Access Management (IAM) is a service that controls access to AWS resources.

It manages access through:

- IAM users
- IAM roles
- IAM policies

**Example:**
A hospital backup application needs permission to upload files to a specific S3 bucket.

It should not have permission to delete every S3 bucket in the AWS account.

---

### Q10. What is IAM over-privilege?

**Answer:**

IAM over-privilege occurs when a user or application has more permissions than necessary.

**Example:**
An employee who only needs to read reports receives full administrator permissions.

**Security Risk:**
If the account is compromised, an attacker can misuse the excessive permissions.

**Remediation:**
Remove unnecessary permissions and apply least privilege.

---

### Q11. What is the principle of least privilege?

**Answer:**

The principle of least privilege means granting only the minimum permissions necessary to perform a task.

**Example:**
A reporting application should have permission to read required reports but not delete them.

**Benefits:**

- Reduces unauthorized access.
- Limits damage from compromised accounts.
- Reduces accidental changes.
- Improves security control.

---

### Q12. How do you identify and correct an over-privileged AWS IAM policy?

**Answer:**

An overly permissive IAM policy may contain:

```json
{
  "Effect": "Allow",
  "Action": "s3:*",
  "Resource": "*"
}
```

**Problem:**
This permits all S3 actions on all applicable S3 resources.

**Corrected Policy:**

```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::hospital-reports/*"
}
```

**Explanation:**
The corrected policy allows reading objects only from the specified S3 bucket.

**Remediation Steps:**

1. Identify the permissions actually required.
2. Remove unnecessary actions.
3. Restrict access to specific resources.
4. Test the corrected permissions.
5. Monitor for excessive access.

---

### Q13. What is HashiCorp Vault?

**Answer:**

HashiCorp Vault is a tool used to securely manage secrets.

Examples of secrets include:

- Database passwords
- API keys
- Authentication tokens
- Application credentials

**Example:**
Instead of storing a database password in application code, the application requests credentials from Vault.

**Benefit:**
Vault centralizes secret management and can issue temporary credentials.

---

### Q14. What is the Vault database secrets engine?

**Answer:**

The Vault database secrets engine generates database credentials dynamically.

**Example:**

1. An application requests database access.
2. Vault generates a temporary username and password.
3. The application connects to the database.
4. The credentials expire after their configured lifetime.
5. Vault revokes the credentials according to its lease configuration.

**Benefit:**
Applications do not need permanent database passwords.

---

### Q15. What are TTLs, leases, and revocation in Vault?

**Answer:**

**TTL (Time to Live):**
The period for which credentials remain valid.

**Lease:**
A record that tracks the validity and expiration of a secret.

**Revocation:**
The process of invalidating credentials before their normal expiration.

**Example:**
Vault generates database credentials valid for one hour.

After expiration, Vault can revoke the credentials and remove database access.

---

### Q16. How can you demonstrate Vault credentials, leases, and revocation?

**Answer:**

The following is an illustrative Vault CLI transcript.

**Step 1: Generate database credentials**

```bash
vault read database/creds/reporting-role
```

**Example Output:**

```text
lease_id         database/creds/reporting-role/abc123
lease_duration   1h
lease_renewable  true
username         v-token-report-123
password         ********
```

**Step 2: Revoke the credential**

```bash
vault lease revoke database/creds/reporting-role/abc123
```

**Step 3: Verify revocation**

Attempt database authentication using the revoked credentials.

**Expected Result:**
The revoked credentials should no longer authenticate successfully.

**Audit Evidence:**

- Credential generation timestamp
- Lease ID
- TTL
- Revocation command result
- Failed database authentication after revocation

**Note:**
These outputs are examples, not actual lab evidence. Passwords must not be exposed in audit reports.

---

### Q17. How can Python help with an IAM security audit?

**Answer:**

Python can automatically analyze account inventories and identify risky configurations.

A Python script can detect:

- Administrator accounts without MFA
- Inactive accounts that remain enabled
- Over-privileged service accounts
- Unnecessary administrative permissions
- Long-lived credentials

**Example:**
A CSV file contains account names, roles, MFA status, and activity information.

Python processes the file and generates security findings in JSON format.

---

### Q18. How can Python assign severity scores to IAM findings?

**Answer:**

Python can assign severity based on predefined security rules.

**Example Severity Table:**

| Finding | Severity | Reason |
|---------|----------|--------|
| Administrator without MFA | Critical | High risk of privileged account takeover |
| Unused administrator account | High | Unnecessary privileged access |
| Over-privileged service account | High | Large potential impact |
| Standard user without MFA | Medium | Increased account compromise risk |
| Minor account metadata issue | Low | Limited security impact |

**Example JSON Finding:**

```json
{
  "account": "admin01",
  "finding": "Privileged account without MFA",
  "severity": "Critical",
  "score": 9,
  "remediation": "Enforce MFA for the account"
}
```

**Key Point:**
Severity scoring helps security teams prioritize remediation.

The score above is an illustrative internal risk score, not an official CVSS score.

---

## Part 2: Conceptual Learning Objectives

### Q19. What is the difference between SAML federation and password delegation?

**Answer:**

**SAML Federation:**
An application trusts an Identity Provider to authenticate users.

The application receives a security assertion instead of the user's password.

**Password Delegation:**
A system passes or uses a user's password to authenticate against another system.

**Main Difference:**
SAML federation allows authentication across trusted systems without sharing the user's password with each application.

---

### Q20. What is the difference between IAM and PAM?

**Answer:**

| IAM | PAM |
|-----|-----|
| Identity and Access Management | Privileged Access Management |
| Manages general access | Manages high-risk privileged access |
| Controls who can access resources | Controls and monitors elevated privileges |
| Applies to users and applications | Focuses on privileged identities and sessions |
| Example: Employee accessing reports | Example: Administrator accessing a production database |

**Key Point:**
IAM manages access broadly, while PAM adds protection for powerful accounts.

---

### Q21. What is a standing privileged credential?

**Answer:**

A standing privileged credential is an account or credential that maintains elevated permissions continuously.

**Example:**
A database administrator account has permanent full access to a hospital database.

**Security Risk:**
If attackers steal the credential, they may immediately gain privileged access.

**Remediation:**

- Use Just-in-Time access.
- Remove unnecessary permanent privileges.
- Use temporary credentials.
- Monitor privileged activity.

---

### Q22. What is Just-in-Time (JIT) access?

**Answer:**

Just-in-Time access means granting privileged permissions only when needed.

**Example:**
A hospital IT administrator requests database administrator access for 30 minutes.

After the approved period, elevated access expires.

**Benefits:**

- Reduces permanent privileged access.
- Limits opportunities for credential misuse.
- Reduces the attack surface.
- Improves access control.

---

### Q23. How do TTL-based credentials reduce security risks?

**Answer:**

TTL-based credentials automatically expire after a configured period.

**Example:**
A database password remains valid for one hour instead of indefinitely.

**Benefits:**

- Reduces the useful lifetime of stolen credentials.
- Limits long-term unauthorized access.
- Supports automatic credential rotation.
- Reduces dependence on permanent secrets.

**Important:**
Attackers may still cause damage while credentials are valid.

TTL should be combined with least privilege and monitoring.

---

### Q24. What is credential theft blast radius?

**Answer:**

Blast radius refers to the amount of damage an attacker could cause after compromising an account or credential.

**Example:**

- A stolen read-only account may expose a limited set of reports.
- A stolen administrator account may expose many systems and sensitive databases.

**How to Reduce Blast Radius:**

- Apply least privilege.
- Enable MFA.
- Use JIT access.
- Use temporary credentials.
- Monitor privileged activity.

---

### Q25. What is ePHI?

**Answer:**

ePHI stands for Electronic Protected Health Information.

It refers to protected patient health information stored, processed, or transmitted electronically.

**Examples:**

- Electronic medical records
- Patient diagnoses
- Laboratory results
- Treatment information
- Prescription information

ePHI is protected under the US HIPAA framework.

---

### Q26. How can IAM misconfigurations expose ePHI?

**Answer:**

IAM misconfigurations can allow unauthorized users or applications to access sensitive patient information.

**Example:**
An AWS IAM role has unnecessary permission to read an S3 bucket containing patient records.

If the role is compromised, attackers may access those records.

**Consequences:**

- Patient privacy breaches
- Regulatory consequences
- Financial loss
- Reputational damage

**Remediation:**
Apply least privilege, MFA, access reviews, and monitoring.

---

### Q27. How can identity and cloud security problems affect patient safety?

**Answer:**

Identity and cloud security failures can affect the availability and integrity of healthcare systems.

**Example:**
An attacker compromises an over-privileged account and modifies or deletes patient records.

Doctors may then be unable to access accurate information needed for treatment.

**Potential Consequences:**

- Delayed treatment
- Incorrect medical decisions
- Unavailable patient records
- Disruption of hospital operations

**Key Point:**
Healthcare cybersecurity protects both sensitive information and patient safety.

---

## Part 3: Transversal Learning Objectives

### Q28. What is an IAM audit finding?

**Answer:**

An IAM audit finding is a documented security weakness identified during an access-control review.

A complete finding includes:

1. Finding title
2. Description
3. Evidence
4. Severity
5. Business impact
6. Recommended remediation
7. Validation method

**Example:**
An administrator account does not have MFA enabled.

---

### Q29. How do you write a professional IAM audit finding?

**Answer:**

**Finding ID:** IAM-001

**Title:** Privileged Account Without MFA

**Severity:** Critical

**Description:**
A privileged account has MFA disabled.

**Evidence:**
The account inventory identifies `admin01` as a privileged account with MFA disabled.

**Risk:**
An attacker who obtains the account password may gain privileged access.

**Remediation:**

- Enable MFA.
- Review administrator privileges.
- Monitor privileged authentication.
- Remove unnecessary access.

**Validation:**
Verify that MFA is enabled and test that privileged sign-in requires the additional authentication factor.

**Note:**
This is an illustrative audit finding. Real findings must reference verified evidence.

---

### Q30. How should IAM risks be explained to a CISO?

**Answer:**

A CISO (Chief Information Security Officer) needs to understand:

- The security issue
- Business impact
- Risk severity
- Required remediation

**Example:**

"Several privileged accounts have excessive access permissions. If compromised, these accounts could expose sensitive patient information or disrupt critical healthcare services. We recommend enforcing least privilege, MFA, and time-limited privileged access."

**Key Point:**
Focus on business risk and recommended actions rather than unnecessary technical details.

---

### Q31. How should IAM risks be presented to a Board Risk Committee?

**Answer:**

A Board Risk Committee needs a high-level explanation of organizational risk.

**Example:**

"Excessive access privileges increase the organization's exposure to data breaches and operational disruption. Reducing permanent privileged access and improving identity controls will lower the likelihood and impact of major security incidents."

**Important Information for the Board:**

- Overall risk level
- Potential business impact
- Remediation priorities
- Responsible owners
- Expected completion dates
- Remediation progress

---

### Q32. What is traceability in an IAM security audit?

**Answer:**

Traceability means being able to follow a security finding from its original evidence through analysis to the final management report.

**Example Workflow:**

```text
accounts.csv
     |
     v
iam_audit.py
     |
     v
findings.json
     |
     v
IAM Audit Report
     |
     v
CISO / Board Risk Committee
```

**Explanation:**

1. `accounts.csv` contains account inventory data.
2. `iam_audit.py` analyzes the inventory.
3. `findings.json` stores detected security issues.
4. The IAM audit report explains findings and remediation.
5. Management receives a summary of the risks.

**Benefit:**
Auditors can verify that findings are supported by evidence.

---

### Q33. Why must security findings include evidence?

**Answer:**

Evidence proves that a security issue exists.

Without evidence, a finding is only a claim.

**Example:**

**Weak Finding:**
"MFA is disabled."

**Evidence-Based Finding:**
"The account inventory shows that administrator account `admin01` has MFA disabled."

**Benefits:**

- Improves audit credibility.
- Supports remediation decisions.
- Helps validate findings.
- Provides accountability.

---

### Q34. Why is severity scoring important in IAM audits?

**Answer:**

Severity scoring helps organizations prioritize security issues.

**Example:**
A privileged account without MFA may require more urgent remediation than a minor documentation issue.

Severity scoring should consider:

- Likelihood of exploitation
- Potential business impact
- Privilege level
- Sensitivity of affected information
- Existing security controls

**Key Point:**
Higher-risk findings should generally receive higher remediation priority.

---

### Q35. How can an organization verify that IAM remediation was successful?

**Answer:**

After correcting a security issue, the organization should test the configuration again.

**Example:**
An administrator account was missing MFA.

**Validation Steps:**

1. Enable MFA.
2. Verify MFA is required during sign-in.
3. Confirm the account retains only necessary permissions.
4. Record the validation results.
5. Update the audit finding with remediation evidence.

**Key Point:**
An issue should only be marked as resolved after the remediation has been verified.

---

## Quick Revision – 10 Important Questions

| Question | Short Answer |
|----------|--------------|
| What does SAML do? | Enables federated authentication and Single Sign-On. |
| What is an Identity Provider? | A system that authenticates users and provides trusted identity information. |
| What is least privilege? | Giving users only the permissions they need. |
| What is AWS IAM? | A service for managing access to AWS resources. |
| What is PAM? | Privileged Access Management. |
| What is JIT access? | Temporary privileged access granted only when needed. |
| What is TTL? | Time to Live, the validity period of a credential or lease. |
| What does Vault do? | Securely manages secrets and can issue temporary credentials. |
| What is ePHI? | Electronic Protected Health Information. |
| Why is audit traceability important? | It connects evidence to findings, remediation, and management reporting. |

---

## Final Summary

Identity and Access Management (IAM) ensures that the right people and applications have the right permissions for the right amount of time.

The most important security principles are:

1. **Least Privilege:** Give only necessary permissions.
2. **MFA:** Require additional authentication protection.
3. **PAM:** Protect and monitor privileged access.
4. **JIT Access:** Grant elevated permissions only when needed.
5. **TTL-Based Credentials:** Use temporary credentials that expire.
6. **SAML Security:** Validate assertions, signatures, and role mappings.
7. **IAM Auditing:** Identify excessive permissions and document findings.
8. **Traceability:** Connect evidence, analysis, findings, and reports.
9. **Risk Communication:** Explain technical issues in business terms.
10. **Patient Safety:** Protect healthcare data and critical clinical systems.
