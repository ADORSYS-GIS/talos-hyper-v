variable "hyperv_hosts" {
  type = map(object({
    host     = string  # e.g. "10.0.0.10"
    username = string
    # iso_path is the path on that hyperv host where the iso will be placed
    iso_path = string
  }))
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
