module "talos_image_factory" {
  source = "./modules/talos-image-factory"

  ntp_ip        = var.ntp_server
  talos_version = var.talos_version
  gw_ip         = var.gateway_server
  network_mask  = var.network_mask

  machines_configs = {
    for vm in var.host_vms : vm.ip => {
      host_name   = vm.name
      mac_address = try(coalesce(vm.mac, null), local.vms_macs[vm.ip])
      extensions  = try(coalesce(vm.extensions, null), default_talos_extensions)
    }
  }

  dns_01 = var.default_dns_01
  dns_02 = var.default_dns_02
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
