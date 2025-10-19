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
    kubernetes = {
      source  = "hashicorp/kubernetes"
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

provider "kubernetes" {
  host                   = data.talos_machine_configuration.this.cluster_name
  cluster_ca_certificate = base64decode(data.talos_client_configuration.this.client_configuration.ca_certificate)
  token                  = data.talos_machine_configuration.this.machine_secrets.trustdinfo.token
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = module.talos_cluster.client_configuration
}

data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = module.talos_cluster.machine_secrets
}
