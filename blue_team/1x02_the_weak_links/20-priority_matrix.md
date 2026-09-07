# Priority Matrix

| Horizon | Timeline | Finding ID | Description | Remediation Action | Owner | Estimated Cost |
|---|---|---|---|---|---|---|
| Immediate | 24–48 hours | Finding 1 | **Critical EHR Database Remote Code Execution (RCE)** | Apply vendor cumulative security update through a controlled testing process, including staging validation and a scheduled maintenance window. | IT / Database Admin | $5,000 (Mid-point) |
| Immediate | 24–48 hours | Finding 2 | **Legacy Windows Server 2012 R2 PACS Node** | Implement network micro-segmentation and deploy 24/7 EDR behavioral monitoring to reduce exploitation risk. | Security | $500 (Mid-point) |
| Short-term | 7 days | Finding 3 | **Unauthenticated Patient Portal API Endpoints** | Enforce JWT validation and implement strict OAuth 2.0 scope controls at the API gateway layer. | IT / App Dev | $5,000 (Mid-point) |
| Short-term | 7 days | Finding 4 | **Default Service Credentials on Infusion Pump Server** | Replace default credentials with privileged vault-managed passwords and restrict administrative access through jump boxes. | IT / Biomedical Eng. | $500 (Mid-point) |
| Short-term | 7 days | Finding 7 | **Missing MFA for Remote VPN Access** | Integrate VPN gateway authentication with the Identity Provider (IDP) and require hardware-token or push-based MFA. | IT / IAM | $5,000 (Mid-point) |
| Short-term | 7 days | Finding 8 | **Unrestricted Outbound Guest Wi-Fi Rules** | Restrict guest VLAN outbound traffic to required web ports (80/443), block administrative ports, and enable traffic filtering. | IT / Network Security | $500 (Mid-point) |
| Medium-term | 30 days | Finding 5 | **Unencrypted Internal Lab Results Transmission** | Implement internal IPSec transport-mode encryption tunnels to protect sensitive laboratory data in transit. | IT / Network Infrastructure | $5,000 (Mid-point) |
| Medium-term | 30 days | Finding 6 | **Outdated OpenSSL on Pharmacy Workstations** | Deploy the Pharmacy Management Suite hotfix package using centralized endpoint management tools. | IT / Endpoint Management | $5,000 (Mid-point) |

---

# Budget Summary

## Total Estimated Remediation Cost

**$27,500**

The total remediation budget is calculated using the median estimated values across all identified findings:

- **Three remediation activities at $500 each**
- **Five remediation activities at $5,000 each**

---

## Impact on Annual Security Budget

**Annual Security Budget:** $120,000  

**Total Remediation Allocation:** $27,500  

**Remaining Security Budget:** $92,500  

The remediation effort consumes approximately **22.9% of the annual security budget**, leaving sufficient financial capacity for:

- Continuous security monitoring operations
- Security tooling maintenance
- Incident response activities
- Unexpected emergency vulnerabilities
- Hardware lifecycle replacements

---

# Deletions and Deferrals

No critical technical remediation activities require deferral because the immediate and short-term remediation costs total **$16,500**, which remains within available operational cash flow.

However, to preserve financial flexibility, the organization should consider delaying or reducing:

- Discretionary security awareness training expansion programs
- Non-essential security tooling upgrades
- Lower-priority security improvement initiatives scheduled for later quarters

This approach ensures sufficient liquidity remains available for:

- Emergency security patches
- Critical infrastructure replacements
- Unexpected cybersecurity incidents
- Additional remediation activities identified through continuous monitoring
