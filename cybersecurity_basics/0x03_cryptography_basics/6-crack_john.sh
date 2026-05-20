#!/bin/bash
# Run John specifically for the identified Raw-SHA256 hash
john --format=Raw-SHA256 --wordlist=/usr/share/wordlists/rockyou.txt "$1" > /dev/null 2>&1

# Extract the password using the --show command and save it to the file
john --show --format=Raw-SHA256 "$1" | cut -d: -f2 | grep -v '^$' > 6-password.txt
