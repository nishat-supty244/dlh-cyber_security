# The Cryptographic Attack Surface

## 1. TLS Downgrade

### Attack
**TLS Downgrade**

### Mechanism
An active attacker positioned on the network path intercepts the initial client-server handshake message. The attacker strips out modern protocol support flags (such as TLS 1.2 or TLS 1.3) from the client's capabilities list, forcing the server to fall back and negotiate an insecure legacy protocol version like TLS 1.0.

### MedDefense Vulnerability
**Affected Component:** MedDefense patient portal (`portal.meddefense.local`) web server configuration.

### Evidence
- Finding 005 from the vulnerability assessment (1x02).
- The assessment verified that the server supports both TLS 1.0 and TLS 1.2 concurrently.

### Viable Today
**Yes.**  
Because the server accepts legacy Client Hello parameters and permits older protocols, an unmitigated man-in-the-middle attacker can successfully force the protocol downgrade.

### Mitigation
- Completely disable TLS 1.0 and TLS 1.1 on all web servers and load balancers.
- Enforce TLS 1.2 and TLS 1.3 exclusively.
- Deploy HTTP Strict Transport Security (HSTS) to prevent protocol downgrade attempts.

---

# 2. Collision Attack

### Attack
**Collision Attack**

### Mechanism
A collision attack exploits mathematical weaknesses in cryptographic hash functions where two different plaintext inputs produce the exact same hash output. Attackers use this weakness to substitute a malicious file, script, or certificate in place of a trusted object without changing the verification checksum.

### MedDefense Vulnerability
**Affected Components:**
- Legacy software update verification scripts.
- Historical file download integrity validation processes.

### Evidence
- T6 analysis identified historical reliance on MD5 and SHA-1 checksums for asset and patch verification.

### Viable Today
**Yes.**  
Collision attacks remain possible if legacy systems or scripts continue accepting MD5 or SHA-1 validation hashes. Modern systems enforcing SHA-256 are not vulnerable to practical collision attacks.

### Mitigation
- Remove all usage of MD5 and SHA-1.
- Replace weak hashing algorithms with SHA-256 or SHA-512.
- Update file verification, code signing, and audit logging pipelines.

---

# 3. Birthday Attack

### Attack
**Birthday Attack**

### Mechanism
A birthday attack uses probability mathematics based on the birthday paradox to find hash collisions or weaken fixed-size cryptographic outputs faster than brute force.

The effective security strength of an **N-bit hash output** is reduced to approximately:

\[
2^{N/2}
\]

operations.

For example, 64-bit block ciphers such as Blowfish or 3DES become vulnerable after processing approximately:

\[
2^{32}
\]

blocks of encrypted data, allowing attackers to identify collisions and potentially recover plaintext information.

### MedDefense Vulnerability
**Affected Components:**
- Legacy medical device interfaces.
- Systems utilizing 3DES or Blowfish encryption for data transmission.

### Evidence
- T6 analysis identified 3DES and Blowfish block size limitations.
- Sweet32 vulnerability exposure thresholds were identified.

### Viable Today
**Yes.**  
High-volume legacy data flows using 64-bit block ciphers under a single static key can allow attackers to accumulate enough ciphertext blocks to exploit collision weaknesses.

### Mitigation
- Retire all 64-bit block ciphers:
  - DES
  - 3DES
  - Blowfish
- Replace them with modern 128-bit block ciphers such as AES-256.

---

# 4. Kerberoasting

### Attack
**Kerberoasting**

### Mechanism
Kerberoasting is an Active Directory attack where an authenticated domain user requests a Service Ticket (TGS) for a service principal name (SPN) associated with a user-managed service account.

The ticket is encrypted using the target service account's password hash. The attacker extracts the ticket and performs offline password cracking using high-speed GPU resources without generating significant network activity.

### MedDefense Vulnerability
**Affected Component:**  
Active Directory domain controllers allowing legacy RC4 encryption for Kerberos tickets.

### Evidence
- Finding 018 from Phase 1 (1x02).
- T6 analysis identified active RC4 permissions within Active Directory.

### Viable Today
**Yes.**  
Active Directory environments permitting RC4-HMAC encryption remain vulnerable because RC4-based Kerberos tickets are significantly easier to crack compared to modern AES-based encryption.

### Mitigation
- Disable RC4 and DES encryption types for Kerberos.
- Enforce AES-256 ticket encryption.
- Implement strong and complex service account passwords.
- Regularly audit service accounts and SPNs.

---

# 5. On-Path / MITM on Unencrypted Channels

### Attack
**On-Path / Man-in-the-Middle (MITM) Attack on Unencrypted Channels**

### Mechanism
An attacker positioned on the local network intercepts traffic flowing through unencrypted communication channels.

Because no encryption or integrity protection exists, the attacker can:
- Read sensitive information.
- Modify transmitted data.
- Inject malicious payloads into active sessions.

### MedDefense Vulnerability
**Affected Components:**
- Internal PACS medical imaging transfers (DICOM traffic).
- Unencrypted database connection strings (`ehr-db-01`).

### Evidence
- T0 Data Protection Map.
- Vulnerability findings showing unencrypted internal communication between diagnostic equipment and storage servers.

### Viable Today
**Yes.**  
Any attacker with access to internal network infrastructure or ARP spoofing capabilities can capture unencrypted DICOM images and database queries.

### Mitigation
- Enable TLS encryption for all database connections.
- Implement network segmentation.
- Use IPsec or TLS tunnels for internal PACS medical image transfers.
- Restrict unnecessary internal network access.

---

# 6. Key Recovery from Memory

### Attack
**Key Recovery from Memory (RAM Scraping / Cold Boot / Direct Extraction)**

### Mechanism
If an attacker gains administrative or root-level access to an operating system, they can inspect memory spaces, dump process contents, or use memory extraction tools to locate cryptographic keys stored in RAM.

### MedDefense Vulnerability
**Affected Components:**
- Billing server (`billing-srv-01`).
- Application memory environments where encryption keys exist during runtime.

### Evidence
- T14 Key Management analysis identified risks associated with application-level key storage.
- OS privilege boundaries were identified as a protection limitation.

### Viable Today
**Yes.**  
If an attacker achieves full root privileges on a standard host, software-managed encryption keys stored in memory can potentially be extracted.

### Mitigation
- Use Hardware Security Modules (HSMs) for master key protection.
- Utilize Trusted Platform Modules (TPMs) where appropriate.
- Ensure plaintext keys never remain exposed within general application memory.
- Implement strong operating system access controls and monitoring.

---
