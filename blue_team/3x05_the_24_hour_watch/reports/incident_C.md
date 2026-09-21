# Incident Report: INC-20260921-C

## Executive Summary
During shift monitoring, incident INC-20260921-C was identified affecting primary hosts including hostname-2. Investigation confirmed malicious activity characterized by unauthorized process execution and beaconing. Appropriate asset containment and isolation recommendations have been formulated.

## Timeline
2026-09-21T13:00:56Z | hostname-2 | Initial anomaly detection triggered by monitoring rule.
2026-09-21T13:00:56Z | hostname-2 | Suspicious process execution pattern observed.
2026-09-21T13:00:56Z | hostname-2 | Outbound connection established to external indicator.

## Affected Assets
| HOST | CRITICALITY | DATA_CLASS | ZONE |
|---|---|---|---|
| hostname-2 | HIGH | MEDICAL | INTERNAL |

## Indicators of Compromise
| TYPE | VALUE | CONFIDENCE | SOURCE |
|---|---|---|---|
| IP | 198[.]51[.]100[.]73 | high | ioc_feed.json |

## ATT&CK Mapping
| TECHNIQUE | NAME | EVIDENCE |
|---|---|---|
| T1071.001 | Application Layer Protocol: Web Protocols | Observed in enriched process and network telemetry. |
| T1543.003 | Create or Modify System Process: Windows Service | Observed in enriched process and network telemetry. |

## Detection Performance
- rule_brute_force: Fired successfully
- rule_persistence: Fired successfully

## Recommended Actions
1. Isolate host hostname-2 from the corporate network immediately.
2. Revoke active credentials and session tokens for compromised user accounts.
3. Block external indicator destinations at the perimeter firewall.
4. Perform forensic disk acquisition for offline malware analysis.

## Evidence References
EVT-C-1
EVT-C-2
