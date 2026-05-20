#!/bin/bash # hashcat
awk '{a[NR]=$0} END {while((getline < ARGV[2]) > 0) {for(i in a) print a[i]$0}}' "$1" "$2"
