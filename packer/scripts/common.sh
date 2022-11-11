#!/usr/bin/env bash

# Raspberry Pi OS pulls in a preload that is supposed to increase performance
# of certain memory- and string-related functions. These, however, for the
# time being, get dropped in as 32-bit ELF binaries - incompatible with our
# 64-bit architecture. Remove the preloads.
rm /etc/ld.so.preload

mkdir -p /srv/
