
# Chain of Custody: LH-2026-0414-01

## Case Header

- **Case number:** LH-2026-0414-01
- **Incident ID:** IR-2026-0414-01
- **Lead investigator:** Nishat Sultana Supty
- **Date opened:** 2026-10-18
- **Litigation hold reference:** Memo from Helena Reyes, 2026-04-14T07:30Z
- **IR Commander:** James Chen
- **Evidence acquirer:** Mike Torres, Network Engineer
- **Investigation status:** Baseline hash verification pending

**Document rule:** This chain-of-custody log is append-only. Existing entries must not be deleted or silently modified. Any correction must be recorded as a new entry referencing the original.

The acquisition notes were completed by Mike Torres on 2026-04-14T07:42Z. Known acquisition gaps are documented below.

---

## Artifact Registry

| Artifact ID | Artifact Name | Format | Acquired By | Acquisition Timestamp (UTC) | Acquisition Tool | SHA-256 at Acquisition | Storage Path | Access Controls |
|---|---|---|---|---|---|---|---|---|
| ART-001 | `wst-ws-031.dd` | RAW/DD | Mike Torres | 2026-04-14T04:51Z (start) to 06:14Z (complete) | FTK Imager | NOT COMPUTED AT ACQUISITION | `\\evidence\share\IR-2026-0414-01\wst-ws-031.dd` (expected path) | Required: read-only, IR team only; verification pending |
| ART-002 | `wst-ws-031.mem` | RAW memory dump | Mike Torres | 2026-04-14T03:02Z | WinPmem v3.3-rc3 | NOT COMPUTED AT ACQUISITION | `\\evidence\share\IR-2026-0414-01\wst-ws-031.mem` (expected path) | Required: read-only, IR team only; verification pending |
| ART-003 | `wst-ws-017.mem` | RAW memory dump | Mike Torres | 2026-04-14T03:38Z | WinPmem (version not specified) | NOT COMPUTED AT ACQUISITION | `\\evidence\share\IR-2026-0414-01\wst-ws-017.mem` (expected path) | Required: read-only, IR team only; verification pending |

**Registry notes:**

- All three artifacts were acquired on 2026-04-14.
- The acquisition notes identify the evidence share as `\\evidence\share\IR-2026-0414-01\`.
- Individual filenames have been appended to the recorded directory path; exact storage locations must be verified.
- No SHA-256 hashes were calculated during acquisition.
- Actual evidence storage permissions have not yet been independently verified.
- First-access hashes must be established before forensic analysis.

---

## First-Access SHA-256 Baseline

Because acquisition-time SHA-256 hashes are unavailable, the forensic analyst must establish a baseline at first forensic access.

The first-access baseline does not retroactively prove integrity at the time of acquisition.

| Artifact ID | Artifact Name | First-Access SHA-256 | Verification Timestamp (UTC) | Status |
|---|---|---|---|---|
| ART-001 | `wst-ws-031.dd` | PENDING | PENDING | Not verified |
| ART-002 | `wst-ws-031.mem` | PENDING | PENDING | Not verified |
| ART-003 | `wst-ws-017.mem` | PENDING | PENDING | Not verified |

### Hash Verification Procedure

Before analyzing an artifact:

1. Confirm its identity and actual storage path.
2. Confirm that the evidence is protected against modification.
3. Calculate its SHA-256 hash using `sha256sum`.
4. Save the hash output in the `hashes/` directory.
5. Record the actual UTC verification timestamp.
6. Append the verification event to the Access Log.
7. Use a verified working copy or read-only access for analysis.

### Linux Commands

Run these commands from the directory containing the forensic artifacts:

```bash
mkdir -p hashes

date -u +"%Y-%m-%dT%H:%M:%SZ"
sha256sum wst-ws-031.dd | tee hashes/ART-001.sha256

date -u +"%Y-%m-%dT%H:%M:%SZ"
sha256sum wst-ws-031.mem | tee hashes/ART-002.sha256

date -u +"%Y-%m-%dT%H:%M:%SZ"
sha256sum wst-ws-017.mem | tee hashes/ART-003.sha256
```

Record the actual hashes and timestamps after executing these commands.

Do not replace the acquisition-hash entries with the newly calculated baseline hashes.

For subsequent verification, compare the current SHA-256 against the established first-access baseline.

Any mismatch must be immediately recorded as a `DEVIATION`.

---

## Access Log

The following entries reconstruct known acquisition and handling events from `acquisition_notes.md`.

Historical entries do not imply that a complete chain of custody existed during acquisition.

| Timestamp (UTC) | Actor | Artifact ID | Action | Tool | Hash Verified | Notes |
|---|---|---|---|---|---|---|
| 2026-04-14T03:02Z | Mike Torres | ART-002 | acquire_memory_dump | WinPmem v3.3-rc3 | no | Captured from live WST-WS-031 while the host was still beaconing. Data transferred using USB3/external NVMe workflow and copied to evidence share. DEVIATION: No SHA-256 calculated. |
| 2026-04-14T03:38Z | Mike Torres | ART-003 | acquire_memory_dump | WinPmem | no | Captured from WST-WS-017 console at West Campus. DEVIATION: No SHA-256 calculated. |
| Before disk imaging; exact time unknown | Mike Torres | ART-001 | pre_acquisition_filesystem_access | Windows Explorer / filesystem mount | no | Live filesystem mounted read-write to check whether `update.xml` existed. DEVIATION: Potential filesystem metadata changes. |
| 2026-04-14T04:51Z | Mike Torres | ART-001 | acquire_disk_start | FTK Imager | no | RAW/DD acquisition started. Host had already been isolated to VLAN 999. Filesystem had not been remounted read-only. |
| 2026-04-14T06:14Z | Mike Torres | ART-001 | acquire_disk_complete | FTK Imager | no | Disk imaging completed. DEVIATION: No SHA-256 calculated. |
| 2026-04-14T07:30Z | Helena Reyes | ALL | litigation_hold_reference | Legal memo | n/a | Litigation hold LH-2026-0414-01 referenced in project instructions. |
| 2026-04-14T07:42Z | Mike Torres | ALL | acquisition_notes_handoff | Acquisition notes | no | Acquisition record completed and handed to forensic analyst. DEVIATION: Physical and network access history between acquisition and handoff was not fully documented. |

### Subsequent Access Events

The following rows are templates only. They are not completed events.

Append actual events after performing the corresponding actions.

| Timestamp (UTC) | Actor | Artifact ID | Action | Tool | Hash Verified | Notes |
|---|---|---|---|---|---|---|
| PENDING | Steve | ART-001 | hash_verify | sha256sum | pending | First-access baseline to be stored in `hashes/ART-001.sha256`. |
| PENDING | Steve | ART-002 | hash_verify | sha256sum | pending | First-access baseline to be stored in `hashes/ART-002.sha256`. |
| PENDING | Steve | ART-003 | hash_verify | sha256sum | pending | First-access baseline to be stored in `hashes/ART-003.sha256`. |

**Logging rule:** Every subsequent evidence access must produce a new entry containing the actual UTC timestamp, actor, artifact ID, action, tool, hash-verification status, and notes.

Planned actions must never be represented as completed forensic activities.

---

## Acquisition Deviations

### DEVIATION-001: Missing Acquisition Hashes

**Affected artifacts:** ART-001, ART-002, ART-003

**Description:**

Mike Torres confirmed that SHA-256 hashes were not calculated during acquisition.

**Impact:**

The investigator cannot cryptographically confirm that the current artifacts are identical to their acquisition-time state.

**Required action:**

Calculate first-access SHA-256 baseline hashes before analysis and record the results.

**Status:** Open — baseline verification pending.

### DEVIATION-002: Read-Write Filesystem Access

**Affected artifact:** ART-001

**Description:**

Mike Torres mounted the live filesystem read-write before disk acquisition to confirm the presence of `update.xml`.

Windows Explorer was opened on the mounted filesystem.

The filesystem was not remounted read-only before the FTK Imager acquisition.

**Impact:**

Filesystem metadata, including access timestamps, may have changed during this activity.

**Required action:**

Document the interaction and consider possible timestamp contamination when analyzing the filesystem timeline.

**Status:** Documented — impact to be assessed during forensic analysis.

### DEVIATION-003: Incomplete Chain of Custody

**Affected artifacts:** ART-001, ART-002, ART-003

**Description:**

No formal chain-of-custody form was maintained during acquisition.

The acquirer did not record all individuals who had physical or network access to the artifacts between acquisition and handoff.

**Impact:**

The historical custody record is incomplete.

**Required action:**

Preserve the original acquisition notes and document all subsequent access and transfers.

**Status:** Documented — historical gap cannot be retroactively eliminated.

### DEVIATION-004: Evidence Storage Controls Unverified

**Affected artifacts:** ART-001, ART-002, ART-003

**Description:**

The acquisition notes identify the evidence share but do not confirm the actual access-control configuration.

**Impact:**

Read-only protection and IR-team-only access have not been independently established.

**Required action:**

Verify permissions and access restrictions before analysis.

**Status:** Open — verification pending.

---

## Deviation Handling Procedure

If an artifact's SHA-256 differs from its established baseline:

1. Stop analysis of the affected artifact.
2. Preserve both expected and observed hash values.
3. Record the actual UTC timestamp.
4. Identify the actor, artifact, and tool involved.
5. Append a new `DEVIATION` entry to the Access Log.
6. Notify James Chen and the appropriate legal contact.
7. Investigate the discrepancy before resuming analysis.

### Deviation Record Template

- **Deviation ID:** [ID]
- **Timestamp (UTC):** [TIMESTAMP]
- **Artifact ID:** [ART-ID]
- **Expected SHA-256:** [HASH]
- **Observed SHA-256:** [HASH]
- **Actor:** [NAME]
- **Tool:** [TOOL]
- **Description:** [DETAILS]
- **Escalated to:** [NAME]
- **Resolution:** [STATUS]

---

## Evidence Handling Rules

1. Preserve original forensic artifacts.
2. Verify SHA-256 before first analysis access.
3. Use verified working copies or read-only access.
4. Document every access event.
5. Record timestamps in UTC.
6. Preserve original acquisition records.
7. Never overwrite or delete previous access log entries.
8. Append corrections rather than modifying historical records.
9. Record integrity mismatches as `DEVIATION` events.
10. Maintain evidence preservation throughout the litigation hold.

---

## Litigation Hold

- **Reference:** LH-2026-0414-01
- **Issued by:** Helena Reyes, General Counsel
- **Reference timestamp:** 2026-04-14T07:30Z
- **Related incident:** IR-2026-0414-01

All relevant forensic artifacts, acquisition records, hash records, and investigation documentation must be preserved in accordance with the litigation hold.

Evidence must not be deleted or modified contrary to the hold instructions.

---

## Source References

- `acquisition_notes.md` — Original acquisition notes, Mike Torres, 2026-04-14T07:42Z.
- `wst-ws-031.dd` — ART-001.
- `wst-ws-031.mem` — ART-002.
- `wst-ws-017.mem` — ART-003.

Supplementary logs available for later investigation:

- `ad_auth_log.jsonl`
- `proxy_log.jsonl`
- `siem_alert_export.json`

These supplementary files must be registered and their integrity documented before forensic analysis if used as evidence.

---

## Investigation Status

- [x] Acquisition notes reviewed
- [x] Case header created
- [x] Artifact registry created
- [x] Historical acquisition events documented
- [x] Acquisition deviations recorded
- [x] First-access baseline procedure documented
- [ ] Actual evidence storage paths verified
- [ ] Evidence access controls verified
- [ ] SHA-256 baseline for ART-001 calculated
- [ ] SHA-256 baseline for ART-002 calculated
- [ ] SHA-256 baseline for ART-003 calculated
- [ ] Actual verification events appended to Access Log

**Status:** Chain-of-custody record prepared. Baseline hash verification and evidence storage checks remain pending.
