# The CSR Workshop: MedDefense Patient Portal

## Part 1 – Key Generation Decision

For the MedDefense patient portal (`portal.meddefense.local`), **ECC P-256 (Elliptic Curve Cryptography)** was selected for private key generation.

### Justification

- **Security Level:** ECC P-256 provides cryptographic strength comparable to RSA-3072 while using a significantly smaller key size, offering strong protection against modern cryptographic attacks.
- **Performance Impact:** ECC requires substantially less CPU overhead during TLS handshakes, helping maintain high throughput and low latency for the 800+ daily patient sessions handled by the patient portal.
- **Compatibility:** Modern web browsers, mobile devices, and enterprise clinical workstations provide near-universal support for the P-256 curve (`prime256v1` / ANSI X9.62).
- **Standards Alignment:** This selection complies with the approved cryptographic algorithm reference (Table **T6**) and organizational security requirements.

### Key Generation Command

```bash
openssl ecparam -genkey -name secp256r1 -out portal_key.pem
chmod 600 portal_key.pem
```

---

## Part 2 – CSR Generation

To generate the Certificate Signing Request (CSR) with the required Distinguished Name (DN) fields and Subject Alternative Names (SANs), OpenSSL was executed using command-line parameters instead of an external configuration file.

### CSR Generation Command

```bash
openssl req -new -key portal_key.pem -out portal.csr \
  -subj "/C=US/ST=Massachusetts/L=Boston/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" \
  -addext "subjectAltName = DNS:portal.meddefense.local,DNS:meddefense.local,DNS:portal.meddefense.com"
```

---

## Part 3 – CSR Inspection & Verification

After generating the CSR, the request should be inspected to verify that all subject information and extensions have been embedded correctly before submission to the Certificate Authority (CA).

### Inspection Command

```bash
openssl req -text -noout -in portal.csr
```

### Example Output Summary

```text
Certificate Request:
    Data:
        Version: 1 (0x0)

        Subject:
            C=US,
            ST=Massachusetts,
            L=Boston,
            O=MedDefense Health Systems,
            OU=Information Technology,
            CN=portal.meddefense.local

        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)

                ASN1 OID: prime256v1
                NIST CURVE: P-256

        Attributes:
            Requested Extensions:
                X509v3 Subject Alternative Name:
                    DNS:portal.meddefense.local
                    DNS:meddefense.local
                    DNS:portal.meddefense.com

    Signature Algorithm: ecdsa-with-SHA256
    Signature Value:
        ...
```

### Verification Checklist

- ✅ Subject Common Name (CN) is correct.
- ✅ Organization information matches MedDefense.
- ✅ Public key algorithm is **ECC P-256**.
- ✅ Subject Alternative Names contain all required hostnames.
- ✅ Signature algorithm is **ECDSA with SHA-256**.

---

## Part 4 – Complete Certificate Lifecycle Procedure

### Step 1 – CSR Generation

- Generate the private key (`portal_key.pem`).
- Generate the Certificate Signing Request (`portal.csr`).
- Secure the private key with restrictive permissions (`chmod 600`).

---

### Step 2 – Submit the CSR

Submit `portal.csr` to the organization's Certificate Authority using either:

- ACME automation
- Commercial CA workflow
- Internal enterprise PKI

---

### Step 3 – Domain Validation

The Certificate Authority validates ownership of the domain using one of the supported validation methods:

- HTTP-01 Challenge
- DNS-01 Challenge
- TLS-ALPN-01 (where supported)

---

### Step 4 – Certificate Issuance

After successful validation, the CA signs the public key and issues the server certificate.

Example files:

```text
portal.crt
ca-chain.crt
```

---

### Step 5 – Install the Certificate

Copy the certificate and private key into secure system locations.

```text
Certificate:
/etc/ssl/certs/portal.crt

Private Key:
/etc/ssl/private/portal_key.pem
```

Update the Nginx TLS configuration.

Example:

```nginx
ssl_certificate     /etc/ssl/certs/portal.crt;
ssl_certificate_key /etc/ssl/private/portal_key.pem;
```

Restart the web service.

```bash
sudo systemctl restart nginx
```

---

### Step 6 – Verify Deployment

Verify that the certificate has been installed correctly.

```bash
openssl s_client -connect portal.meddefense.local:443
```

Confirm:

- Certificate chain is valid.
- ECC public key is presented.
- Subject Alternative Names are correct.
- TLS handshake completes successfully.

---

### Step 7 – Decommission the Previous Certificate

After successful deployment:

- Archive the expired certificate.
- Remove obsolete certificates from the server.
- Revoke compromised or retired certificates if required.
- Update internal certificate inventory.

---

### Step 8 – Continuous Monitoring

Enable automated certificate lifecycle monitoring.

Recommended alert schedule:

| Remaining Validity | Action |
|-------------------:|--------|
| 90 Days | Initial renewal reminder |
| 60 Days | Schedule certificate replacement |
| 30 Days | Begin renewal process |
| 7 Days | Critical renewal alert |

Continuous monitoring ensures certificates are renewed before expiration and helps prevent unexpected service interruptions.

---

## Summary

The MedDefense Patient Portal uses an **ECC P-256** private key to provide strong cryptographic security with excellent performance and broad compatibility. A CSR containing the required Distinguished Name fields and Subject Alternative Names is generated using OpenSSL, verified for correctness, and submitted to a trusted Certificate Authority. After domain validation, the issued certificate is installed on the Nginx web server, verified through TLS testing, and continuously monitored throughout its lifecycle to maintain uninterrupted, secure HTTPS services.
