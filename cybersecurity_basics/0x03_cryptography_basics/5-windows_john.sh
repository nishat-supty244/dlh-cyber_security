#!/bin/bash
john --wordlist=/usr/share/wordlists/rockyou.txt --format=nt "$1" > /dev/null
john --show --format=nt "$1" | cut -d ':' -f 2 > 5-password.txt
