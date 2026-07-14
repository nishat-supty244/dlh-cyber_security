# Asset Criticality Assessment

This assessment categorizes MedDefense Health Systems' assets and evaluates them using the **Confidentiality, Integrity, and Availability (CIA) Triad**. The goal is to prioritize security efforts based on their impact on patient care, operational continuity, and regulatory compliance.

## Asset Criticality Matrix

| Asset Category | Confidentiality | Integrity | Availability | Overall Criticality | Justification |
|----------------|-----------------|-----------|--------------|---------------------|---------------|
| **EHR System** | Critical | Critical | Critical | **Critical** | Centralized repository for all patient Protected Health Information (PHI). Any outage forces healthcare providers to rely on paper records, significantly increasing the risk of clinical errors and delays in patient care. |
| **PACS / Imaging** | High | Critical | High | **Critical** | Stores diagnostic imaging data. Compromise of image integrity can lead to incorrect diagnoses and treatment decisions by radiologists and surgeons. |
| **Medical IoT** | High | Critical | Critical | **Critical** | Connected infusion pumps, patient monitors, and other medical devices directly impact patient safety. Unauthorized manipulation can result in life-threatening consequences. |
| **Network Core** | High | High | Critical | **Critical** | Serves as the backbone for clinical and administrative communications. Failure causes organization-wide service disruption across all healthcare facilities. |
| **Billing Infrastructure** | Critical | Medium | High | **High** | Contains sensitive financial and insurance-related PHI. A breach may result in regulatory reporting obligations, substantial financial penalties, and legal liability. |
| **Clinical Endpoints** | High | High | Medium | **High** | Workstations used to access EHR and PACS systems. Compromised endpoints are common entry points for malware, lateral movement, and data exfiltration. |
| **Administrative Endpoints** | High | Medium | Low | **Medium** | Supports daily administrative operations. While less critical to direct patient care, compromise can expose sensitive business information and enable broader attacks. |
| **Physical Security Systems** | Medium | High | Medium | **Medium** | Controls physical access to server rooms and critical infrastructure. Failure increases the risk of unauthorized physical access and hardware tampering. |

---

# Top 5 Most Critical Assets

## 1. EHR System (`ehr-srv-01`, `ehr-db-01`)

The Electronic Health Record (EHR) system is the organization's most critical asset, serving as the primary source of patient medical history, treatment records, medication information, and clinical decision support. Loss of availability forces clinicians to operate without accurate patient information, significantly increasing the likelihood of medical errors, delayed treatment, and compromised patient safety.

---

## 2. Medical IoT Devices (Infusion Pumps & Patient Monitors)

Medical IoT devices represent the highest patient safety risk because they directly interact with patients. Unauthorized access or manipulation could alter medication dosages, suppress alarms, or display inaccurate vital signs, potentially causing immediate physical harm or fatalities.

---

## 3. PACS / Imaging (`pacs-srv-01`, MRI Scanner)

The Picture Archiving and Communication System (PACS) stores and manages diagnostic imaging used by radiologists and physicians. Maintaining data integrity is essential because altered or corrupted medical images can lead to incorrect diagnoses, inappropriate treatments, and serious patient harm that may remain undetected until after care has been delivered.

---

## 4. Network Core (FortiGate 100F Firewall & Cisco Core Switches)

The network core provides connectivity for all clinical and administrative systems throughout the healthcare environment. Due to the flat network architecture, failure of the core firewall or switching infrastructure would interrupt communication between systems, preventing access to electronic health records, medical devices, imaging systems, and other essential services across all facilities.

---

## 5. Billing Infrastructure (`billing-srv-01`)

The billing infrastructure stores sensitive financial records, insurance information, and patient billing data. Although it has a lower direct impact on patient safety, it remains a high-value target for ransomware and data theft. A compromise could result in major financial losses, operational disruption, HIPAA violations, regulatory penalties, and reputational damage.

---

# Summary

The assessment identifies the **EHR System, Medical IoT devices, PACS/Imaging systems, Network Core infrastructure, and Billing Infrastructure** as the highest-priority assets requiring the strongest security controls. These systems have the greatest potential impact on patient safety, healthcare operations, data confidentiality, and regulatory compliance if compromised.
