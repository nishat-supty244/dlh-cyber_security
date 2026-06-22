Threat Modeling Analysis of an E-Commerce Platform
Introduction
This report presents a threat modeling assessment for an e-commerce platform that allows users to browse products, add items to a shopping cart, complete purchases through a checkout process, and view their order history. The platform consists of a React frontend application, a Node.js backend API, a PostgreSQL database, and integration with the Stripe payment gateway.
The objective of this assessment is to identify potential security threats affecting the checkout process, analyze trust boundaries within the system architecture, and evaluate the risk of SQL Injection vulnerabilities using the DREAD risk assessment methodology. The findings are intended to support secure system design and guide future security improvements.
________________________________________
System Overview
The e-commerce platform provides public access to product browsing and shopping cart functionality, while checkout and order history features require user authentication. Customer interactions originate from a web browser and are processed through the React frontend before being sent to the Node.js backend API. Business logic is executed on the backend, which communicates with the PostgreSQL database for data storage and with Stripe for payment processing.
System Architecture
User Browser
     │
     ▼
React Frontend
     │
     ▼
Node.js API Backend
   │          │
   ▼          ▼
PostgreSQL   Stripe
 Database    Payment Gateway
________________________________________
Trust Boundary Analysis
Trust boundaries represent points where data moves between components with different trust levels. Identifying these boundaries helps determine where validation, authentication, and security controls are required.
Trust Boundary 1: User Browser to Backend Services
The first trust boundary exists between the user's browser and the application's backend services. Information submitted from the browser, including product selections, cart contents, and checkout requests, must be treated as untrusted because users can manipulate requests using browser developer tools or interception proxies.
This boundary presents risks such as request tampering, session manipulation, and malicious input injection. Consequently, all user-supplied data must be validated and verified on the server side before being processed.
Trust Boundary 2: Backend API to PostgreSQL Database
The second trust boundary exists between the Node.js backend and the PostgreSQL database. Although the backend is considered a trusted component, user input eventually reaches the database through backend operations.
Failure to properly validate or sanitize data before database interaction may result in SQL Injection attacks, unauthorized data access, or corruption of stored information. Secure database communication and parameterized queries are therefore critical security controls at this boundary.
Trust Boundary 3: Backend API to Stripe Payment Gateway
The third trust boundary exists between the organization's infrastructure and the external Stripe payment platform. Data crossing this boundary includes payment requests, transaction confirmations, and payment status updates.
Because Stripe is a third-party service, all communications must be authenticated and encrypted. Additionally, the application must verify payment responses to prevent fraudulent transaction confirmations or API abuse.
Trust Boundary Diagram
+--------------------+
|    User Browser    |
+---------+----------+
          |
          | Trust Boundary #1
          |
+---------v----------+
|   React Frontend   |
|   Node.js Backend  |
+---------+----------+
          |
          | Trust Boundary #2
          |
+---------v----------+
| PostgreSQL Database|
+--------------------+

          |
          | Trust Boundary #3
          |
+---------v----------+
| Stripe Payment API |
+--------------------+
________________________________________
STRIDE Threat Analysis
Threat 1: Checkout Price Manipulation
STRIDE Category: Tampering
One of the most significant threats to the checkout process is the manipulation of product pricing information. Because users control their browsers, an attacker may intercept and modify requests before they are sent to the backend server.
Attack Scenario
Consider a scenario where a customer adds a product worth $500 to their shopping cart. Before completing the purchase, the attacker uses a proxy tool such as Burp Suite to intercept the checkout request. The attacker changes the product price from $500 to $5 and forwards the modified request to the server. If the backend relies on client-provided pricing information, the purchase may be completed at the altered price.
Impact
A successful attack could result in direct financial losses, fraudulent purchases, inventory loss, and reputational damage. Over time, repeated exploitation could significantly affect business revenue.
Likelihood
The likelihood of this threat is considered high because request interception tools are widely available and require only moderate technical knowledge.
Mitigation
To mitigate this risk, all pricing calculations should be performed on the server side. Product prices should be retrieved directly from the database during checkout, and any price information received from the client should be ignored. Additionally, Stripe checkout sessions should be generated exclusively by backend services to prevent manipulation.
________________________________________
Threat 2: Session Hijacking During Checkout
STRIDE Category: Spoofing
Session hijacking occurs when an attacker gains unauthorized access to a user's authenticated session and performs actions while impersonating the legitimate customer.
Attack Scenario
An attacker obtains a valid session token through phishing, malware, or insecure browser storage. The attacker then uses the stolen token to access the victim's account and complete purchases without authorization.
Impact
The consequences include unauthorized transactions, financial disputes, customer dissatisfaction, and reputational damage to the organization.
Likelihood
The likelihood of this threat is assessed as medium. While obtaining a session token requires additional effort compared to simple request manipulation, session theft remains a common attack technique.
Mitigation
Organizations should store authentication tokens in secure HttpOnly cookies, implement Multi-Factor Authentication (MFA) for sensitive operations, and use session expiration and token rotation mechanisms. Monitoring systems should also detect unusual account activity.
________________________________________
Threat 3: Payment Data Interception
STRIDE Category: Information Disclosure
Sensitive payment information may be exposed if communications between system components are not adequately protected.
Attack Scenario
An attacker positioned on an insecure network performs a Man-in-the-Middle attack and attempts to intercept payment-related communications. If encryption is weak or improperly configured, sensitive transaction data may be disclosed.
Impact
Exposure of payment information can lead to financial fraud, regulatory penalties, legal liability, and loss of customer trust.
Likelihood
The likelihood is considered medium to low because modern web applications commonly use HTTPS. However, misconfigurations and implementation errors remain possible.
Mitigation
The application should enforce TLS 1.3, enable HTTP Strict Transport Security (HSTS), and utilize Stripe Elements so that payment card information is transmitted directly to Stripe rather than passing through application servers.
________________________________________
DREAD Risk Assessment: SQL Injection in Product Search
Threat Description
The product search functionality accepts user-supplied input that is used to query product information from the database. If search parameters are incorporated into SQL queries without proper sanitization or parameterization, an attacker may inject malicious SQL commands.
For example:
' OR 1=1 --
This payload could manipulate query logic and potentially expose sensitive database contents.
DREAD Analysis
The DREAD methodology evaluates risk across five categories: Damage Potential, Reproducibility, Exploitability, Affected Users, and Discoverability.
Factor	Score	Justification
Damage Potential	9	Database compromise could expose customer and order data.
Reproducibility	10	Successful attacks can be repeated consistently.
Exploitability	8	Basic SQL Injection knowledge and publicly available tools are sufficient.
Affected Users	9	Most customers could be impacted by a data breach.
Discoverability	9	Search functionality is publicly accessible and easily identified.
Risk Calculation
DREAD Score = (Damage + Reproducibility + Exploitability + Affected Users + Discoverability) ÷ 5
= (9 + 10 + 8 + 9 + 9) ÷ 5
= 45 ÷ 5
= 9.0
Risk Rating
The resulting DREAD score is 9.0/10, which classifies SQL Injection within the product search functionality as a High-Risk vulnerability requiring immediate remediation.
Recommended Mitigations
The organization should implement parameterized SQL queries, use secure ORM frameworks, enforce input validation, apply least-privilege permissions to database accounts, and conduct regular penetration testing to identify vulnerabilities before attackers can exploit them.
________________________________________
Conclusion
This threat modeling exercise identified several significant security risks affecting the checkout process of the e-commerce platform. Among the analyzed threats, checkout price manipulation and SQL Injection represent the highest business risks due to their potential impact on revenue and customer data confidentiality.
To reduce exposure, priority should be given to implementing server-side validation, parameterized database queries, secure session management practices, and encrypted communications with external payment services. These controls provide a strong foundation for protecting customer information and maintaining the integrity of the checkout process.
References
1.	Microsoft Security Development Lifecycle (SDL) – STRIDE Threat Modeling Framework.
2.	OWASP Top 10 Web Application Security Risks.
3.	OWASP SQL Injection Prevention Cheat Sheet.
4.	OWASP Session Management Cheat Sheet.
5.	Stripe Security and PCI Compliance Documentation.

