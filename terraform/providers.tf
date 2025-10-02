terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 0.1.3"
    }
  }
}

provider "hyperv" {
  user     = var.hyperv_host.user
  password = var.hyperv_host.password
  host     = var.hyperv_host.host
  port     = var.hyperv_host.port
  https    = var.hyperv_host.https
  insecure = var.hyperv_host.insecure
  use_ntlm = var.hyperv_host.use_ntlm
}
