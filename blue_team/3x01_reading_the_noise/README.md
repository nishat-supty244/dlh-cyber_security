# Learning Objectives — Questions & Answers

## 1. Log Reading and Format Literacy

### Q1. How do you identify, enumerate, and profile every source type present in a normalized security dataset?

**Answer:**

First, inspect the normalized dataset and identify the field that represents the **source type** or **log source**. Then enumerate all unique source values.

For each source type, profile:

- Number of events
- Fields present
- Fields frequently populated
- Example values
- Time range
- Event types or actions

This reveals what sources exist and what kind of security information each source provides.

---

### Q2. How can field presence, field cardinality, and example values reveal the operational role of a log source?

**Answer:**

The fields available in a source provide clues about what the source records.

- **Field presence** tells you what information the source can provide.
- **Field cardinality** tells you how many different values appear in a field.
- **Example values** show what those values actually represent.

For example, a source containing `src_ip`, `dst_ip`, `dst_port`, and `protocol` is likely a **network telemetry source**, while a source containing `username`, `logon_type`, and `authentication_status` is likely an **authentication source**.

---

### Q3. How do you build a reusable CLI query toolkit for a flat JSON dataset without a SIEM?

**Answer:**

Create command-line scripts that can repeatedly perform common operations such as:

- Filtering events by source, host, user, or time
- Counting events
- Grouping events by fields
- Finding unique values
- Sorting results
- Pivoting from one field to another
- Searching for suspicious activity

Tools such as `jq`, `awk`, `grep`, and shell scripts can provide basic SIEM-like analytical capabilities directly against JSON data.

---

# 2. Behavioral Baselining

### Q4. What is a behavioral baseline?

**Answer:**

A behavioral baseline is a mathematical description of what **normal activity** looks like for a system, user, host, or environment over a period of historical data.

It provides a reference point that allows analysts to identify activity that significantly differs from normal behavior.

---

### Q5. Why is a behavioral baseline the foundation of anomaly detection?

**Answer:**

Anomaly detection needs to know what **normal** looks like before it can identify something abnormal.

The baseline establishes normal patterns such as:

- Typical login counts
- Normal processes
- Usual network connections
- Expected file activity
- Normal activity times

Without a baseline, it is difficult to determine whether an observed event is unusual.

---

### Q6. How is a behavioral baseline different from a static threshold?

**Answer:**

A **static threshold** uses a fixed value, such as:

> Alert if there are more than 20 logins.

A **behavioral baseline** adapts to historical behavior, such as:

> This server normally has 3–5 logins per hour, but it suddenly had 40.

Static thresholds are simple but may generate false positives because different systems naturally have different activity levels.

Behavioral baselines are more context-aware.

---

### Q7. How do you compute an authentication baseline from historical normalized data?

**Answer:**

Group historical authentication events by relevant dimensions such as:

- Host
- User
- Authentication type
- Time of day
- Day of week

Then calculate statistics such as:

- Average event count
- Median
- Minimum and maximum
- Standard deviation
- Typical successful/failed login ratio

These statistics form the authentication baseline.

---

### Q8. How do you compute a process baseline?

**Answer:**

Analyze historical process events and determine which processes normally execute on each host.

Useful measurements include:

- Process execution frequency
- Unique process names
- Parent-child process relationships
- Command-line patterns
- Execution times
- Users launching processes

For example, if `powershell.exe` normally runs five times per day on a server but suddenly runs hundreds of times, the deviation may be anomalous.

---

### Q9. How do you compute a network baseline?

**Answer:**

Analyze historical network events and establish normal patterns for:

- Source and destination IPs
- Ports
- Protocols
- Connection frequency
- Bytes transferred
- External destinations
- Network services

For example, a server that normally communicates only with internal systems but suddenly starts making repeated connections to an unfamiliar external IP may deviate from its baseline.

---

### Q10. How do you compute a file baseline?

**Answer:**

Analyze historical file activity and determine normal patterns such as:

- Files created
- Files modified
- Files deleted
- File paths
- File extensions
- Users performing the activity
- Frequency of changes

This allows unusual file activity to be detected later.

---

### Q11. How do you compute a temporal baseline?

**Answer:**

A temporal baseline describes **when activity normally occurs**.

Analyze activity according to:

- Hour of day
- Day of week
- Business hours
- Weekends
- Holidays or other known inactive periods

For example, a workstation may normally generate activity between 08:00 and 18:00. Significant activity at 03:00 could therefore be anomalous.

---

### Q12. Why must baselines be specific to the host, role, and time of day or week?

**Answer:**

Different systems and users naturally have different behaviors.

A database server may generate thousands of network events every hour, while a workstation may generate only a few hundred.

Similarly, an administrator may legitimately perform actions that would be unusual for a normal employee.

Therefore, useful baselines should consider:

**Host + Role + Time**

This reduces false positives and makes anomalies more meaningful.

---

### Q13. How should a baseline be stored so another script can consume it without human interpretation?

**Answer:**

The baseline should be stored in a **machine-readable format**, such as JSON.

It should contain structured information such as:

- Host
- Role
- Source
- Metric
- Time window
- Mean
- Median
- Standard deviation
- Expected range
- Sample count

Another script can then automatically load the baseline and compare new events against it.

---

# 3. Anomaly Detection and Correlation

### Q14. How do you compare an evaluation window against a baseline to identify deviations?

**Answer:**

First, calculate the same metrics for the evaluation window that were calculated for the baseline.

Then compare the evaluation values with the baseline values.

For example:

```text
Baseline average: 10 authentication events/hour
Evaluation window: 45 authentication events/hour
