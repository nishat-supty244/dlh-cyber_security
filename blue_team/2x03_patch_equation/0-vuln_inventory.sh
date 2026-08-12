#!/usr/bin/env bash
#
# 0-vuln_inventory.sh - Enumerates installed packages, cross-references upgradable
# packages with security pockets, extracts CVEs safely without interactive prompts,
# evaluates severity against cve_feed.json, and outputs vulnerability_inventory.json.
#

set -euo pipefail

for cmd in python3 jq dpkg-query apt-cache; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: Required command '$cmd' is not installed." >&2
        exit 1
    fi
done

FEED_FILE="cve_feed.json"
OUTPUT_FILE="vulnerability_inventory.json"

if [ ! -f "$FEED_FILE" ]; then
    echo '{"cves": {}}' > "$FEED_FILE"
fi

python3 - << 'EOF'
import json
import subprocess
import os
import re
import urllib.request
from pathlib import Path

FEED_FILE = "cve_feed.json"
OUTPUT_FILE = "vulnerability_inventory.json"

cve_feed = {}
if os.path.exists(FEED_FILE):
    try:
        with open(FEED_FILE, "r") as f:
            cve_feed = json.load(f)
    except Exception:
        cve_feed = {}

def get_cve_details(cve_id):
    cve_data = cve_feed.get("cves", cve_feed).get(cve_id, {})
    cvss = cve_data.get("cvss", cve_data.get("max_cvss", 0.0))
    try:
        cvss = float(cvss)
    except (ValueError, TypeError):
        cvss = 0.0
    
    severity = cve_data.get("severity", "")
    if not severity:
        if cvss >= 9.0:
            severity = "critical"
        elif cvss >= 7.0:
            severity = "high"
        elif cvss >= 4.0:
            severity = "medium"
        elif cvss > 0.0:
            severity = "low"
        else:
            severity = "unknown"
            
    in_kev = cve_data.get("in_cisa_kev", cve_data.get("cisa_kev", False))
    return cvss, severity, bool(in_kev)

# 1. Enumerate all installed packages
installed_packages = {}
dpkg_cmd = ["dpkg-query", "-W", "-f=${binary:Package} ${Version} ${Status}\n"]
res = subprocess.run(dpkg_cmd, capture_output=True, text=True, check=True)
for line in res.stdout.splitlines():
    parts = line.split()
    if len(parts) >= 3:
        pkg, ver, status = parts[0], parts[1], " ".join(parts[2:])
        if "installed" in status:
            installed_packages[pkg] = ver

# 2. Cross-reference against apt list --upgradable
upgradable_packages = {}
apt_list_cmd = ["apt", "list", "--upgradable"]
res = subprocess.run(apt_list_cmd, capture_output=True, text=True)
lines = res.stdout.splitlines()[1:]
for line in lines:
    match = re.match(r"^([^/]+)/([^\s]+)\s+([^\s]+)", line)
    if match:
        pkg, pocket_info, candidate_ver = match.groups()
        upgradable_packages[pkg] = {
            "candidate_version": candidate_ver,
            "pocket_hint": pocket_info
        }

vulnerability_list = []

# 3. For each upgradable package, inspect policy, pocket, and CVEs
for pkg, info in upgradable_packages.items():
    installed_ver = installed_packages.get(pkg, "unknown")
    candidate_ver = info["candidate_version"]
    
    policy_res = subprocess.run(["apt-cache", "policy", pkg], capture_output=True, text=True)
    source_pocket = "unknown"
    for pline in policy_res.stdout.splitlines():
        if "security" in pline or "updates" in pline or "backports" in pline:
            parts = pline.strip().split()
            if len(parts) >= 3:
                source_pocket = parts[2].rstrip(",")
                break
    if source_pocket == "unknown":
        source_pocket = info["pocket_hint"]

    cves = set()
    
    # Non-interactive changelog retrieval via URL or fallback environment
    changelog_text = ""
    try:
        # Construct Ubuntu changelog URL convention: https://changelogs.ubuntu.com/changelogs/pool/main/p/pkg/pkg_version/changelog
        # Or query via apt-get with non-interactive environment variables
        env = os.environ.copy()
        env["DEBIAN_FRONTEND"] = "noninteractive"
        env["APT_LISTCHANGES_FRONTEND"] = "none"
        
        ch_res = subprocess.run(
            ["apt-get", "changelog", f"{pkg}"],
            capture_output=True, text=True, timeout=3, env=env
        )
        if ch_res.returncode == 0:
            changelog_text = ch_res.stdout
    except Exception:
        pass

    # Extract CVEs from changelog output
    found_cves = set(re.findall(r"CVE-\d{4}-\d{4,7}", changelog_text))
    
    # Fallback to local USN mapping if present
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
        cvss, sev, kev = get_cve_details(cve)
        if cvss > max_cvss:
            max_cvss = cvss
            severity = sev
        if kev:
            in_cisa_kev = True

    if not severity or severity == "none":
        severity = "low" if cves else "none"

    vulnerability_list.append({
        "package": pkg,
        "installed_version": installed_ver,
        "candidate_version": candidate_ver,
        "source_pocket": source_pocket,
        "cves": cves,
        "max_cvss": max_cvss,
        "severity": severity,
        "in_cisa_kev": in_cisa_kev
    })

output_data = {"packages": vulnerability_list}
with open(OUTPUT_FILE, "w") as f:
    json.dump(output_data, f, indent=2)
    f.write("\n")

print(f"Vulnerability inventory successfully written to {OUTPUT_FILE}")
EOF
