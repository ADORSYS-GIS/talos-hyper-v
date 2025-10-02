variable "hyperv_host" {
  type = object({
    host            = string
    port            = optional(number, 5985)
    https           = optional(bool, false)
    insecure        = optional(bool, true)
    use_ntlm        = optional(bool, true)
    user            = string
    password        = string
    tls_server_name = optional(string, "")
    cacert_path     = optional(string, "")
    cert_path       = optional(string, "")
    key_path        = optional(string, "")
  })
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

variable "api_vip" {
  type = string
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
  default = "webserver.vhdx"
}

variable "vhd_size_gb" {
  type    = number
  default = 40
}

variable "talos_version" {
  type    = string
  default = "v1.11.2"
}

variable "iso_path" {
  type = string
}

variable "production" {
  type    = bool
  default = false
  description = "If true, enforce production checks (HTTPS required, cert thumbprint required)"
}