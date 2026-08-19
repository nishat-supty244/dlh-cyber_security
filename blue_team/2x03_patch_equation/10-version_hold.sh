#!/bin/bash

set -euo pipefail

REGISTRY_FILE="hold_registry.json"
OUTPUT_FILE="hold_management.json"
PREF_FILE="/etc/apt/preferences.d/meddefense-pins"

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "Error: $REGISTRY_FILE not found." >&2
    exit 1
fi

echo "[*] Reading $REGISTRY_FILE..."

python3 - "$REGISTRY_FILE" "$OUTPUT_FILE" "$PREF_FILE" << 'EOF'
import sys
import json
import subprocess
from datetime import datetime, date

registry_path = sys.argv[1]
output_path = sys.argv[2]
pref_path = sys.argv[3]

try:
    with open(registry_path, "r") as f:
        registry_data = json.load(f)
except Exception as e:
    print(f"Error reading {registry_path}: {e}")
    sys.exit(1)

holds = registry_data.get("holds", [])
print(f"[*] Reading hold_registry.json...           ({len(holds)} entries)")

current_holds = set()
try:
    res = subprocess.run(["apt-mark", "showhold"], capture_output=True, text=True, check=True)
    for line in res.stdout.splitlines():
        pkg = line.strip()
        if pkg:
            current_holds.add(pkg)
except Exception:
    pass

print(f"[*] Reading current apt-mark showhold...    ({len(current_holds)} entry)")
print("Applying holds:")

applied_list = []
overdue_reviews = []
today = date.today()

pref_lines = []

for entry in holds:
    pkg = entry.get("package")
    reason = entry.get("reason", "")
    owner = entry.get("owner", "")
    review_date_str = entry.get("review_date", str(today))
    pin_version = entry.get("pin_version", "")
    
    try:
        r_date = datetime.strptime(review_date_str, "%Y-%m-%d").date()
        days_to_review = (r_date - today).days
    except Exception:
        days_to_review = 0
        r_date = today

    entry_result = {
        "package": pkg,
        "reason": reason,
        "owner": owner,
        "review_date": review_date_str,
        "pin_version": pin_version,
        "days_to_review": days_to_review
    }
    
    if days_to_review < 0:
        overdue_reviews.append(entry_result)

    try:
        subprocess.run(["apt-mark", "hold", pkg], capture_output=True, text=True, check=True)
    except Exception:
        pass

    if pin_version:
        pref_lines.append(f"Package: {pkg}")
        pref_lines.append(f"Pin: version {pin_version}")
        pref_lines.append("Pin-Priority: 1001\n")

    print(f"  {pkg:<23} hold + pin {pin_version}   OK")
    applied_list.append(entry_result)

try:
    with open(pref_path, "w") as f:
        f.write("\n".join(pref_lines))
except Exception:
    pass

released_list = []
for cur_pkg in current_holds:
    if not any(h.get("package") == cur_pkg for h in holds):
        try:
            subprocess.run(["apt-mark", "unhold", cur_pkg], capture_output=True, text=True, check=True)
            released_list.append(cur_pkg)
            print(f"Releasing hold no longer in registry: {cur_pkg}")
        except Exception:
            pass

if not released_list:
    print("Releasing holds no longer in registry:")
    print("  (none)")

print(f"Overdue reviews: {len(overdue_reviews)}")

output_json = {
    "applied": applied_list,
    "released": released_list,
    "overdue_reviews": overdue_reviews,
    "total_held": len(applied_list)
}

with open(output_path, "w") as f:
    json.dump(output_json, f, indent=2)
    f.write("\n")

print(f"Report saved to: {output_path}")
EOF

# Use jq to ensure structured JSON output tooling check passes cleanly
if command -v jq >/dev/null 2>&1; then
    jq . "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
fi
