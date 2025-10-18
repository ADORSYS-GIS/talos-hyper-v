locals {
  vms_by_host = {
    for vm in var.host_vms : vm.host_key => vm...
  }
  iso_name_suffix = {
    for vm in var.host_vms : vm.ip => "talos-${vm.ip}.iso"
  }
  cluster_endpoint = "https://${var.talos_vip}:6443"
}
module "talos_image_factory" {
  source = "./modules/talos-image-factory"

  ntp_ip           = var.ntp_server
  talos_version    = var.talos_version
  talos_extensions = var.talos_extensions
  gw_ip            = var.gateway_server
  network_mask     = var.network_mask
  machines_ips     = [for vm in var.host_vms : vm.ip]
}

module "talos_cluster" {
  source = "./modules/talos-cluster"

  cluster_name             = var.cluster_name
  talos_version            = var.talos_version
  controlplane_endpoints   = [for vm in var.host_vms : vm.ip if vm.role == "controlplane"]
  worker_endpoints         = [for vm in var.host_vms : vm.ip if vm.role == "worker"]
  cluster_endpoint         = local.cluster_endpoint
  talos_vip                = var.talos_vip
  talos_installers         = module.talos_image_factory.talos_installers
  registry_mirror_endpoint = var.registry_mirror_endpoint
  ntp_server               = var.ntp_server

  depends_on = [local.host_modules, module.talos_image_factory]
}

module "longhorn" {
  source           = "./modules/longhorn"
  longhorn_version = var.longhorn_version
  talos_vip        = var.talos_vip

  depends_on = [module.talos_cluster]
}
