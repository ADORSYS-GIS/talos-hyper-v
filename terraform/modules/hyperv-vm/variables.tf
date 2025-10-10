variable "vm" {
  type = object({
    name    = string
    role    = string
    ip      = string
    mac     = optional(string)
    memory  = optional(number, 4096)
    cpus    = optional(number, 2)
    disk_gb = optional(number, 40)
  })
}

variable "iso_path" {
  type        = string
  description = "Path to the Talos ISO image."
}

variable "cluster_switch" {
  type        = string
  description = "External Switch all VMs should be connected to."
}

variable "disk_dir_path" {
  type        = string
  description = "Parent directory for all VMs disks"
  default     = "D:\\Hyper-V\\VHDs"
}
