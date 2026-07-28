# 10. The CSR Workshop: MedDefense Patient Portal

## Part 1 - Key Generation Decision

For the MedDefense patient portal (`portal.meddefense.local`), **ECC P-256 (Elliptic Curve Cryptography)** was selected for private key generation.

### Justification

- **Security Level:** ECC P-256 provides cryptographic strength equivalent to RSA-3072 while using a significantly smaller key size, offering strong protection against modern cryptographic attacks.
- **Performance Impact:** Elliptic Curve Cryptography requires substantially less CPU overhead during TLS handshakes, making it ideal for maintaining high throughput and low latency for the 800+ daily patient sessions handled by the portal.
- **Compatibility:** Modern web browsers, mobile devices, and clinical workstations provide near-universal support for the P-256 curve (ANSI X9.62 / NIST `prime256v1`).
- **Alignment:** This selection satisfies the requirements specified in the MedDefense Algorithm Reference Table (`T6`).

### Key Generation Command

```bash
openssl ecparam -genkey -name secp256r1 -out portal_key.pem
chmod 600 portal_key.pem
```

---

## Part 2 - CSR Generation Process

To generate the Certificate Signing Request (CSR) for the MedDefense patient portal, OpenSSL was executed using command-line arguments. The CSR includes the required Distinguished Name (DN) attributes and Subject Alternative Names (SANs).

### Distinguished Name (DN)

| Field | Value |
|-------|-------|
| **Common Name (CN)** | `portal.meddefense.local` |
| **Organization (O)** | MedDefense Health Systems |
| **Organizational Unit (OU)** | Information Technology |
| **Locality (L)** | Boston |
| **State (ST)** | Massachusetts |
| **Country (C)** | US |

### Subject Alternative Names (SAN)

- `portal.meddefense.local`
- `meddefense.local`
- `portal.meddefense.com`

### CSR Generation Command

```bash
openssl req -new -key portal_key.pem -out portal.csr \
  -subj "/C=US/ST=Massachusetts/L=Boston/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" \
  -addext "subjectAltName=DNS:portal.meddefense.local,DNS:meddefense.local,DNS:portal.meddefense.com"
```

---

## Part 3 - CSR Inspection & Verification

After generating the CSR, it should be inspected to verify that all metadata, distinguished name fields, and certificate extensions have been correctly embedded before submission to the Certificate Authority (CA).

### Inspection Command

```bash
openssl req -text -noout -in portal.csr
```

### Verification Checklist

Verify that the inspection output includes:

- ✅ Common Name (CN): `portal.meddefense.local`
- ✅ Organization: **MedDefense Health Systems**
- ✅ Organizational Unit: **Information Technology**
- ✅ Country: **US**
- ✅ State: **Massachusetts**
- ✅ Locality: **Boston**
- ✅ Public Key Algorithm: **ECC P-256 (`prime256v1`)**
- ✅ Subject Alternative Names:
  - `portal.meddefense.local`
  - `meddefense.local`
  - `portal.meddefense.com`
- ✅ Signature Algorithm: **ECDSA with SHA-256**

---

## Part 4 - The Full Certificate Lifecycle Procedure

### Step 1 - CSR Generation

Generate the private key (`portal_key.pem`) and Certificate Signing Request (`portal.csr`), then secure the private key using restrictive file permissions.

---

### Step 2 - Submission to the Certificate Authority

Submit `portal.csr` to the organization's automated ACME Certificate Authority or a commercial Certificate Authority for certificate issuance.

---

### Step 3 - Domain Validation

The Certificate Authority validates domain ownership using one of the supported challenge-response mechanisms:

- HTTP-01
- DNS-01

---

### Step 4 - Certificate Issuance

Once validation is successful, the Certificate Authority signs the public key and returns the operational TLS certificate.

Example output:

```text
portal.crt
```

---

### Step 5 - Installation on the Web Server

Copy the issued certificate and private key to the secure Nginx certificate directories.

| File | Location |
|------|----------|
| Certificate | `/etc/ssl/certs/portal.crt` |
| Private Key | `/etc/ssl/private/portal_key.pem` |

Configure Nginx to use the new certificate.

```nginx
ssl_certificate     /etc/ssl/certs/portal.crt;
ssl_certificate_key /etc/ssl/private/portal_key.pem;
```

Restart the web server.

```bash
sudo systemctl restart nginx
```

---

### Step 6 - Certificate Verification

Verify that the new certificate is correctly deployed and being served by the web server.

```bash
openssl s_client -connect portal.meddefense.local:443
```

Confirm that:

- The certificate chain is valid.
- The ECC public key is presented.
- The Subject Alternative Names are correct.
- The TLS handshake completes successfully.

---

### Step 7 - Decommission the Old Certificate

After successful deployment:

- Archive the expired certificate.
- Remove obsolete certificate files.
- Revoke legacy certificates or trust anchors if required.
- Update the certificate inventory.

---

### Step 8 - Certificate Monitoring and Renewal

Enable automated certificate lifecycle monitoring to prevent unexpected expiration.

Recommended alert schedule:

| Remaining Validity | Action |
|-------------------:|--------|
| **90 Days** | Initial renewal reminder |
| **60 Days** | Schedule certificate replacement |
| **30 Days** | Begin renewal process |
| **7 Days** | Critical renewal alert |

Continuous monitoring ensures timely certificate renewal and uninterrupted HTTPS availability for the MedDefense patient portal.
