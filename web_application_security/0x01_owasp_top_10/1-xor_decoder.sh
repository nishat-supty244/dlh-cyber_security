#!/bin/bash

# Remove the {xor} prefix using parameter expansion
val=${1#"{xor}"}

# Use echo and perl to perform the XOR operation
# This avoids shell metacharacters and complex block structures
echo "$val" | base64 -d | perl -ne 'BEGIN {$k=0x5F} print chr(ord($_) ^ $k) for split ""'