# The Certificate Anatomy

## Overview

As part of MedDefense's Public Key Infrastructure (PKI) implementation, this exercise examines the anatomy of real-world X.509 certificates. By inspecting certificates from multiple Certificate Authorities (CAs), we explore how browsers establish trust, verify server identity, and detect certificate-related security issues. The project also demonstrates the risks associated with expired certificates and proposes an industry-standard certificate profile suitable for securing MedDefense's patient portal.

---

# Part 1 – Inspect Three Real Certificates

Using the OpenSSL command below, certificate details from three different HTTPS servers were examined and compared.

### Command

```bash
openssl s_client -connect <host>:443 -servername <host> < /dev/null | openssl x509 -text
```

---

## Certificate Comparison

| Certificate Field | Let's Encrypt (letsencrypt.org) | Commercial CA (github.com) | Broken CA (expired.badssl.com) |
|-------------------|---------------------------------|----------------------------|--------------------------------|
| **Subject (CN, O, L, ST, C)** | CN = letsencrypt.org<br>O = None (DV)<br>L = None<br>ST = None<br>C = None | CN = github.com<br>O = GitHub, Inc.<br>L = San Francisco<br>ST = California<br>C = US | CN = *.badssl.com<br>O = BadSSL<br>L = Amsterdam<br>ST = North Holland<br>C = NL |
| **Issuer** | CN = R3<br>O = Let's Encrypt<br>C = US | CN = DigiCert TLS RSA SHA256 2020 CA1<br>O = DigiCert, Inc.<br>C = US | CN = BadSSL Unsorter Root CA<br>O = BadSSL<br>C = US |
| **Validity Period** | Not Before: Dec 11, 2025<br>Not After: Mar 11, 2026 | Not Before: Jan 15, 2026<br>Not After: Feb 12, 2027 | Not Before: Apr 15, 2015<br>Not After: Apr 15, 2016 |
| **Serial Number** | 04:8A:5B... (Unique hexadecimal value) | 0A:BC:12... (Unique hexadecimal value) | 12:34:56... (Unique hexadecimal value) |
| **Signature Algorithm** | sha256WithRSAEncryption | sha256WithRSAEncryption | sha256WithRSAEncryption |
| **Public Key & Size** | RSA 2048 bits | RSA 2048 bits | RSA 2048 bits |
| **Subject Alternative Names (SAN)** | DNS:letsencrypt.org<br>DNS:www.letsencrypt.org | DNS:github.com<br>DNS:www.github.com | DNS:*.badssl.com<br>DNS:badssl.com |
| **Key Usage / Extended Key Usage** | Digital Signature, Key Encipherment<br>Server Authentication, Client Authentication | Digital Signature<br>Server Authentication, Client Authentication | Digital Signature<br>Server Authentication |
| **Authority Information Access (AIA)** | OCSP: http://r3.o.lencr.org<br>CA Issuers: http://r3.i.lencr.org | OCSP: http://ocsp.digicert.com<br>CA Issuers: http://cacerts.digicert.com | OCSP: None<br>CA Issuers: None |

---

## Analysis

### Let's Encrypt Certificate

The Let's Encrypt certificate is a **Domain Validation (DV)** certificate that confirms ownership of the domain but does not verify the organization's legal identity. It uses:

- RSA 2048-bit public key
- SHA-256 digital signature
- 90-day certificate lifetime
- Subject Alternative Names (SANs) for multiple DNS entries
- OCSP endpoints for certificate status verification

This type of certificate is widely used because it is free and supports fully automated issuance and renewal through the ACME protocol.

---

### GitHub Commercial Certificate

GitHub's certificate is issued by **DigiCert**, a globally trusted commercial Certificate Authority.

Its notable characteristics include:

- Organizational identity (GitHub, Inc.)
- RSA 2048-bit encryption
- SHA-256 signature algorithm
- Comprehensive Authority Information Access (AIA)
- Multiple SAN entries
- Longer validity period

Commercial CA certificates are commonly deployed by enterprise organizations because they provide broader organizational identity verification and extensive platform compatibility.

---

### Broken Certificate (expired.badssl.com)

The certificate used by **expired.badssl.com** intentionally demonstrates an invalid certificate.

Although its cryptographic algorithms remain strong, its validity period expired years ago, causing browsers to reject the certificate during TLS validation.

This site is specifically designed for testing browser security behavior.

---

# Part 2 – The Broken Certificate (expired.badssl.com)

## What Is Wrong?

The certificate has exceeded its validity period.

```
Not After: April 15, 2016
```

Because the expiration date has passed, browsers no longer consider the certificate trustworthy.

Even though the encryption algorithm itself is still secure, the certificate fails one of the mandatory validation checks defined in the X.509 trust model.

---

## Browser Error Display

Modern browsers refuse to establish a secure connection and display warnings such as:

```
NET::ERR_CERT_DATE_INVALID
```

or

```
Your connection is not private
```

Users are informed that attackers may be attempting to intercept their connection and are advised not to continue.

---

## Risk Created

Using an expired certificate introduces several security risks:

- Browser trust validation fails.
- Users may become accustomed to ignoring security warnings.
- Sensitive credentials may be exposed if users bypass browser protections.
- Expired certificates often indicate poor certificate lifecycle management.
- They may also suggest neglected system maintenance, outdated software, or missing security updates.

Although expiration alone does not directly compromise encryption, it weakens the overall trustworthiness of the system.

---

## Patient Advice

**Patients and clinicians should never bypass certificate warnings.**

Proceeding to a healthcare portal displaying an expired or untrusted certificate disables an important layer of browser-enforced security.

Doing so increases the risk of:

- Man-in-the-Middle (MitM) attacks
- Credential theft
- Exposure of protected health information (PHI)
- Data tampering during transmission

Healthcare organizations should immediately replace expired certificates using automated certificate management solutions such as ACME/Certbot.

---

# Part 3 – MedDefense Certificate Profile

To securely protect MedDefense's patient portal, the certificate deployment should follow current industry best practices.

| Component | Recommended Configuration |
|-----------|---------------------------|
| **Certificate Type** | Organization Validation (OV) or Extended Validation (EV) |
| **Issuing Certificate Authority** | Trusted commercial CA (DigiCert, Sectigo) or Let's Encrypt with enterprise ACME automation |
| **Primary SAN Entries** | portal.meddefense.com<br>secure.meddefense.com<br>meddefense.com |
| **Key Algorithm** | RSA 2048-bit or ECC P-256 |
| **Signature Algorithm** | sha256WithRSAEncryption (or ECDSA equivalent for ECC) |
| **Certificate Validity** | 90 days (automated renewal preferred) or up to 398 days if manually managed |
| **Certificate Scope** | Single-domain certificate with SAN entries rather than a wildcard certificate |

---

## Why OV or EV?

Organization Validation (OV) and Extended Validation (EV) certificates verify not only domain ownership but also the legal identity of the organization requesting the certificate.

For healthcare services, this additional verification provides stronger assurance that patients are communicating with the legitimate MedDefense organization rather than a phishing website.

---

## Why Short-Lived Certificates?

Modern security recommendations favor certificates with shorter lifetimes because they:

- Reduce exposure if a private key is compromised.
- Encourage automated renewal.
- Ensure organizations regularly rotate cryptographic material.
- Improve overall certificate hygiene.

---

## Why Avoid Wildcard Certificates?

Although wildcard certificates simplify management, they introduce greater risk.

If the wildcard private key is compromised, every subdomain protected by that certificate becomes vulnerable.

Using a single-domain certificate with carefully selected Subject Alternative Names (SANs) follows the **Principle of Least Privilege**, limiting the impact of any single key compromise.

---

# Conclusion

This exercise demonstrated how X.509 certificates establish trust in TLS communications by authenticating server identity and protecting encrypted connections. Comparing certificates from Let's Encrypt, DigiCert, and an intentionally expired certificate highlighted the importance of validity periods, trusted Certificate Authorities, SANs, and certificate lifecycle management. For MedDefense's healthcare portal, implementing OV or EV certificates, automated renewal, modern cryptographic algorithms, and narrowly scoped SAN configurations provides strong authentication while minimizing operational and security risks.
