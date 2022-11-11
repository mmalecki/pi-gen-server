#!/usr/bin/env bash
apt-get -y install docker.io docker-compose
usermod -a -G docker $OPERATOR_USER

mkdir -p /srv/docker
