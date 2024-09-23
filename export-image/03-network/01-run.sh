#!/bin/bash -e

# This is so that we have a well-known resolver available
# within the Packer environment, which doesn't have access
# to 127.0.0.53:53.
# Later removed by Packer as the final packaging step.
install -v -m 644 files/resolv.conf "${ROOTFS_DIR}/etc/resolv.conf"

on_chroot <<-EOF
systemctl enable systemd-resolved
EOF
