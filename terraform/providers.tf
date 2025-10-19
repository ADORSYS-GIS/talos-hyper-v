terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "~> 1.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(module.talos_cluster.cluster_ca_certificate)
    token                  = module.talos_cluster.cluster_token
  }
}
