# Passive Reconnaissance Report: holbertonschool.com

## 1. Executive Summary
This report details the infrastructure and technology footprint of `holbertonschool.com`. Through passive OSINT (Open Source Intelligence) techniques, including DNS analysis and Certificate Transparency log review, we have mapped the target's public-facing assets and identifying service providers.

## 2. Infrastructure & IP Ranges
* **Primary IP Resolution:** `198.202.211.1` (via `dig`)
* **Hosting/Infrastructure Provider:** The domain resolves to managed hosting services. WHOIS analysis indicates the infrastructure is provided by managed cloud/CDN providers (e.g., Webflow, Cloudflare).
* **Observation:** The use of shared CDN infrastructure effectively hides the origin server's private IP, protecting the target from direct IP-based scanning.

## 3. Subdomains & Technology Stack
Based on Certificate Transparency logs (`crt.sh`) and header inspection, the following subdomains and technologies were identified:

| Subdomain | Technology/Framework | Evidence |
| :--- | :--- | :--- |
| `www.holbertonschool.com` | Webflow / Managed CDN | SSL Issuer (Google/Let's Encrypt), CDN Headers |
| `blog.holbertonschool.com` | WordPress / Automattic | Certificate common name: `tls.automattic.com` |
| `yriry2.holbertonschool.com` | Unknown / Staging | Active Let's Encrypt certificates |

## 4. Methodology
* **DNS Enumeration:** Utilized `dig` to determine current A records and hosting resolution.
* **Certificate Transparency:** Consulted `crt.sh` to extract all SSL/TLS certificates issued to the domain, enabling the discovery of subdomains that are not linked directly on the main site.
* **Technology Fingerprinting:** Analyzed SSL certificate issuers and used browser-based network inspection to identify the underlying CMS (Webflow/WordPress) and CDN providers.

## 5. Conclusion
`holbertonschool.com` maintains its web presence via third-party managed infrastructure. This strategy simplifies maintenance and improves security by abstracting the origin server behind global CDNs. The reconnaissance performed was entirely passive, confirming no interaction with the target’s backend services.

*Disclaimer: This report was generated using passive reconnaissance techniques only. No intrusive or active testing was performed against the infrastructure.*
