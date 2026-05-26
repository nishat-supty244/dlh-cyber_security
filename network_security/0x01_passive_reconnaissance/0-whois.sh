#!/bin/bash
whois "$1" | grep -E "^Registrant Name:|^Admin Name:" | awk -F': +' '{print $1 "," $2}' > "$1.csv"
