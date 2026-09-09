# MedDefense Detection Engineering Specification

## Purpose
This specification defines the contract, operational boundaries, and validation requirements for the MedDefense detection engineering pipeline. It establishes standardized artifact criteria and quality gates to protect clinical assets against advanced threats.

## Inputs
- **Normalized Evidence**: `$HANDOFF_DIR/data/normalized_events.json` resolved via `HANDOFF_DIR`.
- **Baseline Package**: `$BASELINE_PKG/baselines/baseline_summary.json` resolved via `BASELINE_PKG`.
- **Risk Register**: `$ASSETS_DIR/risk_register.json` resolved via `ASSETS_DIR`.

## Rule Authoring Standard
- **Sigma Structure**: YAML-based schema utilizing `title`, `id`, `status`, `description`, `logsource`, and `detection` blocks.
- **Required Fields**: `id` (must be a valid UUID v4), `title`, `level`, and `logsource`.
- **Naming Convention**: `[nnn]_[descriptive_name].yml` (e.g., `001_ssh_brute_force.yml`).
- **ATT&CK Tag Requirement**: Every rule must contain at least one valid MITRE ATT&CK tactic or technique tag (e.g., `attack.t1110.001`).

## Execution Model
- **Runner Script**: `3-sigma_runner.sh` parses rule YAML and evaluates predicates against normalized event streams.
- **Preprocessing Primitives**: Dynamic field extraction, timestamp normalization to ISO-8601, and custom feature augmentation (e.g., `hour_of_day`, `baseline_seen`).
- **Window Semantics**: Supports time-bounded evaluations (`--window start,end`) and dry-run syntax checks (`--dry-run`).

## Quality Thresholds
- **Precision & Recall**: Minimum precision of $\ge 0.50$ and recall of $\ge 0.60$ for production deployment.
- **F1 Score**: Rules must achieve an F1 score $\ge 0.70$ ([STRONG]) to ship without review, while F1 $< 0.30$ ([WEAK]) triggers mandatory retirement or tuning.
- **False Positive Rate**: Baseline false positive count must not exceed 10 matches over a 7-day clean window.

## Tuning Protocol
- Noisy rules with FP count $> 10$ are tagged `[TUNE]` during baseline audits.
- Tuning applies explicit negative filters, expanded context fields, or adjusted temporal thresholds.
- Validation re-runs the tuned rule against the 7-day clean baseline to confirm zero or minimal false positives.

## Risk Ranking Model
- **Risk Score**: Calculated as the sum of $(\text{likelihood} \times \text{impact})$ across intersecting threat scenarios from the risk register.
- **Priority Score**: Computed as $\text{risk\_score} \times F1$, enforcing a floor of $\text{risk\_score} \times 0.1$ for rules with zero F1.

## Outputs
- **Alert Queue**: `alert_queue.json` containing structured alert payloads (`rule_id`, `rule_title`, `level`, `evidence_path`, `match_count`, `matches`, `execution_time_ms`).
- **Downstream Contract**: Passes validated alert structures directly into the 3x03 incident response and orchestration framework.

## Failure Modes
- **Malformed YAML**: Syntax errors or missing keys cause parser exceptions; caught by `--dry-run` with exit code 1.
- **Missing Evidence Stream**: Results in empty match sets if normalized event paths are unresolvable or uninitialized.
- **Temporal Mismatch**: Invalid ISO timestamp formats cause window filtering to silently bypass event constraints.

## Reviewer Checklist
- Verify file location under `rules/sigma/`.
- Confirm UUID v4 format for the rule `id`.
- Validate MITRE ATT&CK tag mapping against the risk register.
- Ensure false positive rate remains within acceptable thresholds during baseline execution.
