# Task 4 — URL and Attachment Autopsy

## What is this task about?

This task is about **safely investigating suspicious URLs and email attachments** found in phishing emails.

We have suspicious emails such as **E2, E3, E5, and E7**.

The goal is to understand what makes their links or attachments suspicious **without actually opening them**.

---

## What do I need to do?

For each suspicious URL or attachment, I need to:

1. Find the original URL or attachment.
2. Defang the URL.
3. Identify the domain or IP address.
4. Identify which email it came from.
5. Explain why it is suspicious.
6. Show safe ways to investigate it.
7. Record what the email evidence tells us.
8. Give the indicator a risk rating.

---

## What does "defang" mean?

Defanging means changing a URL so that nobody can accidentally click it.

For example:

Normal:

https://example.com/login

Defanged:

hxxps://example[.]com/login

We use this when documenting suspicious URLs.

---

## What should I look for?

I should look for things such as:

- Lookalike domains
- Fake login pages
- Suspicious IP addresses
- SPF/DKIM/DMARC failures
- Urgent deadlines
- Payment requests
- Requests for passwords or verification
- Suspicious filenames
- Links inside attachments
- Domains pretending to be trusted companies

---

## How can I investigate safely?

I should **not click the suspicious URL**.

Instead, I can use safe investigation methods such as:

```bash
whois example.com
dig example.com
nslookup example.com
curl -I https://example.com
