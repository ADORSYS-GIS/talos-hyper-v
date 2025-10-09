variable "longhorn_version" {
  description = "Version of the Longhorn Helm chart to deploy."
  type        = string
  default     = "1.10.0"
}

variable "talos_vip" {
  description = "The VIP address of the Talos cluster."
  type        = string
}