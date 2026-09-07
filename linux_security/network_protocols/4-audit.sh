#!/bin/bash
grep -Ev "PermitRootLogin no|PasswordAuthentication no|X11Forwarding no" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
