**Kill Chain Reconstruction: The HEALTHBANE Campaign**

**1\. Campaign Timeline**

The HEALTHBANE campaign unfolded across a coordinated operational window in April 2026. The progression spans initial reconnaissance, spear-phishing credential harvesting, subsequent lateral movement/malware delivery, and DNS-tunneling exfiltration:

- **2026-03-28 to 2026-04-12:** Early staging and prior/related infrastructure registration (observed via commercial feed historical domains like rx-benefits-portal.com and healthcare-login.com).
- **2026-04-05 to 2026-04-10:** Primary registration window for Stage 1 lookalike domains (e.g., meddefense-portal.com, medequip-supplies.net, meddefense-benefits.org) at Namecheap.
- **2026-04-14:** Earliest phishing email observed at an HC3 partner organization in the Midwest ISAC region. At MedDefense, nurse Diane Marsh receives and interacts with Email 2 at 15:02:33 UTC (probable credential submission at 15:02:58 UTC).
- **2026-04-14 through 2026-04-16:** Primary Stage 1 credential harvesting window across targeted organizations. MedDefense closes internal 4x00 investigation on 2026-04-16.
- **2026-04-16 through 2026-04-22:** Stage 2 malware delivery window. Attackers utilize stolen credentials to authenticate to cloud email accounts, sending .docm attachments to colleagues. Malware downloads (svchost_update.exe) occur from secondary C2 domains.
- **2026-04-18:** Independent researcher Marcus Weller obtains the phishing kit via a misconfigured server directory listing (/kit/static/).
- **2026-04-22:** Phishing kit infrastructure taken down / rotated by operators. Researcher notifies HC3.
- **2026-04-23 through 2026-04-26:** Stage 3 data exfiltration window. Patient and insurance records exfiltrated via base32-encoded DNS TXT-record queries to data-sync.healthbane-c2.net.
- **2026-04-25:** HHS HC3 publishes sector advisory HC3-2026-HEALTHBANE-001 (TLP:CLEAR).
- **2026-04-26:** Acme CTI commercial feed extract published (ACME-HEALTH-2026-0426-117).

**2\. Phase-by-Phase Analysis**

**Stage 1: Credential Harvesting**

- **Phishing Operation:** Spear-phishing emails impersonating healthcare-adjacent senders (staff portal, IT support, insurance, HR benefits). Emails utilized lookalike domains and PHPMailer 6.6.0.
- **Targeting Pattern:** US healthcare providers, with strongest signal in the Midwest ISAC region (hospital systems, outpatient clinics, medical billing services, and regional insurance administrators).
- **Infrastructure Used:** Namecheap registrar for domains (meddefense-portal.com, medequip-supplies.net, meddefense-benefits.org, outlook-protection.com), hosted on Hostinger, DigitalOcean, and OVH virtual private servers (IPs: 91.234.99.107, 185.176.43.22, 164.90.218.73, 51.38.42.17).
- **Known Victims:** At least 14 targeted organizations in the Midwest ISAC region; HC3 confirmed visibility across 6 organizations. MedDefense recorded 3 targeted employees, with 1 confirmed interaction/probable credential submission (dmarsh).
- **MedDefense Evidence:** SIEM connection logs showing a 47-second HTTPS session, lack of concurrent Sysmon file download events, and user attestation confirming password entry.
- **Success Rate:** Observed across 100% of HC3-visible organizations (6/6) for initial credential harvesting.

**Stage 2: Malware Delivery**

- **Transition to Follow-up:** Attackers leveraged credentials harvested in Stage 1 to authenticate directly into legitimate cloud email accounts, sending follow-up internal phishing emails to colleagues from compromised mailboxes.
- **Document Type:** Macro-enabled Word documents (.docm), specifically HEALTHBANE_S2_invoice.docm (SHA-256: a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456).
- **Artifacts & Tooling:** VBA macros executed PowerShell commands to pull a Windows executable (svchost_update.exe, SHA-256: b9c8a7d6e5f4321098765432109876543210fedcba9876543210fedcba987654) and a PowerShell exfiltrator (sync_healthdata.ps1).
- **Download Infrastructure:** Secondary C2 domains (healthbane-c2.net, update-healthbane.net) hosted on OVH (IP: 51.38.42.191) and DigitalOcean/Vultr.
- **Persistence Mechanisms:** Established via a scheduled task named _"HealthSync Update Service"_ and Windows Registry Run keys.
- **Evidence Source:** Sandbox analysis, EDR telemetry, and packet captures from the 2 compromised organizations analyzed by HC3. (Note: Stage 2 did _not_ reach execution at MedDefense).

**Stage 3: Data Exfiltration**

- **Data Targeted:** Patient medical records and insurance claims data.
- **Protocol & Tool used:** Custom RAT deployed in Stage 2 encoded sensitive data into base32 subdomains within DNS TXT-record queries. Queries fired at 10–15 second intervals with label lengths ranging from 44 to 60 characters. Command responses from C2 utilized base64-encoded strings inside DNS TXT records.
- **Exfiltration Infrastructure:** data-sync.healthbane-c2.net resolving via OVH-hosted C2 nodes (51.38.42.191).
- **Evidence Source:** Full packet captures (PCAPs) and DNS query logs from the two deeply compromised HC3 partner organizations.
- **Confirmed vs. Unclear:** Confirmed via DNS telemetry and PCAPs at two victim sites; unclear whether broader patient records were successfully parsed or staged prior to DNS tunneling across other organizations.

**3\. Evidence Quality Assessment**

- **Confirmed Evidence:**
  - Stage 1 email headers, X-Mailer strings (PHPMailer 6.6.0), and domain registration timelines.
  - MedDefense internal phishing emails (E2, E5, E7) and user click logs for dmarsh.
  - Exact file hashes for Stage 2 macro docs (.docm), payloads (.exe), and PowerShell scripts (.ps1).
  - DNS query patterns, subdomain label lengths, and timing intervals for Stage 3 exfiltration.
- **Corroborated Evidence:**
  - Phishing kit directory structure and central configuration (config.php), independently recovered by researcher Marcus Weller and corroborated by HC3 advisory findings.
  - Infrastructure hosting providers (Namecheap, Hostinger, OVH, DigitalOcean) reported across multiple feeds.
- **Inferred Evidence:**
  - Staged domains (e.g., portal-secure-meddefense.com) expected to be rotated in once active domains are burned.
  - Attacker use of automated per-target templating scripts based on layout consistency across victim brands.
- **Unknowns:**
  - Exact volume of patient data successfully exfiltrated during Stage 3 at the two impacted external organizations.
  - Whether credentials harvested from MedDefense were actively tested or logged in external authentication portals prior to account lockout.

**4\. Intelligence Gaps & Recommendations**

- **Attribution Gaps:** Sources disagree significantly (HEALTHBANE via HC3, VITALSCORE via commercial feed, APT-MEDAGENT via independent researcher). There is insufficient signals intelligence or victim-side telemetry to definitively link the campaign to a known named threat group.
- **Missing Victim Telemetry:** Complete visibility is restricted to 6 HC3-visible organizations out of at least 14 targeted entities in the Midwest ISAC region. Telemetry from the remaining 8 organizations remains unshared.
- **Commercial-Feed Uncertainty:** Broad machine-clustering introduced noise (unrelated file hashes and shared CDN IP ranges), creating false-positive risks that required manual filtering.
- **Recommended Collection to Fill Gaps:**
  1. Expand sector-wide sharing agreements to capture telemetry from unrepresented healthcare providers targeted in the Midwest ISAC region.
  2. Perform deep artifact collection on seized phishing kit source code to identify unique developer watermarks or reuse patterns.
  3. Monitor passive DNS and certificate transparency logs proactively for newly registered compound healthcare keywords (med\*-\*, health\*-\*) to catch rotated infrastructure before active deployment.
