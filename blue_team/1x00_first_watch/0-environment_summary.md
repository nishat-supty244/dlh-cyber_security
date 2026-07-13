# Incident Classification Report

## Environment Summary

### Organization
MedDefense is a healthcare organization that operates multiple clinical sites and relies on several critical information systems, including an Electronic Health Record (EHR) system, a billing server, a pharmacy management system, a patient portal, a public-facing website, and a corporate network. These systems support patient care, administrative operations, and business continuity.

### Scope
This assessment covers the six security incidents recorded in MedDefense's incident log over the previous six months. The analysis focuses on identifying the security principles affected by each incident using the CIA Triad.

### Objective
The objective of this assessment is to classify each reported incident according to the primary security principle it impacts, identify any secondary impacts where applicable, and provide a clear justification for each classification.

### Methodology
Each incident is evaluated using the CIA Triad framework:
- **Confidentiality** – Protection against unauthorized access or disclosure of information.
- **Integrity** – Protection against unauthorized modification or corruption of information.
- **Availability** – Ensuring systems, services, and information remain accessible to authorized users when required.

For each incident, the primary CIA pillar is identified, a justification is provided, and any secondary CIA impact is documented when supported by the available evidence.

---

# Incident Classification Table

| Incident | Primary CIA Pillar | Justification | Secondary CIA Pillar | Secondary Justification |
|----------|--------------------|---------------|----------------------|-------------------------|
| **Incident A – Ransomware on Billing Server** | **Availability** | Availability was primarily impacted because the ransomware encrypted the billing server, preventing the finance team from processing insurance claims for four days. | **Integrity** | Integrity was also affected because the ransomware altered the stored data by encrypting it, making the original information unusable until recovery. |
| **Incident B – Broken Access Control in Patient Portal** | **Confidentiality** | Confidentiality was primarily impacted because authenticated patients could access other patients' laboratory results through a broken access control mechanism. | None | No evidence indicates that patient records were modified or that the portal became unavailable. |
| **Incident C – Incorrect Medication Dosages** | **Integrity** | Integrity was primarily impacted because a faulty database update script overwrote medication dosage values, causing inaccurate information to be displayed. | None | The system remained operational, and there is no indication that unauthorized users accessed sensitive information. |
| **Incident D – Public Website Defacement** | **Integrity** | Integrity was primarily impacted because unauthorized changes were made to the website's homepage, replacing legitimate content with a political message. | **Availability** | Availability experienced a minor impact because the website was taken offline briefly during restoration, although the primary issue was the unauthorized modification of content. |
| **Incident E – EHR System Outage** | **Availability** | Availability was primarily impacted because the Electronic Health Record system was unavailable for nine hours during the database migration, preventing physicians from accessing electronic patient records. | None | There is no evidence that patient data was disclosed or modified during the outage. |
| **Incident F – Personal Laptop Connected to Internal Network** | **Confidentiality** | Confidentiality was primarily impacted because an unmanaged personal laptop had access to the same network segment as the HR file share, increasing the risk of unauthorized access to sensitive employee information. | None | No evidence confirms that files were modified or that systems became unavailable during the exposure period. |

---

# Conclusion

The incident analysis demonstrates that MedDefense has experienced security events affecting all three principles of the CIA Triad.

Availability was most significantly affected by ransomware and the prolonged Electronic Health Record system outage, both of which disrupted critical healthcare and business operations. Confidentiality issues resulted from improper access controls and inadequate network segmentation, exposing sensitive information to unauthorized access. Integrity issues arose from unauthorized website modifications and erroneous database updates that compromised the accuracy of information.

This classification provides a structured understanding of previous security incidents and establishes a foundation for future risk assessment, security control evaluation, and security posture improvement.
