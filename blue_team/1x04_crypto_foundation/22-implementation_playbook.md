# The Implementation Playbook (Condensed)**

##Action #1: Patient Portal TLS Hardening & Protocol Upgrade**

- **Priority: Immediate | System: portal.meddefense.com**
- **Prerequisites: Backup config file, valid ACME 90-day cert ready, staging verified.**
- **Steps:**
  - **Remove TLS 1.0/1.1 from /etc/nginx/sites-available/portal.conf.**
  - **Enforce AEAD ciphers (ECDHE-ECDSA-AES256-GCM-SHA384).**
  - **Enable HSTS (max-age=63072000).**
  - **Test syntax and reload Nginx (sudo nginx -t && sudo systemctl reload nginx).**
- **Validation: Run external TLS scanner (testssl.sh); monitor portal logs for connection stability.**
- **Rollback: Restore config backup and reload Nginx (Max downtime: 5 mins).**
- **Window: Overnight (02:00 - 03:00 AM) | Comms: Helpdesk, Clinical Ops, CISO.**

**Action #2: Active Directory Kerberos RC4 Disabling**

- **Priority: Immediate | System: dc01.meddefense.local, dc02.meddefense.local**
- **Prerequisites: AD system state backup complete, legacy apps audited.**
- **Steps:**
  - **Open GPMC (gpmc.msc) -> Computer Configuration -> Security Settings.**
  - **Locate _Network security: Configure encryption types allowed for Kerberos_.**
  - **Deselect RC4/DES; leave AES128 and AES256 enabled.**
  - **Force group policy update (gpupdate /force).**
- **Validation: Check Event ID 4768/4769 for AES-256 tickets; verify domain auth stability.**
- **Rollback: Re-enable RC4 in GPO and run gpupdate /force (Max downtime: 10 mins).**
- **Window: Overnight (01:00 - 02:00 AM) | Comms: SysAdmins, Helpdesk.**

**Action #3: EHR Database Transparent Data Encryption (TDE)**

- **Priority: Immediate | System: ehr-db-01 (PostgreSQL)**
- **Prerequisites: Cloud HSM provisioned, offline cold backup verified.**
- **Steps:**
  - **Provision Master Encryption Key inside Cloud HSM.**
  - **Bind PostgreSQL TDE parameters in postgresql.conf to HSM provider.**
  - **Initialize encryption on unencrypted tablespaces.**
  - **Restart PostgreSQL service.**
- **Validation: Run pg_data_retrieval_status query; verify application read/write latency.**
- **Rollback: Disable TDE flag in config and restore from cold backup (Max downtime: 30 mins).**
- **Window: Overnight (00:00 - 02:00 AM) | Comms: Clinical Staff, EHR Support, CISO.**

**Action #4: Backup Storage Volume Encryption**

- **Priority: Phase 1 | System: NAS-01**
- **Prerequisites: Encryption packages installed, backup writes quiesced.**
- **Steps:**
  - **Halt scheduled backups.**
  - **Initialize AES-256-XTS LUKS container (cryptsetup luksFormat).**
  - **Open encrypted volume and format filesystem (mkfs.ext4).**
  - **Mount storage volume to /mnt/meddefense_backups and update /etc/crypttab.**
- **Validation: Run cryptsetup status; perform test backup write/restore.**
- **Rollback: Unmount volume, close container, restore physical snapshot (Max downtime: 45 mins).**
- **Window: Overnight (01:00 - 04:00 AM) | Comms: Backup Admins, Systems Engineering.**

**Action #5: Billing Database Record-Level Encryption & Tokenization**

- **Priority: Phase 1 | System: billing-srv-01 (MySQL)**
- **Prerequisites: Tokenization vault API ready, application encryption libraries installed.**
- **Steps:**
  - **Deploy application-tier encryption wrapper libraries to billing middleware.**
  - **Alter table schemas to store tokenized handles/AES-256 ciphertext instead of PANs.**
  - **Configure runtime app policies to fetch keys dynamically from HSM.**
  - **Restart billing application service cluster.**
- **Validation: Query MySQL directly (SELECT cc_number...) to verify masking; run payment test simulation.**
- **Rollback: Revert app binaries and restore database schema from backup (Max downtime: 30 mins).**
- **Window: Overnight (02:00 - 04:00 AM) | Comms: Finance Team, Billing Supervisors, CISO.**
