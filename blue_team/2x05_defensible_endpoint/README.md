# Learning Objectives

## 1. Cross-Project Synthesis

### Q1. What is the main goal of Cross-Project Synthesis?

**Answer:** The main goal is to combine Linux hardening (2x00), Windows hardening (2x01), telemetry engineering (2x02), patch management (2x03), and perimeter defense (2x04) into **one integrated security workflow** for the same environment.

### Q2. Which security areas should be integrated in this project?

**Answer:**

* Linux hardening — 2x00
* Windows hardening — 2x01
* Telemetry engineering — 2x02
* Patch management — 2x03
* Perimeter defense — 2x04

### Q3. Why is it important to integrate these projects instead of treating them separately?

**Answer:** Real-world security requires multiple controls to work together. Hardening reduces vulnerabilities, telemetry detects suspicious activity, patch management fixes weaknesses, and perimeter defense controls network traffic.

### Q4. What does "single integrated workflow" mean?

**Answer:** It means taking one environment from its initial state, applying the required security controls, validating them, collecting evidence, and producing a final compliance report as **one continuous process**.

### Q5. What is a professional handoff package?

**Answer:** It is a complete set of scripts, reports, evidence, hashes, manifests, and operational instructions that allows another engineer to **verify and operate the solution without needing additional explanation**.

---

# 2. Defensible Engineering

## Baseline

### Q6. What is an unhardened baseline?

**Answer:** It is a structured record of the environment **before security changes are applied**. It shows the original configuration and security posture.

### Q7. Why do we capture a baseline before hardening?

**Answer:** So we can compare the **before and after states** and prove that the security controls were actually applied.

### Q8. What does "structured evidence" mean?

**Answer:** It means recording baseline information in an organized, machine-readable format such as **JSON or CSV**, instead of relying only on screenshots or written descriptions.

---

## Target State

### Q9. What is a target state?

**Answer:** The target state defines **how the environment should look after hardening**. It specifies the expected configuration for each security control.

### Q10. Why should the target state be defined in data rather than prose?

**Answer:** Data can be automatically checked and compared. This allows scripts to determine whether a control is **compliant or non-compliant** instead of relying on someone's interpretation.

### Q11. Give an example of a target state.

**Answer:** Instead of saying:

> "SSH should be secure."

The target state could specify:

```text
PermitRootLogin = false
```

The validation script can then directly check whether the actual value matches the expected value.

---

## End-to-End Pipeline

### Q12. What does it mean to compose hardening, instrumentation, and defense scripts into one pipeline?

**Answer:** It means connecting the different security scripts so they work together in a logical sequence.

For example:

```text
Baseline
   ↓
Hardening
   ↓
Telemetry
   ↓
Patch Management
   ↓
Perimeter Defense
   ↓
Validation
   ↓
Compliance Report
```

### Q13. What does "idempotent" mean?

**Answer:** An idempotent script can be run multiple times without causing unwanted changes or progressively breaking the system.

### Q14. Why is idempotency important in security automation?

**Answer:** Engineers may need to rerun scripts after failures, during maintenance, or during future deployments. The script should safely bring the system to the desired state every time.

### Q15. What does "auditable" mean for a security script?

**Answer:** It means the script provides enough information to determine **what it changed, what it checked, and whether the operation succeeded or failed**.

---

## Compliance Reporting

### Q16. What is a machine-readable compliance report?

**Answer:** It is a structured report, such as JSON, that records the compliance status of every security control.

### Q17. Why do we need a single compliance report?

**Answer:** It provides one authoritative view of the entire security posture instead of requiring an engineer to check multiple separate reports.

### Q18. What information can a compliance report contain?

**Answer:**

* Control ID
* Expected state
* Actual state
* Compliance status
* Validation result
* Evidence location
* Timestamp
* Error information, if applicable

### Q19. What does PASS/FAIL compliance mean?

**Answer:** Each control is evaluated against a defined requirement. If the actual state matches the expected state, it is **PASS**; otherwise, it is **FAIL**.

---

## Telemetry and Validation

### Q20. What does "telemetry evidence" mean?

**Answer:** It is evidence showing that the required logging, monitoring, and detection mechanisms are working correctly.

### Q21. Why must telemetry evidence be packaged in a specific format?

**Answer:** Because **Module 3 consumes that evidence**. Using the expected format allows the next module to automatically process and validate the telemetry.

### Q22. What is validation evidence?

**Answer:** Validation evidence proves that a security control actually works. For example, instead of simply claiming that a firewall rule exists, evidence could show that the expected traffic is allowed or blocked.

---

# 3. Professional Handoff

## Executable Runbook

### Q23. What is a runbook?

**Answer:** A runbook is a set of **executable instructions** that tells another engineer exactly how to deploy, validate, operate, or troubleshoot the security solution.

### Q24. What does it mean that the runbook should be "executable, not narrative"?

**Answer:** It means the runbook should primarily consist of **scripts and commands that can actually be executed**, rather than long explanations of what someone should theoretically do.

### Q25. Why is an executable runbook important?

**Answer:** It makes the handoff reproducible. Another engineer should be able to follow the steps and achieve the same result without needing additional briefing.

---

## Manifest and Integrity

### Q26. What is a manifest?

**Answer:** A manifest is a structured list of the files included in the handoff package, usually containing information such as **filename, size, and cryptographic hash**.

### Q27. Why do we include file hashes?

**Answer:** Hashes allow the receiver to verify that the files have **not been modified or corrupted** after the package was created.

### Q28. Which type of hash could be used for file integrity verification?

**Answer:** A cryptographic hash such as **SHA-256** can be used.

### Q29. How does a receiver verify a file using its hash?

**Answer:** The receiver calculates the hash of the received file and compares it with the hash recorded in the manifest. If they match, the file's contents are unchanged.

---

## Evaluation Criteria

### Q30. What does it mean for evaluation criteria to be binary and countable?

**Answer:** Each requirement should have a clear result such as **PASS or FAIL**, and the results should be measurable and countable.

### Q31. Why should evaluation criteria be binary?

**Answer:** To remove subjectivity. The quality of the handoff should be determined by **verifiable technical requirements**, not personal opinion.

### Q32. Give an example of a binary evaluation criterion.

**Answer:**

**Subjective:**

```text
"The firewall configuration looks secure."
```

**Binary:**

```text
"Required firewall rules exist and unauthorized inbound traffic is blocked — PASS/FAIL."
```

---

# Overall Project Objective

### Q33. What should you be able to demonstrate at the end of this project?

**Answer:** I should be able to take a raw environment, capture its baseline, define a measurable target state, apply Linux and Windows hardening, deploy telemetry, manage patches, configure perimeter defenses, validate every control, generate a machine-readable compliance report, and package everything into an **auditable, reproducible, and verifiable professional handoff**.

### Q34. What is the overall workflow of the project?

**Answer:**

```text
Raw Environment
       ↓
Capture Baseline
       ↓
Define Target State
       ↓
Apply Hardening & Defense
       ↓
Deploy Telemetry
       ↓
Patch Management
       ↓
Validate Controls
       ↓
Generate Compliance Report
       ↓
Package Evidence + Runbook + Manifest
       ↓
Professional Handoff
```

## Key Takeaway

The overall objective is to demonstrate that you can move an environment from:

```text
Insecure / Unknown State
          ↓
    Hardened State
          ↓
    Monitored State
          ↓
    Validated State
          ↓
Professional Handoff
```

In short:

> **Baseline → Define → Harden → Monitor → Patch → Defend → Validate → Report → Handoff**
