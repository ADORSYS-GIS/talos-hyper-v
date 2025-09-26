terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 0.1.3"
    }
  }
}

# Provider for Host1
provider "hyperv" {
  alias           = "host1"
  user            = var.hyperv_user
  password        = var.hyperv_password
  host            = var.hyperv_host1
  port            = var.hyperv_port
  https           = var.hyperv_https
  insecure        = var.hyperv_insecure
  use_ntlm        = var.hyperv_use_ntlm
  tls_server_name = var.hyperv_tls_server_name
  script_path     = var.hyperv_script_path
  timeout         = var.hyperv_timeout
}

# Provider for Host2
# provider "hyperv" {
#   alias           = "host2"
#   user            = var.hyperv_user
#   password        = var.hyperv_password
#   host            = var.hyperv_host2
#   port            = var.hyperv_port
#   https           = var.hyperv_https
#   insecure        = var.hyperv_insecure
#   use_ntlm        = var.hyperv_use_ntlm
#   tls_server_name = var.hyperv_tls_server_name
#   script_path     = var.hyperv_script_path
#   timeout         = var.hyperv_timeout
# }
