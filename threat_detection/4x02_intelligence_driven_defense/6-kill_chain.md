````markdown
# 6-Kill Chain Reconstruction: The HEALTHBANE Campaign

## 1. Campaign Timeline

The HEALTHBANE campaign unfolded across a coordinated operational window in April 2026. The progression spans initial reconnaissance, spear-phishing credential harvesting, subsequent lateral movement/malware delivery, and DNS-tunneling exfiltration.

- **2026-03-28 to 2026-04-12:** Early staging and prior/related infrastructure registration, observed via commercial feed historical domains such as `rx-benefits-portal.com` and `healthcare-login.com`.

- **2026-04-05 to 2026-04-10:** Primary registration window for Stage 1 lookalike domains, including:
  - `meddefense-portal.com`
  - `medequip-supplies.net`
  - `meddefense-benefits.org`

  These domains were registered through Namecheap.

- **2026-04-14:** Earliest phishing email observed at an HC3 partner organization in the Midwest ISAC region. At MedDefense, nurse Diane Marsh received and interacted with Email 2 at `15:02:33 UTC`. Probable credential submission occurred at `15:02:58 UTC`.

- **2026-04-14 through 2026-04-16:** Primary Stage 1 credential-harvesting window across targeted organizations. MedDefense closed its internal 4x00 investigation on `2026-04-16`.

- **2026-04-16 through 2026-04-22:** Stage 2 malware-delivery window. Attackers used stolen credentials to authenticate to cloud email accounts and send `.docm` attachments to colleagues. Malware downloads, including `svchost_update.exe`, occurred from secondary C2 domains.

- **2026-04-18:** Independent researcher Marcus Weller obtained the phishing kit through a misconfigured server directory listing at `/kit/static/`.

- **2026-04-22:** Phishing-kit infrastructure was taken down or rotated by the operators. The researcher notified HC3.

- **2026-04-23 through 2026-04-26:** Stage 3 data-exfiltration window. Patient and insurance records were exfiltrated through Base32-encoded DNS TXT-record queries to `data-sync.healthbane-c2.net`.

- **2026-04-25:** HHS HC3 published sector advisory `HC3-2026-HEALTHBANE-001` with TLP:CLEAR marking.

- **2026-04-26:** Acme CTI commercial feed extract was published as `ACME-HEALTH-2026-0426-117`.

---

## 2. Phase-by-Phase Analysis

### Stage 1: Credential Harvesting

#### Phishing Operation

- Spear-phishing emails impersonated healthcare-adjacent senders, including:
  - Staff portals
  - IT support
  - Insurance
  - HR benefits
- Emails used lookalike domains.
- The phishing infrastructure used **PHPMailer 6.6.0**.

#### Targeting Pattern

The primary targets were US healthcare providers, with the strongest signal observed in the Midwest ISAC region.

Targeted organizations included:

- Hospital systems
- Outpatient clinics
- Medical billing services
- Regional insurance administrators

#### Infrastructure Used

The campaign used **Namecheap** for domain registration and infrastructure hosted across:

- Hostinger
- DigitalOcean
- OVH virtual private servers

Known infrastructure included:

- `meddefense-portal.com`
- `medequip-supplies.net`
- `meddefense-benefits.org`
- `outlook-protection.com`

Known IP addresses included:

- `91.234.99.107`
- `185.176.43.22`
- `164.90.218.73`
- `51.38.42.17`

#### Known Victims

- At least **14 targeted organizations** were identified in the Midwest ISAC region.
- HC3 confirmed visibility across **6 organizations**.
- MedDefense recorded **3 targeted employees**.
- **1 employee** had confirmed interaction and probable credential submission:
  - `dmarsh`

#### MedDefense Evidence

MedDefense evidence included:

- SIEM connection logs showing a **47-second HTTPS session**.
- No concurrent Sysmon file-download events.
- User attestation confirming password entry.

#### Success Rate

The activity was observed across **100% of HC3-visible organizations (6/6)** for the initial credential-harvesting stage.

---

### Stage 2: Malware Delivery

#### Transition to Follow-up

Attackers leveraged credentials harvested during Stage 1 to authenticate directly into legitimate cloud email accounts.

They then sent follow-up phishing emails to colleagues from compromised mailboxes.

#### Document Type

The malware-delivery stage used macro-enabled Microsoft Word documents (`.docm`).

Example:

- `HEALTHBANE_S2_invoice.docm`

SHA-256:

```text
a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
````

#### Artifacts and Tooling

VBA macros executed PowerShell commands to download:

* `svchost_update.exe`
* `sync_healthdata.ps1`

SHA-256 for `svchost_update.exe`:

```text
b9c8a7d6e5f4321098765432109876543210fedcba9876543210fedcba987654
```

#### Download Infrastructure

Secondary C2 domains included:

* `healthbane-c2.net`
* `update-healthbane.net`

The infrastructure was hosted across:

* OVH
* DigitalOcean
* Vultr

Known OVH IP:

* `51.38.42.191`

#### Persistence Mechanisms

The attackers established persistence using:

* Scheduled task: `HealthSync Update Service`
* Windows Registry Run keys

#### Evidence Source

Evidence came from:

* Sandbox analysis
* EDR telemetry
* Packet captures from two compromised organizations analyzed by HC3

> **Important:** Stage 2 did **not** reach execution at MedDefense.

---

### Stage 3: Data Exfiltration

#### Data Targeted

The attackers targeted:

* Patient medical records
* Insurance claims data

#### Protocol and Tool Used

A custom RAT deployed during Stage 2 encoded sensitive data into **Base32 subdomains** within DNS TXT-record queries.

Observed behavior included:

* DNS queries every **10–15 seconds**
* Subdomain label lengths between **44 and 60 characters**
* Command responses from the C2 using Base64-encoded strings inside DNS TXT records

#### Exfiltration Infrastructure

The primary exfiltration domain was:

`data-sync.healthbane-c2.net`

The domain resolved through OVH-hosted C2 infrastructure, including:

* `51.38.42.191`

#### Evidence Source

Evidence came from:

* Full packet captures (PCAPs)
* DNS query logs
* Two deeply compromised HC3 partner organizations

#### Confirmed vs. Unclear

**Confirmed:**

* DNS telemetry showed the tunneling behavior.
* PCAPs confirmed DNS-based exfiltration at two victim sites.

**Unclear:**

* Whether larger volumes of patient records were successfully parsed.
* Whether additional data was staged before DNS tunneling at other organizations.

---

## 3. Evidence Quality Assessment

### Confirmed Evidence

The following evidence is directly observed or strongly supported:

* Stage 1 email headers.
* `X-Mailer` strings showing **PHPMailer 6.6.0**.
* Domain registration timelines.
* MedDefense internal phishing emails:

  * E2
  * E5
  * E7
* User click logs for `dmarsh`.
* Exact file hashes for:

  * Stage 2 macro-enabled documents (`.docm`)
  * Payloads (`.exe`)
  * PowerShell scripts (`.ps1`)
* DNS query patterns.
* DNS subdomain label lengths.
* DNS query timing intervals for Stage 3 exfiltration.

### Corroborated Evidence

The following findings were supported by multiple sources:

* Phishing-kit directory structure.
* Central configuration file: `config.php`.
* Phishing kit independently recovered by researcher Marcus Weller.
* Findings corroborated by HC3 advisory information.
* Infrastructure providers reported across multiple sources:

  * Namecheap
  * Hostinger
  * OVH
  * DigitalOcean

### Inferred Evidence

Some findings remain analytical or inferred:

* Staged domains such as `portal-secure-meddefense.com` may have been intended to replace active domains after infrastructure exposure.
* The attackers may have used automated per-target templating scripts based on consistent layouts across victim brands.

### Unknowns

The following questions remain unresolved:

* Exact volume of patient data successfully exfiltrated during Stage 3 at the two impacted external organizations.
* Whether credentials harvested from MedDefense were actively tested.
* Whether harvested MedDefense credentials were logged into external authentication portals before account lockout.

---

## 4. Intelligence Gaps and Recommendations

### Attribution Gaps

Sources disagree on the identity or naming of the threat actor/campaign:

* **HC3:** HEALTHBANE
* **Commercial Feed:** VITALSCORE
* **Independent Researcher:** APT-MEDAGENT
* **MedDefense 4x00:** Avoids external attribution

There is currently insufficient signals intelligence and victim-side telemetry to definitively link the campaign to a known named threat group.

### Missing Victim Telemetry

Complete visibility is limited.

* At least **14 organizations** were targeted in the Midwest ISAC region.
* HC3 has visibility into **6 organizations**.
* Telemetry from the remaining **8 organizations** has not been shared.

This limits the ability to reconstruct the full campaign.

### Commercial-Feed Uncertainty

Broad machine-based clustering introduced additional noise, including:

* Unrelated file hashes
* Shared CDN IP ranges
* Weak infrastructure associations

These findings created false-positive risks and required manual filtering.

### Recommended Collection to Fill Gaps

1. **Expand sector-wide information sharing**

   * Establish or expand sharing agreements to obtain telemetry from healthcare providers targeted in the Midwest ISAC region.

2. **Perform deeper phishing-kit analysis**

   * Collect and analyze the seized phishing-kit source code.
   * Look for unique developer watermarks, coding patterns, or reuse patterns.

3. **Monitor passive DNS and Certificate Transparency**

   * Proactively monitor newly registered domains using healthcare-related naming patterns such as:

     * `med*-*`
     * `health*-*`
   * Use this monitoring to identify rotated infrastructure before it becomes actively deployed.

---

## 5. Overall Kill Chain Summary

The reconstructed campaign follows a multi-stage attack chain:

```text
Reconnaissance / Infrastructure Staging
                ↓
        Spear-Phishing
                ↓
      Credential Harvesting
                ↓
       Account Compromise
                ↓
     Internal Follow-up Phishing
                ↓
        Macro Document
                ↓
       PowerShell Execution
                ↓
        Malware Delivery
                ↓
          Persistence
                ↓
       Data Collection
                ↓
       DNS Tunneling
                ↓
        Data Exfiltration
```

The available evidence supports the reconstruction of the major campaign stages, while attribution and the complete scope of victim impact remain uncertain.

```

This is now **raw Markdown**, including the `#`, `##`, `###`, bullet points, tables, backticks, and code block syntax.
```
