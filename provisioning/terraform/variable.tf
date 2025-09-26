variable "hyperv_user" {
  type = string
  default = "Administrator"
}

variable "hyperv_password" {
  type = string
  default = "P@ssw0rd"
  sensitive = true
}

variable "hyperv_host1" {
  type = string
  default = "127.0.0.1"
}

variable "hyperv_port" {
  type = number
  default = 5986
}

variable "hyperv_https" {
  type = bool
  default = false
}

variable "hyperv_insecure" {
  type = bool
  default = true
}

variable "hyperv_use_ntlm" {
  type = bool
  default = true
}

variable "hyperv_tls_server_name" {
  type = string
  default = ""
}

variable "hyperv_cacert_path" {
  type = string
  default = ""
}

variable "hyperv_cert_path" {
  type = string
  default = ""
}

variable "hyperv_key_path" {
  type = string
  default = ""
}

variable "hyperv_script_path" {
  type = string
  default = "C:/Temp/terraform_%RAND%.cmd"
}

variable "hyperv_timeout" {
  type = string
  default = "30s"
}

variable "vms_by_host" {
  type = map(list(object({
    name    = string
    role    = string  # "controlplane" or "worker"
    ip      = string  # static IP to configure inside Talos
    mac     = optional(string)
    memory  = optional(number, 4096)
    cpus    = optional(number, 2)
    disk_gb = optional(number, 40)
    host_key = optional(string) # the key (host map key) to indicate which hyperv host to create on - handled in root module mapping
  })))
}

variable "mgmt_switch_name" {
  type = string
  default = "MgmtSwitch"
}

variable "api_vip" {
  type = string
}

variable "vm_memory" {
  type = number
  default = 4096
}

variable "vm_cpu" {
  type = number
  default = 2
}

variable "switch" {
  type = string
  default = "ExternalSwitch"
}

variable "vhd_name" {
  type = string
  default = "webserver.vhdx"
}

variable "vhd_size_gb" {
  type = number
  default = 40
}
variable "iso_path" {
  type = string
}
