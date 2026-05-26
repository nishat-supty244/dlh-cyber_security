#!/bin/bash
# Check if an IP address was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <ip-address>"
    exit 1
fi

# Use showmount to list exports from the target IP
showmount -e "$1"
