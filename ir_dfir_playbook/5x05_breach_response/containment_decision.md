
# MedDefense Health Systems — Containment Decision

**Incident ID:** IR-2026-0420-01  

**Severity:** SEV1 — Critical  

**Incident date:** 2026-04-20  

**Prepared by:** Nishat Sultana Supty 

**Status:** Strategy selected for exercise; operational authorization pending

## 1. Situation and Scope

Four workstations — CS-WS-101, CS-WS-104, CS-WS-107 and CS-WS-112 — show Cobalt Strike C2 activity. All four contain `encryption_staging.ps1`, but execution is not confirmed.

**C2 domain:** `staging.office365-cdn.net`  
**C2 IP:** `45.152.66.114:443`

Proxy records also show historical C2-related connections from FILE-SVR-01, although no active beacon is confirmed at containment time.

Windows Security logs show 1,847 file-access events involving clinical PDF documents between 2026-04-19 02:14:01Z and 02:41:12Z. The activity used `MEDDEFENSE\jdoe`, logon ID `0xAF12C4B8`, and the suspicious process `svchost32.exe`. The account has no documented clinical need for this access.

Clinical operations remain active. Data exfiltration and ransomware execution are not confirmed.

## 2. Containment Strategy Comparison

| Strategy | Action | Attacker impact | Patient-care impact | Evidence preserved / destroyed | Estimated time | Reversibility |
|---|---|---|---|---|---|---|
| A — Full shutdown | Power off all five assets | Stops activity on those hosts, but may leave other attacker access | High: loss of workstations and clinical file services | Disk preserved; volatile RAM, active sessions and live connections lost | 5–15 min | Systems restartable; lost RAM unrecoverable |
| B — Selective isolation | Isolate four workstations; restrict FILE-SVR-01; block C2 domain/IP; revoke exposed credentials | Interrupts known C2 channels, limits lateral movement and credential reuse | Moderate: workstation disruption; essential file access retained | RAM and disks largely preserved; live connection state changes | 15–45 min | Mostly reversible through approved controls |
| C — Monitor only | Continue service with enhanced logging | Attacker retains potential access and ransomware deployment capability | Low immediate disruption; high future risk | Live behavior observable, but attacker may alter or destroy evidence | 5–10 min | Monitoring removable; subsequent damage may be irreversible |

*Times are estimates, not measured execution results.*

## 3. Selected Strategy and Rationale

**Chosen strategy: B — Selective isolation and credential containment.**

The four workstations require prompt network isolation because they have Cobalt Strike activity and ransomware staging. Blocking `staging.office365-cdn.net` and `45.152.66.114` will interrupt the known external C2 route. The `MEDDEFENSE\jdoe` account requires urgent session revocation and credential reset because it was associated with unauthorized access to clinical files. FILE-SVR-01 should receive tightly restricted network access rather than immediate shutdown: it has historical suspicious connections and file-access activity, but no confirmed active beacon, and its services may be essential to patient care. Keeping systems powered on where safe also preserves volatile forensic evidence. This approach accepts temporary workstation disruption and some loss of live network-state evidence to reduce ransomware and patient-data risks without unnecessarily stopping clinical operations.

## 4. Authorization and Rollback

**Authorizing role:** IR Commander — James Chen.  
**Clinical coordination:** Authorized clinical operations lead.  
**Authorization status:** Not recorded; operational approval pending.

**Rollback trigger:** Confirmed patient-safety impact or loss of essential clinical service without an effective fallback, as declared by the clinical operations lead.

Rollback must be approved and limited to restoring essential clinical access through trusted alternatives. Compromised hosts, accounts and known C2 destinations must not be automatically reconnected.

## 5. Containment Success Criteria

1. All four compromised workstations are confirmed isolated.
2. FILE-SVR-01 has restricted connectivity with essential clinical services maintained.
3. Firewall and DNS/web filtering block the known C2 IP and domain.
4. `MEDDEFENSE\jdoe` sessions and credentials are contained.
5. Other accounts exposed during the 72-hour dwell are reviewed.
6. Post-containment telemetry confirms no successful C2 communication.
7. Clinical operations are validated and all actions documented.

**Decision status:** Selected for exercise; not yet executed.
