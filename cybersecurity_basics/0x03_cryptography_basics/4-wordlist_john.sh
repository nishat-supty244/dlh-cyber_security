#!/bin/bash
rm -f cracked.pot 4-password.txt
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt "$1"
john --format=raw-md5 --show "$1" | cut -d: -f2 | grep -v '^$' > 4-password.txt
