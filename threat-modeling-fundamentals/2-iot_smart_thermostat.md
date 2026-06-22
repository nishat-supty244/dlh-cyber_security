# IoT Smart Thermostat — Threat Analysis

## 1. IoT-Specific Threats (Not typical in web apps)

### 1.1 Physical Debug Interface Abuse
**Description:** Attackers use exposed debug ports (UART/JTAG/SWD).  
**Attack Scenario:** Device is opened → attacker connects debugger → extracts firmware and secrets.  
**Impact:** Full device compromise, key extraction, persistent access.  
**Likelihood:** Medium  

**DREAD Score:**  
- Damage: 8  
- Reproducibility: 7  
- Exploitability: 7  
- Affected Users: 6  
- Discoverability: 8  
**Risk = (8+7+7+6+8)/5 = 7.2**

**Mitigation:**
- Disable debug interfaces in production
- Secure boot + hardware root of trust
- Tamper-resistant casing

---

### 1.2 Firmware Extraction via Flash Dumping
**Description:** Direct reading of firmware from flash memory.  
**Attack Scenario:** Attacker uses hardware programmer to dump firmware chip.  
**Impact:** Reverse engineering, credential leakage.  
**Likelihood:** Medium  

**DREAD Score:** 7.6  

**Mitigation:**
- Flash encryption
- Read-out protection
- Secure key storage (TPM/Secure Element)

---

### 1.3 Rogue OTA Firmware Injection
**Description:** Malicious firmware delivered via update channel.  
**Attack Scenario:** Compromised OTA server or MITM injects fake firmware.  
**Impact:** Persistent malware, HVAC manipulation, full takeover.  
**Likelihood:** Medium-High  

**DREAD Score:** 8.0  

**Mitigation:**
- Code signing verification
- Secure boot enforcement
- Certificate pinning

---

### 1.4 Sensor Spoofing
**Description:** Fake environmental input manipulation.  
**Attack Scenario:** Heating/cooling sensor is artificially heated/cooled.  
**Impact:** Wrong HVAC behavior, energy waste.  
**Likelihood:** Medium  

**Mitigation:**
- Sensor anomaly detection
- Multi-sensor validation

---

### 1.5 Wi-Fi / RF Disruption
**Description:** Wireless communication interference.  
**Attack Scenario:** Deauth attacks or RF jamming.  
**Impact:** Loss of control, device downtime.  
**Likelihood:** Medium  

**Mitigation:**
- WPA3 security
- Anti-deauth protection
- Channel hopping resilience

---

## 2. Physical Access Attack Chain

### Description
Physical access enables full device compromise.

### Attack Chain
```text
Physical access
→ Open device casing
→ Access debug ports / flash chip
→ Dump firmware
→ Extract credentials & keys
→ Modify firmware
→ Flash malicious image
→ Persistent control


Impact
Full system compromise
Privacy leakage (occupancy patterns)
HVAC manipulation (safety risk)
Lateral network movement
Likelihood

Medium

3. OTA Security Controls
3.1 Code Signing
Ensures only manufacturer-approved firmware runs
3.2 Secure Boot
Verifies firmware integrity at boot time
3.3 TLS Communication
Encrypts firmware transfer (TLS 1.2/1.3)
3.4 Rollback Protection
Prevents downgrade to vulnerable firmware versions
3.5 Secure Key Storage
Uses TPM / secure element for key protection
3.6 Atomic A/B Updates
Safe update switching between partitions
3.7 Integrity Validation
SHA-256 + signature verification
OTA Security Summary
Control	Purpose
Code Signing	Prevent unauthorized firmware
Secure Boot	Block tampered firmware at startup
TLS	Secure update transmission
Rollback Protection	Prevent downgrade attacks
Secure Storage	Protect cryptographic keys
A/B Updates	Prevent bricking
Integrity Check	Detect corruption
References
OWASP IoT Security Guidance
NISTIR 8259 IoT Security Baseline
ENISA IoT Security Recommendations
