# 12. The Disk Encryption Lab & Backup Strategy: MedDefense NAS-01

## Objective

The objective of this lab is to validate **encryption at rest** by implementing **LUKS (Linux Unified Key Setup)** on a virtual disk (loop device). This simulates securing the MedDefense backup server (**NAS-01**) without modifying production systems. The exercise demonstrates how encrypted storage protects sensitive patient backups from unauthorized access while maintaining data integrity.

---

# Part 1 - LUKS Setup & Execution

To safely test encryption before deployment, a **500 MB virtual disk image** is created and encrypted using **LUKS with AES-256-XTS**.

## Step 1 - Create a 500 MB Virtual Disk Image

```bash
dd if=/dev/zero of=encrypted_volume.img bs=1M count=500 status=progress
```

**Purpose**

- Creates a 500 MB blank file named `encrypted_volume.img`.
- The file acts as a virtual storage device for testing disk encryption.

---

## Step 2 - Format the Image with LUKS

```bash
sudo cryptsetup luksFormat encrypted_volume.img
```

**Purpose**

- Initializes the virtual disk as a LUKS-encrypted container.
- Creates the LUKS header and encryption metadata.
- Prompts for a passphrase that will protect the encryption keys.

---

## Step 3 - Open the Encrypted Container

```bash
sudo cryptsetup luksOpen encrypted_volume.img secure_vol
```

**Purpose**

- Unlocks the encrypted volume using the passphrase.
- Creates the mapped device:

```text
/dev/mapper/secure_vol
```

which behaves like a normal block device.

---

## Step 4 - Create an ext4 Filesystem

```bash
sudo mkfs.ext4 /dev/mapper/secure_vol
```

**Purpose**

- Formats the unlocked encrypted volume with the ext4 filesystem.
- Enables Linux to store files and directories inside the encrypted container.

---

## Step 5 - Mount the Filesystem and Write Test Data

```bash
sudo mkdir -p /mnt/secure_backup
sudo mount /dev/mapper/secure_vol /mnt/secure_backup
echo "CONFIDENTIAL: MedDefense Patient Medical Records Archive Test" | sudo tee /mnt/secure_backup/test_record.txt
```

**Purpose**

- Mounts the encrypted filesystem.
- Writes a sample confidential record to verify encryption and data integrity.

---

## Step 6 - Unmount and Close the Volume

```bash
sudo umount /mnt/secure_backup
sudo cryptsetup luksClose secure_vol
```

**Purpose**

- Unmounts the encrypted filesystem.
- Removes the decrypted device mapping.
- Returns the storage to an encrypted, inaccessible state.

---

# Part 2 - Verification & Security Proof

## 1. Raw String Analysis After Closure

After the encrypted volume is closed, examine the raw disk image.

```bash
strings encrypted_volume.img | head -50
```

### Findings

The output displays only:

- LUKS header metadata
- Encryption algorithm information
- Random binary data

The original plaintext message:

```text
CONFIDENTIAL: MedDefense Patient Medical Records Archive Test
```

is **not visible**.

### Security Proof

This demonstrates **encryption at rest**.

Even if an attacker steals the storage media or accesses the raw backup image, the data remains unreadable without the correct decryption key.

---

## 2. Re-Opening and Data Integrity Verification

Reopen the encrypted volume.

```bash
sudo cryptsetup luksOpen encrypted_volume.img secure_vol
sudo mkdir -p /mnt/secure_backup
sudo mount /dev/mapper/secure_vol /mnt/secure_backup
```

Read the stored file.

```bash
cat /mnt/secure_backup/test_record.txt
```

Example Output

```text
CONFIDENTIAL: MedDefense Patient Medical Records Archive Test
```

Close the encrypted volume.

```bash
sudo umount /mnt/secure_backup
sudo cryptsetup luksClose secure_vol
```

### Validation

The successful recovery of the stored data confirms:

- Encryption protects the data while stored.
- Data integrity is preserved.
- Authorized users can fully recover the data after authentication.

---

# Part 3 - The LUKS Automation Script (`12-luks_manager.sh`)

```bash
#!/bin/bash

set -e

IMG="encrypted_volume.img"
VOL="secure_vol"
MNT="/mnt/secure_backup"

case "$1" in

create)
    dd if=/dev/zero of="$IMG" bs=1M count=500 status=progress
    sudo cryptsetup luksFormat --batch-mode "$IMG"
    sudo cryptsetup luksOpen "$IMG" "$VOL"
    sudo mkfs.ext4 "/dev/mapper/$VOL"
    sudo cryptsetup luksClose "$VOL"
    echo "[+] Volume created successfully."
    ;;

open)
    sudo cryptsetup luksOpen "$IMG" "$VOL"
    sudo mkdir -p "$MNT"
    sudo mount "/dev/mapper/$VOL" "$MNT"
    echo "[+] Volume opened and mounted at $MNT."
    ;;

close)
    sudo umount "$MNT"
    sudo cryptsetup luksClose "$VOL"
    echo "[+] Volume closed."
    ;;

*)
    echo "Usage: $0 {create|open|close}"
    exit 1
    ;;
esac
```

### Script Functions

| Mode | Description |
|------|-------------|
| `create` | Creates a new 500 MB encrypted LUKS volume and formats it with ext4. |
| `open` | Unlocks the encrypted volume and mounts it. |
| `close` | Unmounts the filesystem and securely locks the encrypted volume. |

---

# Part 4 - MedDefense Backup Encryption Design (NAS-01)

## Encryption Level Selection

The recommended approach for **NAS-01** is **volume-level encryption using LUKS (AES-256-XTS)**.

### Justification

- Protects the entire backup repository.
- Encrypts backup files, metadata, directory structures, and filesystem information.
- Requires no modification to backup applications.
- Provides transparent encryption and decryption once the volume is unlocked.
- Simplifies operational management compared to file-by-file encryption.

---

## Backup Performance Impact

Modern processors supporting **AES-NI hardware acceleration** significantly reduce encryption overhead.

Estimated impact:

- Approximately **3%–5%** performance overhead during backup and restore operations.
- Backup jobs should be scheduled during off-peak maintenance windows (e.g., **01:00–04:00 AM**) to minimize effects on production systems.

---

## Encryption Key Storage

Encryption keys **must not** be stored on **NAS-01**.

Instead, they should be stored within:

- Enterprise Key Management System (KMS)
- Cloud Hardware Security Module (HSM)
- Secure offline key escrow

### Reason

Separating encryption keys from the encrypted storage prevents attackers from obtaining both the encrypted backups and the decryption keys if the NAS is stolen or compromised.

---

## Key Loss Implications

Loss of all encryption keys results in:

- Permanent loss of access to encrypted backups.
- Inability to recover patient records.
- Irreversible data loss.

### Mitigation

- Maintain secure key backups.
- Implement quorum-based key escrow.
- Replicate recovery keys across multiple HSM locations.
- Regularly test disaster recovery procedures.

---

## Cloud Replication Integration

Offsite backup replicas must remain encrypted during both **transmission** and **storage**.

### Recommended Strategy

- Encrypt backups on NAS-01 before replication.
- Transfer encrypted backups using secure communication channels (TLS/VPN).
- Store encrypted replicas in cloud storage.
- Manage cloud encryption keys using an independent cloud KMS or HSM.
- Use separate, scope-limited encryption keys for cloud replicas to reduce the impact of a single key compromise.

This layered approach ensures that patient backup data remains protected both on-premises and in offsite cloud environments while supporting secure disaster recovery.
