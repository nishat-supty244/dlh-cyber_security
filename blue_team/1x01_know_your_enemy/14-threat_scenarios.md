# Threat Scenarios

---

# Scenario 1: The Ransomware Siege

- **Threat Actor:** Ransomware Groups (BlackReef)
- **Motivation:** Financial Gain
- **Initial Vector:** VPN Exploit
- **Attack Surface:** External

## Attack Sequence

1. VPN exploit
2. Internal discovery
3. Domain Controller compromise
4. Backup destruction
5. Ransomware deployment

## STRIDE Categories

- Information Disclosure
- Denial of Service (DoS)
- Elevation of Privilege

## Impact

- Clinical shutdown
- Massive HIPAA fines

## Gaps Exploited

- **NET-01**
- **VULN-01**
- **DATA-02**

## Detection Opportunities

- Firewall logs
- Endpoint Detection and Response (EDR)
- Backup monitoring and alerts

---

# Scenario 2: Insider Data Exfiltration

- **Threat Actor:** Malicious Insider (Billing)
- **Motivation:** Financial Gain
- **Initial Vector:** Abuse of legitimate access
- **Attack Surface:** Human / Internal

## Attack Sequence

1. Access assessment
2. Bulk data export
3. USB transfer
4. Credential theft
5. Remote data scraping

## STRIDE Categories

- Information Disclosure
- Repudiation

## Impact

- Reputational damage
- Legal liability

## Gaps Exploited

- **SEC-04**
- **MON-01**
- **IAM-01**

## Detection Opportunities

- User Behavior Analytics (UBA)
- Data Loss Prevention (DLP)
- VPN logs

---

# Scenario 3: Supply Chain Compromise

- **Threat Actor:** Nation-State APT
- **Motivation:** Espionage
- **Initial Vector:** Vendor access pathway
- **Attack Surface:** External / Internal

## Attack Sequence

1. Vendor tunnel pivot
2. Network discovery
3. Administrative credential theft
4. Executive data access
5. Data exfiltration

## STRIDE Categories

- Elevation of Privilege
- Information Disclosure

## Impact

- Intellectual property theft
- Strategic disadvantage

## Gaps Exploited

- **VEND-01**
- **NET-01**
- **MON-01**

## Detection Opportunities

- Vendor session logs
- Credential misuse alerts
- Network traffic monitoring
