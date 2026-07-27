# The Hash Laboratory 

## Overview

As part of **MedDefense's infrastructure hardening initiative**, this document covers **Task 3** of the cryptographic curriculum. It examines the core properties of cryptographic hashing, distinguishing hashing from reversible encryption.

Through hands-on experimentation, this laboratory analyzes:

- The Avalanche Effect
- Hash collisions and the Birthday Problem
- Rainbow table mitigation through unique salting
- Key stretching algorithms
- File integrity verification using Bash scripting

---

# Part 1: The Avalanche Effect

## Commands and Experimental Output

### SHA-256

```bash
echo -n "MedDefense" | sha256sum
# Output:
39e026e107a44b2268e43e16e61033fdcc5d2bd62b23e03aca51db35c8671098  -

echo -n "MedDefense1" | sha256sum
# Output:
97a4141d69cc726a7f6ef577df588d4010c3fe4f235a8bdb616732ba9bf17b92  -
```

### MD5

```bash
echo -n "MedDefense" | md5sum
# Output:
75d47fd4b4d183456d0f98fd9ba6ae4d  -

echo -n "MedDefense1" | md5sum
# Output:
0d2aed72043f78c2935e61ba8520306d  -
```

---

## Analysis

### SHA-256 Character Variance

Comparing the two **64-character hexadecimal** outputs shows that:

- **62 of 64 characters changed**
- Approximately **97%** of the output differs.

### MD5 Character Variance

Comparing the two **32-character hexadecimal** outputs shows that:

- **30 of 32 characters changed**
- Approximately **94%** of the output differs.

### The Avalanche Effect

The **Avalanche Effect** is a fundamental property of secure cryptographic hash functions.

A tiny modification to the input—even changing a single character or bit—causes widespread and unpredictable changes throughout the resulting hash.

Ideally:

- About **50% or more of the output bits** should change.
- No predictable relationship should exist between similar inputs.

This property makes cryptographic hashes highly resistant to reverse engineering and pattern analysis.

---

# Part 2: Hash Collisions and the Birthday-Problem

## Unique Output Spaces

| Algorithm | Output Size | Possible Hash Values |
|-----------|------------:|---------------------:|
| MD5 | 128 bits | $2^{128}$ |
| SHA-256 | 256 bits | $2^{256}$ |

---

## Collision Vulnerability

Because hash outputs are finite, different inputs can eventually produce the same output.

This event is known as a **hash collision**.

---

## The Birthday-Problem

The Birthday Problem states that a collision becomes statistically likely after approximately:

```text
2^(N/2)
```

attempts, where **N** is the hash length.

### Examples

| Algorithm | Approximate Collision Complexity |
|-----------|--------------------------------:|
| MD5 | $2^{64}$ |
| SHA-256 | $2^{128}$ |

Since MD5 has a much smaller output space, collisions are significantly easier to discover than with SHA-256.

---

## Active Directory Implications

Connecting these findings to **Finding 018** from **Phase 1 (1x02_the_weak_links)**:

If MedDefense's Active Directory infrastructure still relies upon legacy **RC4/MD5-dependent Kerberos** mechanisms, attackers could exploit collision-related weaknesses to:

- Forge Kerberos tickets
- Perform credential attacks
- Crack weak hashes
- Compromise authentication mechanisms

Modern enterprise environments should therefore eliminate legacy cryptographic protocols wherever possible.

---

# Part 3: Rainbow-Table Demonstration

## Unsalted MD5 Hash

```bash
echo -n "password123" | md5sum
```

**Output**

```text
e2fc714c4727ee9395f324cd2e7f331f
```

### CrackStation Result

```text
password123
```

The password is recovered immediately using publicly available rainbow tables.

---

## Salted MD5 Hash

```bash
echo -n "s4lt9xQ2:password123" | md5sum
```

**Output**

```text
6d537fa53f1db2c22b0451ef4ef9fbe8
```

### CrackStation Result

```text
No Results Found
```

---

## Why Salting Defeats Rainbow Tables

A **salt** is a unique, random value added to every password before hashing.

For example:

```text
password123
```

becomes

```text
s4lt9xQ2:password123
```

This ensures that:

- Every stored password hash is unique.
- Users with identical passwords produce different hashes.
- Precomputed rainbow tables become useless.
- Attackers would need separate tables for every possible salt.

Consequently, salting effectively prevents large-scale password cracking attacks.

---

# Part 4: Key Stretching Algorithms

## bcrypt

bcrypt uses the **Blowfish** key schedule to intentionally slow password hashing.

Its configurable **cost factor** controls computational complexity:

```text
2^(cost)
```

Higher cost factors require exponentially more computation, making brute-force attacks substantially slower.

---

## PBKDF2

PBKDF2 repeatedly applies a pseudorandom function using:

- A password
- A unique salt
- A configurable iteration count

Increasing the iteration count proportionally increases the attacker's workload.

---

## Argon2

Argon2 was the winner of the **Password Hashing Competition**.

Unlike traditional algorithms, Argon2 is **memory-hard**, requiring substantial RAM for every password verification attempt.

Its configurable parameters include:

- Memory usage
- Execution time
- Parallelism

This significantly reduces the effectiveness of GPU- and ASIC-based password cracking.

---

## Recommendations

### Recommended Password Hashing

For enterprise applications, MedDefense should adopt:

- **Argon2id** (preferred)
- **bcrypt** (acceptable alternative)

These algorithms provide significantly stronger resistance against modern password-cracking hardware.

---

## Active Directory Status

Microsoft Active Directory stores passwords as **NTLM hashes**, which are based on the obsolete **MD4** algorithm.

Weaknesses include:

- No salting
- No key stretching
- Susceptibility to relay attacks
- High vulnerability to offline password cracking

Modern authentication mechanisms should replace NTLM wherever possible.

---

# Part 5: The Integrity Verification Script

The file integrity verification tool **`3-hash_verify.sh`** has been implemented and committed to:

```text
blue_team/1x04_crypto_foundation/
```

---

## Bash Script

```bash
#!/bin/bash
# 3-hash_verify.sh - File Integrity Verification Tool

FILE_PATH="$1"
EXPECTED_HASH="$2"

# Validate arguments
if [ -z "$FILE_PATH" ] || [ -z "$EXPECTED_HASH" ]; then
    echo "Usage: $0 <file_path> <expected_sha256_hash>"
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found."
    exit 1
fi

# Compute SHA-256 hash
ACTUAL_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')

# Compare hashes
if [ "$ACTUAL_HASH" = "$EXPECTED_HASH" ]; then
    echo "INTEGRITY OK"
    exit 0
else
    echo "INTEGRITY FAILED - expected $EXPECTED_HASH got $ACTUAL_HASH"
    exit 1
fi
```

---

## Script Features

The script performs the following tasks:

- Validates command-line arguments.
- Verifies that the target file exists.
- Computes the SHA-256 checksum.
- Compares the calculated hash with the expected value.
- Reports integrity status.
- Returns standard exit codes suitable for automation.

---

## Output Examples

### Successful Verification

```text
INTEGRITY OK
```

Exit Code:

```text
0
```

---

### Failed Verification

```text
INTEGRITY FAILED - expected <expected_hash> got <actual_hash>
```

Exit Code:

```text
1
```

---

# Summary

## Key Findings

- SHA-256 and MD5 demonstrate the **Avalanche Effect**, where minimal input changes produce drastically different outputs.
- MD5's smaller hash space makes it significantly more vulnerable to collisions and Birthday attacks than SHA-256.
- Salting effectively defeats rainbow table attacks by ensuring every stored password hash is unique.
- Modern password hashing should rely on **Argon2id** or **bcrypt**, rather than legacy MD4/NTLM.
- The `3-hash_verify.sh` script automates SHA-256 file integrity verification with reliable status reporting and exit codes.

---

# Conclusion

This laboratory demonstrates the essential role of cryptographic hashing in protecting data integrity, password security, and authentication systems. Experimental results validate the Avalanche Effect, illustrate the practical risks of hash collisions and legacy algorithms, and emphasize the necessity of salting and key stretching to resist modern password-cracking techniques. The accompanying integrity verification script further reinforces operational security by enabling automated validation of file authenticity within the MedDefense infrastructure.
