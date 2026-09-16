#!/bin/bash
set -euo pipefail

FINDINGS_DIR="findings"
COMPARISON_DIR="comparison"

mkdir -p "$COMPARISON_DIR"

JSON_OUT="$COMPARISON_DIR/tradeoff_table.json"
MD_OUT="$COMPARISON_DIR/tradeoff_table.md"

# ------------------------------------------------------------
# 1. Check that findings directory exists
# ------------------------------------------------------------

if [ ! -d "$FINDINGS_DIR" ]; then
    echo "Error: findings directory not found: $FINDINGS_DIR" >&2
    exit 1
fi

# ------------------------------------------------------------
# 2. Load all finding JSON files
# ------------------------------------------------------------

mapfile -t FINDING_FILES < <(
    find "$FINDINGS_DIR" -maxdepth 1 -type f -name "*.json" | sort
)

if [ "${#FINDING_FILES[@]}" -eq 0 ]; then
    echo "Error: No finding JSON files found in $FINDINGS_DIR" >&2
    exit 1
fi

# ------------------------------------------------------------
# 3. Validate every finding
# ------------------------------------------------------------

for f in "${FINDING_FILES[@]}"; do

    # Check valid JSON
    if ! jq empty "$f" >/dev/null 2>&1; then
        echo "Error: Invalid JSON: $f" >&2
        exit 1
    fi

    # Check required fields
    scenario_id=$(jq -r '.scenario_id // empty' "$f")
    interface=$(jq -r '.interface // empty' "$f")
    time=$(jq -r '.time_to_first_answer_seconds // empty' "$f")

    if [ -z "$scenario_id" ]; then
        echo "Error: Missing scenario_id in $f" >&2
        exit 1
    fi

    if [ -z "$interface" ]; then
        echo "Error: Missing interface in $f" >&2
        exit 1
    fi

    if [ -z "$time" ]; then
        echo "Error: Missing time_to_first_answer_seconds in $f" >&2
        exit 1
    fi

    # Check that actions exists
    if ! jq -e '.actions | type == "array"' "$f" >/dev/null 2>&1; then
        echo "Error: actions array missing in $f" >&2
        exit 1
    fi

done

# ------------------------------------------------------------
# 4. Build comparison data using Python
# ------------------------------------------------------------

python3 - "$FINDINGS_DIR" "$JSON_OUT" "$MD_OUT" <<'PY'
import json
import os
import glob
import sys

findings_dir = sys.argv[1]
json_out = sys.argv[2]
md_out = sys.argv[3]

# Allowed operational causes from the task
ALLOWED_CAUSES = {
    "native_field_surface",
    "text_speed_iteration",
    "context_join_ergonomics",
    "timeline_visualization",
    "reproducibility",
    "filter_bar_efficiency",
    "pipeline_expressiveness",
}

# ------------------------------------------------------------
# Load findings
# ------------------------------------------------------------

findings = {}

for path in sorted(glob.glob(os.path.join(findings_dir, "*.json"))):

    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    scenario = data.get("scenario_id")
    interface = data.get("interface")

    if not scenario or not interface:
        continue

    findings.setdefault(scenario, {})[interface] = data


# ------------------------------------------------------------
# Find CLI + Wazuh pairs
# ------------------------------------------------------------

comparisons = []

for scenario_id in sorted(findings):

    pair = findings[scenario_id]

    if "cli" not in pair or "wazuh_export" not in pair:
        print(
            f"Warning: incomplete pair for {scenario_id}; skipping",
            file=sys.stderr
        )
        continue

    cli = pair["cli"]
    export = pair["wazuh_export"]

    # --------------------------------------------------------
    # Metrics
    # --------------------------------------------------------

    cli_time = float(cli["time_to_first_answer_seconds"])
    export_time = float(export["time_to_first_answer_seconds"])

    cli_actions = len(cli.get("actions", []))
    export_actions = len(export.get("actions", []))

    # Positive delta means CLI took longer
    time_delta = cli_time - export_time

    # Positive delta means CLI used more actions
    action_delta = cli_actions - export_actions

    # --------------------------------------------------------
    # Determine faster interface
    # --------------------------------------------------------

    if cli_time < export_time:
        advantage = "cli"
    elif export_time < cli_time:
        advantage = "export"
    else:
        advantage = "tie"

    # --------------------------------------------------------
    # Determine action advantage
    # --------------------------------------------------------

    if cli_actions < export_actions:
        action_advantage = "cli"
    elif export_actions < cli_actions:
        action_advantage = "export"
    else:
        action_advantage = "tie"

    # --------------------------------------------------------
    # Look for explicitly documented operational cause
    # --------------------------------------------------------

    cause = (
        cli.get("operational_cause")
        or export.get("operational_cause")
    )

    if cause not in ALLOWED_CAUSES:
        cause = None

    # --------------------------------------------------------
    # Evidence-based fallback
    #
    # This looks at what the finding actually touched.
    # --------------------------------------------------------

    if cause is None:

        combined_text = json.dumps(
            {
                "cli_actions": cli.get("actions", []),
                "export_actions": export.get("actions", []),
                "cli_fields": cli.get("fields_touched", []),
                "export_fields": export.get("fields_touched", []),
            }
        ).lower()

        # Structured Wazuh fields strongly indicate native field use
        if advantage == "export" and any(
            field in combined_text
            for field in [
                "agent.name",
                "user.name",
                "winlog.event_id",
                "agent.labels",
                "source.ip",
                "destination.ip",
            ]
        ):
            cause = "native_field_surface"

        # Timeline / timestamp investigation
        elif "timeline" in combined_text or "@timestamp" in combined_text:
            cause = "timeline_visualization"

        # Filtering/search language
        elif any(
            word in combined_text
            for word in [
                "filter",
                "kql",
                "search",
                "query",
            ]
        ):
            cause = "filter_bar_efficiency"

        # CLI-heavy jq/grep/awk/shell processing
        elif advantage == "cli" and any(
            word in combined_text
            for word in [
                "jq",
                "grep",
                "awk",
                "sed",
                "command",
                "shell",
            ]
        ):
            cause = "text_speed_iteration"

        # Pipeline / chained processing
        elif any(
            word in combined_text
            for word in [
                "pipeline",
                "jq",
                "awk",
                "sort",
                "uniq",
            ]
        ):
            cause = "pipeline_expressiveness"

        # Reproducibility if explicitly mentioned
        elif "reproduc" in combined_text:
            cause = "reproducibility"

        # Context joining
        elif any(
            word in combined_text
            for word in [
                "asset_inventory",
                "context",
                "fallback",
                "inventory",
            ]
        ):
            cause = "context_join_ergonomics"

        else:
            cause = "text_speed_iteration" if advantage == "cli" else "native_field_surface"

    # --------------------------------------------------------
    # Human-readable difference
    # --------------------------------------------------------

    if advantage == "cli":
        faster_by = cli_time - export_time
    elif advantage == "export":
        faster_by = export_time * -1 + cli_time
    else:
        faster_by = 0

    comparisons.append({
        "scenario_id": scenario_id,
        "cli_time": cli_time,
        "export_time": export_time,
        "time_delta_cli_minus_export": time_delta,
        "cli_action_count": cli_actions,
        "export_action_count": export_actions,
        "action_delta_cli_minus_export": action_delta,
        "faster_interface": advantage,
        "action_efficiency_advantage": action_advantage,
        "operational_cause": cause,
    })


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

export_advantages = sum(
    1 for x in comparisons if x["faster_interface"] == "export"
)

cli_advantages = sum(
    1 for x in comparisons if x["faster_interface"] == "cli"
)

ties = sum(
    1 for x in comparisons if x["faster_interface"] == "tie"
)

summary = {
    "scenarios_analyzed": len(comparisons),
    "export_advantages": export_advantages,
    "cli_advantages": cli_advantages,
    "ties": ties,
}

output = {
    "scenarios_analyzed": len(comparisons),
    "comparisons": comparisons,
    "summary": summary,
}

# ------------------------------------------------------------
# Write JSON
# ------------------------------------------------------------

with open(json_out, "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2)

# ------------------------------------------------------------
# Write Markdown
# ------------------------------------------------------------

with open(md_out, "w", encoding="utf-8") as f:

    f.write("# Structured Trade-off Analysis: CLI vs Wazuh Export\n\n")

    f.write(
        "| Scenario | CLI Time (s) | Export Time (s) | "
        "Time Delta (CLI-Export) | CLI Actions | Export Actions | "
        "Faster Interface | Action Advantage | Operational Cause |\n"
    )

    f.write(
        "|---|---:|---:|---:|---:|---:|---|---|---|\n"
    )

    for x in comparisons:

        f.write(
            f"| {x['scenario_id']} "
            f"| {x['cli_time']:.0f} "
            f"| {x['export_time']:.0f} "
            f"| {x['time_delta_cli_minus_export']:.0f} "
            f"| {x['cli_action_count']} "
            f"| {x['export_action_count']} "
            f"| {x['faster_interface']} "
            f"| {x['action_efficiency_advantage']} "
            f"| {x['operational_cause']} |\n"
        )

    f.write("\n## Summary\n\n")
    f.write(
        f"- **Scenarios Analyzed**: {summary['scenarios_analyzed']}\n"
    )
    f.write(
        f"- **Export Advantages**: {summary['export_advantages']}\n"
    )
    f.write(
        f"- **CLI Advantages**: {summary['cli_advantages']}\n"
    )
    f.write(
        f"- **Ties**: {summary['ties']}\n"
    )

PY

# ------------------------------------------------------------
# 5. Print final summary
# ------------------------------------------------------------

SCENARIOS=$(jq -r '.summary.scenarios_analyzed' "$JSON_OUT")
EXPORT_ADV=$(jq -r '.summary.export_advantages' "$JSON_OUT")
CLI_ADV=$(jq -r '.summary.cli_advantages' "$JSON_OUT")
TIES=$(jq -r '.summary.ties' "$JSON_OUT")

echo "scenarios analyzed   : $SCENARIOS"
echo "export advantages    : $EXPORT_ADV"
echo "cli advantages       : $CLI_ADV"
echo "ties                 : $TIES"
echo "comparison/tradeoff_table.json written"
echo "comparison/tradeoff_table.md written"
