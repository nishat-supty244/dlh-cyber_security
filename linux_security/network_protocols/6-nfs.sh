#!/bin/bash
[ -z "$1" ] && echo "Usage: $0 <ip>" || showmount -e "$1"
