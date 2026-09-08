# Detection Engineering Fundamentals

## Q1. What are the four main types of detection?

**Answer:** The four main detection types are:

1. **Signature detection** – looks for known malicious patterns or indicators.
2. **Anomaly detection** – looks for activity that is unusual compared with normal behavior.
3. **Behavioral detection** – looks for suspicious sequences or patterns of actions.
4. **Correlation detection** – combines multiple related events or data sources to identify suspicious activity.

---

## Q2. What is signature detection?

**Answer:** Signature detection looks for a **specific, known pattern** associated with malicious activity.

For example, detecting a known malicious file name, IP address, hash, or command.

```text
IF process_name = "mimikatz.exe"
THEN alert
