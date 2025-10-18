variable "talos_version" {
  type        = string
  description = "The version of Talos to use."
}

variable "talos_extensions" {
  type        = list(string)
  description = "A list of Talos extensions to include in the image."
}

variable "machines_ips" {
  type = list(string)
}

variable "ntp_ip" {
  type = string
}

variable "gw_ip" {
  type = string
}

variable "network_mask" {
  type = string
}
