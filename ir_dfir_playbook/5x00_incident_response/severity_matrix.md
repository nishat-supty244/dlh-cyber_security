**MedDefense Severity Matrix**

**Purpose**

Establish a common severity classification for all MedDefense incidents, from initial detection through closure. Severity is based on patient safety, data exposure, and service availability.

**Severity Matrix**

| **Level** | **Patient Safety Impact** | **Data Exposure** | **Service Availability** | **Max Response Time** | **Decision Authority** |
| --------- | ------------------------- | ----------------- | ------------------------ | --------------------- | ---------------------- |
| SEV1      | high                      | confirmed_broad   | full_outage              | 15 min                | CISO                   |
| SEV2      | moderate                  | confirmed_limited | partial_outage           | 30 min                | IR Commander           |
| SEV3      | low                       | suspected         | degraded                 | 60 min                | SOC Lead               |
| SEV4      | none                      | none              | none                     | 240 min               | SOC Analyst            |

**Level Definitions**

**SEV1**

- Ransomware affecting clinical systems across multiple MedDefense sites.
- Confirmed exfiltration of patient records at scale.
- Patient monitoring systems offline during active patient care.

**SEV2**

- Confirmed compromise of an account with access to clinical systems or patient records.
- Malware confirmed on a workstation at a clinical site, with potential to spread.
- Confirmed limited exposure of patient information or a partial outage affecting clinical services.

**SEV3**

- Suspected unauthorized access to a MedDefense system, with no confirmed data exposure.
- Malware detected on a non-critical workstation, with no evidence of spread to clinical systems.
- Degraded performance of a non-critical application or internal service without significant patient safety impact.

**SEV4**

- A blocked phishing email with no evidence of user interaction or compromise.
- A low-confidence security alert that requires routine validation.
- An isolated policy violation with no confirmed compromise, data exposure, or service disruption.

**Escalation Rule**

Severity must be reviewed at every incident status update and whenever new evidence becomes available. Raise severity immediately when evidence indicates greater patient safety impact, data exposure, or service disruption; use the highest applicable severity criterion. Lower severity only after containment is confirmed, the relevant risks are reassessed, and the IR Commander approves the downgrade. Record every severity change, its supporting evidence, and the approving role in the incident log.
