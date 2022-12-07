#!/usr/bin/env bash
mkdir -p /srv/docker/home-assistant
cd /srv/docker/home-assistant

tee docker-compose.yml <<-EOF
version: '2.4'
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    volumes:
      - ./home-assistant:/config
    ports:
      - 80:8123
    restart: unless-stopped
    networks:
      - home-assistant

  zigbee2mqtt:
    image: koenkk/zigbee2mqtt
    restart: unless-stopped
    user: '1002:20'
    ports:
      - 8000:8080
    volumes:
      - /run/udev:/run/udev:ro
      - ./zigbee2mqtt:/app/data
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0
    networks:
      - home-assistant

  mqtt:
    image: eclipse-mosquitto:2
    restart: unless-stopped
    volumes:
      - ./mosquitto/:/mosquitto/config/:ro
      - mosquitto:/mosquitto/data/
    networks:
      - home-assistant
    ports:
      - 1883:1883
      - 9001:9001

  wolbridge:
    image: ghcr.io/mmalecki/wakeupbr-docker:latest
    restart: unless-stopped
    network_mode: host
    command: -l 0.0.0.0:9 -o 255.255.255.255

  mdns_repeater:
    image: jdbeeler/mdns-repeater:latest
    restart: unless-stopped
    network_mode: host
    privileged: true
    environment:
      - DOCKER_NETWORK_NAME=home-assistant
      - EXTERNAL_INTERFACE=wlan0
      - USE_MDNS_REPEATER=1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  mosquitto:

networks:
  home-assistant:
    driver: bridge
EOF

chown -R ${OPERATOR_USER}:${OPERATOR_GROUP} .

mkdir -p /etc/systemd/dnssd

tee /etc/systemd/dnssd/home.dnssd <<-EOF
[Service]
Name=%H
Type=_http._tcp
Port=80
TxtText=path=/
EOF
