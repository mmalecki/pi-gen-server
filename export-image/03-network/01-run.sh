#!/bin/bash -e

on_chroot <<-EOF
systemctl enable systemd-resolved
EOF
