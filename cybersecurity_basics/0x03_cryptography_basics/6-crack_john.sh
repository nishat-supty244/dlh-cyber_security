#!/bin/bash
# Run John and redirect output to /dev/null to keep it clean
john --format=Raw-SHA256 --wordlist=/usr/share/wordlists/rockyou.txt "$1" > /dev/null 2>&1

# Extract only the password and save to the file, overwriting it
john --show --format=Raw-SHA256 "$1" | cut -d: -f2 | grep -v '^$' > 6-password.txt

# Force the file to be exactly one line
sed -i '$!d' 6-password.txt
