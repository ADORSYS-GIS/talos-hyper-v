terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.2.1"
    }
  }
}

provider "hyperv" {
  user     = var.host_config.user
  password = var.host_config.password
  host     = var.host_config.host
  port     = var.host_config.port
  https    = var.host_config.https
  insecure = var.host_config.insecure
  use_ntlm = var.host_config.use_ntlm
}
