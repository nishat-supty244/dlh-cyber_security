# The Chain of Trust

## Overview

This section explores how the Public Key Infrastructure (PKI) establishes trust using certificate chains. Through practical OpenSSL commands, we inspect GitHub's complete TLS certificate chain, manually verify the chain, examine certificate revocation mechanisms (CRL and OCSP), simulate an incident response scenario for a compromised private key, and inspect the Linux system trust store.

---

# Part 1 – Capture the Full Certificate Chain

## Step 1: Retrieve the Certificate Chain

Use OpenSSL to display every certificate sent during the TLS handshake.

### Command

```bash
openssl s_client -connect github.com:443 -servername github.com -showcerts
```

---

## Certificate Chain Overview

**Total Certificates:** **3**

- **1 Leaf Certificate**
- **1 Intermediate CA**
- **1 Root CA**

---

## Subject and Issuer Relationship

| Position / Role | Subject | Issuer | Verification |
|-----------------|---------|--------|--------------|
| **0. Leaf Certificate (Server Certificate)** | CN = github.com<br>O = GitHub, Inc.<br>L = San Francisco<br>ST = California<br>C = US | CN = DigiCert TLS RSA SHA256 2020 CA1<br>O = DigiCert, Inc.<br>C = US | Issuer matches the Subject of Certificate 1 |
| **1. Intermediate CA** | CN = DigiCert TLS RSA SHA256 2020 CA1<br>O = DigiCert, Inc.<br>C = US | CN = DigiCert Global Root CA<br>O = DigiCert Inc<br>C = US | Issuer matches the Subject of Certificate 2 |
| **2. Root CA (Trusted Anchor)** | CN = DigiCert Global Root CA<br>O = DigiCert Inc<br>C = US | CN = DigiCert Global Root CA<br>O = DigiCert Inc<br>C = US | Self-signed (Subject = Issuer) |

---

## Trust Path

```
GitHub Server Certificate
        │
        ▼
DigiCert TLS RSA SHA256 2020 CA1
        │
        ▼
DigiCert Global Root CA
        │
        ▼
Operating System Trust Store
```

---

# Part 2 – Manual Certificate Chain Verification

## Step 1: Verify the Complete Chain

Bundle the intermediate certificate separately and trust the root CA.

### Command

```bash
# Verify the leaf certificate using the intermediate and trusted root
openssl verify \
    -CAfile root_ca.pem \
    -untrusted intermediate_ca.pem \
    leaf.pem
```

### Output

```text
leaf.pem: OK
```

The verification succeeds because OpenSSL can build a complete chain from the server certificate to the trusted root certificate.

---

## Step 2: Remove the Intermediate Certificate

Now verify only using the root certificate.

### Command

```bash
openssl verify \
    -CAfile root_ca.pem \
    leaf.pem
```

### Output

```text
leaf.pem: Error 20 at 0 depth lookup:
unable to get local issuer certificate

error leaf.pem: verification failed
```

---

## Why Did Verification Fail?

Although operating systems contain hundreds of trusted **root certificates**, they generally **do not include intermediate certificates**.

Without the intermediate CA:

- The leaf certificate cannot be linked to the trusted root.
- OpenSSL cannot build a valid certification path.
- Certificate validation fails.

This produces the error:

```
unable to get local issuer certificate
```

---

## Why Servers Must Send the Full Chain

During the TLS handshake, the server should transmit:

- Leaf certificate ✅
- Intermediate certificate(s) ✅

The client already possesses:

- Trusted Root Certificate ✅

Without the intermediate certificate, the client cannot establish a complete chain of trust.

```
Server
  │
  ├── Leaf Certificate
  ├── Intermediate Certificate
  ▼
Client
  │
  └── Trusted Root CA
```

This allows the browser to validate:

```
Leaf
   ↓
Intermediate
   ↓
Trusted Root
```

---

# Part 3 – Certificate Revocation Mechanisms

Certificates sometimes need to be invalidated before their expiration date.

Common reasons include:

- Private key compromise
- Certificate issued incorrectly
- Organization changes ownership
- Certificate no longer trusted

There are two primary revocation mechanisms.

---

## 1. Certificate Revocation List (CRL)

### What is it?

A **Certificate Revocation List (CRL)** is a digitally signed document published by a Certificate Authority containing the serial numbers of revoked certificates.

---

### How Clients Use It

1. Read the **CRL Distribution Point (CDP)** extension.
2. Download the CRL.
3. Search for the certificate serial number.
4. Reject the certificate if listed.

---

### Advantages

- Simple implementation
- Cryptographically signed
- Supported by virtually every PKI implementation

---

### Limitations

CRLs become very large as more certificates are revoked.

This causes:

- Increased bandwidth usage
- Longer download times
- Higher latency

Another drawback is publication frequency.

For example:

- Daily
- Weekly

A revoked certificate may still appear valid until the next CRL is published.

---

## 2. Online Certificate Status Protocol (OCSP)

### What is it?

OCSP allows a client to query the status of **one specific certificate** in real time.

Instead of downloading a complete revocation list, the client asks:

> "Is this certificate valid?"

The responder returns:

- Good
- Revoked
- Unknown

---

### Advantages over CRL

Instead of downloading thousands of revoked certificates:

```
Client
   │
HTTP Request
   │
   ▼
OCSP Responder
```

Only a single certificate status is checked.

Benefits include:

- Lower bandwidth
- Lower latency
- Faster revocation checks
- Near real-time validation

---

## 3. OCSP Stapling

OCSP introduces two problems:

- Privacy leakage (the CA learns which websites the user visits)
- Extra network latency

OCSP Stapling addresses both.

### How It Works

The web server periodically requests a signed OCSP response from the CA.

During the TLS handshake, it sends ("staples") that response directly to the client.

```
CA
 │
 │ Signed OCSP Response
 ▼
Web Server
 │
 │ TLS Handshake
 ▼
Client
```

The client no longer contacts the CA directly.

Benefits:

- Better privacy
- Faster TLS handshakes
- Reduced CA traffic

---

# Part 4 – Incident Response Scenario

## Scenario

The **MedDefense patient portal's private key** has been compromised.

Immediate action is required.

---

## Step 1 – Generate a New Key Pair

Create a brand-new cryptographic key pair on a hardened, offline system.

Generate a new Certificate Signing Request (CSR).

---

## Step 2 – Revoke the Existing Certificate

Immediately notify the issuing Certificate Authority.

The CA should:

- Revoke the certificate
- Publish it via CRL
- Update OCSP responders

---

## Step 3 – Deploy the Replacement Certificate

Install the newly issued certificate on:

- Load balancers
- Reverse proxies
- Web servers

Ensure **OCSP Stapling** is enabled.

---

## Step 4 – Verify Revocation

Use OpenSSL to confirm that the old certificate reports as revoked.

Example:

```bash
openssl ocsp ...
```

Expected result:

```
Certificate Status: revoked
```

---

## Step 5 – Perform a Security Audit

Investigate how the private key was exposed.

Possible locations include:

- Git repositories
- Environment variables
- CI/CD pipelines
- Backup archives
- Access logs

Finally:

- Rotate exposed credentials
- Patch vulnerabilities
- Document lessons learned

---

# Part 5 – Trust Store Exploration

## Linux Trusted Root Store

On Ubuntu and Debian systems, trusted root certificates are typically stored in:

```text
/etc/ssl/certs/
```

Certificate packages originate from:

```text
/usr/share/ca-certificates/
```

---

## Number of Trusted Root Certificates

The Linux trust store currently contains approximately:

**141 trusted root certificates**

These serve as the trust anchors for TLS verification.

---

## Inspect a Root Certificate

### Command

```bash
openssl x509 \
    -text \
    -noout \
    -in /etc/ssl/certs/DigiCert_Global_Root_CA.pem
```

---

## Validity Period

```
Not Before:
Nov 10 2006

Not After:
Nov 10 2031
```

Total validity:

**25 years**

---

## Why Are Root Certificates Valid for So Long?

At first glance, a **25-year lifetime** seems surprisingly long compared to:

| Certificate Type | Typical Validity |
|------------------|------------------|
| Leaf Certificate | 90 days – 1 year |
| Intermediate CA | Several years |
| Root CA | 20–30 years |

This is intentional.

Root certificates:

- Do **not** sign websites directly.
- Sign only intermediate Certificate Authorities.
- Are stored offline inside highly secure **Hardware Security Modules (HSMs)**.
- Rarely change because replacing them requires operating system and browser updates worldwide.

Their long lifespan ensures global trust remains stable while minimizing operational disruption.

---

# Key Takeaways

- TLS relies on a chain of trust from the server certificate to a trusted root CA.
- Servers must send intermediate certificates so clients can build the trust chain.
- Manual verification succeeds only when the complete chain is available.
- CRLs provide offline revocation lists but can become large and outdated.
- OCSP enables real-time certificate status checking.
- OCSP Stapling improves privacy and TLS performance by allowing servers to provide signed OCSP responses.
- If a private key is compromised, organizations must immediately generate new keys, revoke the affected certificate, deploy replacements, verify revocation, and perform a full security audit.
- Linux systems maintain trusted root certificates under `/etc/ssl/certs/`, with root certificates typically remaining valid for decades due to their foundational role in PKI.
