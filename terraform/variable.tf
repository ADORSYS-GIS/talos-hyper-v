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
    name               = string
    role               = string # "controlplane" or "worker"
    ip                 = string # static IP to configure inside Talos
    mac                = optional(string)
    memory             = optional(number)
    cpus               = optional(number)
    disk_gb            = optional(number, 40)
    storage_disk_sizes = optional(list(number), [])
    host_key           = optional(string) # the key (host map key) to indicate which hyperv host to create on - handled in root module mapping
    extensions         = optional(list(string))
  }))
}

variable "talos_vip" {
  type        = string
  description = "The virtual IP address for the Talos cluster."
}

variable "switch" {
  type    = string
  default = "Default Switch"
}

variable "talos_version" {
  type    = string
  default = "v1.11.2"
}

variable "root_secret_name" {
  description = "Name of the Kubernetes Secret that stores the root CA."
  type        = string
  default     = "wazuh-root-ca"
}

variable "cluster_name" {
  type        = string
  description = "The name of the Talos cluster."
}

variable "subject" {
  type = object({
    country      = string
    locality     = string
    organization = string
    common_name  = string
  })
}

variable "iso_prefix_path" {
  type        = string
  description = "Prefix path to the Talos ISO image."
}

variable "longhorn_version" {
  description = "Version of the Longhorn Helm chart to deploy."
  type        = string
  default     = "1.10.0"
}

variable "ntp_server" {
  type        = string
  description = "Local NTP server"
}

variable "gateway_server" {
  type        = string
  description = "Gateway server"
}

variable "network_mask" {
  type    = string
  default = "255.255.255.0"
}

variable "registry_mirror_endpoint" {
  type        = string
  description = "The local docker registry endpoint"
}

variable "default_memory" {
  type    = number
  default = 4096
}

variable "default_cpus" {
  type    = number
  default = 2
}

variable "disk_dir_path" {
  type    = string
  default = null
}

variable "default_talos_extensions" {
  type        = list(string)
  default     = ["iscsi-tools", "util-linux-tools"]
  description = "List of Talos extensions to install."
}

variable "default_dns_01" {
  type    = string
  default = "1.1.1.1"
}

variable "default_dns_02" {
  type    = string
  default = "8.8.8.8"
}

variable "ip_range" {
  type = string
}

variable "wazuh_helm_config" {
  description = "Configuration for the Wazuh deployment."
  type = object({
    helm_release_name          = string
    helm_chart_version         = string
    master_enrollment_password = string
    indexer_auth_username      = string
    indexer_auth_password      = string
  })
  default = {
    helm_release_name          = "wazuh-helm"
    helm_chart_version         = "0.6.1-rc.11"
    master_enrollment_password = "j60B6_e`jmQ_3z!z"
    indexer_auth_username      = "wazuh"
    indexer_auth_password      = "Wazuh@12345"
  }
  sensitive = true
}
