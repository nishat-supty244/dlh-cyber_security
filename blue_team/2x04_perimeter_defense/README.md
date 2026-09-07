
# Suricata Setup — Simple Explanation

## What are these variables?

These lines create **variables** that store the locations of files and folders.

Instead of repeatedly typing long paths, we give each path a short name.

---

## 1. `RULES_SRC`

```bash
RULES_SRC="/home/analyst/MedDefense_Lab/suricata/rules"
```

### Meaning

This tells the script:

> **Where are the original Suricata rules?**

The rules are located here:

```text
/home/analyst/MedDefense_Lab/suricata/rules
```

Think:

```text
RULES_SRC = Take the rules FROM here
```

---

## 2. `RULES_DEST`

```bash
RULES_DEST="/var/lib/suricata/rules"
```

### Meaning

This tells the script:

> **Where should the Suricata rules be copied?**

The destination is:

```text
/var/lib/suricata/rules
```

Think:

```text
RULES_SRC
    ↓
  copy rules
    ↓
RULES_DEST
```

So:

```text
/home/analyst/MedDefense_Lab/suricata/rules
                    ↓
              COPY THE RULES
                    ↓
/var/lib/suricata/rules
```

---

## 3. `CONFIG_FILE`

```bash
CONFIG_FILE="suricata.yaml"
```

### Meaning

This tells the script:

> **The Suricata configuration file is called `suricata.yaml`.**

Instead of writing:

```bash
suricata -c suricata.yaml
```

the script can use:

```bash
suricata -c "$CONFIG_FILE"
```

This makes the script easier to maintain.

---

## 4. `SMOKE_PCAP`

```bash
SMOKE_PCAP="/home/analyst/MedDefense_Lab/PCAPs/smoke.pcap"
```

### Meaning

This tells the script:

> **This is the test network-traffic recording that Suricata should analyze.**

The file is:

```text
smoke.pcap
```

A PCAP is a **recording of network packets/traffic**.

So:

```text
smoke.pcap
     ↓
  Suricata
     ↓
Analyze the recorded traffic
     ↓
Generate alerts
```

The PCAP is part of the MedDefense lab. Suricata does not connect to a real MedDefense network.

---

## 5. `SMOKE_DIR`

```bash
SMOKE_DIR="/tmp/suricata-smoke"
```

### Meaning

This tells the script:

> **Where should Suricata put the results of the smoke test?**

The results will go into:

```text
/tmp/suricata-smoke/
```

For example:

```text
/tmp/suricata-smoke/eve.json
```

`eve.json` contains Suricata's detected events and alerts.

---

# Easy way to remember

These five variables answer five simple questions:

| Variable      | Question it answers                     |
| ------------- | --------------------------------------- |
| `RULES_SRC`   | Where are my rules?                     |
| `RULES_DEST`  | Where should I put the rules?           |
| `CONFIG_FILE` | What is my Suricata configuration file? |
| `SMOKE_PCAP`  | Which PCAP should I test?               |
| `SMOKE_DIR`   | Where should I save the test results?   |

---

# Overall Flow

```text
MedDefense Rules
      ↓
RULES_SRC
      ↓
Copy rules
      ↓
RULES_DEST
      ↓
Suricata uses
suricata.yaml
      ↓
SMOKE_PCAP
(smoke.pcap)
      ↓
   Suricata
      ↓
Analyze network traffic
      ↓
SMOKE_DIR
      ↓
   eve.json
      ↓
   🚨 Alerts
```

## One-line summary

> **These variables simply tell the script where to find the Suricata rules, where to put them, which configuration to use, which PCAP to analyze, and where to save the results.**
