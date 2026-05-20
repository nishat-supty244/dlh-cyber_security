#!/bin/bash
# 1. Run Hashcat on the hash file provided as $1
# Mode 0 is MD5. We use -m 0 to specify the hash type.
# We redirect output to /dev/null to keep the terminal clean.
hashcat -m 0 -a 0 --force "$1" /usr/share/wordlists/rockyou.txt > /dev/null 2>&1

# 2. Extract the cracked password
# Hashcat creates a "potfile" where it stores cracked passwords.
# We can use the --show flag to display it.
hashcat -m 0 --show --force "$1" | cut -d: -f2 > 7-password.txt
