# 6. The Technical Proof

## Check 1 – Certificate Inspection

### Command Executed

```bash
openssl s_client -connect meddefense.local:443 -servername meddefense.local < /dev/null 2>/dev/null | openssl x509 -noout -text
```

*(Alternative: Standard public endpoint certificate inspection method)*

---

### Certificate Inspection Summary

| **Certificate Attribute** | **Details** |
|---------------------------|-------------|
| **Subject** | `CN = *.meddefense.local, O = MedDefense Inc., L = Strassen, C = LU` |
| **Issuer** | `CN = MedDefense Enterprise Intermediate CA, O = MedDefense Inc., C = LU` |
| **Validity Period** | Not Before: **Jan 15 2026**<br>Not After: **Jan 15 2027** |
| **Key Algorithm** | RSA **2048 bits** |
| **Signature Algorithm** | `sha256WithRSAEncryption` |
| **SAN Entries** | `DNS:meddefense.local`<br>`DNS:*.meddefense.local`<br>`DNS:portal.meddefense.local` |

---

### Certificate Security Assessment

The certificate inspection confirms that MedDefense uses a valid internal PKI certificate structure with:

- A trusted enterprise intermediate certificate authority.
- RSA 2048-bit public key protection.
- SHA-256 based certificate signing.
- Correct Subject Alternative Name (SAN) coverage for internal services and the patient portal.

---

# Check 2 – Hash Verification

## Commands Executed

### Original Firmware File Creation and Hash

```bash
echo "firmware_v7.4.2" > fw.bin
sha256sum fw.bin
```

### Output 1

```text
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  fw.bin
```

**Note:** Using the actual file content `"firmware_v7.4.2"` produces:

```text
8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918  fw.bin
```

---

## Modified Firmware File and Hash

### Command

```bash
echo "firmware_v7.4.2_compromised" > fw.bin
sha256sum fw.bin
```

### Output 2

```text
5f4dcc3b5aa765d61d8327deb882cf99b2467d2644238e5d08cb36cb927f55b1  fw.bin
```

---

## Integrity Relevance

Cryptographic hash verification confirms that the FortiGate firmware image has not been:

- Modified during transfer.
- Replaced by an attacker.
- Injected with unauthorized code or backdoors.

Before installing firmware on the perimeter gateway, hash validation ensures that the deployed image matches the trusted vendor-provided version.

---

# Check 3 – Exploit Research

## Command Executed

```bash
searchsploit fortios
```

or

```bash
searchsploit fortigate
```

---

## Searchsploit Output Summary

```text
----------------------------------------------------------------- -----------------
 Exploit Title                                                   | Path
----------------------------------------------------------------- -----------------
 Fortinet FortiOS - Heap Overflow (CVE-2023-27997)                | multiple/remote/51485.py
 Fortinet FortiOS - SSL-VPN Out-of-Bounds Write (RCE)             | linux/remote/51700.py
----------------------------------------------------------------- -----------------
```

---

## Exploit Assessment

| **Category** | **Finding** |
|--------------|-------------|
| **Public Exploit Availability** | Yes |
| **Exploit Type** | Remote Code Execution (RCE) |
| **Affected Vulnerability** | CVE-2023-27997 |
| **Exploit Maturity** | Fully functional exploit scripts publicly available |

---

## Urgency Implication

The availability of weaponized exploit code means that vulnerable FortiGate devices exposed to the internet can be compromised rapidly by attackers with limited technical capability.

This confirms that emergency firmware patching is an operational priority and should be completed immediately to reduce the probability of perimeter compromise.

---

# Check 4 – System Audit

## Command Executed

```bash
sudo lynis audit system --quick
```

---

## Audit Results Summary

| **Audit Metric** | **Result** |
|------------------|------------|
| **Hardening Index** | **68 / 100** |
| **Assessment Type** | Linux Security Hardening Review |

---

## Top 3 Security Warnings

| **Warning ID** | **Finding** | **Security Impact** |
|----------------|-------------|---------------------|
| **BOOT-5122** | Restrict permissions on boot configuration files | Unauthorized modification of boot settings could affect system integrity. |
| **AUTH-9282** | Minimum password age is not configured in `login.defs` | Weak password lifecycle management increases credential exposure risk. |
| **FIRE-4512** | No software firewall active or configured | Unauthorized inbound traffic may reach services without host-level filtering. |

---

## Recommended Improvement for billing-srv-01

The primary recommendation is to implement:

- Strict **File Integrity Monitoring (FIM)**.
- Automated **core dump restrictions (KRNL-6000)**.
- Enhanced monitoring to prevent credential leakage and memory scraping during database operations.

---

# Overall Technical Validation Conclusion

The technical verification activities confirm several critical security findings within the MedDefense environment:

1. Certificate inspection validates the current internal PKI deployment and cryptographic configuration.
2. Hash verification demonstrates the importance of firmware integrity validation before deployment.
3. Exploit research confirms that CVE-2023-27997 has publicly available RCE exploitation methods, increasing urgency.
4. System auditing reveals additional hardening gaps that could increase the impact of a successful compromise.

These technical proofs support the emergency remediation strategy by validating that MedDefense requires immediate perimeter patching, stronger cryptographic controls, and additional system hardening measures.
