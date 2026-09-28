**Task 0: Intelligence Intake Summary — HEALTHBANE Campaign**

**1\. Individual Source Overview**

**Source 1: HHS HC3 Sector Threat Advisory**

- **Source Name:** HHS HC3 Sector Threat Advisory (HC3-2026-HEALTHBANE-001)
- **Source Type:** Government advisory
- **Date Published:** 2026-04-25
- **TLP Classification:** TLP:CLEAR (unrestricted distribution)
- **Number of Indicators Provided:** 23 indicators
- **Types of Indicators:** Domains (8), IPs (6), File hashes (5), URLs (4)
- **One-Line Summary:** HC3 tracks a multi-stage campaign (HEALTHBANE) targeting US healthcare organizations via spear-phishing, credential harvesting, macro-enabled malware delivery, and DNS tunneling exfiltration.
- **Key Limitations or Cautions:** Attribution is unconfirmed; commercial names are noted but not endorsed; observations are based on 6 partner organizations and sensor data.

**Source 2: Acme CTI Commercial Feed**

- **Source Name:** Acme CTI Commercial Feed Extract (ACME-HEALTH-2026-0426-117)
- **Source Type:** Commercial feed
- **Date Published:** 2026-04-26
- **TLP Classification:** TLP:AMBER (authorized for internal defense at MedDefense only)
- **Number of Indicators Provided:** 41 indicators
- **Types of Indicators:** Domains (12), IPs (15), File hashes (9), URLs (5)
- **One-Line Summary:** Automated CTI feed extract tracking related infrastructure under the proprietary label "VITALSCORE" with varying confidence ratings and clustering tags.
- **Key Limitations or Cautions:** Indicators are auto-tagged by a clustering engine with limited human review (SAMPLED); includes low-confidence, shared-hosting, and unrelated cluster noise that could trigger false positives if blocked blindly.

**Source 3: Researcher Blog Analysis**

- **Source Name:** Marcus Weller Research Blog ("The Phishing Kit Behind The HEALTHBANE Campaign")
- **Source Type:** Open-source research
- **Date Published:** 2026-04-24
- **TLP Classification:** N/A (Public blog post)
- **Number of Indicators Provided:** 14 indicators
- **Types of Indicators:** Domains (5), IPs (3), File hashes (4), URLs (2)
- **One-Line Summary:** Independent technical analysis examining the PHP credential harvester kit, tooling fingerprints (PHPMailer 6.6.0, wkhtmltopdf 0.12.6), and linking infrastructure to prior campaigns under the private label APT-MEDAGENT.
- **Key Limitations or Cautions:** Solo researcher with no visibility into victim telemetry; attribution is medium confidence based solely on tooling and infrastructure overlap.

**Source 4: MedDefense Internal Investigation**

- **Source Name:** MedDefense Internal Investigation Report (MD-2026-IR-0414-001 / 4x00 Findings)
- **Source Type:** Internal investigation
- **Date Published:** 2026-04-16
- **TLP Classification:** INTERNAL (not for external share)
- **Number of Indicators Provided:** 11 indicators
- **Types of Indicators:** Domains (3), IPs (3), File hashes (1), URLs (1), Email addresses (3)
- **One-Line Summary:** Internal post-incident analysis confirming a spear-phishing attack against three MedDefense employees, resulting in one probable credential submission (nurse Diane Marsh) without confirmed later-stage compromise.
- **Key Limitations or Cautions:** Limited to initial stage detection; packet capture analysis and endpoint forensics deferred to subsequent projects (4x01); attribution intentionally omitted.

**2\. Consolidated View & Metrics**

- **Total Raw Indicators Across All Sources:** 89
- **Total Unique Indicators After Deduplication:** 64

**Indicators Appearing in Multiple Sources**

The core confirmed indicators shared across official, commercial, and internal reporting include:

- **Domains:** meddefense-portal.com, medequip-supplies.net, meddefense-benefits.org, outlook-protection.com, healthbane-c2.net, data-sync.healthbane-c2.net, update-healthbane.net
- **IPs:** 91.234.99.107, 185.176.43.22, 164.90.218.73, 51.38.42.17, 51.38.42.191, 45.77.218.9
- **Hashes:**
  - a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
  - b9c8a7d6e5f4321098765432109876543210fedcba9876543210fedcba987654
  - c7d6e5f4a3b291827364554637281900a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6
  - 2f4a6c8e0b1d3f5a7c9e1b3d5f7a9c1e3b5d7f9a1c3e5b7d9f1a3c5e7b9d1f
  - dd5efb6d1ab4c67890abcdef1234567890abcdef1234567890abcdef12345678
- **URLs:** Standardized login and verification endpoints associated with the primary domains.

**Indicators Appearing in Only One Source**

- **Commercial Feed Only (Acme):** Historical/prior domains (rx-benefits-portal.com, healthcare-login.com), potential staged infrastructure (verify-health-portal.net, secure-insurance-login.com, claims-verify-portal.net), shared infrastructure / CDN / cloud IPs with high false-positive potential (159.89.112.45, 192.99.207.114, 20.83.144.56, 13.107.42.14, 172.67.192.40, 104.21.35.7), and several low-confidence or unrelated file hashes.
- **Researcher Blog Only:** Staging domain portal-secure-meddefense.com (Medium confidence) and kit ZIP hash ffaabbccdd0011223344556677889900aabbccddeeff00112233445566778899.
- **MedDefense Internal Report Only:** Internal sender email addresses (<noreply@meddefense-portal.com>, <invoices@medequip-supplies.net>, <hr-notifications@meddefense-benefits.org>).

**3\. Source Conflicts & Resolution Plan**

1. **Attribution Discrepancies:**
   - _Conflict:_ HC3 marks attribution as **UNCONFIRMED** (mid-tier cybercrime); Acme uses the proprietary commercial label **VITALSCORE**; Researcher Marcus Weller attributes activity to **APT-MEDAGENT** with **MEDIUM** confidence based on historical campaign tooling; MedDefense internal report avoids attribution.
   - _Resolution:_ Adopt HC3's official campaign designation (**HEALTHBANE**) for operational reporting. Acknowledge "VITALSCORE" and "APT-MEDAGENT" as commercial and researcher aliases respectively, without asserting high-confidence threat group attribution to executive leadership.
2. **Commercial Feed Noise & False Positive Risks:**
   - _Conflict:_ The Acme CTI feed introduces unverified machine-clustered indicators, shared hosting IPs (e.g., DigitalOcean, OVH CDN, Microsoft Azure), and unrelated malware hashes. Blindly operationalizing these would cause widespread business disruption.
   - _Resolution:_ Filter out indicators with low Acme confidence (<50) or those residing on shared cloud infrastructure (e.g., 13.107.42.14, 20.83.144.56). Restrict automated blocking to high-confidence confirmed indicators while placing medium-confidence items on monitoring/watchlist status.
3. **Inconsistent Indicator Presence:**
   - _Conflict:_ Early-stage domains (e.g., portal-secure-meddefense.com) appear in researcher findings before being active in victim telemetry or government advisories.
   - _Resolution:_ Treat researcher-identified staged domains as proactive intelligence. Add them to DNS monitoring and sinkhole lists before they are actively leveraged in phishing rotations.
