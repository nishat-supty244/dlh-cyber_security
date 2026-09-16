# Structured Trade-off Analysis: CLI vs Wazuh Export

| Scenario | CLI Time (s) | Export Time (s) | Time Delta (CLI-Export) | CLI Actions | Export Actions | Faster Interface | Action Advantage | Operational Cause |
|---|---:|---:|---:|---:|---:|---|---|---|
| anchor | 1 | 1 | 0 | 5 | 7 | tie | cli | timeline_visualization |
| scenario_a | 1 | 1 | 0 | 6 | 7 | tie | cli | timeline_visualization |
| scenario_b | 48 | 25 | 23 | 5 | 5 | export | tie | native_field_surface |
| scenario_c | 45 | 1 | 44 | 5 | 4 | export | export | native_field_surface |

## Summary

- **Scenarios Analyzed**: 4
- **Export Advantages**: 2
- **CLI Advantages**: 0
- **Ties**: 2
