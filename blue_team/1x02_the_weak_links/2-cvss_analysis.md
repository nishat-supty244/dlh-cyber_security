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

## 1. Attack Vector (AV)

### Value

```
AV:N - Network
```

### Meaning

The vulnerability can be exploited remotely through a network connection, including:

- The internet
- Internal networks
- Other routable networks

No physical or local access is required.

### Other Values

| Value | Meaning | Impact |
|-------|---------|--------|
| A | Adjacent Network | Requires access to the same local network |
| L | Local | Requires access to the local system |
| P | Physical | Requires physical device access |

### Why AV:N Was Selected

The Apache HTTP Server processes incoming HTTP requests over the network without requiring authentication.

An attacker can send a malicious HTTP request directly to the vulnerable server.

### Score Impact

Changing:

```
AV:N → AV:L
```

would reduce the score because the attacker would first need local access to the system.

---

# 2. Attack Complexity (AC)

### Value

```
AC:L - Low
```

### Meaning

The exploit does not require:

- Special conditions
- Timing attacks
- Complex preparation
- Unusual configurations

The attack can be automated and reliably executed.

### Other Value

| Value | Meaning |
|-------|---------|
| H | High complexity |

High complexity reduces the score because exploitation becomes less reliable.

### Why AC:L Was Selected

The attacker only needs to send a specially crafted HTTP multipart request to trigger the buffer overflow in Apache `mod_lua`.

---

# 3. Privileges Required (PR)

### Value

```
PR:N - None
```

### Meaning

The attacker does not need:

- A user account
- Credentials
- Administrative privileges

### Other Values

| Value | Meaning |
|-------|---------|
| L | Low privileges required |
| H | High privileges required |

### Why PR:N Was Selected

The vulnerable HTTP endpoint accepts requests from anonymous users.

No authentication is required before exploitation.

---

# 4. User Interaction (UI)

### Value

```
UI:N - None
```

### Meaning

The attack does not require a user to:

- Click a link
- Open a document
- Approve an action

### Other Value

| Value | Meaning |
|-------|---------|
| R | Required |

### Why UI:N Was Selected

The attacker can directly send a malicious request to the Apache server without human involvement.

---

# 5. Scope (S)

### Value

```
S:U - Unchanged
```

### Meaning

The impact remains within the security authority of the vulnerable component.

The attack affects the Apache server process only.

### Other Value

| Value | Meaning |
|-------|---------|
| C | Changed |

Scope would become changed if exploitation affected another security boundary, such as:

- Container escape
- Hypervisor compromise
- Another application

### Why S:U Was Selected

The vulnerability operates within Apache's own process permissions.

---

# 6. Confidentiality, Integrity, Availability

## Values

```
C:H/I:H/A:H
```

---

## Confidentiality (C:H)

### Meaning

The attacker can access sensitive information.

Examples:

- Database records
- Configuration files
- User information

---

## Integrity (I:H)

### Meaning

The attacker can modify or destroy data.

Examples:

- Changing files
- Installing malware
- Altering configurations

---

## Availability (A:H)

### Meaning

The attacker can disrupt services.

Examples:

- Crashing Apache
- Stopping applications
- Causing denial of service

---

# Why C:H/I:H/A:H Were Selected

Remote Code Execution (RCE) allows an attacker to:

- Read sensitive data
- Modify system files
- Stop or compromise services

Therefore, all CIA impact metrics are rated as High.

---

# Score Change Analysis

## Change Attack Vector

Original:

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

Modified:

```
CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

---

## New Base Score

```
7.8 - High
```

---

## Reason for Score Reduction

Changing:

```
Attack Vector: Network → Local
```

removes remote exploitation capability.

The attacker must already have:

- Local system access
- Terminal access
- Code execution ability

This significantly reduces the attack surface and lowers the urgency.

---

# Exercise 2: CVSS Vector Construction

## Scenario Characteristics

| Scenario | CVSS Mapping |
|----------|--------------|
| Exploitable only from local network | AV:A |
| Exploitation requires specific conditions | AC:H |
| Attacker requires low privileges | PR:L |
| No user interaction required | UI:N |
| Only affects the targeted system | S:U |
| Complete confidentiality compromise | C:H |
| No integrity impact | I:N |
| No availability impact | A:N |

---

# Manual CVSS Vector String

```
CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N
```

---

# Result

| Metric | Value |
|--------|-------|
| Base Score | 5.3 |
| Severity | Medium |

---

# Explanation

The vulnerability has a moderate risk because:

### Reducing Factors

- Requires local network access
- Requires low-level privileges
- High attack complexity
- No integrity impact
- No availability impact

### Increasing Factor

- High confidentiality impact

The attacker can access sensitive information but cannot modify systems or disrupt services.

---

# Exercise 3: CVSS Comparison

## Vulnerability Comparison

| Finding | CVE | Score | Severity |
|---------|-----|-------|----------|
| Finding 001 | CVE-2021-44790 | 9.8 | Critical |
| Finding 029 | CVE-2021-43798 | 7.5 | High |

---

# Finding 1: CVE-2021-44790

## CVSS Vector

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

## Score

```
9.8 - Critical
```

---

# Finding 2: CVE-2021-43798

## CVSS Vector

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
```

## Score

```
7.5 - High
```

---

# Side-by-Side Metric Comparison

| Metric | Finding 001 | Finding 029 |
|--------|-------------|-------------|
| Attack Vector | Network (N) | Network (N) |
| Attack Complexity | Low (L) | Low (L) |
| Privileges Required | None (N) | None (N) |
| User Interaction | None (N) | None (N) |
| Scope | Unchanged (U) | Unchanged (U) |
| Confidentiality | High (H) | High (H) |
| Integrity | High (H) | None (N) |
| Availability | High (H) | None (N) |

---

# Key Score Difference Analysis

The main difference between the two vulnerabilities is the impact on:

- Integrity
- Availability

---

# CVE-2021-44790 Impact

This vulnerability enables:

- Remote Code Execution
- Complete system compromise

Therefore:

```
Integrity = High
Availability = High
```

An attacker can:

- Modify files
- Install malware
- Disable services

This results in:

```
CVSS Score: 9.8 Critical
```

---

# CVE-2021-43798 Impact

Grafana Path Traversal allows:

- Unauthorized file reading
- Sensitive information disclosure

However, it does not directly allow:

- File modification
- Service disruption

Therefore:

```
Integrity = None
Availability = None
```

Result:

```
CVSS Score: 7.5 High
```

---

# Final Conclusion

When comparing vulnerabilities with similar access conditions:

- Network exposure
- No authentication required
- No user interaction

the biggest score differences usually come from the **CIA impact metrics**.

A vulnerability that allows:

- Data access only → Lower score
- Data modification and service disruption → Much higher score

Therefore, **Integrity and Availability often have a major influence on final CVSS severity when attack accessibility is already high.**
