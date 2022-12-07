#!/usr/bin/env bash

# Raspberry Pi OS pulls in a preload that is supposed to increase performance
# of certain memory- and string-related functions. These, however, for the
# time being, get dropped in as 32-bit ELF binaries - incompatible with our
# 64-bit architecture. Remove the preloads.
rm /etc/ld.so.preload

# Use the same configurations for both networks, but keep them separate in case
# they need to be re-configured separately.
configure_network () {
  tee /etc/systemd/network/$1.network <<-EOF
    [Match]
    Name=$1

    [Network]
    DHCP=yes
    MulticastDNS=yes
    LLMNR=no
  EOF
}

configure_network wlan0
configure_network eth0

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
