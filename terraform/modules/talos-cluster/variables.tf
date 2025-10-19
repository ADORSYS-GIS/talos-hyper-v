variable "cluster_name" {
  type        = string
  description = "The name of the Talos cluster."
}

variable "talos_version" {
  type        = string
  description = "The version of Talos to use."
}

variable "controlplane_endpoints" {
  type        = list(string)
  description = "A list of IP addresses for the control plane nodes."
}

variable "worker_endpoints" {
  type        = list(string)
  description = "A list of IP addresses for the worker nodes."
  default     = []
}

variable "cluster_endpoint" {
  type        = string
  description = "The cluster endpoint URL."
}

variable "talos_vip" {
  type        = string
  description = "The virtual IP address for the Talos cluster."
  default     = ""
}

variable "ip_range" {
  type = string
}

variable "talos_installers" {
  type        = map(string)
  description = "The Talos installer image URL."
}

variable "ntp_server" {
  type        = string
  description = "Local NTP server"
}

variable "registry_mirror_endpoint" {
  type        = string
  description = "The local docker registry endpoint"
}
