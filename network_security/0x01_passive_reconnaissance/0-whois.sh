#!/bin/bash
whois "$1" | awk -F': +' '
$1 == "Registrant Name" { print "Registrant Name," $2 }
$1 == "Admin Name" { print "Admin Name," $2 }
' > "$1.csv"
