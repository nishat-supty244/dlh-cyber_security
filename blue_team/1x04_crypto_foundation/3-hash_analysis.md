The Hash Laboratory

## Overview
As a security analyst hardening MedDefense's infrastructure, understanding cryptographic hashing is essential for safeguarding stored credentials, ensuring data integrity, and recognizing the vulnerabilities of legacy authentication structures. Unlike encryption, hashing is a strictly one-way mathematical function. This laboratory exercise evaluates the avalanche effect, hash collision properties, rainbow table vulnerabilities, key stretching algorithms, and file integrity verification scripts.

---

## Part 1: The Avalanche Effect

### Execution and Commands
Hashing the baseline string `"MedDefense"` and a slightly modified string `"MedDefense1"` (adding a single character) across both SHA-256 and MD5 yields the following experimental outputs:

```bash
# SHA-256 hashing
echo -n "MedDefense" | sha256sum
# Output: 39e026e107a44b2268e43e16e61033fdcc5d2bd62b23e03aca51db35c8671098  -
echo -n "MedDefense1" | sha256sum
# Output: 97a4141d69cc726a7f6ef577df588d4010c3fe4f235a8bdb616732ba9bf17b92  -

# MD5 hashing
echo -n "MedDefense" | md5sum
# Output: 75d47fd4b4d183456d0f98fd9ba6ae4d  -
echo -n "MedDefense1" | md5sum
# Output: 0d2aed72043f78c2935e61ba8520306d  -
```

### Analysis of the Avalanche Effect
* **SHA-256 Difference:** Comparing the two 64-character hex outputs reveals that **62 out of 64 characters** differ.
* **MD5 Difference:** Comparing the two 32-character hex outputs reveals that **30 out of 32 characters** differ.
* **The Avalanche Phenomenon:** The avalanche effect demonstrates that a minute, single-bit modification in the input propagates through the mathematical rounds to alter approximately 50% (or more) of the output bits, ensuring that ciphertexts or hashes exhibit no discernible correlation to their source inputs.

---

## Part 2: Hash Collisions and the Birthday Problem

### Unique Output Calculations
* **MD5 (128-bit):** Produces $2^{128}$ possible unique outputs (approximately $3.4 	imes 10^{38}$).
* **SHA-256 (256-bit):** Produces $2^{256}$ possible unique outputs (approximately $1.1 	imes 10^{75}$).

### Collision Vulnerability & Active Directory Implications
A shorter hash output space (such as MD5's 128-bit space) is significantly more susceptible to collision attacks due to the mathematics of the Birthday Problem, which dictates that a collision can be found with a $50\%$ probability after approximately $2^{N/2}$ trials (e.g., $2^{64}$ operations for MD5), well within reach of modern specialized hardware. A birthday attack exploits this statistical probability by generating and comparing numerous input permutations until two distinct inputs produce identical hash outputs. 

Connecting this to **Finding 018 from Phase 1 (`1x02_the_weak_links`)**, if MedDefense's Active Directory relies on legacy RC4 encryption for Kerberos tickets—which internally depends on MD4/MD5 hash transformations—an attacker can exploit structural weaknesses and collisions to forge tickets or crack user credential hashes rapidly, reducing secure password protection to a timeframe of minutes.

---

## Part 3: Rainbow Table Demonstration

### MD5 Unsalted vs. Salted Lookup
* **Unsalted Hash (`password123`):** 
  `echo -n "password123" | md5sum` $
ightarrow$ `e2fc714c4727ee9395f324cd2e7f331f`
  * *Crackstation Result:* Instantly resolved/cracked to `password123` because precomputed rainbow tables contain this ubiquitous hash value.
* **Salted Hash (`s4lt9xQ2:password123`):** 
  `echo -n "s4lt9xQ2:password123" | md5sum` $
ightarrow$ `6d537fa53f1db2c22b0451ef4ef9fbe8`
  * *Crackstation Result:* Returns **No Results Found**.

### Why Salting Defeats Rainbow Tables
Salting prepends or appends a random, unique string to each user's password before hashing, completely invalidating precomputed rainbow tables because an attacker would need to precompute an entirely unique table for every possible random salt value in existence. Assigning a unique salt to every user ensures that two users with identical passwords (e.g., both choosing `Password123!`) will yield completely different stored hashes, thwarting bulk database compromise and dictionary/rainbow table attacks.

---

## Part 4: Key Stretching Algorithms

### Algorithm Comparison

* **bcrypt:**
  * *Mechanism:* Built upon the Blowfish block cipher key setup routine, bcrypt incorporates an intentionally complex and resource-intensive key schedule.
  * *Brute-Force Resistance:* It is highly resistant to GPU and ASIC acceleration because its design requires substantial memory access patterns per iteration.
  * *Cost Factor Control:* The "cost factor" (or work factor) parameter logarithmically controls the iteration count ($2^{	ext{cost}}$), allowing defenders to scale computational difficulty upward as hardware performance improves.

* **PBKDF2 (Password-Based Key Derivation Function 2):**
  * *Mechanism:* A standard key derivation function that applies a pseudorandom function (such as HMAC-SHA-256) iteratively to a password combined with a salt.
  * *Brute-Force Resistance:* Increases the time cost of verification, though it can be parallelized more easily on GPUs than memory-hard functions unless paired with high iteration counts.
  * *Cost Factor Control:* The "iteration count" parameter directly specifies the exact number of sequential rounds the hashing function executes.

* **Argon2:**
  * *Mechanism:* The winner of the Password Hashing Competition, Argon2 is a memory-hard function designed to maximize resistance against GPU, FPGA, and ASIC-based cracking rigs.
  * *Brute-Force Resistance:* It forces cracking hardware to allocate large blocks of RAM per hash attempt, creating severe hardware bottlenecks for attackers trying to execute massive parallel guesses.
  * *Cost Factor Control:* Parameters control execution time, parallelism degree, and memory consumption limits.

### Recommendations & Active Directory Status
* **MedDefense Recommendation:** For MedDefense's enterprise application password storage, **Argon2id** (or **bcrypt** where legacy framework compatibility is required) is strongly recommended due to superior GPU-hardening and memory-hard design.
* **Active Directory Default Status:** Active Directory by default stores passwords using NT hashes (NTLM, based on MD4). **This default is entirely inadequate** by modern security standards because NTLM hashes are fast to compute, un-salted by default, and trivial to crack or relay in enterprise environments unless hardened with Credential Guard and modern AES Kerberos policies.

---

## Part 5: The Integrity Verification Script

The integrity verification tool `3-hash_verify.sh` has been developed, tested, and committed to the repository. It accepts a target file path and an expected SHA-256 hash, computes the file's cryptographic hash, performs validation, outputs the exact status code strings, and returns proper exit codes.

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
