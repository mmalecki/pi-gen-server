#!/usr/bin/env bash
set -e

apt-get -y install cloud-init

cat -> /etc/cloud/cloud.cfg.d/nocloud.cfg <<EOF
datasource_list: [ NoCloud, None ]
datasource:
  NoCloud:
    fs_label: None
EOF
