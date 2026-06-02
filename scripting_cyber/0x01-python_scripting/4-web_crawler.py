#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

def crawl_website(start_url, max_depth=2):
    """
    Recursively crawls a website up to a specified depth.
    """
    visited = set()
    
    # We use a helper function to handle the recursion 
    # while keeping the public function signature exactly as required.
    def _crawl(url, depth):
        if depth < 0 or url in visited:
            return
        
        visited.add(url)
        try:
            # Fetch the page
            response = requests.get(url, timeout=3)
            # Parse links
            soup = BeautifulSoup(response.text, 'html.parser')
            domain = urlparse(start_url).netloc
            
            for link in soup.find_all('a', href=True):
                full_url = urljoin(url, link['href'])
                # Only crawl if same domain
                if urlparse(full_url).netloc == domain:
                    _crawl(full_url, depth - 1)
        except:
            pass

    _crawl(start_url, max_depth)
    return visited
