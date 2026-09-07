#!/bin/bash
john --show --format=nt "$1" | sed -n '1p' | cut -d: -f2 > 5-password.txt
