locals {
  op = [
    "OPERATOR_USER=${var.operator_user_name}",
    "OPERATOR_GROUP=${var.operator_user_name}",
  ]

  etc_hosts = "sed -i \"s/raspberrypi/$(hostname)/\" /etc/hosts"

  server_builds = [
    "source.arm-image.prusa_i3",
    "source.arm-image.home",
    "source.arm-image.infra",
  ]

  desktop_builds = [
    "source.arm-image.media",
  ]
}

build {
  sources = concat(local.server_builds, local.desktop_builds)

  name = "common"

  provisioner "shell" {
    script = "scripts/common.sh"
  }

  provisioner "shell" {
    only = local.server_builds
    script = "scripts/systemd.sh"
  }

  provisioner "shell" {
    script = "scripts/install-docker.sh"
    environment_vars = local.op
  }

  provisioner "shell" {
    script = "scripts/install-cloud-init.sh"
  }

  provisioner "shell" {
    only = ["arm-image.prusa_i3"]
    script = "scripts/install-octoprint.sh"
    environment_vars = local.op
  }

  provisioner "shell" {
    only = ["arm-image.home"]
    script = "scripts/install-home-assistant.sh"
    environment_vars = local.op
  }

  provisioner "shell" {
    only = ["arm-image.media"]
    script = "scripts/install-media.sh"
  }

  provisioner "file" {
    only = ["arm-image.prusa_i3"]

    destination = "/etc/cloud/cloud.cfg.d/prusa-i3.cfg"
    content = templatefile("templates/cloud-init-common.tmpl", {
      hostname = "prusa-i3"
      cmds : [
        local.etc_hosts,
        "cd /srv/docker/octoprint && docker compose up -d",
      ]
    })
  }

  provisioner "file" {
    only = ["arm-image.home"]

    destination = "/etc/cloud/cloud.cfg.d/home.cfg"
    content = templatefile("templates/cloud-init-common.tmpl", {
      hostname = "home"
      cmds : [
        local.etc_hosts,
        "cd /srv/docker/home-assistant && docker compose up -d",
      ]
    })
  }

  provisioner "file" {
    only = ["arm-image.infra"]

    destination = "/etc/cloud/cloud.cfg.d/infra.cfg"
    content = templatefile("templates/cloud-init-common.tmpl", {
      hostname = "infra"
      cmds : [
        local.etc_hosts,
      ]
    })
  }

  provisioner "file" {
    only = ["arm-image.media"]

    destination = "/etc/cloud/cloud.cfg.d/media.cfg"
    content = templatefile("templates/cloud-init-common.tmpl", {
      hostname = "media"
      cmds : [
        local.etc_hosts,
      ]
    })
  }

  provisioner "shell" {
    only = local.server_builds
    script = "scripts/systemd-post.sh"
  }

  provisioner "shell" {
    only = ["arm-image.infra", "arm-image.home"]
    script = "scripts/wired-post.sh"
  }
}
