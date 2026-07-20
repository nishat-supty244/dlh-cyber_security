# The CVSS Deconstruction

# Exercise 1: Deconstruction of CVE-2021-44790

## CVSS Vector String

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

**Base Score:** 9.8  
**Severity:** Critical

---

# Component Breakdown

## AV:N — Attack Vector: Network

### Meaning

The vulnerability can be exploited remotely through a network connection, including:

- The internet
- Internal networks
- Other routable networks

No physical or local access is required.

### Other Values and Impact

| Value | Meaning | Impact |
|-------|---------|--------|
| A | Adjacent Network | Requires access to the same local network |
| L | Local | Requires access to the local machine |
| P | Physical | Requires physical device access |

Changing the value from **Network (N)** to **Local (L)** lowers the score because the attacker must already have access to the system boundary.

### Why Selected

The Apache HTTP Server processes incoming HTTP request bodies over the public network without requiring authentication.

An attacker can send a malicious HTTP request directly to the server.

---

# AC:L — Attack Complexity: Low

### Meaning

Exploitation requires no specialized conditions.

An attacker can:

- Script the attack
- Reliably execute the exploit
- Repeat exploitation without special timing or environmental requirements

### Other Values and Impact

| Value | Meaning |
|-------|---------|
| H | High complexity |

Changing Attack Complexity from **Low (L)** to **High (H)** would reduce the score because exploitation would require more difficult conditions.

### Why Selected

Sending a crafted HTTP multipart request to trigger the Apache `mod_lua` buffer overflow is straightforward and repeatable.

---

# PR:N — Privileges Required: None

### Meaning

The attacker does not require:

- User credentials
- Existing accounts
- Administrative permissions

### Other Values and Impact

| Value | Meaning |
|-------|---------|
| L | Low privileges required |
| H | High privileges required |

Requiring privileges lowers the score because attackers must first obtain access.

### Why Selected

The vulnerable Apache HTTP endpoint accepts requests from anonymous, unauthenticated users.

---

# UI:N — User Interaction: None

### Meaning

The exploit works without requiring a user to:

- Click a link
- Open a file
- Approve an action

### Other Value

| Value | Meaning |
|-------|---------|
| R | User interaction required |

User interaction requirements reduce the likelihood of exploitation.

### Why Selected

A simple automated HTTP POST or GET request can trigger the vulnerability without human involvement.

---

# S:U — Scope: Unchanged

### Meaning

The impact remains within the security scope of the vulnerable component.

The exploitation affects the Apache web server process only.

### Other Value

| Value | Meaning |
|-------|---------|
| C | Changed |

Scope would become changed if exploitation crossed security boundaries, such as:

- Container escape
- Hypervisor compromise
- Impacting another application

### Why Selected

The vulnerability remains within the permissions and context of the Apache process.

---

# C:H / I:H / A:H — Impact Metrics

## Confidentiality: High (C:H)

### Meaning

The attacker can access sensitive information.

Examples:

- Application data
- Configuration files
- User information

---

## Integrity: High (I:H)

### Meaning

The attacker can modify or destroy data.

Examples:

- Changing files
- Installing malicious software
- Altering configurations

---

## Availability: High (A:H)

### Meaning

The attacker can disrupt services.

Examples:

- Crashing Apache
- Stopping applications
- Causing denial of service

---

## Why C:H/I:H/A:H Were Selected

Remote Code Execution (RCE) allows attackers to:

- Read sensitive information
- Modify system resources
- Disable or compromise services

Therefore, all three CIA impact categories receive the highest rating.

---

# Score Change Analysis

## Change: Attack Vector Network → Local

### Original Vector

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

### Modified Vector

```
CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

---

## New Base Score

```
8.4 - High
```

---

## Reason for Score Reduction

Changing:

```
Attack Vector: Network (N) → Local (L)
```

removes remote exploitation capability.

The attacker must already have:

- Local account access
- Terminal access
- Existing execution privileges

Although the vulnerability remains highly damaging because successful exploitation provides complete system control, the reduced accessibility lowers the overall severity from **Critical (9.8)** to **High (8.4)**.

---

# Exercise 2: CVSS Vector Construction

## Scenario Characteristics and Mapping

| Scenario Characteristic | CVSS Mapping |
|------------------------|--------------|
| Exploitable only from local network | AV:A (Adjacent Network) |
| Exploitation requires specific conditions | AC:H (High Complexity) |
| Attacker needs low-level privileges | PR:L (Low Privileges Required) |
| No user interaction required | UI:N (None) |
| Affects only targeted system | S:U (Unchanged) |
| Confidentiality completely compromised | C:H (High) |
| No integrity impact | I:N (None) |
| No availability impact | A:N (None) |

---

# Manual CVSS Vector String

```
CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N
```

---

# Result

| Category | Result |
|----------|--------|
| Base Score | 4.8 |
| Severity Rating | Medium |

---

# Explanation

This vulnerability receives a Medium rating because:

## Risk Increasing Factor

- Complete confidentiality compromise

## Risk Reducing Factors

- Requires adjacent network access
- Requires low-level privileges
- High attack complexity
- No integrity impact
- No availability impact

The attacker may access sensitive information but cannot modify systems or disrupt services.

---

# Exercise 3: CVSS Comparison

## Vulnerability Comparison

| Finding | CVE | CVSS Score | Severity |
|---------|-----|------------|----------|
| Finding 001 | CVE-2021-44790 | 9.8 | Critical |
| Finding 029 | CVE-2021-43798 | 7.5 | High |

---

# Finding 1: CVE-2021-44790

## Vector

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

## Base Score

```
9.8 - Critical
```

---

# Finding 2: CVE-2021-43798 (Grafana Path Traversal)

## Vector

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
```

## Base Score

```
7.5 - High
```

---

# Side-by-Side Component Comparison

| Metric | Finding 001 | Finding 029 |
|--------|-------------|-------------|
| Attack Vector (AV) | Network (N) | Network (N) |
| Attack Complexity (AC) | Low (L) | Low (L) |
| Privileges Required (PR) | None (N) | None (N) |
| User Interaction (UI) | None (N) | None (N) |
| Scope (S) | Unchanged (U) | Unchanged (U) |
| Confidentiality (C) | High (H) | High (H) |
| Integrity (I) | High (H) | None (N) |
| Availability (A) | High (H) | None (N) |

---

# Key Score Difference Analysis

The difference between the **9.8 Critical score** and the lower score comes mainly from differences in the CIA impact metrics:

- Confidentiality
- Integrity
- Availability

---

# Finding 001 Impact

CVE-2021-44790 enables:

- Remote Code Execution
- Complete system compromise

Impact:

```
Confidentiality = High
Integrity = High
Availability = High
```

An attacker can:

- Read sensitive information
- Modify system files
- Disable services

This results in:

```
CVSS Score: 9.8 Critical
```

---

# Finding 029 Impact

Grafana Path Traversal allows:

- Unauthorized file reading
- Sensitive information disclosure

However, it does not directly provide:

- Data modification
- System takeover
- Service disruption

Impact:

```
Confidentiality = High
Integrity = None
Availability = None
```

Result:

```
CVSS Score: 7.5 High
```

---

# Final Analysis

When comparing vulnerabilities with similar access characteristics:

- Network exposure
- Low attack complexity
- No authentication required
- No user interaction required

the biggest score differences come from the **CIA impact metrics**.

## Major CVSS Score Drivers

| Factor | Effect |
|--------|--------|
| Remote exploitation | Increases severity |
| No privileges required | Increases severity |
| No user interaction | Increases severity |
| High confidentiality impact | Increases severity |
| High integrity impact | Greatly increases severity |
| High availability impact | Greatly increases severity |

A vulnerability that only exposes information will have a lower score than one that enables complete system compromise.
