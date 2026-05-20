#!/bin/bash
echo "SELinux status:          $(sestatus | grep "Current mode" | cut -d: -f2 | tr -d ' ' | tr '[:upper:]' '[:lower:]')"
