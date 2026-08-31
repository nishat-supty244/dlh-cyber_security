#!/usr/bin/env python3
import json
import os
import subprocess
import re

script_dir = os.path.dirname(os.path.abspath(__file__))
capstone_dir = os.path.join(script_dir, "capstone")
exec_dir = os.path.join(capstone_dir, "exec")
os.makedirs(exec_dir, exist_ok=True)

json_report_path = os.path.join(exec_dir, "validation_report.json")
log_file_path = os.path.join(exec_dir, "validate_all.log")

# Locate target_state.json dynamically
possible_paths = [
    os.path.join(script_dir, "target_state.json"),
    os.path.join(capstone_dir, "target_state.json"),
    "/home/analyst/MedDefense_Lab/capstone/target_state.json"
]

target_state_path = next((p for p in possible_paths if os.path.exists(p)), None)

if not target_state_path:
    print("Error: target_state.json not found in any expected paths.")
    exit(2)

try:
    with open(target_state_path, "r") as f:
        data = json.load(f)
except Exception as e:
    print(f"Error loading target state JSON from {target_state_path}: {e}")
    exit(1)

controls = data.get("controls", [])
results = []
total_controls = len(controls)
pass_count = 0
fail_count = 0
error_count = 0
family_stats = {}

for ctrl in controls:
    cid = ctrl.get("id", "UNKNOWN")
    family = ctrl.get("family", "GENERAL")
    check_type = ctrl.get("check_type")
    check_target = ctrl.get("check_target", "")
    expected = ctrl.get("expected_value")
    field = ctrl.get("field")

    if family not in family_stats:
        family_stats[family] = {"total": 0, "pass": 0, "fail": 0, "error": 0}
    family_stats[family]["total"] += 1

    verdict = "fail"
    evidence = ""

    try:
        if check_type == "file_exists":
            if os.path.exists(check_target):
                verdict = "pass"
                evidence = f"Path exists: {check_target}"
            else:
                verdict = "fail"
                evidence = f"Path not found: {check_target}"
        elif check_type == "json_field_equals":
            if os.path.exists(check_target):
                with open(check_target, "r") as jf:
                    jdata = json.load(jf)
                val = jdata.get(field)
                if val == expected:
                    verdict = "pass"
                    evidence = f"Field '{field}' equals expected value: {expected}"
                else:
                    verdict = "fail"
                    evidence = f"Field '{field}' value '{val}' does not match expected '{expected}'"
            else:
                verdict = "error"
                evidence = f"JSON file missing for check: {check_target}"
        elif check_type == "json_field_gte":
            if os.path.exists(check_target):
                with open(check_target, "r") as jf:
                    jdata = json.load(jf)
                val = jdata.get(field, 0)
                if val >= expected:
                    verdict = "pass"
                    evidence = f"Field '{field}' value {val} >= expected {expected}"
                else:
                    verdict = "fail"
                    evidence = f"Field '{field}' value {val} < expected {expected}"
            else:
                verdict = "error"
                evidence = f"JSON file missing for check: {check_target}"
        elif check_type == "command_exit_zero":
            res = subprocess.run(check_target, shell=True, capture_output=True, text=True)
            if res.returncode == 0:
                verdict = "pass"
                evidence = f"Command exited 0: {check_target}"
            else:
                verdict = "fail"
                evidence = f"Command exited {res.returncode}: {check_target}"
        elif check_type == "grep_match":
            if os.path.exists(check_target):
                with open(check_target, "r") as gf:
                    content = gf.read()
                if re.search(str(expected), content):
                    verdict = "pass"
                    evidence = f"Found pattern '{expected}' in {check_target}"
                else:
                    verdict = "fail"
                    evidence = f"Pattern '{expected}' not found in {check_target}"
            else:
                verdict = "error"
                evidence = f"File missing for grep check: {check_target}"
        else:
            verdict = "error"
            evidence = f"Unknown check_type: {check_type}"
    except Exception as e:
        verdict = "error"
        evidence = f"Exception during evaluation: {str(e)}"

    if verdict == "pass":
        pass_count += 1
        family_stats[family]["pass"] += 1
    elif verdict == "fail":
        fail_count += 1
        family_stats[family]["fail"] += 1
    else:
        error_count += 1
        family_stats[family]["error"] += 1

    results.append({
        "id": cid,
        "family": family,
        "check_type": check_type,
        "verdict": verdict,
        "evidence": evidence
    })

pass_percentage = (pass_count / total_controls * 100) if total_controls > 0 else 0.0

report = {
    "hostname": "hawthorne-app-01",
    "summary": {
        "total_controls": total_controls,
        "pass_count": pass_count,
        "fail_count": fail_count,
        "error_count": error_count,
        "pass_percentage": round(pass_percentage, 2)
    },
    "family_breakdown": family_stats,
    "controls": results
}

with open(json_report_path, "w") as rf:
    json.dump(report, rf, indent=2)

print("\n--- CONTROL FAMILY SUMMARY ---")
print(f"{'FAMILY':<25} | {'TOTAL':<6} | {'PASS':<6} | {'FAIL':<6} | {'ERROR':<6}")
print("-" * 55)
for fam, stats in family_stats.items():
    print(f"{fam:<25} | {stats['total']:<6} | {stats['pass']:<6} | {stats['fail']:<6} | {stats['error']:<6}")
print("-" * 55)
print(f"Overall: {pass_count}/{total_controls} passed ({pass_percentage:.1f}%)\n")

if fail_count > 0 or error_count > 0:
    exit(1)
else:
    exit(0)
