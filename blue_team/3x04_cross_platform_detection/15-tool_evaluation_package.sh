#!/bin/bash
set -euo pipefail

PKG_DIR="tool_evaluation"

# Idempotent cleanup and directory creation
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR"/{findings,rules/wazuh,comparison/questions,playbook,brief,workspace,runtime}

# 1. Define mandatory files by category
FINDINGS=(
    "findings/anchor_cli.json" "findings/anchor_export.json"
    "findings/scenario_a_cli.json" "findings/scenario_a_export.json"
    "findings/scenario_b_cli.json" "findings/scenario_b_export.json"
    "findings/scenario_c_cli.json" "findings/scenario_c_export.json"
)

RULES=(
    "rules/wazuh/001_ssh_brute_force.xml"
    "rules/wazuh/003_interpreter_abuse.xml"
    "rules/wazuh/010_credential_theft_chain.xml"
    "rules/wazuh/translation_report.json"
)

COMPARISON=(
    "comparison/questions/q1.yml"
    "comparison/questions/q2.yml"
    "comparison/questions/q3.yml"
    "comparison/questions/q4.yml"
    "comparison/query_comparison.json"
    "comparison/tradeoff_table.json"
    "comparison/tradeoff_table.md"
    "comparison/workflow_comparison.json"
)

PLAYBOOK=("playbook/tool_agnostic_playbook.md")
BRIEF=("brief/vendor_brief.md")
WORKSPACE=("workspace/workspace_init.json")

# Gather all runtime scripts dynamically
RUNTIME=()
for script in [0-1]*.sh; do
    if [[ -f "$script" ]]; then
        RUNTIME+=("$script")
    fi
done

# 2. Helper function to validate and copy files
copy_files() {
    local category="$1"
    shift
    local files=("$@")
    local count=0

    for src in "${files[@]}"; do
        if [[ ! -s "$src" ]]; then
            echo "ERROR: Required file missing or empty: $src" >&2
            exit 1
        fi
        
        local dest="$PKG_DIR/$src"
        if [[ "$category" == "runtime" ]]; then
            dest="$PKG_DIR/runtime/$(basename "$src")"
        fi
        
        cp "$src" "$dest"
        ((count++))
    done
    printf "copying %-10s ... %d files\n" "$category" "$count"
}

# 3. Execute copies
copy_files "findings" "${FINDINGS[@]}"
copy_files "rules" "${RULES[@]}"
copy_files "comparison" "${COMPARISON[@]}"
copy_files "playbook" "${PLAYBOOK[@]}"
copy_files "brief" "${BRIEF[@]}"
copy_files "workspace" "${WORKSPACE[@]}"
copy_files "runtime" "${RUNTIME[@]}"

# 4. Generate MANIFEST.json with sha256 hashes
echo -n "MANIFEST.json      : "
cd "$PKG_DIR"

MANIFEST_ENTRIES=()
while IFS= read -r -d '' file; do
    rel_path="${file#./}"
    size=$(stat -c%s "$rel_path")
    hash=$(sha256sum "$rel_path" | awk '{print $1}')
    MANIFEST_ENTRIES+=("{\"path\": \"$rel_path\", \"size\": $size, \"sha256\": \"$hash\"}")
done < <(find . -type f -not -name "MANIFEST.json" -print0 | sort -z)

# Output valid JSON array and wrap it using jq
printf "%s\n" "${MANIFEST_ENTRIES[@]}" | jq -s '{
  "package": "tool_evaluation",
  "generated_at": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "files": .
}' > MANIFEST.json

ENTRY_COUNT=$(jq '.files | length' MANIFEST.json)
echo "$ENTRY_COUNT entries"

# 5. Final check
if [[ "$ENTRY_COUNT" -gt 0 ]]; then
    echo "sanity check       : ok"
else
    echo "ERROR: Manifest sanity check failed." >&2
    exit 1
fi

cd ..
echo "tool_evaluation/ ready"
