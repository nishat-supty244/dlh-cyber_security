# 10. The CSR Workshop: MedDefense Patient Portal

## Part 1 - Key Generation Decision

### Algorithm Selection: ECC P-256

**Chosen Algorithm: ECC P-256 (Elliptic Curve Cryptography)**

ECC P-256 was selected for the MedDefense patient portal (`portal.meddefense.local`) because it provides strong cryptographic security while minimizing computational overhead during TLS handshakes.

The decision is based on the following considerations:

- **Security Level:** ECC P-256 provides cryptographic strength comparable to RSA-3072 while using a significantly smaller key size, protecting patient data against modern cryptographic attacks.
- **Performance Impact:** ECC requires substantially less CPU overhead during TLS handshakes, making it ideal for maintaining high throughput and low latency for the 800+ daily patient sessions handled by the portal.
- **Compatibility:** Modern web browsers, mobile devices, and enterprise clinical workstations provide near-universal support for the P-256 curve (ANSI X9.62 / NIST `prime256v1`).
- **Alignment:** The selected algorithm satisfies the requirements specified in the MedDefense Algorithm Reference Table (T6).

### Key Generation Command

Generate the ECC private key.

```bash
openssl ecparam -genkey -name secp256r1 -out portal_key.pem
```

Protect the private key from unauthorized access.

```bash
chmod 600 portal_key.pem
```

---

## Part 2 - CSR Generation Process

To generate the Certificate Signing Request (CSR), OpenSSL is executed using command-line arguments. The CSR includes the required Distinguished Name (DN) attributes together with the Subject Alternative Names (SANs).

### Distinguished Name Fields

| Field | Value |
|-------|-------|
| **Common Name (CN)** | portal.meddefense.local |
| **Organization (O)** | MedDefense Health Systems |
| **Organizational Unit (OU)** | Information Technology |
| **Locality (L)** | Boston |
| **State (ST)** | Massachusetts |
| **Country (C)** | US |

### Subject Alternative Names (SAN)

| SAN Entry |
|-----------|
| portal.meddefense.local |
| meddefense.local |
| portal.meddefense.com |

### CSR Generation Command

```bash
openssl req -new -key portal_key.pem -out portal.csr \
  -subj "/C=US/ST=Massachusetts/L=Boston/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" \
  -addext "subjectAltName=DNS:portal.meddefense.local,DNS:meddefense.local,DNS:portal.meddefense.com"
```

---

## Part 3 - CSR Inspection & Verification

After generating the CSR, inspect the request to verify that all subject information and certificate extensions have been embedded correctly before submission to the Certificate Authority (CA).

### Inspection Command

```bash
openssl req -text -noout -in portal.csr
```

### Verification Checklist

Confirm that the inspection output contains:

| Field | Expected Value | Verified |
|-------|----------------|:--------:|
| Common Name | portal.meddefense.local | ✅ |
| Organization | MedDefense Health Systems | ✅ |
| Organizational Unit | Information Technology | ✅ |
| Country | US | ✅ |
| State | Massachusetts | ✅ |
| Locality | Boston | ✅ |
| Public Key Algorithm | ECC P-256 (`prime256v1`) | ✅ |
| SAN | portal.meddefense.local | ✅ |
| SAN | meddefense.local | ✅ |
| SAN | portal.meddefense.com | ✅ |
| Signature Algorithm | ECDSA with SHA-256 | ✅ |

---

## Part 4 - The Full Certificate Lifecycle Procedure

### Phase 1 - Preparation

#### Step 1: Key Generation

- Generate the ECC private key (`portal_key.pem`).
- Secure the private key using restrictive file permissions (`chmod 600`).

#### Step 2: CSR Generation

- Generate the Certificate Signing Request (`portal.csr`).
- Verify that all Distinguished Name fields are correct.
- Confirm that all Subject Alternative Names are present.

---

### Phase 2 - Certificate Authority Submission

#### Step 3: Submit the CSR

Submit `portal.csr` to the organization's Certificate Authority using either:

- Automated ACME Certificate Authority
- Commercial Certificate Authority workflow

---

### Phase 3 - Validation Process

#### Step 4: Domain Validation

The Certificate Authority validates ownership of the domain using one of the supported challenge-response methods:

- HTTP-01 Challenge
- DNS-01 Challenge

---

### Phase 4 - Certificate Issuance

#### Step 5: Receive the Certificate

After successful validation, the Certificate Authority signs the public key and issues the TLS certificate.

Example output:

```text
portal.crt
```

---

### Phase 5 - Installation on the Web Server

#### Step 6: Install the Certificate

Copy the certificate and private key into the secure Nginx directories.

| File | Location |
|------|----------|
| Certificate | `/etc/ssl/certs/portal.crt` |
| Private Key | `/etc/ssl/private/portal_key.pem` |

Configure Nginx.

```nginx
ssl_certificate     /etc/ssl/certs/portal.crt;
ssl_certificate_key /etc/ssl/private/portal_key.pem;
```

Restart the web service.

```bash
sudo systemctl restart nginx
```

---

### Phase 6 - Verification

#### Step 7: Verify the New Certificate

Verify the deployed certificate.

```bash
openssl s_client -connect portal.meddefense.local:443
```

Confirm that:

- The certificate chain is valid.
- The ECC public key is presented.
- The Subject Alternative Names are correct.
- TLS negotiation completes successfully.

---

### Phase 7 - Decommission the Old Certificate

#### Step 8: Remove Legacy Certificate

- Archive the expired certificate.
- Remove obsolete certificate files.
- Revoke legacy trust anchors if required.
- Update the certificate inventory.

---

### Phase 8 - Monitoring and Renewal

#### Step 9: Enable Certificate Monitoring

Configure automated monitoring to alert administrators before certificate expiration.

| Remaining Validity | Action |
|-------------------:|--------|
| **90 Days** | Initial renewal reminder |
| **60 Days** | Schedule certificate replacement |
| **30 Days** | Begin renewal process |
| **7 Days** | Critical renewal alert |

Continuous monitoring ensures that certificates are renewed before expiration and helps maintain uninterrupted HTTPS availability for the MedDefense patient portal.
