Threat Modeling Report: E-Commerce Platform Checkout Process
1. Executive Summary

This report analyzes security threats affecting the checkout process of an e-commerce platform consisting of a React frontend, Node.js backend, PostgreSQL database, and Stripe payment integration. The assessment applies the STRIDE threat modeling methodology and DREAD risk scoring framework to identify, evaluate, and prioritize security risks.

The analysis identified three significant threats:

Price Manipulation During Checkout (Tampering)
Session Hijacking During Payment (Spoofing)
Payment Data Interception (Information Disclosure)

Additionally, SQL Injection within the product search functionality was evaluated using the DREAD methodology and determined to represent a High Risk threat with a score of 9.0/10.

2. System Architecture
Architecture Diagram
+---------------------+
|      Customer       |
|  Web Browser/User   |
+----------+----------+
           |
           | HTTPS
           |
+----------v----------+
|   React Frontend    |
+----------+----------+
           |
           | REST API
           |
+----------v----------+
|   Node.js Backend   |
+----+-----------+----+
     |           |
     | SQL       | HTTPS
     |           |
+----v----+   +--v----+
|PostgreSQL|   |Stripe|
| Database |   |Payment|
+----------+   +-------+
3. Trust Boundary Analysis
Trust Boundary Diagram
+---------------------------------------------------+
|                 Internet Zone                     |
|                                                   |
|  User Browser                                     |
|       |                                           |
+-------|-------------------------------------------+
        |
        | Trust Boundary #1
        |
+-------v-------------------------------------------+
|             Application Zone                      |
|                                                   |
| React Frontend                                    |
|       |                                           |
|       v                                           |
| Node.js Backend                                   |
+-------|-------------------------------------------+
        |
        | Trust Boundary #2
        |
+-------v-------------------------------------------+
|               Data Zone                           |
|                                                   |
| PostgreSQL Database                               |
+---------------------------------------------------+

        |
        | Trust Boundary #3
        |
+-------v-------------------------------------------+
|           External Service Zone                   |
|                                                   |
| Stripe Payment Platform                           |
+---------------------------------------------------+
Trust Boundary 1: User Browser → Backend
Description

User-controlled data enters the trusted application environment.

Security Concerns
Request tampering
Credential theft
Malicious payload injection
Example

An attacker modifies checkout requests using Burp Suite before submission.

Trust Boundary 2: Backend → PostgreSQL Database
Description

Application logic communicates with persistent storage.

Security Concerns
SQL Injection
Unauthorized database access
Data corruption
Example

Unsanitized search parameters are executed directly as SQL queries.

Trust Boundary 3: Backend → Stripe Payment Gateway
Description

Sensitive payment information is exchanged with a third-party service.

Security Concerns
API abuse
Data interception
Payment fraud
Example

An attacker attempts to forge payment confirmation messages.

4. STRIDE Threat Analysis
Threat 1: Price Manipulation During Checkout
STRIDE Category

Tampering

Description

An attacker modifies product prices or quantities in requests submitted from the browser before they reach the backend.

Attack Scenario
User adds a product worth $500 to cart.
Attacker intercepts the checkout request using a proxy tool.
Price field is changed from $500 to $5.
Backend trusts client-side price data.
Payment is processed at the manipulated amount.
Impact
Direct financial loss
Fraudulent transactions
Inventory loss
Reputational damage
Likelihood

High

Client-side manipulation tools are freely available and require minimal technical skill.

Suggested Mitigation
Calculate all prices server-side.
Validate product IDs against database values.
Use Stripe Checkout Sessions generated exclusively by backend services.
Reject requests containing client-calculated totals.
Threat 2: Session Hijacking During Payment
STRIDE Category

Spoofing

Description

An attacker impersonates a legitimate user by obtaining authentication credentials or session tokens.

Attack Scenario
User logs into the platform.
Session token is stolen through malware, phishing, or insecure storage.
Attacker reuses the token.
Purchases are completed under the victim's account.
Impact
Unauthorized purchases
Account compromise
Chargebacks
Customer dissatisfaction
Likelihood

Medium

Requires token theft but remains a common attack technique.

Suggested Mitigation
Store tokens in HttpOnly cookies.
Implement MFA for checkout activities above defined thresholds.
Monitor anomalous purchases.
Apply short session lifetimes and token rotation.
Threat 3: Payment Data Interception
STRIDE Category

Information Disclosure

Description

Sensitive payment-related information is intercepted while transmitted between system components.

Attack Scenario
User submits payment details.
Traffic passes through an insecure network.
Attacker performs a Man-in-the-Middle attack.
Payment information is exposed.
Impact
Exposure of financial information
Regulatory penalties
Loss of customer trust
Potential fraud
Likelihood

Medium-Low

Modern HTTPS reduces probability but misconfigurations remain possible.

Suggested Mitigation
Enforce TLS 1.3.
Implement HSTS.
Use Stripe Elements to prevent card data from passing through application servers.
Continuously monitor TLS configurations.
5. DREAD Risk Assessment: SQL Injection in Product Search
Threat Description

The product search function accepts user input. If the application constructs SQL queries using string concatenation, attackers may inject malicious SQL commands.

Example Payload
' OR 1=1 --

This payload may alter query logic and expose sensitive information.

DREAD Scoring
Factor	Score (0-10)	Justification
Damage Potential	9	Full database compromise could expose customer, order, and payment metadata.
Reproducibility	10	Successful attack can be repeated consistently.
Exploitability	8	Requires basic SQL injection knowledge and freely available tools.
Affected Users	9	Database compromise affects most customers.
Discoverability	9	Search functionality is publicly visible and easily tested.
Risk Calculation

Formula:

DREAD Score = (D + R + E + A + D) / 5

Substituting values:

(9 + 10 + 8 + 9 + 9) / 5
= 45 / 5
= 9.0
Final Risk Rating

9.0 / 10 (High Risk)

Recommended Mitigation
Mitigation	Priority
Parameterized Queries	Critical
ORM Prepared Statements	Critical
Input Validation	High
Least-Privilege Database Accounts	High
Security Monitoring and Logging	Medium
Penetration Testing	Medium
6. Real-World Implementation Considerations
Mitigation	Cost	Implementation Time	Security Benefit
Parameterized Queries	Low	1-2 days	Very High
Server-side Price Validation	Low	1 day	Very High
MFA Deployment	Medium	1-2 weeks	High
HSTS Enforcement	Low	Few hours	Medium
Security Monitoring	Medium	1 week	High
Annual Penetration Testing	Medium-High	Ongoing	High
7. Conclusion

The most critical risks identified are SQL Injection and Checkout Price Manipulation because they can directly impact revenue and customer data. Immediate implementation of parameterized queries and server-side transaction validation should be prioritized. Session protection controls and payment-channel hardening should follow as part of a defense-in-depth strategy.

References
STRIDE Threat Modeling Framework – Microsoft Security Development Lifecycle.
OWASP Top 10: Injection Vulnerabilities.
OWASP Session Management Cheat Sheet.
OWASP Transport Layer Security Cheat Sheet.
Stripe Security Best Practices Documentation.
