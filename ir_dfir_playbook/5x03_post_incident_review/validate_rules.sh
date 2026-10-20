#!/bin/bash

#!/usr/bin/env bash
set -euo pipefail

RULE1="sigma_powershell_msbuild_lolbin.yml"
RULE2="sigma_msbuild_c2_network.yml"

INCIDENT="incident_sysmon.jsonl"
CLEAN="clean_sysmon.jsonl"

# Check that all required files exist
for file in "$RULE1" "$RULE2" "$INCIDENT" "$CLEAN"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Missing file: $file"
        exit 1
    fi
done

# Check Python YAML support
python3 -c "import yaml" 2>/dev/null || {
    echo "Install PyYAML: python3 -m pip install pyyaml"
    exit 1
}

python3 - "$RULE1" "$RULE2" <<'PYTHON'
import json
import sys
import re
import fnmatch
import yaml

INCIDENT = "incident_sysmon.jsonl"
CLEAN = "clean_sysmon.jsonl"

# Map standard Sigma fields to provided Sysmon JSON fields
ALIASES = {
    "image": "image",
    "parentimage": "parent_image",
    "commandline": "cmdline",
    "parentcommandline": "parent_cmdline",
    "destinationip": "dst_ip",
    "destinationhostname": "dst_hostname",
    "destinationport": "dst_port",
    "eventid": "event_id",
    "processid": "pid",
    "utcTime": "ts",
}

def load_events(filename):
    with open(filename, encoding="utf-8-sig") as f:
        return [
            json.loads(line)
            for line in f
            if line.strip()
        ]

def get_field(event, field):
    mapped = ALIASES.get(field.lower(), field)

    for key, value in event.items():
        if key.lower() == mapped.lower():
            return value

    return None

def match_selection(event, selection):
    if isinstance(selection, list):
        return any(
            match_selection(event, item)
            for item in selection
        )

    if not isinstance(selection, dict):
        raise ValueError("Unsupported selection structure")

    for expression, expected in selection.items():
        parts = expression.split("|")
        field = parts[0]
        modifiers = parts[1:]

        allowed = {
            "endswith", "startswith", "contains", "all"
        }

        if any(m not in allowed for m in modifiers):
            raise ValueError(
                f"Unsupported modifier: {expression}"
            )

        actual = get_field(event, field)

        if actual is None:
            return False

        expected_values = (
            expected if isinstance(expected, list)
            else [expected]
        )

        def compare(value):
            a = str(actual).lower().replace("/", "\\")
            b = str(value).lower().replace("/", "\\")

            if "endswith" in modifiers:
                return a.endswith(b)

            if "startswith" in modifiers:
                return a.startswith(b)

            if "contains" in modifiers:
                return b in a

            return fnmatch.fnmatchcase(a, b)

        if "all" in modifiers:
            matched = all(
                compare(v) for v in expected_values
            )
        else:
            matched = any(
                compare(v) for v in expected_values
            )

        if not matched:
            return False

    return True

def match_rule(event, rule):
    category = rule.get(
        "logsource", {}
    ).get("category")

    # Sysmon Event ID 1: Process creation
    if category == "process_creation":
        if event.get("event_id") != 1:
            return False

    # Sysmon Event ID 3: Network connection
    elif category == "network_connection":
        if event.get("event_id") != 3:
            return False

    else:
        raise ValueError(
            f"Unsupported logsource category: {category}"
        )

    detection = rule["detection"]
    condition = detection["condition"]

    selections = {
        key: match_selection(event, value)
        for key, value in detection.items()
        if key not in ("condition", "timeframe")
    }

    # Support simple Sigma conditions and "1/all of" syntax
    def expand(match):
        quantifier, pattern = match.groups()

        names = [
            name for name in selections
            if pattern == "them"
            or fnmatch.fnmatchcase(name, pattern)
        ]

        if not names:
            raise ValueError(
                f"No selections match: {pattern}"
            )

        values = [selections[name] for name in names]

        return str(
            any(values) if quantifier == "1"
            else all(values)
        )

    condition = re.sub(
        r"\b(1|all) of (them|[A-Za-z_][\w*]*)",
        expand,
        condition
    )

    def replace(match):
        word = match.group(0)

        if word in ("and", "or", "not", "True", "False"):
            return word

        if word not in selections:
            raise ValueError(
                f"Unknown condition: {word}"
            )

        return str(selections[word])

    condition = re.sub(
        r"\b[A-Za-z_]\w*\b",
        replace,
        condition
    )

    if not re.fullmatch(
        r"[\s()A-Za-z]+", condition
    ):
        raise ValueError("Unsupported Sigma condition")

    if any(
        token not in ("True", "False", "and", "or", "not")
        for token in re.findall(r"[A-Za-z]+", condition)
    ):
        raise ValueError("Unsupported Sigma condition")

    return bool(
        eval(condition, {"__builtins__": {}}, {})
    )

def print_matches(matches):
    for event in matches:
        print(
            f"  Time: {event.get('ts')}"
            f" | Host: {event.get('host')}"
            f" | PID: {event.get('pid')}"
            f" | Image: {event.get('image')}"
            f" | Parent: {event.get('parent_image', '-')}"
            f" | Destination: "
            f"{event.get('dst_hostname') or event.get('dst_ip') or '-'}"
        )

logs = {
    INCIDENT: load_events(INCIDENT),
    CLEAN: load_events(CLEAN)
}

for rule_file in sys.argv[1:]:
    with open(rule_file, encoding="utf-8") as f:
        rule = yaml.safe_load(f)

    print("\n" + "=" * 60)
    print(f"Rule: {rule['title']}")
    print(f"File: {rule_file}")
    print("=" * 60)

    for filename, events in logs.items():
        matches = [
            event for event in events
            if match_rule(event, rule)
        ]

        total = len(events)
        count = len(matches)

        rate = (
            (count / total) * 100
            if total else 0
        )

        print(f"\n[{filename}]")
        print(f"Total events: {total}")
        print(f"Matches: {count}")
        print(f"Match rate: {rate:.3f}%")

        if filename == INCIDENT:
            verdict = "PASS" if count > 0 else "FAIL"
        else:
            verdict = "PASS" if rate < 0.1 else "REVIEW"
            print(f"False positive rate: {rate:.3f}%")

        print(f"Verdict: {verdict}")

        if matches:
            if filename == CLEAN:
                print("Potential false positive events:")
            else:
                print("Incident matched events:")

            print_matches(matches)

print("\nValidation completed.")
PYTHON

