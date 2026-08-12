#!/bin/bash

set -uo pipefail

PLAN_FILE="patch_plan.json"
LOG_FILE="patch_execution_log.json"
LOCK_FILE="/var/lock/meddefense-patch.lock"

if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file $PLAN_FILE not found." >&2
    exit 1
fi

python3 - "$PLAN_FILE" "$LOG_FILE" "$LOCK_FILE" << 'EOF'
import sys
import os
import json
import time
import subprocess
import hashlib
import socket
import fcntl

plan_path = sys.argv[1]
log_path = sys.argv[2]
lock_path = sys.argv[3]

# Acquire advisory lock
lock_fd = None
try:
    print("[*] Acquiring lock /var/lock/meddefense-patch.lock... ", end="", flush=True)
    lock_fd = open(lock_path, "w")
    
    # Try locking with exponential backoff if busy
    acquired = False
    delay = 1
    total_wait = 0
    while total_wait < 120:
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            acquired = True
            break
        except BlockingIOError:
            time.sleep(delay)
            total_wait += delay
            delay = min(delay * 2, 15)
            
    if not acquired:
        print("FAILED (Lock busy)")
        sys.exit(2)
    print("OK")
except Exception as e:
    print(f"FAILED ({e})")
    sys.exit(2)

def cleanup_lock():
    if lock_fd:
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_UN)
            lock_fd.close()
        except Exception:
            pass

# Ensure lock is released on exit
import atexit
atexit.register(cleanup_lock)

# Load plan
try:
    with open(plan_path, "r") as f:
        plan_data = json.load(f)
except Exception as e:
    print(f"Error loading plan: {e}")
    sys.exit(1)

plan_entries = plan_data.get("plan", [])
if isinstance(plan_data, list):
    plan_entries = plan_data

print(f"[*] Loading plan: {plan_path} ({len(plan_entries)} entries)")

# Compute plan source hash
plan_hash = ""
try:
    with open(plan_path, "rb") as f:
        plan_hash = hashlib.sha256(f.read()).hexdigest()
except Exception:
    pass

started_at = int(time.time())
hostname = socket.gethostname()

execution_entries = []
succeeded_count = 0
failed_count = 0
any_failed = False

def get_installed_version(pkg):
    try:
        res = subprocess.run(["dpkg-query", "-W", "-f=${Version}", pkg], capture_output=True, text=True)
        if res.returncode == 0:
            return res.stdout.strip()
    except Exception:
        pass
    return "unknown"

def get_service_state(svc):
    try:
        res = subprocess.run(["systemctl", "show", svc, "-p", "ActiveState,SubState,MainPID", "--no-ambiguous"], capture_output=True, text=True)
        state = {"ActiveState": "unknown", "SubState": "unknown", "MainPID": "0"}
        for line in res.stdout.splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                state[k.strip()] = v.strip()
        return state
    except Exception:
        return {"ActiveState": "unknown", "SubState": "unknown", "MainPID": "0"}

for idx, entry in enumerate(plan_entries, 1):
    pkg = entry.get("package", "")
    bucket = entry.get("bucket", "scheduled")
    affected_services = entry.get("affected_services", [])
    requires_restart = entry.get("requires_restart", False)
    
    # Record pre block
    pre_installed_version = get_installed_version(pkg)
    pre_service_states = {svc: get_service_state(svc) for svc in affected_services if svc != "(kernel-wide)"}
    
    pre_block = {
        "installed_version": pre_installed_version,
        "service_states": pre_service_states
    }
    
    print(f"[{idx}/{len(plan_entries)}] {pkg:<21} {bucket:<13} apt-get ... ", end="", flush=True)
    
    start_time = time.time()
    
    # Handle dpkg lock / apt run with exponential backoff for lock contention
    apt_success = False
    exit_status = 1
    stdout_text = ""
    stderr_text = ""
    
    apt_delay = 2
    apt_wait = 0
    while apt_wait < 120:
        env = os.environ.copy()
        env["DEBIAN_FRONTEND"] = "noninteractive"
        
        proc = subprocess.run(
            ["apt-get", "install", "--only-upgrade", "-y", pkg],
            capture_output=True, text=True, env=env
        )
        exit_status = proc.returncode
        stdout_text = proc.stdout
        stderr_text = proc.stderr
        
        if exit_status == 0:
            apt_success = True
            break
        elif "E: Could not get lock" in stderr_text or "Resource temporarily unavailable" in stderr_text:
            time.sleep(apt_delay)
            apt_wait += apt_delay
            apt_delay = min(apt_delay * 2, 30)
        else:
            break

    duration = round(time.time() - start_time, 1)
    
    if apt_success:
        print(f"OK ({duration}s)")
    else:
        print(f"FAILED (Exit: {exit_status})")
        failed_count += 1
        any_failed = True

    # Restart services if required and no kernel/reboot needed
    restart_results = {}
    if apt_success and requires_restart and affected_services:
        for svc in affected_services:
            if svc == "(kernel-wide)":
                continue
            print(f"      try-restart {svc:<27} ", end="", flush=True)
            try:
                res = subprocess.run(["systemctl", "try-restart", svc], capture_output=True, text=True)
                if res.returncode == 0:
                    print("OK")
                    restart_results[svc] = "OK"
                else:
                    print("FAILED")
                    restart_results[svc] = "FAILED"
            except Exception:
                print("FAILED")
                restart_results[svc] = "FAILED"

    if apt_success:
        succeeded_count += 1

    # Record post block
    post_installed_version = get_installed_version(pkg)
    post_service_states = {svc: get_service_state(svc) for svc in affected_services if svc != "(kernel-wide)"}
    
    post_block = {
        "installed_version": post_installed_version,
        "service_states": post_service_states
    }

    execution_entries.append({
        "package": pkg,
        "pre": pre_block,
        "post": post_block,
        "status": "success" if apt_success else "failed",
        "exit_status": exit_status,
        "duration_seconds": duration,
        "stdout_tail": "\n".join(stdout_text.splitlines()[-10:]),
        "stderr_tail": "\n".join(stderr_text.splitlines()[-10:]),
        "restart_results": restart_results
    })

    if not apt_success:
        # Stop loop on failure as instructed
        break

finished_at = int(time.time())

log_data = {
    "started_at": started_at,
    "finished_at": finished_at,
    "hostname": hostname,
    "plan_source_hash": plan_hash,
    "entries": execution_entries
}

with open(log_path, "w") as f:
    json.dump(log_data, f, indent=2)
    f.write("\n")

print(f"Succeeded: {succeeded_count}  Failed: {failed_count}")
print(f"Log saved to: {log_path}")

if any_failed:
    sys.exit(1)
else:
    sys.exit(0)
EOF
