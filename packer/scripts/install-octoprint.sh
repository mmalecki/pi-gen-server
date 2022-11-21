#!/usr/bin/env bash
mkdir -p /srv/docker/octoprint
cd /srv/docker/octoprint

tee > docker-compose.yml <<-EOF
version: '3'

services:
  octoprint:
    image: mmalecki/octoprint-mdns:1.8.6
    restart: unless-stopped
    ports:
      - 80:80
    devices:
      - /dev/ttyACM0:/dev/ttyACM0
      - /dev/video0:/dev/video0
    volumes:
      - octoprint:/octoprint
    environment:
      - ENABLE_MJPG_STREAMER=true
    networks:
      - octoprint

  mdns_repeater:
    image: jdbeeler/mdns-repeater:latest
    network_mode: "host"
    privileged: true
    environment:
      - DOCKER_NETWORK_NAME=octoprint
      - EXTERNAL_INTERFACE=wlan0
      - USE_MDNS_REPEATER=1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  octoprint:

networks:
  octoprint:
EOF

chown -R ${OPERATOR_USER}:${OPERATOR_GROUP} .

mkdir -p /etc/systemd/dnssd

tee > /etc/systemd/dnssd/prusa-i3.dnssd <<-EOF
[Service]
Name=%H
Type=_http._tcp
Port=80
TxtText=path=/ devicetype=octoprint
EOF
