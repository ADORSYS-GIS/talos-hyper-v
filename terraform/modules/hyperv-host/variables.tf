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
  type = list(object({
    name    = string
    role    = string # "controlplane" or "worker"
    ip      = string # static IP to configure inside Talos
    mac     = optional(string)
    memory  = optional(number, 4096)
    cpus    = optional(number, 2)
    disk_gb = optional(number, 40)
  }))
  description = "A list of VMs to create on this host."
}

variable "iso_path" {
  type        = string
  description = "Path to the Talos ISO image on the Hyper-V host."
}

variable "cluster_switch" {
  type        = string
  description = "Name of the virtual switch to connect the VMs to."
}

variable "production" {
  type        = bool
  default     = false
  description = "If true, enforce production checks (HTTPS required, cert thumbprint required)"
}