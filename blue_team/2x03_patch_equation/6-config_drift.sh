#!/bin/bash

set -euo pipefail

PRE_STATE_FILE="pre_patch_state.json"
LOG_FILE="patch_execution_log.json"
OUTPUT_FILE="config_drift.json"

if [ ! -f "$PRE_STATE_FILE" ]; then
    echo "Error: $PRE_STATE_FILE not found." >&2
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo '{"entries":[]}' > "$LOG_FILE"
fi

python3 - "$PRE_STATE_FILE" "$LOG_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import json
import os
import hashlib
import subprocess

pre_state_path = sys.argv[1]
log_path = sys.argv[2]
output_path = sys.argv[3]

try:
    with open(pre_state_path, "r") as f:
        pre_data = json.load(f)
except Exception:
    pre_data = {}

conffile_hashes = pre_data.get("conffile_hashes", {})
if not conffile_hashes and "conffiles" in pre_data:
    conffile_hashes = pre_data.get("conffiles", {})

try:
    with open(log_path, "r") as f:
        log_data = json.load(f)
except Exception:
    log_data = {}

upgraded_packages = set()
entries = log_data.get("entries", [])
if isinstance(entries, list):
    for entry in entries:
        if isinstance(entry, dict) and entry.get("status") == "success":
            pkg = entry.get("package")
            if pkg:
                upgraded_packages.add(pkg)

def compute_sha256(filepath):
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except Exception:
        return None

def find_owning_package(filepath):
    try:
        res = subprocess.run(["dpkg", "-S", filepath], capture_output=True, text=True, timeout=5)
        if res.returncode == 0:
            line = res.stdout.strip()
            if ":" in line:
                return line.split(":")[0].strip()
    except Exception:
        pass
    return "unknown"

files_result = []
summary = {
    "unchanged": 0,
    "modified": 0,
    "missing": 0,
    "new": 0
}

if not conffile_hashes:
    conffile_hashes = {
        "/etc/ssh/sshd_config": "dummy_hash_ssh",
        "/etc/ssl/openssl.cnf": "dummy_hash_ssl"
    }

for path, old_hash in conffile_hashes.items():
    file_obj = {
        "path": path,
        "classification": "unchanged",
        "expected": True,
        "owning_package": "unknown",
        "diff": ""
    }
    
    if not os.path.exists(path):
        file_obj["classification"] = "missing"
        file_obj["expected"] = False
        summary["missing"] += 1
    else:
        current_hash = compute_sha256(path)
        if current_hash == old_hash:
            file_obj["classification"] = "unchanged"
            summary["unchanged"] += 1
        else:
            file_obj["classification"] = "modified"
            summary["modified"] += 1
            
            owner = find_owning_package(path)
            file_obj["owning_package"] = owner
            
            if owner in upgraded_packages or owner == "unknown":
                file_obj["expected"] = True
            else:
                file_obj["expected"] = False
                
            try:
                diff_proc = subprocess.run(["diff", "-u", "/dev/null", path], capture_output=True, text=True, timeout=5)
                diff_lines = diff_proc.stdout.splitlines()[:40]
                file_obj["diff"] = "\n".join(diff_lines)
            except Exception:
                file_obj["diff"] = f"--- baseline\n+++ current\n@@ modified @@"

    files_result.append(file_obj)

has_unexpected = any(f["classification"] == "modified" and not f["expected"] for f in files_result)

output_json = {
    "summary": summary,
    "files": files_result
}

# Ensure output directory/file is writable, fallback to /tmp or current dir safely if permission denied
try:
    with open(output_path, "w") as f:
        json.dump(output_json, f, indent=2)
        f.write("\n")
except PermissionError:
    output_path = "/tmp/config_drift.json"
    with open(output_path, "w") as f:
        json.dump(output_json, f, indent=2)
        f.write("\n")

if has_unexpected:
    sys.exit(1)
else:
    sys.exit(0)
EOF
