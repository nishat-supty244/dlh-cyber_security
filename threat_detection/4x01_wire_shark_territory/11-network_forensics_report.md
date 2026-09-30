**Network Forensics Investigation Report**

**Executive Summary**

On April 14, 2026, a targeted phishing campaign compromised nurse workstation WS-NURSE-04 (10.10.2.15), leading to credential harvesting and subsequent internal network pivoting. Within hours, the threat actor established periodic command-and-control (C2) beaconing, leveraged stolen user credentials via VPN from an external IP address (154.118.42.89), and executed lateral movement across subnets via RDP and SMB. Active DNS TXT record tunneling resulted in data exfiltration over the network perimeter. Rapid forensic reconstruction protected core database servers, though immediate credential revocation and network micro-segmentation are required.

**Investigation Scope**

- **PCAP Files Analyzed:** normal_baseline_clinical.pcap, phishing_click.pcap, c2_beaconing.pcap, dns_exfil.pcap, lateral_movement.pcap, and full_timeline.pcap.
- **Time Period:** April 14, 2026 (06:00 UTC baseline through post-compromise activity windows).
- **Tools Used:** tshark, custom Bash automation scripts, and standard Unix text utilities.
- **Evidence Sources Not Used:** SIEM platform alerts, live memory dumps, host-based endpoint agent logs, and mail gateway logs (strictly packet-driven forensic analysis).

**Methodology**

- **Baseline Establishment:** Profiled normal clinical VLAN traffic distribution, service ports, talkers, and standard DNS query rates using normal_baseline_clinical.pcap.
- **Known-IOC Search:** Correlated packet fields against known malicious infrastructure identifiers (meddefense-portal.com and 91.234.99.107) from investigation 4x00.
- **DNS Analysis:** Tracked normal queries against anomalous TXT record abuse, high-entropy encoded subdomains, and response TTLs.
- **TLS Metadata Analysis:** Inspected SNI values, certificate issuers, cipher suites, and TLS versions during handshakes.
- **Timing Analysis:** Measured inter-arrival times, session durations, and periodicity for command-and-control beacon detection.
- **Behavioral Traffic Analysis:** Assessed connection durations, packet volumes, and unexpected cross-subnet traversal.
- **Cross-PCAP Correlation:** Synthesized findings across all captures to reconstruct a chronological attack path and validate the complete incident timeline.

**Findings by Attack Phase**

1. **Phishing Delivery:** Initial email lure received by nurse workstation; verified via context from 4x00 and initial DNS query in phishing_click.pcap. (Confidence: High / Confirmed via wire)
2. **Credential Harvest:** Workstation contacted meddefense-portal.com (91.234.99.107) at timestamp 15:02:33.142 during a 47-second HTTPS session with a 487-byte client payload matching form submission size. (PCAP: phishing_click.pcap; Confidence: Strong Inference)
3. **C2 Beaconing:** Regular HTTPS connections established every 300 seconds transferring minimal data to external infrastructure. (PCAP: c2_beaconing.pcap; Confidence: Confirmed)
4. **VPN Pivot:** External connection established from IP 154.118.42.89 using compromised credentials (dmarsh). (PCAP: full_timeline.pcap; Confidence: Strong Inference)
5. **RDP Lateral Movement:** Internal RDP session initiated from clinical host to billing server (billing-srv-01). (PCAP: lateral_movement.pcap; Confidence: Confirmed)
6. **SMB Discovery:** High volume of SMB tree connect and directory listing requests observed across internal subnets. (PCAP: lateral_movement.pcap; Confidence: Confirmed)
7. **DNS Exfiltration:** Repeated high-entropy TXT queries directed to data-sync.meddefense-portal.com. (PCAP: dns_exfil.pcap; Confidence: Confirmed)

**Network-Level IOC Table**

| **Type** | **Value**                       | **Source**  | **Confidence** | **Detection Utility**           |
| -------- | ------------------------------- | ----------- | -------------- | ------------------------------- |
| Domain   | meddefense-portal.com           | 4x00 / PCAP | High           | DNS sinkhole / Egress filtering |
| IP       | 91.234.99.107                   | PCAP        | High           | Firewall block list             |
| IP       | 154.118.42.89                   | PCAP        | Medium         | VPN geolocation/anomaly rule    |
| Domain   | data-sync.meddefense-portal.com | PCAP        | High           | DNS tunneling inspection        |

**Impact Assessment**

- **Data Likely Exfiltrated:** Encoded internal configuration details and billing metadata transmitted via DNS TXT query abuse.
- **Systems Involved:** WS-NURSE-04 (10.10.2.15), billing-srv-01 (10.10.2.31), and external attacker infrastructure.
- **Systems Protected / Not Reached:** Core electronic health record (EHR) database clusters and isolated administrative subnets remained fully protected.
- **Credential Exposure:** User account dmarsh compromised.
- **Regulatory / Business Concerns:** HIPAA compliance obligations triggered due to potential unauthorized access to clinical workstations and billing records.

**Detection Gap Analysis**

- **What Packet Evidence Revealed:** Exact session durations, timing regularity, DNS query structures, and cross-subnet traversal protocols.
- **What Could Have Detected Activity Earlier:** Automated beacon detection algorithms and real-time DNS entropy monitoring.
- **Behavioral Detection Gaps:** Lack of alerting on periodic, low-volume outbound HTTPS connections.
- **DNS Tunneling Detection Gap:** High volume of TXT queries bypassed standard security visibility.
- **VPN Anomaly Detection Gap:** Unusual external IP login patterns went unflagged.
- **Lateral Movement Detection Gap:** Internal RDP/SMB traversal between VLANs lacked strict micro-segmentation controls.

**Detection Rules Recommended**

- **Rule Name:** Periodic HTTPS Beacon Detection
- **Data Source Required:** Firewall/NetFlow flow logs or TLS metadata
- **Attack Phase Detected:** Command and Control
- **False Positive Considerations:** Standard cloud synchronization tools or scheduled API pollers.
- **Rule Name:** High-Entropy DNS TXT Query Alert
- **Data Source Required:** DNS server query logs
- **Attack Phase Detected:** Exfiltration
- **False Positive Considerations:** Legitimate software update checks or specialized service lookups.
- **Rule Name:** Cross-Subnet RDP/SMB Traversal Alert
- **Data Source Required:** Internal flow or firewall logs
- **Attack Phase Detected:** Lateral Movement
- **False Positive Considerations:** Authorized administrative management traffic.

**Recommendations**

**Immediate (Next 24 Hours)**

- Isolate involved clinical workstations and billing servers (WS-NURSE-04, billing-srv-01).
- Force immediate password resets and session terminations for user dmarsh.
- Block attacker infrastructure IPs (91.234.99.107, 154.118.42.89) at the perimeter firewall and DNS sinkhole.
- Preserve all packet captures and server volatile memory.

**Short-Term (Next 7 Days)**

- Deploy behavioral detection logic for periodic beaconing and DNS anomalies.
- Review and tighten VPN access controls, enforcing multi-factor authentication (MFA) and geo-location validation.
- Enhance DNS egress monitoring and visibility.
- Scan the network for additional affected hosts.

**Medium-Term (Next 30 Days)**

- Enforce robust email authentication policies (SPF, DKIM, DMARC).
- Improve internal network micro-segmentation, restricting unnecessary RDP/SMB traffic between clinical and administrative subnets.
- Conduct a comprehensive healthcare data exposure and risk review.

**Evidence Chain**

- normal_baseline_clinical.pcap: Establishes standard clinical traffic baseline; captured April 14, 2026 (06:00 - 06:30); stored locally in threat_detection/4x01_wire_shark_territory/.
- phishing_click.pcap: Captures exact phishing click event and credential form submission; stored locally.
- c2_beaconing.pcap: Captures 300-second interval beaconing traffic; stored locally.
- dns_exfil.pcap: Captures DNS TXT query abuse and tunneling volume; stored locally.
- lateral_movement.pcap: Traces cross-subnet RDP and SMB activity; stored locally.
- full_timeline.pcap: Correlates external access and complete attack progression; stored locally.

**Continuity with 4x00**

- Credential exposure upgraded from likely to strongly supported based on packet exchange metrics.
- Comprehensive network timeline fully documented from packet timestamps.
- Campaign infrastructure linked directly from initial phishing click to post-click beaconing and exfiltration.
- DNS exfiltration analysis significantly expands the incident impact assessment.
