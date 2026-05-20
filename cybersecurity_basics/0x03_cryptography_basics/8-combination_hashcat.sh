#!/bin/bash
while read -r line1; do
    while read -r line2; do
        echo "${line1}${line2}"
    done < "$2"
done < "$1"
