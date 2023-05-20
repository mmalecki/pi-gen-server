variable "source_iso_checksum" {
  description = "Checksum of the built image"
}

variable "source_iso_url" {
  description = "URL or path to the built image"
}

variable "operator_user_name" {
  description = "Operator user on the image"
  default     = "pi"
}

variable "output_directory" {
  default = "../deploy"
}
