#!/bin/bash
grep -E "PermitRootLogin yes|PasswordAuthentication yes|X11Forwarding yes" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null
