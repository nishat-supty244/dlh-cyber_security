#!/bin/bash
# Description: Captures the unhardened state of the Linux endpoint.

OUTPUT_FILE="intake_linux_$(hostname)_$(date +%s).txt"
echo "Starting Linux Environment Intake. Writing to $OUTPUT_FILE..."

{
  echo "=== SYSTEM INFO ==="
  hostname
  uname -r
  cat /etc/os-release | grep -E '^(PRETTY_NAME|VERSION)='
  
  echo -e "\n=== INSTALLED PACKAGE COUNT ==="
  dpkg-query -W | wc -l
  
  echo -e "\n=== LISTENING SOCKETS ==="
  ss -tulnpH
  
  echo -e "\n=== ACTIVE SYSTEMD SERVICES ==="
  systemctl list-units --type=service --state=active --no-pager
  
  echo -e "\n=== CURRENT SSHD CONFIG ==="
  sshd -T 2>/dev/null || echo "Run as root to capture sshd_config."
  
  echo -e "\n=== SYSCTL SECURITY PARAMETERS ==="
  sysctl -a 2>/dev/null | grep -E "^(net\.ipv4\.conf|net\.ipv6\.conf|kernel\.(randomize_va_space|kptr_restrict|dmesg_restrict|yama|unprivileged_bpf_disabled))"
  
  echo -e "\n=== SUID & SGID BINARIES COUNT ==="
  find / -perm /6000 -type f 2>/dev/null | wc -l
  
  echo -e "\n=== WORLD-WRITABLE FILES COUNT ==="
  find / -type f -perm -0002 -not -path "/proc/*" -not -path "/sys/*" 2>/dev/null | wc -l
  
  echo -e "\n=== FIREWALL STATUS (nft ruleset length) ==="
  nft list ruleset 2>/dev/null | wc -l || echo "nftables not active or installed"
  
  echo -e "\n=== TELEMETRY STATUS ==="
  echo "auditd: $(systemctl is-active auditd 2>/dev/null || echo 'not active')"
  echo "rsyslog: $(systemctl is-active rsyslog 2>/dev/null || echo 'not active')"
  echo "sysmon: $(systemctl is-active sysmon 2>/dev/null || echo 'not active')"
} > "$OUTPUT_FILE"

echo "Linux Intake complete."
