#!/bin/bash
hashcat -m 0 -a 1 "$1" wordlist1.txt wordlist2.txt --show > cracked.txt
cut -d':' -f2 cracked.txt > 9-password.txt
rm cracked.txt
