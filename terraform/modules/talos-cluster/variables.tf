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
  type = string
  description = "The cluster endpoint URL."
}