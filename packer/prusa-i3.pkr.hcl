source "arm-image" "prusa_i3" {
  iso_url           = var.source_iso_url
  iso_checksum      = var.source_iso_checksum
  image_type        = "raspberrypi"
  output_filename   = "${var.output_directory}/prusa_i3.img"
  target_image_size = var.target_image_size
  qemu_binary       = "qemu-aarch64-static"
}

build {
  sources = ["source.arm-image.prusa_i3"]

  name = "common"

  provisioner "shell" {
    script = "scripts/common.sh"
  }

  provisioner "shell" {
    script = "scripts/install-docker.sh"
    environment_vars = [
      "OPERATOR_USER=${var.operator_user_name}"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-cloud-init.sh"
  }

  provisioner "shell" {
    script = "scripts/install-octoprint.sh"
  }

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg.d/prusa-i3.cfg"
    content = templatefile("templates/cloud-init-common.tmpl", {
      hostname = "prusa-i3"
      cmds : [
        "sed -i \"s/raspberrypi/$(hostname)/\" /etc/hosts",
        "cd /srv/docker/octoprint && docker-compose up -d",
      ]
    })
  }
}
