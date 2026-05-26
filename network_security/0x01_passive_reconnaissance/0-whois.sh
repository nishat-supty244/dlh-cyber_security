#!/bin/bash

# 1. We run 'whois' on the domain provided ($1)
# 2. We send (|) that messy info into 'awk' to clean it up
whois "$1" | awk -F': ' ' 

# The -F': ' tells awk: "When you see a colon and a space, that is where you split the line!"

/^Registrant Name:/ { print "Registrant Name," $2 }
/^Registrant Organization:/ { print "Registrant Organization," $2 }
/^Registrant Street:/ { print "Registrant Street," $2 " " }
/^Registrant City:/ { print "Registrant City," $2 }
/^Registrant Postal Code:/ { print "Registrant Postal Code," $2 }
 "$1.csv"
