# The Network Posture 

This analysis evaluates how MedDefense’s current flat network architecture amplifies the impact of individual vulnerabilities. The assessment compares the existing network design against a properly segmented architecture to demonstrate how network controls influence exploit impact, lateral movement potential, and overall business risk.

---

# CVE Analysis 1: Apache HTTP Server Remote Code Execution

## Vulnerability Information

| Field | Details |
|---|---|
| **CVE** | CVE-2021-44790 |
| **Affected Host** | 10.10.2.15 (billing-srv-01) |
| **Asset Role** | Core billing and financial records server |
| **CVSS Base Score** | 9.8 (Critical) |
| **Finding Reference** | Finding 001 |

---

# Scenario A: Current Environment (Flat Network)

## Vulnerability Reachability

**Who can reach this vulnerability:**

All internal hosts across:
