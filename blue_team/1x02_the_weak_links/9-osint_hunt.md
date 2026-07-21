# 9. The OSINT Hunt  
## Manual Vulnerability Research Beyond Automated Scans



---

# Introduction: Limitations of Automated Scanning

The SecurePoint Consulting OpenVAS vulnerability scan successfully analyzed **47 hosts** and identified **31 security findings**. However, several critical operational layers were outside the scanner's visibility.

| Asset Type | Scan Coverage | Security Gap |
|------------|---------------|--------------|
| FortiGate 100F Firewall | No authenticated firmware check | FortiOS vulnerabilities remained unknown |
| Office 365 / Entra ID | Cloud environment excluded from scan scope | Cloud identity vulnerabilities remained unknown |
| Synology NAS DSM 7 | Unauthenticated network scan only | Configuration issues and local CVEs remained unidentified |

This OSINT investigation supplements the automated scan by identifying additional high-risk vulnerabilities using trusted external sources, including:

- National Vulnerability Database (NVD)
- CISA Known Exploited Vulnerabilities Catalog
- Official vendor security advisories

---

# Vulnerability 1: FortiGate FortiOS — CVE-2022-40684

## Source Information

| Field | Value |
|------|-------|
| **Source** | NVD: https://nvd.nist.gov/vuln/detail/CVE-2022-40684 |
| **CVE ID** | CVE-2022-40684 |
| **Vendor Advisory** | Fortinet PSIRT FG-IR-22-320 |
| **CISA Listing** | Yes — Added to Known Exploited Vulnerabilities Catalog (August 2022) |
| **CISA Due Date** | 30 days from addition |

---

## Vulnerability Details

| Attribute | Value |
|-----------|-------|
| **Affected Product** | FortiGate 100F running FortiOS versions prior to 7.0.7, 7.2.0, or 6.4.12 |
| **Vulnerability Type** | Authentication Bypass via Improper Authorization |
| **CVSS v3.1 Base Score** | 9.8 (Critical) |
| **CVSS Vector** | CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H |

---

## Description

An improper authorization vulnerability exists within the FortiOS HTTP handler. Remote attackers can bypass authentication controls and modify device parameters through specially crafted HTTP requests targeting REST API components without requiring valid credentials.

---

# Why the Scan Missed It

| Factor | Explanation |
|--------|-------------|
| **Asset Type** | The OpenVAS scan targeted internal server ranges (10.10.0.0/16). The FortiGate firewall operates at the network boundary and its management plane may exist outside the scanning scope. |
| **Authenticated Check Required** | Confirming the exact FortiOS release requires authenticated administrative queries. |
| **No Service Banner Exposure** | Standard HTTP/HTTPS services may not reveal internal firmware versions. |
| **Plugin Database Lag** | Vulnerability signatures may not exist if the scanner database predates the CVE disclosure. |

---

# MedDefense Impact

| Scenario | Consequence |
|----------|-------------|
| Configuration Modification | Attackers could create unauthorized VPN profiles, modify ACL rules, or redirect traffic. |
| Full Perimeter Bypass | Firewall rules could be altered to expose internal systems. |
| Lateral Movement | Attackers could create pathways into internal networks. |
| Data Exfiltration | Malicious outbound communication channels could be established. |
| Audit Trail Destruction | Attackers could disable logging mechanisms to hide activity. |

---

# Recommendation

| Action | Priority | Timeline | Owner |
|--------|----------|----------|-------|
| Upgrade FortiOS | Critical | Within 72 hours | IT Infrastructure Team |
| Verify Current Firmware Version | Critical | Immediately | Security Department |
| Review Firewall Rule Changes | High | Within 7 days | IT Infrastructure Team |
| Enable Administrative Logging | Medium | Within 14 days | Security Department |
| Implement Out-of-Band Management | Medium | Within 30 days | IT Infrastructure Team |

---

## Specific Remediation Steps

1. Access the FortiGate 100F management console.
2. Verify the running version using:

```bash
get system status
