# MedDefense Threat Actor Matrix

| Dimension | Ransomware Groups | Nation-State APT | Insider (Malicious) | Insider (Negligent) | Hacktivist | Unskilled Attacker |
|---|---|---|---|---|---|---|
| **Likelihood** | **Critical:** High sector activity; MedDefense is a "Tier 1" target. | **Low:** No specific geopolitical interest in MedDefense. | **Medium:** Always a present internal risk in clinical environments. | **High:** Constant risk due to high stress and clinical workflows. | **Low:** Unlikely to target MedDefense without a specific grievance. | **High:** Constant automated scanning of public-facing infrastructure. |
| **Capability** | **High:** Professionalized RaaS operations, custom malware, and double-extortion techniques. | **Very High:** Advanced persistent operations and zero-day exploit capabilities. | **Medium:** Uses legitimate, authorized access and existing privileges. | **Low:** Lacks malicious intent; misuses existing access through mistakes or poor practices. | **Low:** Basic scripting, SQL injection, and website defacement techniques. | **Low:** Automated tools and basic vulnerability scanning. |
| **Primary Motivation** | Financial gain (Ransom demands and extortion). | Espionage (Data theft for long-term intelligence advantage). | Revenge, financial gain, or personal curiosity. | Convenience and workload management. | Protest and ideological objectives. | Financial gain through opportunistic resource exploitation. |
| **Preferred Vector** | Phishing, Initial Access Broker (IAB)-purchased access, and VPN exploitation. | Supply chain attacks and advanced persistent access techniques. | Abuse of legitimate credentials and authorized access rights. | Shadow IT, poor password hygiene, and insecure workflows. | Web application exploitation. | Automated scanning of public-facing VPNs and web applications. |
| **Primary Target** | EHR databases and backup infrastructure. | Proprietary research and executive communications. | Patient PHI/PII and financial records. | System configuration and network connectivity. | Public-facing websites. | Computational resources for activities such as crypto-mining. |
| **MedDefense Exposure** | Flat Network (**NET-01**), Lack of Backup Isolation (**DATA-02**). | Supply Chain Risk (**VEND-01**), Lack of Monitoring (**MON-01**). | Lack of User Behavior Analytics/Monitoring (**MON-01**). | Lack of Endpoint Control (**SEC-04**), Shadow IT (**ASSET-02**). | Unpatched Web Vulnerabilities (**VULN-01**). | Unpatched Public-Facing VPNs (**VULN-01**). |

---

# Top 3 Threat Priority Ranking

---

## 1. Ransomware Groups (Organized Crime)

**Priority Level: Highest**

Ransomware groups represent the greatest threat to MedDefense due to the combination of:

- High likelihood of healthcare targeting
- Severe operational impact
- Patient data exposure risks
- Financial and regulatory consequences

MedDefense’s weaknesses, including a **flat network architecture** and **lack of immutable backups**, create the exact conditions that ransomware operators are trained to exploit.

---

## 2. Insider (Negligent)

**Priority Level: High**

Negligent insiders represent a frequent and significant risk because they are a constant presence within healthcare environments.

Factors increasing this risk include:

- High-pressure clinical workflows
- Operational urgency overriding security practices
- Shadow IT usage
- Poor credential hygiene

These behaviors often create the initial access points that more advanced attackers later exploit.

---

## 3. Insider (Malicious)

**Priority Level: High**

Malicious insiders are prioritized third because the potential consequences of unauthorized internal activity are severe, including:

- Patient data breaches
- Regulatory violations
- Financial and reputational damage

Healthcare environments require employees to have broad access to patient systems, making malicious insider activity difficult to detect without strong behavioral monitoring capabilities.

The lack of **User Behavior Analytics (MON-01)** increases the risk by allowing abnormal access patterns and data misuse to remain undetected.
