# Network Traffic Analysis — Learning Objectives 

## 1. Network Traffic Analysis Fundamentals

### Q1. How do you establish a network traffic baseline?

**A:** A traffic baseline is a picture of what **normal network activity** looks like. We observe normal traffic over a period of time and record things like common connections, DNS queries, bytes transferred, session duration, and connection frequency. Later, unusual activity can be compared against this baseline.

---

### Q2. How do you identify deviations from a traffic baseline?

**A:** We look for traffic that is significantly different from normal behavior. For example, a host that normally makes 10 DNS queries per minute suddenly making 500 queries per minute could be a deviation.

---

### Q3. How do you interpret TCP session behavior?

**A:** We look at how a TCP connection starts, communicates, and ends. The normal process is usually **SYN → SYN/ACK → ACK**, followed by data transfer and then connection termination. Repeated failed connections, unusual resets, or very short repeated sessions can be suspicious.

---

### Q4. How does DNS activity differ between legitimate applications and malicious tooling?

**A:** Legitimate applications usually generate predictable DNS queries related to the services they use. Malicious tools may generate **very frequent, random-looking, unusually long, or constantly changing DNS queries**, especially when DNS is being used for command-and-control or data exfiltration.

---

### Q5. How can you analyze TLS traffic without decrypting it?

**A:** We cannot see the encrypted application data, but we can still examine metadata such as **source and destination IPs, ports, timestamps, session duration, packet sizes, certificate information, and connection frequency**. This can reveal suspicious communication patterns.

---

### Q6. How can suspicious timing patterns be identified?

**A:** We look at **when and how often connections occur**. Regular connections at almost identical intervals, such as every 60 seconds, can indicate automated beaconing.

---

### Q7. How do you measure bytes transferred?

**A:** We count the amount of data sent and received during a connection or over a specific period. Unusual amounts of outbound data can be important when investigating possible data theft.

---

### Q8. How do you measure session duration?

**A:** Session duration is the time between the beginning and end of a network connection. We compare the duration with normal behavior to identify unusual long or short sessions.

---

### Q9. How do you measure connection intervals?

**A:** We calculate the time between consecutive connections from the same host to the same or similar destination. Regular intervals can be an indicator of automated communication.

---

### Q10. How do you measure DNS query rates?

**A:** We count the number of DNS queries made by a host during a specific time period, such as queries per minute. A sudden or unusually high rate can indicate suspicious activity.

---

### Q11. What is traffic distribution?

**A:** Traffic distribution describes **where traffic is going, where it is coming from, and how much traffic is exchanged**. We can examine traffic by IP, port, protocol, destination, or host to identify unusual patterns.

---

# 2. Attack Pattern Recognition

### Q12. How does command-and-control beaconing appear in packet captures?

**A:** Beaconing often appears as **repeated connections from an infected host to the same external destination at regular or semi-regular intervals**. The amount of data transferred may also be small and consistent.

---

### Q13. Why is beaconing often invisible to signature-based IDS rules?

**A:** Signature-based IDS systems look for known patterns or signatures. Beaconing may use normal protocols such as **HTTP, HTTPS, or DNS** and may not contain a known malicious signature. Its suspicious nature may only become clear when we examine its timing and behavior.

---

### Q14. How does DNS tunneling work as a covert exfiltration mechanism?

**A:** DNS tunneling abuses DNS queries to secretly transfer data. The attacker encodes information into DNS query names and sends those queries to a server controlled by the attacker.

---

### Q15. How do attackers encode data into DNS labels?

**A:** Data can be converted into an encoding such as **Base32 or hexadecimal** and placed inside DNS subdomain labels. For example, instead of querying a normal domain, a compromised machine may repeatedly query long, random-looking subdomains containing encoded information.

---

### Q16. How does lateral movement appear on the network?

**A:** Lateral movement occurs when an attacker moves from one compromised system to another. On the network, this can appear as **new connections between internal hosts**, especially through services such as SMB, RDP, SSH, WinRM, or other administrative protocols.

---

### Q17. How can authentication-related traffic reveal attacker pivots?

**A:** Authentication traffic can show when a user or account starts accessing another machine. An unusual authentication from one internal host to another can indicate that an attacker is using stolen credentials to move through the network.

---

### Q18. How can you distinguish human browsing from automated malware communications?

**A:** Human browsing is usually **irregular and varied**. Users visit different websites and generate different amounts of traffic. Malware communications are often **repetitive, automated, periodic, and predictable**, such as contacting the same server every few minutes.

---

# 3. Forensic Methodology

### Q19. How do you investigate an incident directly from PCAP evidence?

**A:** We examine the packet capture to identify **hosts, IP addresses, protocols, connections, DNS activity, timestamps, and unusual traffic patterns**. We then reconstruct what happened based on the network evidence.

---

### Q20. How do you correlate multiple PCAP files into one timeline?

**A:** We use the timestamps from each PCAP and place the network events in chronological order. This allows us to see how activity from different captures may be connected.

---

### Q21. How do you extract network indicators of compromise (IOCs)?

**A:** We identify suspicious information such as **IP addresses, domains, URLs, ports, protocols, and unusual connection patterns**. These become network IOCs that can be investigated or monitored.

---

### Q22. How do you reconstruct attacker activity chronologically?

**A:** We arrange the evidence according to timestamps and connect related events.

For example:

**Initial connection → DNS lookup → C2 communication → credential use → lateral movement → data transfer**

This creates a timeline of the attack.

---

### Q23. How do you produce a professional network forensics report?

**A:** A professional report should clearly explain **what happened, when it happened, which systems were involved, what evidence supports the findings, and what indicators were identified**. Conclusions should be based on evidence rather than assumptions.

---

### Q24. How do you support conclusions with packet timestamps and protocol evidence?

**A:** Every important conclusion should be connected to observable evidence. For example, instead of saying:

> "The host was beaconing."

We can show that the host contacted the same destination every 60 seconds, with similar packet sizes, between specific timestamps.

---

# Quick Revision

| Topic | Remember |
|---|---|
| **Baseline** | What normal traffic looks like |
| **Deviation** | Activity that differs from normal |
| **TCP** | Connection establishment, data transfer, termination |
| **DNS** | Queries, frequency, length, randomness |
| **TLS** | Analyze metadata without decrypting content |
| **Timing** | Look for regular/repeated communication |
| **Beaconing** | Repeated automated C2 connections |
| **DNS tunneling** | Hide data inside DNS queries |
| **Lateral movement** | Attacker moving between internal systems |
| **Authentication** | Can reveal account-based pivots |
| **PCAP** | Direct packet-level evidence |
| **IOC** | IP, domain, URL, port, etc. |
| **Timeline** | Reconstruct events in chronological order |
| **Forensics report** | Findings + evidence + timestamps |
