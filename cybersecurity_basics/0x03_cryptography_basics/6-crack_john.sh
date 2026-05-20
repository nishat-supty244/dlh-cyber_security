#!/bin/bash
john --show --format=Raw-SHA256 "$1" | sed -n '1p' | cut -d: -f2 | grep -v '^$' > 6-password.txt
