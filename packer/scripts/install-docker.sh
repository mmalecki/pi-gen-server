#!/usr/bin/env bash

# Add the Docker apt repository
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

tee /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable
EOF

apt-get update -y

# Install Docker and Docker Compose
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

usermod -a -G docker $OPERATOR_USER

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<EOF
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
EOF

mkdir -p /srv/docker
