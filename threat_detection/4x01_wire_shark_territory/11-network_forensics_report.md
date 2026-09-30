

**Description: Generates the comprehensive Network Forensics Investigation Report**

**Network Forensics Investigation Report: MedDefense Health Systems Incident**

**Executive Summary**

**On April 14, 2026, a targeted phishing campaign compromised nurse workstation WS-NURSE-04 (10.10.2.15), leading to credential harvest and subsequent internal lateral movement. The threat actor established command-and-control (C2) beaconing, pivoted into the internal network via compromised VPN credentials, and exfiltrated sensitive data through encoded DNS TXT queries. Patient billing records and sensitive clinical metadata were likely compromised or exfiltrated. Core database servers and uncompromised internal VLANs remained protected behind internal segmentation and firewall controls.**

**Investigation Scope**

- **PCAP Files Analyzed: normal_baseline_clinical.pcap, phishing_click.pcap, c2_beaconing.pcap, dns_exfil.pcap, lateral_movement.pcap, and full_timeline.pcap.**
- **Time Period: April 14, 2026, covering the morning baseline through post-compromise activity windows.**
- **Tools Used: tshark, custom Bash automation scripts, and Wireshark (manual verification).**
- **Excluded Evidence Sources: Host-level endpoint logs, physical memory dumps, SIEM alerts, and mail gateway logs (strictly packet-driven forensic analysis).**

**Methodology**

- **Baseline Establishment: Profiled normal clinical traffic, protocol distribution, and baseline DNS/TLS patterns using normal_baseline_clinical.pcap.**
- **Known-IOC Search: Correlated traffic against known indicators from investigation 4x00 (meddefense-portal.com and 91.234.99.107).**
- **DNS Analysis: Inspected DNS queries, record types (A, TXT), response TTLs, and subdomain entropy.**
- **TLS Metadata Analysis: Analyzed SNI values, certificate issuers, handshake versions, and client record sizes.**
- **Timing Analysis: Measured connection regularity, inter-arrival times, and session durations to detect C2 beaconing.**
- **Behavioral Analysis: Traced cross-subnet connection attempts, RDP usage, and SMB enumeration.**
- **Cross-PCAP Correlation: Synthesized isolated captures into a unified end-to-end attack timeline.**

**Findings by Attack Phase**

1. **Phishing Delivery (Phase 1)**

- **_Narrative Description:_ Target receives and interacts with the phishing lure.**
- **_Evidence Citation:_ External context from 4x00; initial DNS query meddefense-portal.com in phishing_click.pcap at 15:02:33.142.**
- **_MITRE ATT&CK:_ T1566.002 (Phishing: Spearphishing Link)**
- **_Confidence Level:_ High (Contextual) / Confirmed via wire**
- **_Proof:_ Packet evidence proves DNS resolution to external IP 91.234.99.107.**

1. **Credential Harvest (Phase 2)**

- **_Narrative Description:_ User enters credentials into the external phishing portal.**
- **_Evidence Citation:_ phishing_click.pcap (15:02:33.412 - 15:03:20.614).**
- **_MITRE ATT&CK:_ T1056.001 (Input Capture: Keylogging / Web Credentials)**
- **_Confidence Level:_ Strong Inference**
- **_Proof:_ 47-second HTTPS session with a 487-byte client payload matching form submission size.**

1. **C2 Beaconing (Phase 3)**

- **_Narrative Description:_ Compromised workstation establishes automated check-ins with external C2 infrastructure.**
- **_Evidence Citation:_ c2_beaconing.pcap (Starting post-click window).**
- **_MITRE ATT&CK:_ T1071.001 (Application Layer Protocol: Web Protocols)**
- **_Confidence Level:_ Confirmed**
- **_Proof:_ Regular HTTPS connections every 300 seconds transferring minimal data to external IP.**

1. **VPN Pivot (Phase 4)**

- **_Narrative Description:_ Attacker utilizes harvested credentials (dmarsh) to establish external VPN access.**
- **_Evidence Citation:_ full_timeline.pcap / lateral_movement.pcap (External IP 154.118.42.89).**
- **_MITRE ATT&CK:_ T1133 (External Remote Services)**
- **_Confidence Level:_ Strong Inference**
- **_Proof:_ Inbound VPN session established from external infrastructure matching compromised user context.**

1. **RDP Lateral Movement (Phase 5)**

- **_Narrative Description:_ Attacker moves from the clinical workstation to the billing server.**
- **_Evidence Citation:_ lateral_movement.pcap.**
- **_MITRE ATT&CK:_ T1021.001 (Remote Services: Remote Desktop Protocol)**
- **_Confidence Level:_ Confirmed**
- **_Proof:_ Direct RDP TCP session established between clinical VLAN host and billing-srv-01.**

1. **SMB Discovery (Phase 6)**

- **_Narrative Description:_ Attacker enumerates network shares and file structures via SMB.**
- **_Evidence Citation:_ lateral_movement.pcap.**
- **_MITRE ATT&CK:_ T1046 (Network Service Discovery)**
- **_Confidence Level:_ Confirmed**
- **_Proof:_ High volume of SMB tree connect and directory listing requests across internal subnets.**

1. **DNS Exfiltration (Phase 7)**

- **_Narrative Description:_ Data exfiltrated out of the environment via encoded DNS TXT queries.**
- **_Evidence Citation:_ dns_exfil.pcap (data-sync.meddefense-portal.com).**
- **_MITRE ATT&CK:_ T1048.003 (Exfiltration Over Alternative Protocol: Exfiltration Over DNS)**
- **_Confidence Level:_ Confirmed**
- **_Proof:_ Hundreds of unusual, long, encoded subdomains queried via DNS TXT records.**

**Network-Level IOC Table**

**| Type | Value | Source | Confidence | Detection Utility |**

**| Domain | meddefense-portal.com | 4x00 / PCAP | High | DNS blocklisting & sinkholing |**

**| IP | 91.234.99.107 | 4x00 / PCAP | High | Firewall egress filtering |**

**| IP | 154.118.42.89 | PCAP (c2_beaconing) | High | External VPN access blocking |**

**| Domain | data-sync.meddefense-portal.com | PCAP (dns_exfil) | High | DNS query monitoring / alerting |**

**Impact Assessment**

- **Data Likely Exfiltrated: Encoded internal configuration details and billing metadata via DNS TXT channels.**
- **Systems Involved: WS-NURSE-04 (10.10.2.15), billing-srv-01 (10.10.2.31).**
- **Systems Protected / Not Reached: Core electronic health record (EHR) database clusters and isolated administrative subnets.**
- **Credential Exposure: User account dmarsh compromised.**
- **Regulatory / Business Concerns: Potential HIPAA breach notification obligations due to unauthorized access to billing/clinical workstations.**

**Detection Gap Analysis**

- **What Packet Evidence Revealed: Full timing periodicity of beacons and structural encoding of DNS exfiltration.**
- **Earlier Detection Opportunities: Endpoint behavior monitoring on nurse workstation and automated egress TLS inspection.**
- **Behavioral Detection Gaps: Lack of anomaly detection for periodic 300-second outbound connections.**
- **DNS Tunneling Detection Gap: Absence of entropy checks on DNS TXT query volume and length.**
- **VPN Anomaly Detection Gap: Failure to flag anomalous external IP connection using valid credentials.**
- **Lateral Movement Detection Gap: Unrestricted RDP/SMB traversal from clinical VLAN to internal servers.**

**Detection Rules Recommended**

1. **Periodic HTTPS Beaconing Detection**

- **_Data Source:_ Netflow / Firewall / PCAP**
- **_Attack Phase:_ C2 Beaconing**
- **_False Positive Considerations:_ Cloud synchronization tools, scheduled API pollers.**

1. **High-Entropy DNS TXT Exfiltration Rule**

- **_Data Source:_ DNS Server Logs / Packet Capture**
- **_Attack Phase:_ Exfiltration**
- **_False Positive Considerations:_ Legitimate TXT-based service discovery or certificate verification checks.**

1. **Cross-Subnet RDP/SMB Traversal Alert**

- **_Data Source:_ Internal Flow / Firewall Logs**
- **_Attack Phase:_ Lateral Movement**
- **_False Positive Considerations:_ Authorized administrative management traffic.**

**Recommendations**

**Immediate (Next 24 Hours)**

- **Isolate WS-NURSE-04 and billing-srv-01 from the network.**
- **Force immediate password resets and session terminations for user dmarsh and all affected clinical staff.**
- **Block infrastructure IPs (91.234.99.107, 154.118.42.89) and domains (meddefense-portal.com) at the perimeter firewall and DNS sinkhole.**
- **Preserve all PCAP archives and server volatile memory.**

**Short-Term (Next 7 Days)**

- **Deploy behavioral detection logic for regular-interval outbound connections.**
- **Review and restrict VPN access policies, enforcing multi-factor authentication (MFA) and geo-location validation.**
- **Implement strict DNS egress filtering to monitor and restrict TXT query volume.**
- **Perform a broader sweep for additional compromised hosts across all VLANs.**

**Medium-Term (Next 30 Days)**

- **Enforce advanced email authentication protocols (SPF, DKIM, DMARC).**
- **Improve internal DNS anomaly detection and subdomain entropy monitoring.**
- **Implement micro-segmentation and role-based RDP restrictions between clinical and administrative subnets.**
- **Conduct a comprehensive healthcare data exposure and compliance review.**

**Evidence Chain**

- **normal_baseline_clinical.pcap: Establishes standard clinical traffic baseline; captured April 14, 2026 (06:00 - 06:30); stored locally in threat_detection/4x01_wire_shark_territory/.**
- **phishing_click.pcap: Captures exact phishing click event and credential form submission; stored locally.**
- **c2_beaconing.pcap: Captures 300-second interval beaconing traffic; stored locally.**
