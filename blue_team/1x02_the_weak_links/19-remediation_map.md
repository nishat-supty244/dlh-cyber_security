# 19. The Remediation Map
## Targeted Remediation Actions, Operational Constraints, and Risk Evaluation

**Date:** July 21, 2026  
**Prepared By:** Security Department  
**Document Reference:** Project 1x02 — The Weak Links (Vulnerability Assessment Task 19)

---

# Remediation Strategy Overview

The eight highest-priority vulnerabilities identified during Task 17 have been assigned remediation strategies designed specifically for a healthcare environment. Each remediation action considers not only technical correction but also operational availability, patient safety, business continuity, rollback capability, and stakeholder coordination.

The objective is to reduce security exposure while ensuring that remediation activities do not introduce greater operational disruption than the vulnerabilities themselves.

| Metric | Details |
|--------|---------|
| Total Findings Addressed | 8 Critical (AC Priority) Findings |
| Remediation Approaches | Patch, Configuration Change, Compensating Control, Exception Management |
| Immediate Remediation Actions | 5 Actions within 24–48 hours |
| Estimated Overall Cost | $50K+ (including infrastructure changes, engineering effort, and vendor support) |

---

# Finding 001: CVE-2021-44790 — Apache HTTP Server mod_lua Buffer Overflow

## Response Type: Patch

### Patch Source

Upgrade Apache HTTP Server to a security-fixed release addressing CVE-2021-44790.

Recommended remediation sources:

- Apache HTTP Server security updates:
  https://httpd.apache.org/security/vulnerabilities_24.html

- Ubuntu security repository package:
  - Apache version 2.4.52-1ubuntu1.1 or later
  - Available through Ubuntu security repositories or Extended Security Maintenance (ESM)

The update resolves the buffer overflow vulnerability affecting the `mod_lua` module, specifically the `r:parsebody` function.

---

## Prerequisites

Before applying the Apache upgrade, the following preparation steps must be completed:

1. Create a full VM snapshot or complete system backup of `billing-srv-01`.
2. Perform application compatibility testing in a staging environment.
3. Validate billing application functionality after the Apache update.
4. Schedule deployment during a low-business-impact maintenance period.
   - Recommended window: Saturday 02:00–06:00.
5. Notify relevant stakeholders:
   - Finance Director
   - Billing Department Manager
6. Backup current Apache configurations:
   - `httpd.conf`
   - Virtual host configurations
   - `mod_lua` settings

---

## Rollback Plan

If the Apache upgrade causes billing service disruption:

1. Restore the previous VM snapshot or system backup.
2. Downgrade Apache to the previous stable package version.
3. Restore original Apache configuration files.
4. Restart Apache:

```bash
systemctl restart apache2
