#!/bin/sh

pubkey="__PUBKEY__"

sed -i 's/^PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
service ssh restart >/dev/null 2>&1

printf 'root:root\n' | chpasswd

mkdir -p /root/.ssh
printf '%s\n' "$pubkey" >/root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys


