
## The Segmentation Architecture

---

# Part 1 – Network Security Zone Definition

To eliminate the flat internal network architecture (**Finding 008**) and enforce the **principle of least privilege**, MedDefense Health Systems is segmented into five dedicated security zones (VLANs). Communication between zones is routed through internal **stateful firewalls**, where only explicitly authorized traffic is permitted.

---

## Zone 1 – Server Zone

| **Category** | **Details** |
|--------------|-------------|
| **Zone Name** | Server Zone |
| **VLAN ID** | VLAN 10 |
| **IP Range** | 10.200.10.0/24 |
| **Systems Included** | EHR servers (`ehr-srv-01`), billing database servers (`db-sql-01`, `db-sql-02`), Active Directory Domain Controllers (`dc-01`, `dc-02`), internal file servers, and backup repositories |
| **Allowed Outbound Connections** | • DNS queries through approved secure proxy<br>• Operating system updates via designated repositories<br>• NTP synchronization with internal time servers |
| **Allowed Inbound Connections** | • Clinical Workstation Zone via approved application ports (HTTPS/443, LDAP/389)<br>• Administrative access from the Management Zone using SSH/RDP protected by MFA |

---

## Zone 2 – Clinical Workstation Zone

| **Category** | **Details** |
|--------------|-------------|
| **Zone Name** | Clinical Workstation Zone |
| **VLAN ID** | VLAN 20 |
| **IP Range** | 10.200.20.0/23 (10.200.20.0 – 10.200.21.255) |
| **Systems Included** | Nurse station terminals, physician workstations, registration PCs, and clinical mobile carts (`ws-*`) |
| **Allowed Outbound Connections** | • HTTPS access to EHR servers (TCP 443)<br>• SQL connectivity (TCP 1433)<br>• Internet access through secure web proxy for approved clinical resources |
| **Allowed Inbound Connections** | • Established and related return traffic only<br>• Remote management exclusively from the Management Zone |

---

## Zone 3 – Medical Device Zone (IoMT / Clinical Engineering)

| **Category** | **Details** |
|--------------|-------------|
| **Zone Name** | Medical Device Zone |
| **VLAN ID** | VLAN 30 |
| **IP Range** | 10.200.30.0/24 |
| **Systems Included** | Patient monitors, infusion pumps (`med-infusion-*`), MRI scanners (`med-mri-01`), imaging systems, and PACS devices |
| **Allowed Outbound Connections** | • Secure communication with designated PACS servers using DICOM and HTTPS<br>• Local broadcast traffic contained within the VLAN |
| **Allowed Inbound Connections** | • Only authorized clinical monitoring servers and Biomedical Engineering maintenance terminals from the Management Zone<br>• Direct internet access prohibited |

---

## Zone 4 – Management Zone

| **Category** | **Details** |
|--------------|-------------|
| **Zone Name** | Management Zone |
| **VLAN ID** | VLAN 40 |
| **IP Range** | 10.200.40.0/28 |
| **Systems Included** | Administrator jump boxes, security analyst workstations, Wazuh SIEM collectors, and network infrastructure management interfaces |
| **Allowed Outbound Connections** | Administrative access (SSH, HTTPS, RDP with MFA) to all authorized internal network zones |
| **Allowed Inbound Connections** | Restricted to authenticated administrators using MFA from approved management endpoints or secure VPN gateways |

---

## Zone 5 – Guest / IoT Zone

| **Category** | **Details** |
|--------------|-------------|
| **Zone Name** | Guest / IoT Zone |
| **VLAN ID** | VLAN 50 |
| **IP Range** | 10.200.50.0/22 (10.200.50.0 – 10.200.53.255) |
| **Systems Included** | Visitor Wi-Fi devices, patient entertainment tablets, smart HVAC controllers, lighting systems, and non-critical IoT devices |
| **Allowed Outbound Connections** | Internet-only access (HTTP, HTTPS, DNS) through captive portal |
| **Allowed Inbound Connections** | None. Inter-client communication is disabled using Private VLAN (PVLAN) isolation. |

---

# Part 2 – Stateful Firewall Rules (Pseudocode)

The following firewall policies enforce strict segmentation and prevent unauthorized communication between network zones.

| **Rule** | **Traffic Flow** | **Action** | **Purpose** |
|-----------|------------------|------------|-------------|
| **Rule 1** | Management Zone → Server Zone (TCP 22, 3389, 443) | **ALLOW** | Enables secure administrative management of servers through MFA-protected SSH, RDP, and HTTPS sessions. |
| **Rule 2** | Clinical Workstation Zone → Server Zone (TCP 443, 1433) | **ALLOW** | Allows clinicians to access Electronic Health Records (EHR) applications and SQL databases. |
| **Rule 3** | Clinical Workstation Zone → Server Zone (TCP/UDP 389, 636, 53) | **ALLOW** | Supports Active Directory authentication, LDAP, LDAPS, and DNS services. |
| **Rule 4** | Medical Device Zone → Server Zone (TCP 104, 2761, 443) | **ALLOW** | Permits DICOM imaging traffic and secure communications between imaging devices and PACS servers. |
| **Rule 5** | Management Zone → Medical Device Zone (TCP 22, 443, 8080) | **ALLOW** | Restricts medical device maintenance and administration to authorized biomedical engineering personnel. |
| **Rule 6** | Guest / IoT Zone → Internet (TCP 80, 443; UDP 53) | **ALLOW** | Provides isolated internet connectivity without internal network access. |
| **Rule 7** | Clinical Workstation Zone → Server Zone (All Other Ports) | **DENY** | Prevents lateral movement by blocking unauthorized access to SMB, RPC, administrative interfaces, and other unnecessary services. |
| **Rule 8** | Guest / IoT Zone → Medical Device Zone (All Ports) | **DENY** | Prevents guest devices from communicating with clinical medical equipment, protecting patient safety and preventing unauthorized access. |
| **Rule 9** | All Zones → Management Zone (UDP 514, TCP 1514) | **ALLOW** | Centralizes log forwarding to the Wazuh SIEM platform for monitoring and incident detection. |
| **Rule 10** | Any Zone → Any Zone (All Other Traffic) | **DENY** | Implements a Zero Trust default-deny policy by blocking all unspecified inter-VLAN communication. |

---

# Part 3 – Kill Chain Impact Analysis

## Ransomware Kill Chain Disruption

The following walkthrough demonstrates how the proposed segmentation architecture interrupts MedDefense's primary ransomware attack scenario (Kill Chain #1 from Task 1x01).

### Step 1 – Phishing Delivery

An employee receives a spear-phishing email containing a malicious link and unknowingly downloads a malware loader.

**Segmentation Impact:**  
Network segmentation does not prevent the initial phishing delivery because the attack originates at the endpoint.

---

### Step 2 – Initial Execution and Command & Control (C2)

The malware executes within the compromised workstation located in the **Clinical Workstation Zone (VLAN 20)** and attempts outbound communication with its command-and-control server.

**Segmentation Impact:**  
Outbound communication is monitored and can be blocked or logged through secure web filtering, proxy controls, and network monitoring solutions.

---

### Step 3 – Credential Harvesting

The malware extracts cached credentials and authentication tokens from local memory.

**Segmentation Impact:**  
Segmentation does not directly prevent credential theft but limits the usefulness of harvested credentials by restricting where they can be used.

---

### Step 4 – Lateral Movement and Internal Reconnaissance **(Primary Break Point)**

The attacker attempts to enumerate internal hosts using SMB, RDP, RPC, and other common lateral movement techniques to locate backup servers, file shares, and domain controllers.

### Security Impact

Under the previous flat network architecture, the malware could freely scan and move throughout the internal environment.

With the proposed segmented architecture:

- **Firewall Rule 7** blocks all unauthorized workstation-to-server communication.
- **Firewall Rule 10** blocks every unapproved inter-VLAN connection by default.
- SMB file shares, management ports, and unnecessary services remain inaccessible.
- Malware cannot enumerate neighboring workstations or critical infrastructure.

As a result, the attack is confined to the initially compromised workstation, dramatically reducing the ransomware blast radius.

---

### Step 5 – Backup Encryption and Ransomware Deployment

Unable to move laterally, the attacker cannot reach:

- Backup repositories
- Domain Controllers
- Database servers
- Shared file systems

Without access to these high-value assets, enterprise-wide ransomware deployment fails, and widespread encryption of critical systems is prevented.

---

# Overall Kill Chain Impact

The proposed segmentation architecture fundamentally transforms MedDefense's internal network from a flat, implicitly trusted environment into a **Zero Trust, least-privilege architecture**.

By enforcing stateful firewall inspection between functional security zones, the design:

- Prevents unauthorized lateral movement.
- Protects critical servers from compromised endpoints.
- Isolates medical devices from public and guest networks.
- Restricts administrative access to authenticated management systems.
- Centralizes security monitoring through the Wazuh SIEM platform.
- Reduces the attack surface available for privilege escalation and asset discovery.

Collectively, these controls disrupt the lateral movement, privilege escalation, reconnaissance, and ransomware deployment phases across MedDefense's five highest-priority attack kill chains, significantly improving the organization's overall cyber resilience.
