terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 0.1.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
  }
}
