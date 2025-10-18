variable "talos_version" {
  type        = string
  description = "The version of Talos to use."
}

variable "machines_configs" {
  type = map(object({
    host_name   = string
    mac_address = string
    extensions  = list(string)
  }))
}

variable "dns_01" { 
  type = string 
}

variable "dns_02" { 
  type = string 
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
