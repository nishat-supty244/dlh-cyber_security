# Incident Classification Report: CIA Triad Analysis

## Overview

The following table categorizes the security incidents recorded in the MedDefense incident log using the CIA Triad framework:

- **Confidentiality:** Protection of information from unauthorized access or disclosure.
- **Integrity:** Protection of information and systems from unauthorized modification or corruption.
- **Availability:** Ensuring systems, services, and data remain accessible when required.

Applying the CIA Triad provides a structured approach to understand MedDefense's historical security risks and identify areas requiring improved security controls.

---

# Incident Classification Table

| Incident | Primary Impact | Primary Justification | Secondary Impact | Secondary Justification |
|----------|----------------|-----------------------|------------------|-------------------------|
| **Incident A: Ransomware Attack on Billing Server** | **Availability** | Availability was primarily impacted because the ransomware encrypted the billing server, making financial systems inaccessible and preventing the finance team from processing insurance claims for four days. | **Integrity** | Integrity was also affected because the unauthorized encryption process modified the state of stored files, making the original data unreadable to legitimate users. |
| **Incident B: Patient Portal Access Control Failure** | **Confidentiality** | Confidentiality was primarily impacted because a broken access control vulnerability allowed authenticated patients to view other patients' private laboratory results by modifying URL parameters. | **None** | No secondary CIA impact was identified because there was no evidence of data modification or system unavailability. |
| **Incident C: Incorrect Medication Dosage Database Update** | **Integrity** | Integrity was primarily impacted because a faulty database update script modified authorized medication dosage values, causing inaccurate clinical information to be displayed across multiple locations. | **Availability** | Availability was affected because healthcare staff could not rely on the incorrect dosage information for safe clinical decision-making, reducing the practical usability of the system. |
| **Incident D: Public Website Defacement** | **Integrity** | Integrity was primarily impacted because unauthorized actors modified the website homepage content and replaced legitimate information with a political message. | **Availability** | Availability was secondarily impacted because the legitimate website content was unavailable until the website was restored from backup, requiring temporary recovery actions. |
| **Incident E: EHR System Outage During Migration** | **Availability** | Availability was primarily impacted because the Electronic Health Record system became unavailable for nine hours during a database migration, preventing physicians from accessing electronic patient records. | **None** | No secondary CIA impact was identified because there was no indication that patient information was disclosed or modified. |
| **Incident F: Unmanaged Torrent Laptop on Internal Network** | **Confidentiality** | Confidentiality was primarily impacted because an unmanaged personal laptop connected to the internal network had access to the same network segment as the HR file share, creating a risk of unauthorized access to sensitive employee information. | **Availability** | Availability was potentially affected because the torrent client generated unauthorized network traffic that could reduce network performance and impact legitimate business operations. |

---

# Analysis Summary

## Availability Impact

Availability was the most frequently affected CIA pillar in the incident history. Several incidents resulted from operational failures, inadequate recovery planning, or system disruption.

Examples include:

- **Incident A:** Ransomware caused four days of billing system downtime.
- **Incident E:** An untested database migration process caused a nine-hour EHR outage.

These incidents demonstrate the importance of reliable backup processes, tested recovery procedures, and strong business continuity planning.

---

## Integrity Impact

Integrity-related incidents represent a significant concern because inaccurate information can directly affect healthcare decisions.

The most critical example is:

- **Incident C:** Incorrect medication dosage information was displayed due to a database update error.

This incident demonstrates the potential patient safety risks associated with unauthorized or incorrect data modification. Strong change management, validation processes, and access controls are required to protect data accuracy.

---

## Confidentiality Impact

Confidentiality incidents demonstrate weaknesses in access management and network security controls.

Examples include:

- **Incident B:** The patient portal vulnerability exposed protected health information due to improper access control.
- **Incident F:** An unmanaged device gained access to an internal network segment containing sensitive HR resources.

These incidents highlight the need for stronger identity management, network segmentation, and improved asset control.

---

# Conclusion

The CIA Triad analysis shows that MedDefense faces security risks across confidentiality, integrity, and availability domains.

The incidents demonstrate the need for:

- Improved access control mechanisms to protect sensitive information.
- Stronger network segmentation to limit unauthorized access.
- Tested backup and recovery procedures to maintain service availability.
- Better change management processes to prevent unauthorized or incorrect data modification.

Addressing these areas will strengthen MedDefense's overall security posture and reduce the likelihood and impact of future security incidents.
