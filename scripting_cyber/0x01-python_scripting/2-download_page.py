#!/usr/bin/env python3
"""
Module to download and format HTML content from a URL.
"""
import requests
from bs4 import BeautifulSoup


def download_page(url):
    """
    Downloads a web page and returns its prettified HTML.
    """
    try:
        # 1. Send the HTTP GET request
        response = requests.get(url)
        # Check if the request was successful (status code 200)
        response.raise_for_status()
        
        # 2. Parse the content with BeautifulSoup
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 3. Format and return the HTML
        return soup.prettify()
        
    except requests.exceptions.RequestException as e:
        # Return error message if anything goes wrong
        return f"Error: {e}"


if __name__ == "__main__":
    import sys
    if len(sys.argv) == 2:
        print(download_page(sys.argv[1]))
