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

variable "wazuh_helm_config" {
  description = "Configuration for the Wazuh deployment."
  type = object({
    helm_release_name          = string
    helm_chart_version         = string
    master_enrollment_password = string
    indexer_auth_username      = string
    indexer_auth_password      = string
  })
  sensitive = true
}
