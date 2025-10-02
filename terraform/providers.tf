terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 0.1.3"
    }
    powershell = {
      source  = "hashicorp/powershell"
      version = ">= 1.0"
    }
  }
}

provider "hyperv" {
  user     = var.hyperv_hosts["host1"].user
  password = var.hyperv_hosts["host1"].password
  host     = var.hyperv_hosts["host1"].host
  port     = var.hyperv_hosts["host1"].port
  https    = var.hyperv_hosts["host1"].https
  insecure = var.hyperv_hosts["host1"].insecure
  use_ntlm = var.hyperv_hosts["host1"].use_ntlm
}
