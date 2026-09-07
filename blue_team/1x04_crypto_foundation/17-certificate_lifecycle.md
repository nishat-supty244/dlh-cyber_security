# Certificate Lifecycle Management

## Certificate Inventory

| Certificate Asset | Purpose / Description | Current Issuer | Expiration Date (Estimated) | Responsible Owner |
|---|---|---|---|---|
| Patient Portal (`portal.meddefense.com`) | External-facing web portal for 800 daily patients | Commercial CA (Legacy) | 18 days remaining (**Critical**) | Lead Web Infrastructure Engineer |
| EHR Internal APIs (`api.meddefense.local`) | Internal microservice transport and authentication | MedDefense Internal PKI | 45 days remaining | Systems Architecture Team |
| VPN Gateway (`vpn.meddefense.com`) | Secure remote clinician access gateway | Commercial CA | 120 days remaining | Network Operations Lead |
| Email Gateway (`mail.meddefense.com`) | S/MIME and TLS transport encryption for secure email | Commercial CA | 180 days remaining | Enterprise Messaging Administrator |
| Code Signing (`update.meddefense.local`) | Device firmware and software update package verification | Internal Enterprise CA | 300 days remaining | Release Engineering / Security Lead |

---

# Auto-Renewal Strategy

## Recommendation for MedDefense

MedDefense should transition its public-facing patient portal and general web infrastructure to an automated **ACME protocol-based certificate management system** using:

- Let's Encrypt
- Automated enterprise commercial CA integration
- Certificate automation platforms

The recommended approach is to adopt short-lived **90-day certificates** with automated renewal workflows.

---

## Justification for the Patient Portal

The patient portal serves more than **800 daily patients** who depend on it for:

- Appointment access.
- Medical history retrieval.
- Critical healthcare communication.

An expired certificate would result in:

- Browser security warnings.
- Complete access disruption.
- Loss of patient trust.
- Potential interruption of clinical services.

The current **18-day certificate expiration window** demonstrates the risk of manual certificate tracking.

Automated ACME renewal eliminates human error by:

- Automatically detecting upcoming expiration.
- Renewing certificates weeks before expiry.
- Deploying updated certificates automatically.
- Maintaining uninterrupted portal availability.

Examples of automation solutions include:

- Certbot.
- Native cloud/load balancer certificate management.
- Enterprise PKI automation platforms.

---

# Monitoring and Alerting

## Monitoring System

MedDefense should deploy an integrated infrastructure monitoring platform capable of performing daily TLS certificate validation checks.

Recommended solutions:

- Prometheus with Blackbox Exporter.
- Datadog certificate monitoring.
- Dedicated PKI monitoring tools.

The monitoring system should automatically inspect:

- Certificate validity period.
- Expiration dates.
- Certificate chain health.
- Endpoint availability.
- Renewal status.

---

## Alert Thresholds & Routing

| Time Before Expiration | Priority | Action |
|---|---|---|
| **90 Days Out** | Informational | Automated notification sent to the responsible system owner's ticket queue to verify certificate renewal pipeline status. |
| **60 Days Out** | Low Priority | Email notification sent to the Systems Architecture team confirming certificate tracking and renewal script health. |
| **30 Days Out** | Medium Priority | High-visibility ticket assigned to the Lead Infrastructure Engineer and IT Operations Lead for renewal preparation. |
| **7 Days Out** | Critical Priority | PagerDuty/high-urgency escalation sent to the On-Call Security Engineer and CISO for immediate manual intervention if automation fails. |

---

# Certificate Policy

## 1. Prohibition of Self-Signed Certificates in Production

All production systems, including:

- Internal APIs.
- External web portals.
- Enterprise services.

must use certificates issued by:

- Trusted commercial Public Certificate Authorities (CAs).
- MedDefense Internal Enterprise PKI.

Self-signed certificates are strictly prohibited in production environments.

---

## 2. Mandatory Automated Lifecycle Management

All public and internal web certificates must use automated renewal mechanisms wherever technically feasible.

Approved automation methods include:

- ACME protocol.
- Enterprise certificate management platforms.
- Automated PKI workflows.

The goal is to eliminate certificate expiration caused by manual tracking failures.

---

## 3. Prohibition of Weak Cryptographic Keys

Certificate cryptographic requirements:

- RSA keys must be a minimum of **2048 bits**.
- RSA keys of **4096 bits** are required for Root Certificate Authorities.
- Modern ECC curves such as:
  - P-256
  - P-384

are permitted.

The following are prohibited:

- RSA-1024.
- Weak or deprecated cryptographic algorithms.

---

## 4. Enforcement of Mandatory SAN Extensions

Every certificate must include appropriate:

**Subject Alternative Names (SANs)**

that accurately represent the approved domain scope.

Requirements:

- SAN entries must match the intended services.
- Wildcard certificates require CISO approval.
- Overly broad certificate scopes are prohibited.

---

## 5. Mandatory Revocation Infrastructure Support

All issued certificates must support certificate revocation checking through:

- Authority Information Access (AIA) endpoints.
- Online Certificate Status Protocol (OCSP) endpoints.

Production servers must enable:

- OCSP Stapling.

This ensures clients can verify certificate validity efficiently and prevents continued trust in revoked certificates.

---
