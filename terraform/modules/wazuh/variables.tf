variable "root_secret_name" {
  description = "Name of the Kubernetes Secret that stores the root CA."
  type        = string
  default     = "wazuh-root-ca"
}

variable "output_folder" {
  description = "Folder to also write PEM files to (optional, for parity with your script)."
  type        = string
  default     = "wazuh-certs"
}

variable "subject" {
  type = object({
    country      = string
    locality     = string
    organization = string
    common_name  = string
  })
}

variable "helm_release_name" {
  description = "Name of the Helm release for Wazuh."
  type        = string
  default     = "wazuh"
}

variable "helm_chart_version" {
  description = "Version of the Wazuh Helm chart."
  type        = string
  default     = "0.6.1-rc.11"
}

variable "helm_values" {
  description = "YAML values to pass to the Wazuh Helm chart."
  type        = string
  default     = ""
}
