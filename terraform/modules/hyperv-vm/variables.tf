variable "name" { 
  type = string 
}

variable "mac" { 
  type = string 
}

variable "memory" { 
  type = number
  default = 4096 
}

variable "cpus" { 
  type = number
  default = 2 
}

variable "disk_gb" { 
  type = number
  default = 50 
}

variable "storage_disk_gb" { 
  type = number 
  default = null
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
