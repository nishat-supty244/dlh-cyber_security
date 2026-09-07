# Threat Actor Taxonomy Classification

---

## Report A

- **Actor Type:** Nation-state
- **Internal/External:** External
- **Resources:** High (Ability to weaponize zero-day vulnerabilities and maintain 14-month persistent operations)
- **Sophistication:** High (Utilized custom malware, encrypted DNS for C2, and stolen code-signing certificates)
- **Primary Motivation:** Espionage (Theft of proprietary pharmaceutical research and clinical trial data for economic gain)
- **Confidence Level:** High (The combination of zero-day use, long dwell time, and focus on high-value intellectual property is characteristic of state-sponsored actors)

---

## Report B

- **Actor Type:** Organized crime
- **Internal/External:** External
- **Resources:** Medium (Utilization of commercial RATs and established Ransomware-as-a-Service infrastructure)
- **Sophistication:** Medium (Multi-stage campaign from initial phishing to systematic exfiltration and double extortion)
- **Primary Motivation:** Financial gain (Blackmail and ransom demands for data recovery and silence)
- **Confidence Level:** High (The "double extortion" model is the standard business model for modern ransomware syndicates)

---

## Report C

- **Actor Type:** Hacktivist
- **Internal/External:** External
- **Resources:** Low (Utilized common SQL injection vulnerabilities rather than custom or advanced exploits)
- **Sophistication:** Low (Scope limited to public-facing website defacement for signaling purposes)
- **Primary Motivation:** Philosophical or political beliefs (Public protest regarding hospital policy changes)
- **Confidence Level:** High (The use of public defacement and activist messaging is specific to ideologically driven actors)

---

## Report D

- **Actor Type:** Insider threat
- **Internal/External:** Internal
- **Resources:** Low (Leveraged existing system access and administrative knowledge of the environment)
- **Sophistication:** Medium (Demonstrated pre-meditation by creating secondary accounts and disabling backups prior to termination)
- **Primary Motivation:** Revenge (Intentional sabotage of production data following a disciplinary action)
- **Confidence Level:** High (The timing relative to termination and the specific targeting of backups confirms an authorized internal actor)

---

## Report E

- **Actor Type:** Unskilled attacker
- **Internal/External:** External
- **Resources:** Low (Relies on publicly available automated exploit tools)
- **Sophistication:** Low (No lateral movement or persistence; utilized standard crypto-mining tools)
- **Primary Motivation:** Financial gain (Opportunistic harvesting of computing power)
- **Confidence Level:** High (The mass-scanning behavior and lack of targeting are characteristic of automated, low-skill actors)

---

## Report F

- **Actor Type:** Shadow IT
- **Internal/External:** Internal
- **Resources:** Low (Reliance on personal hardware and insecure default credentials)
- **Sophistication:** Low (Inadvertent exposure of an internal device through poor security configuration)
- **Primary Motivation:** Ethical motivations (The actor attempted to perform network monitoring for a personal project without malicious intent)
- **Confidence Level:** High (The introduction of unauthorized, unmanaged hardware by an employee for personal use defines Shadow IT)

---

## Report G

- **Actor Type:** Could be either (Organized crime or Insider threat)
- **Internal/External:** Could be either (External actor utilizing stolen/compromised credentials vs. an insider abusing authorized access)
- **Resources:** Medium (Requires sustained, covert access to specific patient databases)
- **Sophistication:** Medium (Methodical exfiltration over 6 weeks while avoiding detection)
- **Primary Motivation:** Financial gain (Selection of high-value insurance records suggests preparation for insurance fraud or dark web sale)
- **Confidence Level:** Medium (The ambiguity stems from the use of a legitimate physician account from a single, static IP address.)

### Note for Report G

This case could involve either an **Insider threat** using the physician's account while they are away or **Organized crime** using compromised credentials.

To distinguish between them, analysts should investigate the source IP address:

- If the IP maps to a local internal workstation or jump host, it indicates an **Insider threat**.
- If the IP resolves to a known VPN service, proxy node, or an external geographic location inconsistent with the physician's normal access patterns, it indicates **Organized crime**.

---

## Report H

- **Actor Type:** Organized crime
- **Internal/External:** External
- **Resources:** Medium (Ability to perform vulnerability research and successfully exfiltrate records)
- **Sophistication:** Medium (Professionalized extortion tactics using verified data samples)
- **Primary Motivation:** Blackmail (Extortion for the non-disclosure of vulnerability details and exfiltrated records)
- **Confidence Level:** High (The use of proof-of-concept samples for financial gain is a classic criminal extortion strategy)
