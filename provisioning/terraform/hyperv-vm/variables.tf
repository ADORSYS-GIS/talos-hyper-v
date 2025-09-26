variable "vms" {
  type = list(object({
    name    = string
    role    = string
    ip      = string
    mac     = optional(string)
    memory  = optional(number, 4096)
    cpus    = optional(number, 2)
    disk_gb = optional(number, 40)
  }))
}

variable "iso_path" {
  type = string
}

variable "cluster_switch" {
  type = string
}
