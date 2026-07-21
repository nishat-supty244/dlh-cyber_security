# 16. The Noise Filter: Vulnerability Triage and Classification

## Complete Triage of Scan Report Findings

| Finding ID | Severity | Host / Asset | Category | Classification Reason |
|---|---|---|---|---|
| Finding 001 | 9.8 (Critical) | 10.10.2.15 (billing-srv-01) | AC | Unauthenticated remote code execution via mod_lua buffer overflow on a core financial server requires immediate patching. |
| Finding 002 | 7.8 (High) | 10.10.2.15 (billing-srv-01) | AS | Local privilege escalation to root provides a critical component for weaponized exploit chains once initial web access is secured. |
| Finding 003 | Critical (Misconfig) | 10.10.2.11 (ehr-db-01) | AC | Unrestricted internal database binding exposes protected health information to every host on the flat network. |
| Finding 004 | Critical (EOL) | 10.10.1.70 (WS-RAD-01) | AC | Unsupported Windows XP workstation running weaponizable RCE vectors (EternalBlue/BlueKeep) directly threatens patient safety. |
| Finding 005 | 7.5 (High) | 10.10.2.50 (web-srv-01) | AS | Weak TLS 1.0 support on the public patient portal exposes session data to interception and requires protocol disabling. |
| Finding 006 | High (Misconfig) | 10.10.2.15 (billing-srv-01) | AS | MySQL bound to all interfaces on the financial server allows internal network-wide connection attempts. |
| Finding 007 | High (Misconfig) | 10.10.2.20 (ad-dc-01) | AS | Missing LDAP signing and active SMBv1 on the domain controller expose identity management to relay attacks. |
| Finding 008 | High (EOL) | 10.10.2.31 (print-srv-01) | AS | End-of-life Windows Server 2012 R2 print server running vulnerable PrintNightmare components requires scheduled migration. |
| Finding 009 | High (Misconfig) | 10.10.2.15 (billing-srv-01) | AS | Password-based SSH authentication permits potential brute-force attempts without account lockouts. |
| Finding 010 | 7.5 (High) | Multiple (BD Alaris pumps) | AC | Infusion pumps with default credentials and network session vulnerabilities require urgent physical and network isolation. |
| Finding 011 | High (EOL) | 10.10.2.15 (billing-srv-01) | AS | Unsupported Ubuntu 18.04 LTS operating system lacking ESM enrollment leaves kernel packages unpatched. |
| Finding 012 | Medium (Best Practice) | 10.10.2.50 (web-srv-01) | AS | Missing HTTP security headers on the public portal enable standard browser-based exploitation techniques. |
| Finding 013 | Medium | 10.10.2.50 (web-srv-01) | AS | Patient portal SSL certificate expiring in 23 days requires automated renewal configuration to prevent service disruption. |
| Finding 014 | Medium (Architecture) | 10.10.10.1 (Westside Clinic) | AS | Consumer-grade Netgear router terminating site-to-site VPN lacks enterprise hardening and requires hardware replacement. |
| Finding 015 | Medium (Misconfig) | 10.10.2.41 (nas-01) | AC | Backup storage management interface exposed to the flat internal network with unencrypted volumes creates critical data destruction risks. |
| Finding 016 | Medium | Multiple (Philips monitors) | AS | Unauthenticated web interfaces and open HL7 telemetry ports on patient monitors require network segmentation. |
| Finding 017 | Medium (Misconfig) | 10.10.2.10 (ehr-srv-01) | AS | Apache Tomcat error page information disclosure exposes version details used in advanced targeting. |
| Finding 018 | Medium (Misconfig) | Multiple (Domain Controllers) | AS | Domain controllers supporting weak Kerberos DES/RC4 encryption types risk offline cracking attacks. |
| Finding 019 | Medium | Multiple (Workstations) | AS | RDP enabled on multiple endpoints provides targets for brute-force compromise across the network. |
| Finding 020 | 9.8 (Critical) | 10.10.2.40 (backup-srv-01) | FP | OpenSSH PKCS#11 vulnerability requires agent forwarding conditions absent in this server's operational context. |
| Finding 021 | Medium | 10.10.2.50 (web-srv-01) | AS | Enabled HTTP TRACE method creates minor exposure for Cross-Site Tracing attacks. |
| Finding 022 | Low | 10.10.2.10 (ehr-srv-01) | I | System clock skew of 47 seconds requires NTP synchronization for accurate log correlation. |
| Finding 023 | Low (Misconfig) | Multiple (Workstations) | AS | Unrestricted USB mass storage on clinical workstations enables data exfiltration and malware introduction. |
| Finding 024 | Low | 10.10.2.12 (pacs-srv-01) | AS | Unencrypted DICOM medical imaging traffic traverses the network in cleartext. |
| Finding 025 | Low (Misconfig) | 10.10.2.20 (ad-dc-01) | AS | DNS server permitting open zone transfers reveals internal network topology to attackers. |
| Finding 026 | Low | 10.10.2.15 (billing-srv-01) | AS | Outdated local Linux kernel contains privilege escalation CVEs dependent on initial access. |
| Finding 027 | Informational | Multiple (Workstations) | FP | Sophos Endpoint is deployed as the active primary agent, causing Windows Defender status to report incorrectly. |
| Finding 028 | Informational | 10.10.2.99 (Unknown) | AC | Unidentified Linux device running Jupyter/Cockpit on the server subnet represents unvetted shadow IT. |
| Finding 029 | 7.5 (High) | 10.10.10.200 (Westside Unknown) | AC | Unidentified Grafana server running exploitable path traversal vulnerability (CVE-2021-43798) at a remote clinic. |
| Finding 030 | Informational | 10.10.2.10 (ehr-srv-01) | FP | TLS common name mismatch occurs solely due to direct IP client access rather than configuration failure. |
| Finding 031 | 9.8 (Critical) | 10.10.2.10 (ehr-srv-01) | AC | Active AJP connector vulnerable to Ghostcat (CVE-2020-1938) allows unauthenticated file read and credential exposure. |

---

# Triage Summary

| Classification | Count | Description |
|---|---:|---|
| Actionable Critical (AC) | 7 | Immediate remediation required |
| Actionable Standard (AS) | 18 | Scheduled remediation required |
| Informational (I) | 1 | Monitoring and operational improvement |
| False Positive (FP) | 3 | No remediation required |
| **Total Findings** | **31** | 29 formal scan findings + 2 manual additions |

---

# Actionable Findings List

## Actionable Critical (AC) — Immediate Remediation (24–48 Hours)

| Finding | Asset | Issue |
|---|---|---|
| Finding 001 | 10.10.2.15 (billing-srv-01) | Apache RCE via mod_lua buffer overflow |
| Finding 003 | 10.10.2.11 (ehr-db-01) | PostgreSQL unrestricted network access exposing patient records |
| Finding 004 | 10.10.1.70 (WS-RAD-01) | Windows XP End-of-Life MRI workstation with weaponized exploits |
| Finding 010 | Multiple BD Alaris Pumps | Default credentials and session vulnerabilities requiring isolation |
| Finding 015 | 10.10.2.41 (nas-01) | Backup management interface exposed on unsegmented network |
| Finding 029 | 10.10.10.200 (Westside Unknown) | Grafana path traversal vulnerability (CVE-2021-43798) |
| Finding 031 | 10.10.2.10 (ehr-srv-01) | Apache AJP Ghostcat vulnerability (CVE-2020-1938) |

> **Additional Priority Note:**  
> Finding 028 (Unknown Linux device running Jupyter/Cockpit) represents an unvetted shadow IT asset and requires immediate isolation and investigation.

---

# Actionable Standard (AS) — Scheduled Remediation (7–30 Days)

| Finding | Asset | Issue |
|---|---|---|
| Finding 002 | 10.10.2.15 | Apache local privilege escalation to root |
| Finding 005 | 10.10.2.50 | Weak TLS 1.0 support on patient portal |
| Finding 006 | 10.10.2.15 | MySQL unrestricted network binding |
| Finding 007 | 10.10.2.20 | LDAP signing disabled and SMBv1 enabled |
| Finding 008 | 10.10.2.31 | Windows Server 2012 R2 end-of-life status |
| Finding 009 | 10.10.2.15 | SSH password authentication enabled |
| Finding 011 | 10.10.2.15 | Ubuntu 18.04 LTS lacking extended support enrollment |
| Finding 012 | 10.10.2.50 | Missing HTTP security headers |
| Finding 013 | 10.10.2.50 | SSL certificate expiration warning |
| Finding 014 | 10.10.10.1 | Consumer-grade Netgear VPN router |
| Finding 016 | Multiple | Philips IntelliVue monitor web/HL7 exposure |
| Finding 017 | 10.10.2.10 | Apache Tomcat version disclosure |
| Finding 018 | Multiple | Weak Kerberos DES/RC4 encryption support |
| Finding 019 | Multiple | RDP enabled across endpoints |
| Finding 021 | 10.10.2.50 | HTTP TRACE method enabled |
| Finding 023 | Multiple | Unrestricted USB storage on clinical workstations |
| Finding 024 | 10.10.2.12 | Unencrypted DICOM traffic |
| Finding 025 | 10.10.2.20 | DNS zone transfers enabled |
| Finding 026 | 10.10.2.15 | Outdated Linux kernel vulnerabilities |

---

# Final Triage Decision

The vulnerability landscape contains several high-impact risks affecting **financial systems, electronic health records, medical devices, identity infrastructure, and backup systems**.

The highest-priority remediation sequence is:

1. **Patch externally exploitable remote code execution vulnerabilities.**
2. **Isolate vulnerable medical devices and unsupported clinical systems.**
3. **Restrict database, backup, and management interfaces through segmentation.**
4. **Remove legacy protocols and unsupported operating systems.**
5. **Harden authentication, encryption, and network access controls.**

The immediate focus should remain on the **seven Actionable Critical findings**, as these present the greatest probability of compromise and the highest operational impact.
