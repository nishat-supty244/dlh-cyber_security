#!/bin/bash
# Alternative way to show the last 5 logins if 'last' is missing
who /var/log/wtmp | tail -n 5
