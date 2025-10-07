locals {
  vms_by_host = {
    for vm in var.host_vms : vm.host_key => vm...
  }
}

module "host1" {
  source = "./modules/hyperv-host"

  providers = {
    hyperv = hyperv.host1
  }

  host_config    = var.hyperv_hosts["host1"]
  vms            = local.vms_by_host["host1"]
  iso_path       = var.iso_path
  cluster_switch = var.switch
  production     = var.production
}

# Combine outputs from all hosts
module "talos_image_factory" {
  source = "./modules/talos-image-factory"

  talos_version    = var.talos_version
  talos_extensions = var.talos_extensions
}

module "talos_cluster" {
  source = "./modules/talos-cluster"

  cluster_name           = var.cluster_name
  talos_version          = var.talos_version
  controlplane_endpoints = [for vm in var.host_vms : vm.ip if vm.role == "controlplane"]
  worker_endpoints       = [for vm in var.host_vms : vm.ip if vm.role == "worker"]
  cluster_endpoint       = "https://${var.talos_vip}:6443"
  talos_vip              = var.talos_vip

  depends_on = [module.host1]
}

