source "arm-image" "prusa_i3" {
  iso_url           = var.source_iso_url
  iso_checksum      = var.source_iso_checksum
  image_type        = "raspberrypi"
  output_filename   = "${var.output_directory}/prusa_i3.img"
  qemu_binary       = "qemu-aarch64-static"
  target_image_size = var.target_image_size
}

source "arm-image" "home" {
  iso_url           = var.source_iso_url
  iso_checksum      = var.source_iso_checksum
  image_type        = "raspberrypi"
  output_filename   = "${var.output_directory}/home.img"
  qemu_binary       = "qemu-aarch64-static"
  target_image_size = var.target_image_size
}

source "arm-image" "infra" {
  iso_url           = var.source_iso_url
  iso_checksum      = var.source_iso_checksum
  image_type        = "raspberrypi"
  output_filename   = "${var.output_directory}/infra.img"
  qemu_binary       = "qemu-aarch64-static"
  target_image_size = var.target_image_size
}
