#!/usr/bin/env python3
import socket
import requests
import dns.resolver
from bs4 import BeautifulSoup
urllib.parse import urlsparse

def dns_recon(d): print(f"IP: {socket.gethostbyname(d)}\nMX: {[r.exchange.to_text() for r in dns.resolver.resolve(d, 'MX')]}")
def web_recon(d): r=requests.get(f"http://{d}", timeout=3); print(f"Status: {r.status_code}\nHeaders: {dict(r.headers)}\nLinks: {len(BeautifulSoup(r.text, 'html.parser').find_all('a'))}")
def port_scan(d): print([p for p in [80, 443] if socket.socket().connect_ex((d, p)) == 0])
