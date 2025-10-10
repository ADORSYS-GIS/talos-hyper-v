variable "hyperv_hosts" {
  type = map(object({
    host            = string
    port            = optional(number, 5985)
    https           = optional(bool, false)
    insecure        = optional(bool, true)
    use_ntlm        = optional(bool, true)
    user            = string
    password        = string
    cert_thumbprint = optional(string, "")
  }))
  description = "A map of Hyper-V hosts to connect to."
  sensitive   = true
}

variable "host_vms" {
  type = list(object({
    name     = string
    role     = string # "controlplane" or "worker"
    ip       = string # static IP to configure inside Talos
    mac      = optional(string)
    memory   = optional(number, 4096)
    cpus     = optional(number, 2)
    disk_gb  = optional(number, 40)
    host_key = optional(string) # the key (host map key) to indicate which hyperv host to create on - handled in root module mapping
  }))
}

variable "talos_vip" {
  type        = string
  description = "The virtual IP address for the Talos cluster."
  default     = ""
}

variable "vm_memory" {
  type    = number
  default = 4096
}

variable "vm_cpu" {
  type    = number
  default = 2
}

variable "switch" {
  type    = string
  default = "Default Switch"
}

variable "vhd_name" {
  type    = string
  default = "talos-vm.vhdx"
}

variable "vhd_size_gb" {
  type    = number
  default = 40
}

variable "talos_version" {
  type    = string
  default = "v1.11.2"
}
variable "talos_extensions" {
  type        = list(string)
  default     = ["iscsi-tools"]
  description = "List of Talos extensions to install."
}

variable "production" {
  type        = bool
  default     = false
  description = "If true, enforce production checks (HTTPS required, cert thumbprint required)"
}

variable "cluster_name" {
  type        = string
  description = "The name of the Talos cluster."
}

variable "iso_path" {
  type        = string
  description = "Path to the Talos ISO image."
}

variable "longhorn_version" {
  description = "Version of the Longhorn Helm chart to deploy."
  type        = string
  default     = "1.10.0"
}

variable "disk_dir_path" {
  type        = string
  description = "Parent directory for all VMs disks"
  default = "D:\\Hyper-V\\VHDs"
}
