
# 0. The Advisory Analysis: MedDefense Impact Assessment

## Phase-by-Phase MedDefense Mapping

| Phase | Target System | Vulnerability / Gap | Verdict |
|--------|---------------|---------------------|---------|
| **Phase 1 – Initial Access** | **portal.meddefense.local (FortiGate 100F)** | **CVE-2023-27997 / GAP-NET-01** – Unpatched firewall firmware | **EXPOSED** |
| **Phase 2 – Internal Reconnaissance** | **Core routing and VPN memory** | Memory credential exposure / **GAP-IAM-02** | **EXPOSED** |
| **Phase 3 – Lateral Movement** | **Internal servers and workstations** | Flat network (**GAP-NET-02**) and RC4 Kerberos tickets (**GAP-IAM-01**) | **EXPOSED** |
| **Phase 4 – Data Exfiltration** | **ehr-db-01 (PostgreSQL)** and **billing-srv-01 (MySQL)** | Zero encryption at rest (**GAP-SEC-03**) | **EXPOSED** |
| **Phase 5 – Backup Destruction** | **NAS-01 (Backup Storage)** | Unencrypted backup repository accessible on a flat network (**GAP-BCK-01**) | **EXPOSED** |
| **Phase 6 – Ransomware Deployment** | **Domain fleet (Windows/Linux nodes)** | Inconsistent Endpoint Detection and Response (EDR) deployment (**GAP-EDR-01**) | **EXPOSED** |
| **Phase 7 – Extortion** | **Executive leadership (CEO, CFO, Board)** | Untested crisis communication procedures (**GAP-IR-01**) | **EXPOSED** |

---

## Overall Exposure Score & Critical Finding

### Exposure Score

| Metric | Result |
|--------|--------|
| **Total Phases Assessed** | **7** |
| **Phases Exposed** | **7** |
| **Overall Exposure Score** | **7/7 (100% Exposed)** |

---

### Critical Finding

> **MedDefense is critically exposed across every stage of the ransomware attack lifecycle. The highest-priority remediation is to inspect, validate, and immediately patch the FortiGate 100F firmware affected by CVE-2023-27997. This action should be completed within the next four hours to eliminate the organization's primary external attack vector before the scheduled Board meeting.**
