#!/usr/bin/env python3
"""
Module to query multiple DNS record types for a domain.
"""
import dns.resolver


def query_dns_records(domain_name):
    """
    Queries A, AAAA, MX, NS, TXT, and SOA records for a given domain.
    """
    results = {}
    record_types = ['A', 'AAAA', 'MX', 'NS', 'TXT', 'SOA']
    resolver = dns.resolver.Resolver()

    for r_type in record_types:
        try:
            answers = resolver.resolve(domain_name, r_type)
            results[r_type] = answers
        except (dns.resolver.NoAnswer, dns.resolver.NXDOMAIN,
                dns.resolver.NoNameservers, dns.exception.Timeout):
            continue
        except Exception:
            continue
    return results


if __name__ == "__main__":
    import sys
    if len(sys.argv) == 2:
        domain = sys.argv[1]
        results = query_dns_records(domain)
        for r_type, answers in results.items():
            print(f"\n{r_type} Records:")
            print(answers.response.to_text())
