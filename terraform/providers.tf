terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 0.1.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }
}

provider "helm" {
  alias = "talos"
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(module.talos_cluster.cluster_ca_certificate)
    token                  = module.talos_cluster.cluster_token
  }
}
