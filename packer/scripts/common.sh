#!/usr/bin/env bash

# Raspberry Pi OS pulls in a preload that is supposed to increase performance
# of certain memory- and string-related functions. These, however, for the
# time being, get dropped in as 32-bit ELF binaries - incompatible with our
# 64-bit architecture. Remove the preloads.
rm /etc/ld.so.preload

# Enable mDNS, disable LLMNR on the network
tee /etc/systemd/network/wlan0.network <<-EOF
[Match]
Name=wlan0

[Network]
DHCP=yes
MulticastDNS=yes
LLMNR=no
EOF

# Enable mDNS, disable LLMNR on the resolver
tee /etc/systemd/resolved.conf <<-EOF
[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=1.1.1.1
DNSSEC=allow-downgrade
DNSOverTLS=opportunistic
MulticastDNS=yes
LLMNR=no
EOF

# Enable backports, install fresh systemd (and unbreak the time):
tee /etc/apt/sources.list.d/backports.list <<-EOF
deb http://deb.debian.org/debian bullseye-backports main
EOF

apt-get update
apt-get install -y systemd/bullseye-backports systemd-timesyncd/bullseye-backports

# Create our directory structure:
mkdir -p /srv/
