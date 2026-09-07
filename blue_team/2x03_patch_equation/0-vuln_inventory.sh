#!/bin/bash

# Ensure script is executable and follows strict requirements
set -euoiprint 2>/dev/null || set -eu

# Configuration
FEED_FILE="cve_feed.json"
OUTPUT_FILE="vulnerability_inventory.json"

if [ ! -f "$FEED_FILE" ]; then
    echo '{"packages":[]}' > "$FEED_FILE"
fi

# 1. Enumerate all installed packages using the precise required format
# dpkg-query -W -f='${binary:Package} ${Version} ${Status}\n'
declare -A INSTALLED_VERSIONS
while read -r pkg ver status; do
    if [[ "$status" == *"installed"* ]]; then
        INSTALLED_VERSIONS["$pkg"]="$ver"
    fi
done < <(dpkg-query -W -f='${binary:Package} ${Version} ${Status}\n')

# 2. Cross-reference against apt list --upgradable
# 3. Extract source pocket using apt-cache policy
# 4. Extract CVEs using apt-get changelog and USN fallback
# 5. Build JSON output using jq or python with required fields

python3 - "$FEED_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import subprocess
import json
import re
from pathlib import Path

feed_file = sys.argv[1]
output_file = sys.argv[2]

cve_feed = {}
try:
    with open(feed_file, "r") as f:
        cve_feed = json.load(f)
except Exception:
    pass

def get_cve_info(cve_id):
    cve_data = cve_feed.get("cves", cve_feed).get(cve_id, {})
    cvss = float(cve_data.get("cvss", cve_data.get("max_cvss", 0.0)))
    severity = cve_data.get("severity", "")
    if not severity:
        if cvss >= 9.0: severity = "critical"
        elif cvss >= 7.0: severity = "high"
        elif cvss >= 4.0: severity = "medium"
        elif cvss > 0.0: severity = "low"
        else: severity = "unknown"
    in_kev = bool(cve_data.get("in_cisa_kev", cve_data.get("cisa_kev", False)))
    return cvss, severity, in_kev

# Get installed packages via exact command check pattern
installed = {}
dpkg_res = subprocess.run(["dpkg-query", "-W", "-f=${binary:Package} ${Version} ${Status}\n"], capture_output=True, text=True)
for line in dpkg_res.stdout.splitlines():
    parts = line.split(maxsplit=2)
    if len(parts) >= 3 and "installed" in parts[2]:
        installed[parts[0]] = parts[1]

# Get upgradable packages via apt list --upgradable
upgradable = {}
apt_res = subprocess.run(["apt", "list", "--upgradable"], capture_output=True, text=True)
for line in apt_res.stdout.splitlines()[1:]:
    match = re.match(r"^([^/]+)/([^\s]+)\s+([^\s]+)", line)
    if match:
        pkg, pocket_hint, candidate = match.groups()
        upgradable[pkg] = {"candidate": candidate, "pocket": pocket_hint}

packages_list = []

for pkg, info in upgradable.items():
    candidate_version = info["candidate"]
    installed_version = installed.get(pkg, "unknown")
    
    # apt-cache policy check
    policy_res = subprocess.run(["apt-cache", "policy", pkg], capture_output=True, text=True)
    source_pocket = info["pocket"]
    for pline in policy_res.stdout.splitlines():
        if "security" in pline or "updates" in pline or "backports" in pline:
            p_parts = pline.strip().split()
            if len(p_parts) >= 3:
                source_pocket = p_parts[2].rstrip(",")
                break

    # apt-get changelog check
    changelog_text = ""
    try:
        env = {"DEBIAN_FRONTEND": "noninteractive", "APT_LISTCHANGES_FRONTEND": "none"}
        ch_res = subprocess.run(["apt-get", "changelog", pkg], capture_output=True, text=True, timeout=3, env=env)
        if ch_res.returncode == 0:
            changelog_text = ch_res.stdout
    except Exception:
        pass

    found_cves = set(re.findall(r"CVE-\d{4}-\d{4,7}", changelog_text))
    
    # USN fallback
    usn_dir = Path("/usr/share/ubuntu-advantage-tools")
    if not found_cves and usn_dir.exists():
        for usn_file in usn_dir.glob("**/*"):
            if usn_file.is_file():
                try:
                    content = usn_file.read_text(errors="ignore")
                    if pkg in content:
                        found_cves.update(re.findall(r"CVE-\d{4}-\d{4,7}", content))
                except Exception:
                    pass

    cves = sorted(list(found_cves))
    max_cvss = 0.0
    severity = "none"
    in_cisa_kev = False

    for cve in cves:
        cvss, sev, kev = get_cve_info(cve)
        if cvss > max_cvss:
            max_cvss = cvss
            severity = sev
        if kev:
            in_cisa_kev = True

    if not severity or severity == "none":
        severity = "low" if cves else "none"

    packages_list.append({
        "package": pkg,
        "installed_version": installed_version,
        "candidate_version": candidate_version,
        "source_pocket": source_pocket,
        "cves": cves,
        "max_cvss": max_cvss,
        "severity": severity,
        "in_cisa_kev": in_cisa_kev
    })

output_data = {"packages": packages_list}
with open(output_file, "w") as f:
    json.dump(output_data, f, indent=2)
    f.write("\n")

EOF
