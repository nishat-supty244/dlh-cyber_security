#!/bin/bash
# 1. Run Hashcat to crack the hash
hashcat -m 0 -a 0 --force "$1" /usr/share/wordlists/rockyou.txt > /dev/null 2>&1

# 2. Extract ONLY the password part and ensure it is the only content
# We use 'awk' to take the second part after the colon and 'head' to get just the first result
hashcat -m 0 --show --force "$1" | cut -d: -f2 | head -n 1 > 7-password.txt

# 3. Ensure no trailing newlines or extra text exist
# This is a safety measure to ensure the file is strictly just the password
tr -d '\n' < 7-password.txt > tmp && mv tmp 7-password.txt
echo "" >> 7-password.txt
