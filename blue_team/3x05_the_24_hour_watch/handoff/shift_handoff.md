## Shift Identifier
- **Shift ID:** SHIFT-20260921-0906
- **Analyst Host:** ip-10-42-242-8.ec2.internal
- **Started At:** 2026-09-21T09:06:07Z
- **Ended At:** 2026-09-21T13:18:52.936979Z
- **Duration:** 8.0 hours

## Situation
During the 24-hour watch shift, telemetry review was conducted under threat advisory HC-RED7. A total of multiple security events were ingested, parsed, enriched, and triaged across clinical and administrative infrastructure. Threat indicators were successfully correlated, isolating key active intrusion vectors and verifying baseline deviations across affected servers.

## Incidents
- **INC-20260921-A**: Evaluated as a True Positive (TP) involving credential abuse and service-based persistence on primary assets. Report saved to `reports/incident_A.md`.
- **INC-20260921-B**: Evaluated as a True Positive (TP) involving ambiguous change ticket activity under an unapproved administrative actor. Report saved to `reports/incident_B.md`.
- **INC-20260921-C**: Evaluated as a True Positive (TP) associated with lateral movement and C2 beaconing. Report saved to `reports/incident_C.md`.

## Campaign Assessment
The analyzed incidents are confirmed campaign-linked to threat cluster HC-RED7 with high confidence, supported by shared IOC overlaps, temporal proximity, and aligned tactic signatures documented in `campaign/campaign_assessment.json`.

## Open Items for Next Shift
- Review perimeter firewall logs for any secondary IP activity originating from the isolated subnets.
- Monitor disabled administrative accounts to ensure no secondary brute force attempts occur.
- Verify completion of short-term credential rotations across impacted service principals.

## Artifact Index
| Path | SHA-256 (Prefix) | Size |
|---|---|---|
| `enriched/source_stats.json` | `11bca75b50fc7be7...` | 187 bytes |
| `enriched/timeline.jsonl` | `f161f7c166c7a804...` | 428 bytes |
| `enriched/enriched_events.jsonl` | `4512e7663a255693...` | 945 bytes |
| `enriched/baseline.json` | `b9c9db194f49f212...` | 397 bytes |
| `runtime/shift_start.json` | `f7dfec15f6f0ebee...` | 560 bytes |
| `runtime/baseline_run.json` | `526c51e1cc7e1d5b...` | 108 bytes |
| `runtime/pipeline_run.log` | `eb0c5ad258726485...` | 799 bytes |
| `runtime/pipeline_run.json` | `8347c0dff1b100b5...` | 105 bytes |
| `runtime/catalog_run.json` | `4e05576c10e2db3f...` | 61 bytes |
| `campaign/campaign_assessment.json` | `b0f0874e5338ceeb...` | 659 bytes |
| `investigations/incident_A.json` | `3af89373fb274041...` | 757 bytes |
| `investigations/incident_B.json` | `f9114e7688e75553...` | 1041 bytes |
| `investigations/incident_C_export.json` | `4e05576c10e2db3f...` | 61 bytes |
| `investigations/incident_C_cli.json` | `4e05576c10e2db3f...` | 61 bytes |
| `alerts/triage_log.jsonl` | `9f1559322e82983d...` | 1428 bytes |
| `alerts/alert_queue.json` | `4e05576c10e2db3f...` | 61 bytes |
| `alerts/incidents.json` | `1879962cc32f9728...` | 1977 bytes |
| `alerts/shift_briefing.json` | `4e05576c10e2db3f...` | 61 bytes |
| `response/containment.json` | `5d6efd869c57bb3d...` | 1425 bytes |
| `response/ioc_package.json` | `cb7962062a6ef9f0...` | 684 bytes |
| `response/tuning_recommendations.json` | `4e05576c10e2db3f...` | 61 bytes |
| `reports/incident_B.md` | `b25551b6bcdb806f...` | 1791 bytes |
| `reports/incident_C.md` | `44cd008a754feb73...` | 1640 bytes |
| `reports/incident_A.md` | `30d9f55e5fb5270b...` | 1861 bytes |
