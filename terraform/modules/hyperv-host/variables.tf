variable "host_config" {
  type = object({
    host     = string
    port     = optional(number, 5985)
    https    = optional(bool, false)
    insecure = optional(bool, true)
    use_ntlm = optional(bool, true)
    user     = string
    password = string
  })
  description = "Hyper-V host connection details."
  sensitive   = true
}

variable "vms" {
  type = map(object({
    name                     = string
    ip                       = string # static IP to configure inside Talos
    mac                      = optional(string)
    memory                   = optional(number, 4096)
    cpus                     = optional(number, 2)
    disk_gb                  = optional(number, 40)
    storage_disk_label_sizes = optional(list(number), [])
    disk_dir_path            = optional(string)
  }))
  description = "A list of VMs to create on this host."
}

variable "vms_macs" {
  type = map(string)
}

variable "default_memory" {
  type = number
}

variable "default_cpus" {
  type = number
}

variable "default_disk_dir_path" {
  type    = string
  default = null
}

variable "iso_paths" {
  type        = map(string)
  description = "Path to the Talos ISO image on the Hyper-V host, by IP"
}

variable "cluster_switch" {
  type        = string
  description = "Name of the virtual switch to connect the VMs to."
}
