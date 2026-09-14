**1\. What is this project about?**

You are a **SOC Tier 1 Analyst** at MedDefense.

Previously, you learned:

- How to process logs
- How to understand normal vs abnormal behavior
- How to write detection rules
- How to investigate alerts
- How to perform SOC triage

Now you are learning something new:

**Can you investigate the same security incident using two different tools?**

The two methods are:

**Method 1 — CLI**

You already know this workflow:

Evidence files

↓

CLI

↓

jq

↓

Sigma rules

↓

Investigation

↓

Finding

**Method 2 — Wazuh evidence export**

Instead of using a live Wazuh dashboard, you use files that represent what Wazuh would show:

Wazuh

↓

Search results exported to JSON

↓

Dashboard workflow traces

↓

Field mapping documents

↓

Investigation

↓

Finding

**2\. What does "same evidence" mean?**

This is very important.

Both methods are based on the **same 339,000-event evidence pack**.

So you are NOT comparing:

CLI → one dataset

Wazuh → different dataset

You are comparing:

SAME EVIDENCE

↓

┌─────────┴─────────┐

↓ ↓

CLI Wazuh

↓ ↓

Investigation Investigation

Therefore, if the results are different, you need to investigate **why**.

**3\. Why aren't you using a live Wazuh dashboard?**

Normally, you might use:

Browser

↓

Wazuh Dashboard

↓

Search

↓

Results

But your lab environment does **not** provide:

- Live Wazuh dashboard
- Docker socket
- Browser connection to Wazuh
- Port 5601 access

So the lab developers prepared **Wazuh export files** for you.

These files contain things like:

- Wazuh search results
- Dashboard workflow information
- Field mappings

Think of them as:

**A recording of what you would have seen in Wazuh.**

**4\. What does "export mode" mean?**

Instead of interacting with Wazuh directly:

Live mode:

You → Wazuh → Search → Results

you use:

Export mode:

Wazuh → Export files → You → Investigate

The important point is:

**The data and investigation logic are supposed to be the same. Only the way you access the data is different.**

**5\. What is the "Vendor Question"?**

MedDefense is deciding which SIEM/platform approach is better.

The board doesn't want:

"Wazuh has these features and Tool X has these features."

They want:

**"We actually tested these tools against real security scenarios. Here is what happened."**

That's why you need to investigate real incidents using both interfaces.

**6\. Why does James Chen care about this?**

James Chen is the **SOC Lead**.

The company has a platform/vendor evaluation.

The board wants evidence that MedDefense made a proper decision.

James doesn't want you to say:

"I like Wazuh better."

He wants evidence like:

| **Measurement**      | **CLI** | **Wazuh** |
| -------------------- | ------- | --------- |
| Time to first answer | 120 sec | 90 sec    |
| Fields touched       | 8       | 6         |
| Events reviewed      | 30      | 15        |

Now James can say:

"We tested both platforms and Wazuh required fewer events to reach the answer."

That's a **defensible recommendation**.

**7\. What does "three scenarios × two interfaces" mean?**

You will investigate **3 security scenarios**.

Each scenario will be investigated twice:

Scenario 1

├── CLI investigation

└── Wazuh investigation

Scenario 2

├── CLI investigation

└── Wazuh investigation

Scenario 3

├── CLI investigation

└── Wazuh investigation

Therefore:

**3 × 2 = 6 findings**

That's why James asks for:

**Six structured findings**

**8\. What is a structured finding?**

Instead of writing whatever you want, every investigation result must follow the **same JSON format/schema**.

For example, conceptually:

{

"scenario": "...",

"interface": "...",

"finding": "...",

"evidence": "...",

"verdict": "...",

"confidence": "..."

}

The exact schema will be provided by the project files.

The important idea is:

**Every finding must have the same structure.**

This lets you compare CLI and Wazuh fairly.

**9\. What does "three Sigma rules translated to native Wazuh XML" mean?**

You already learned Sigma rules.

Now you have to take **3 Sigma rules** and convert/adapt them into Wazuh's rule format.

Conceptually:

Sigma YAML

↓

Understand detection logic

↓

Translate/adapt

↓

Wazuh XML

↓

Validate with xmllint

For example:

Sigma:

Detect 5 failed SSH logins within 120 seconds

You create the equivalent Wazuh rule.

**10\. What is xmllint doing?**

After creating the Wazuh XML rule, you need to check whether the XML is properly written.

You can use:

xmllint --noout rule.xml

Think of it as:

**"Check whether my XML file is correctly structured."**

**11\. What is the four-language query comparison?**

You need to compare four ways of expressing investigation/search logic:

1. jq
2. Sigma
3. KQL
4. Lucene

For example, suppose the investigation question is:

Find failed SSH logins from the last 24 hours.

You show how that same idea would be represented in each language.

The important thing isn't memorizing syntax.

It's understanding:

FILTER

-

AGGREGATION

-

TIME WINDOW

**12\. What is a tool-agnostic investigation playbook?**

**Tool-agnostic** means:

It doesn't depend on Wazuh, jq, or any specific SIEM.

Instead of saying:

"Click this button in Wazuh."

you write:

"Identify the source IP associated with the suspicious authentication event."

So the playbook works with:

Wazuh

CLI

Splunk

Microsoft Sentinel

Elastic

etc.

The **investigation thinking** stays the same.

**13\. What is the vendor evaluation brief?**

This is your final report to **Dr. Morales**.

You will explain:

- What you tested
- Which scenarios you investigated
- CLI results
- Wazuh results
- What measurements you collected
- Advantages/disadvantages
- Your recommendation
- Evidence supporting your recommendation

The key idea:

**Don't recommend a tool because you like it. Recommend it because your test results support it.**

**14\. What is tool_evaluation/?**

This is the folder where you will put all your project deliverables.

Something like:

tool_evaluation/

│

├── findings/

│ ├── scenario1_cli.json

│ ├── scenario1_wazuh.json

│ ├── scenario2_cli.json

│ ├── scenario2_wazuh.json

│ ├── scenario3_cli.json

│ └── scenario3_wazuh.json

│

├── wazuh_rules/

│ ├── rule1.xml

│ ├── rule2.xml

│ └── rule3.xml

│

├── query_comparison/

│ └── query_comparison.md

│

├── playbook/

│ └── investigation_playbook.md

│

├── vendor_evaluation/

│ └── evaluation_brief.md

│

└── manifest.json

**The exact filenames will depend on your assignment instructions**, but this is the general idea.

**15\. What does the quote at the beginning mean?**

"The best tool for the job is the one you know. The best professional for the job is the one who knows more than one."

Simple meaning:

**Beginner mindset:**

"I know Wazuh, so I can investigate."

**Professional mindset:**

"I know how to investigate. Wazuh is just one of the tools I can use."

That's the **main lesson of this project**.

**16\. The whole project in one picture**

3x04 PROJECT

│

↓

SAME SECURITY EVIDENCE

│

┌─────────┴─────────┐

↓ ↓

CLI Wazuh

↓ ↓

jq Export files

↓ ↓

Investigate Investigate

↓ ↓

└─────────┬─────────┘

↓

Compare results

↓

┌────────────┼────────────┐

↓ ↓ ↓

Findings Query languages Rules

↓

Playbook

↓

Vendor evaluation

↓

Recommendation

↓

Dr. Morales

**⭐ The most important thing to remember**

Your instructor is basically asking you:

**"If I take away your favorite tool, can you still investigate an incident?"**

You need to prove **YES**.

You already know how to investigate using the CLI. Now you'll perform the **same investigations using Wazuh evidence exports**, compare the two approaches using measurable evidence, and produce a professional recommendation.
