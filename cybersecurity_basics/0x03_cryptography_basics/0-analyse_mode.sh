#!/bin/bash
echo "SELinux status:          $(sestatus | awk '/Current mode/ {print tolower($3)}')"
