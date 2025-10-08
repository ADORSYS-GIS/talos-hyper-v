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
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  client_certificate     = module.talos_cluster.kubernetes_client_configuration.client_certificate
  client_key             = module.talos_cluster.kubernetes_client_configuration.client_key
  cluster_ca_certificate = module.talos_cluster.kubernetes_client_configuration.ca_certificate
  host                   = module.talos_cluster.kubernetes_client_configuration.host
}

provider "helm" {

  kubernetes {
    client_certificate     = module.talos_cluster.kubernetes_client_configuration.client_certificate
    client_key             = module.talos_cluster.kubernetes_client_configuration.client_key
    cluster_ca_certificate = module.talos_cluster.kubernetes_client_configuration.ca_certificate
    host                   = module.talos_cluster.kubernetes_client_configuration.host
  }
}
