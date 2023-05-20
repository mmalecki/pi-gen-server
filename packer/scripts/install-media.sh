#!/usr/bin/env bash
mkdir -p /srv/docker/media
cd /srv/docker/media

chown -R ${OPERATOR_USER}:${OPERATOR_GROUP} .

# Install the packages for a primitive "media center".
apt-get install -y vlc tigervnc-standalone-server tigervnc-xorg-extension chromium xorg xfce4 

# Set up a user to run all of these.
MEDIA_GID=1001
groupadd -g $MEDIA_GID media
useradd -g $MEDIA_GID -G bluetooth,video,audio,cdrom,floppy -m media # but not sudo
