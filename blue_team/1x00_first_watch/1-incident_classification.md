# Incident Classification Report

## 1. Introduction

This report analyzes six security incidents from MedDefense's incident log using the CIA Triad framework. Each incident is classified according to its primary security impact: Confidentiality, Integrity, or Availability.

The CIA Triad provides a structured approach to evaluate how security events affect information assets and business operations:

- **Confidentiality:** Protection of information from unauthorized access or disclosure.
- **Integrity:** Protection of information and systems from unauthorized modification or corruption.
- **Availability:** Ensuring systems, services, and data remain accessible when required.

Each incident is evaluated by identifying the primary CIA pillar affected, providing justification, and identifying any secondary impacts.

---

# 2. Incident Classification Table

| Incident | Primary CIA Pillar | Justification | Secondary CIA Pillar | Secondary Justification |
|-----------|--------------------|---------------|----------------------|-------------------------|
| Incident A: Ransomware encrypted billing server | Availability | Availability was primarily impacted because the ransomware encrypted the billing server (billing-srv-01), preventing the finance team from processing insurance claims for four days. | Integrity | Integrity was also affected because ransomware modified the state of stored files by encrypting them, preventing the organization from accessing accurate and usable data. |
| Incident B: Patient portal broken access control | Confidentiality | Confidentiality was primarily impacted because the broken access control allowed authenticated patients to access other patients' laboratory results by modifying URL parameters, exposing protected health information to unauthorized users. | None | No secondary CIA impact was identified because the incident did not affect data availability or modify patient records. |
| Incident C: Incorrect medication dosages displayed | Integrity | Integrity was primarily impacted because a database update script contained a bug that overwrote medication dosage values, causing incorrect medical information to be displayed across all three sites. | None | No secondary CIA impact was identified because the system remained available and there was no evidence of unauthorized disclosure of information. |
| Incident D: Public website defacement | Integrity | Integrity was primarily impacted because unauthorized changes were made to the public website homepage, replacing legitimate content with a political message. | None | No secondary CIA impact was identified because the website remained accessible and did not contain patient information. |
| Incident E: EHR system outage during migration | Availability | Availability was primarily impacted because the EHR system became unavailable for nine hours during a database migration, forcing physicians to use paper records instead of electronic patient records. | None | No secondary CIA impact was identified because there was no evidence that patient information was exposed or modified. |
| Incident F: Intern laptop connected to internal network | Confidentiality | Confidentiality was primarily impacted because an unmanaged personal laptop connected to the internal network had access to the same network segment as the HR file share, creating a potential risk of unauthorized access to sensitive employee information. | None | No secondary CIA impact was identified because no evidence confirmed that data was modified or systems became unavailable. |

---

# 3. Conclusion

The analysis shows that MedDefense experienced incidents affecting all three elements of the CIA Triad.

- Availability impacts were mainly associated with operational disruption, including ransomware encryption and EHR downtime.
- Confidentiality impacts were related to unauthorized access risks involving patient and employee information.
- Integrity impacts resulted from unauthorized or incorrect modifications to systems and data.

Understanding the CIA impact of each incident allows security teams to prioritize remediation efforts, improve security controls, and reduce future risk exposure.
