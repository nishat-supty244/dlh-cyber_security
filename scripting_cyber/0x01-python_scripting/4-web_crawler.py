#!/usr/bin/env python3import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

def crawl_website(url, depth=2, visited=None):
    if visited is None: visited = set()
    if depth < 0 or url in visited: return visited
    
    visited.add(url)
    try:
        
        soup = BeautifulSoup(requests.get(url, timeout=3).text, 'html.parser')
        domain = urlparse(url).netloc
        
        
        for link in soup.find_all('a', href=True):
            full_url = urljoin(url, link['href'])
            if urlparse(full_url).netloc == domain:
                crawl_website(full_url, depth - 1, visited)
    except: pass 
    
    return visited
