variable "release_name" {
  description = "Name of the Helm release."
  type        = string
  default     = "wazuh"
}

variable "chart_version" {
  description = "Version of the Wazuh Helm chart."
  type        = string
  default     = "0.1.0"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy Wazuh into."
  type        = string
  default     = "wazuh"
}

variable "helm_values_load_balancer_ips" {
  description = "YAML values to pass to the Helm chart for load balancer IPs."
  type = object(
    {
      manager   = string
      worker    = string
      dashboard = string
      cluster   = string
    }
  )
  default = {
    manager   = "10.20.0.101"
    worker    = "10.20.0.102"
    dashboard = "10.20.0.103"
    cluster   = "10.20.0.104"
  }
}

variable "helm_values_jira_webhook_url" {
  description = "Jira webhook URL for integration."
  type        = string
  default     = ""
}

variable "helm_values_teams_webhook_url" {
  description = "Microsoft Teams webhook URL for integration."
  type        = string
  default     = ""
}

variable "helm_values_dashboard_branding_logo_default_url" {
  description = "Default URL for the dashboard branding logo."
  type        = string
  default     = "https://www.bvm-ac.org/wp-content/uploads/2019/08/BVMAC-New-R-Nov-2024-.png"
}

variable "helm_values_dashboard_branding_mark_default_url" {
  description = "Default URL for the dashboard branding mark."
  type        = string
  default     = "https://www.bvm-ac.org/wp-content/uploads/2019/08/BVMAC-New-R-Nov-2024-.png"
}

variable "helm_values_dashboard_branding_loading_logo_default_url" {
  description = "Default URL for the dashboard branding loading logo."
  type        = string
  default     = "https://www.bvm-ac.org/wp-content/uploads/2019/08/BVMAC-New-R-Nov-2024-.png"
}

variable "helm_values_dashboard_branding_favicon_url" {
  description = "Favicon URL for the dashboard branding."
  type        = string
  default     = "https://www.bvm-ac.org/wp-content/uploads/2019/08/BVMAC-New-R-Nov-2024-.png"
}

variable "helm_values_dashboard_branding_application_title" {
  description = "Application title for the dashboard branding."
  type        = string
  default     = "Wazuh | BVMAC"
}
