#!/usr/bin/env bash
set -u

log=/boot/firmware/ssh-boot-status.log
{
    echo "=== SSH first-boot recovery: $(date --iso-8601=seconds) ==="
    systemctl unmask ssh.service
    systemctl enable ssh.service
    systemctl restart ssh.service
    systemctl --no-pager --full status ssh.service
    sshd -t
    ss -ltnp '( sport = :22 )'
} >"$log" 2>&1

sync
