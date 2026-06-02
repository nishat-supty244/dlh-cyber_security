#!/usr/bin/env python3
import socket
import requests
import dns.resolver
from bs4 import BeautifulSoup

def dns_recon(domain):
    try:
        print(f"IP Address: {socket.gethostbyname(domain)}")
        print("MX Records:")
        for rdata in dns.resolver.resolve(domain, 'MX'):
            print(f"  {rdata.preference} {rdata.exchange}")
    except Exception as e:
        print(f"DNS lookup failed: {e}")

def web_recon(domain):
    try:
        r = requests.get(f"http://{domain}", timeout=3)
        print(f"Status Code: {r.status_code}")
        print("Important Headers:")
        for h in ['Server', 'Content-Type']:
            print(f"  {h}: {r.headers.get(h, 'N/A')}")
        print(f"Total Links Found: {len(BeautifulSoup(r.text, 'html.parser').find_all('a'))}")
    except Exception as e:
        print(f"Web reconnaissance failed: {e}")

def port_scan(domain):
    print(f"Scanning common ports on {domain}...")
    print("Open ports:")
    for port in [80, 443]:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1.0)
        if sock.connect_ex((domain, port)) == 0:
            print(f"  Port {port}: OPEN")
        sock.close()
