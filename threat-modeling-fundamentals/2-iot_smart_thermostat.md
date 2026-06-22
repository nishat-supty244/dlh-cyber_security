# IoT Smart Thermostat — Threat Analysis

---

## System Overview

A smart thermostat is an IoT device that:
- Connects to home Wi-Fi
- Controls HVAC systems (heating/cooling)
- Collects temperature and occupancy data
- Communicates with mobile app + cloud
- Receives OTA firmware updates

---

## 1. IoT-Specific Threats

---

### 1.1 Physical Tampering

**Description:**  
Attacker physically accesses and manipulates internal hardware.

**Attack Scenario:**  
Device is removed → casing opened → debug ports accessed → firmware extracted or modified.

**Impact:**
- Full device compromise  
- Key extraction  
- Persistent backdoor installation  

**Likelihood:** Medium  

**DREAD Score:**
- Damage: 8  
- Reproducibility: 7  
- Exploitability: 7  
- Affected Users: 6  
- Discoverability: 8  

**Risk = 7.2**

**Mitigation:**
- Disable debug interfaces (UART/JTAG)
- Secure boot enforcement
- Tamper-resistant casing

---

### 1.2 Firmware Extraction

**Description:**  
Attacker extracts firmware from flash memory.

**Attack Scenario:**  
Hardware programmer reads flash chip → firmware dumped → analyzed offline.

**Impact:**
- Reverse engineering  
- Credential/key leakage  
- Vulnerability discovery  

**Likelihood:** Medium  

**Risk = 7.6**

**Mitigation:**
- Flash encryption
- Read-out protection
- Secure element for key storage

---

### 1.3 Rogue OTA Firmware Injection

**Description:**  
Malicious firmware injected via update system.

**Attack Scenario:**  
OTA server compromise or MITM attack → fake firmware delivered to device.

**Impact:**
- Persistent malware  
- HVAC manipulation  
- Full remote takeover  

**Likelihood:** Medium-High  

**Risk = 8.0**

**Mitigation:**
- Code signing
- Secure boot
- TLS encryption
- Certificate pinning

---

### 1.4 Sensor Spoofing

**Description:**  
Manipulation of temperature or environmental sensors.

**Attack Scenario:**  
Attacker artificially heats/cools sensor → device misreads environment.

**Impact:**
- Incorrect HVAC control  
- Energy waste  
- Potential safety risks  

**Likelihood:** Medium  

**Mitigation:**
- Sensor validation logic
- Multi-sensor correlation checks

---

### 1.5 Wi-Fi / RF Attacks

**Description:**  
Wireless disruption or interception attacks.

**Attack Scenario:**  
Wi-Fi deauth attack or RF jamming blocks communication.

**Impact:**
- Loss of control  
- Device downtime  

**Likelihood:** Medium  

**Mitigation:**
- WPA3 encryption
- Anti-deauthentication protections

---

## 2. Physical Access Attack Chain

---

### Description

Physical access allows complete compromise of the device.

---

### Attack Chain

```text
Physical access
→ Open casing
→ Access debug ports / flash chip
→ Dump firmware
→ Extract keys & credentials
→ Modify firmware
→ Reflash device
→ Persistent control

---


## 2. Design security controls for the OTA (Over-The-Air)

---

## 1. Code Signing
- All firmware must be digitally signed by the manufacturer  
- Device verifies signature before installation  
- Prevents malicious or unauthorized firmware  

---

## 2. Secure Boot
- Device only runs verified firmware  
- Ensures trusted boot process from hardware root of trust  
- Prevents persistent malware  

---

## 3. Encrypted Communication (TLS)
- OTA updates must use TLS 1.2+ or TLS 1.3  
- Prevents interception and tampering during transfer  

---

## 4. Integrity Verification
- Use SHA-256 hash validation  
- Ensures firmware is not modified or corrupted  

---

## 5. Anti-Rollback Protection
- Blocks installation of older firmware versions  
- Prevents downgrade attacks  

---

## 6. Secure Update Server
- Use mutual TLS (mTLS) authentication  
- Only trusted servers can distribute updates  

---

## 7. Fail-Safe Updates
- Dual firmware partitions (A/B system)  
- Automatic rollback if update fails  

---

## Summary
OTA security must ensure:
- Authenticity (signed firmware)  
- Integrity (hash verification)  
- Confidentiality (TLS encryption)  
- Availability (rollback support)  
