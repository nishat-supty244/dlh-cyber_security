**MedDefense Severity Matrix**

**Purpose**

Common severity language for all MedDefense incidents. Applied from first alert through closure.

**Severity Matrix**

| **Level** | **Patient Safety Impact** | **Data Exposure** | **Service Availability** | **Max Response Time** | **Decision Authority** |
| --------- | ------------------------- | ----------------- | ------------------------ | --------------------- | ---------------------- |
| SEV1      | high                      | confirmed_broad   | full_outage              | 15 min                | CISO                   |
| SEV2      | moderate                  | confirmed_limited | partial_outage           | 30 min                | IR Commander           |
| SEV3      | low                       | suspected         | degraded                 | 60 min                | SOC Lead               |
| SEV4      | none                      | none              | none                     | 240 min               | SOC Analyst            |

**Level Definitions**

**SEV1**

- Ransomware affecting Epic clinical systems across multiple MedDefense sites.
- Confirmed exfiltration of patient records at scale from the approximately 180,000 active patient records held by MedDefense.
- Epic or a patient monitoring system unavailable during active patient care at Main Hospital.

**SEV2**

- Confirmed compromise of an account with access to Epic or the MedDefense LIS.
- Malware confirmed on a clinical workstation at West Campus (wst-ws-NN.meddefense.local).
- Suspected exfiltration of patient information from a clinical system under investigation.

**SEV3**

- Suspicious authentication activity involving an account in meddefense.local, with no confirmed compromise.
- Malware alert on a non-critical workstation with no evidence of spread to clinical systems.
- Degraded performance of Nexus Patient Scheduling without significant patient safety impact.

**SEV4**

- A blocked phishing email with no evidence of user interaction or compromise.
- A low-confidence Wazuh EDR or Splunk alert requiring routine validation.
- An isolated security policy violation with no confirmed compromise, data exposure, or service disruption.

**Escalation Rule**

Severity is reviewed at every status update. It increases when new evidence raises patient safety, data exposure, or service availability to the next tier. It decreases only after confirmed containment and IR Commander approval.
