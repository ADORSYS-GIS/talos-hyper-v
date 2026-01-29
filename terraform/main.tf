module "talos_image_factory" {
  source = "./modules/talos-image-factory"

  ntp_ip        = var.ntp_server
  talos_version = var.talos_version
  gw_ip         = var.gateway_server
  network_mask  = var.network_mask

  machines_configs = {
    for vm in var.host_vms : vm.ip => {
      host_name        = vm.name
      easy_mac_address = replace(coalesce(vm.mac, local.vms_macs[vm.ip]), ":", "")
      extensions       = coalesce(vm.extensions, var.default_talos_extensions)
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
  ip_range                 = var.ip_range
  kubernetes_version       = var.kubernetes_version

  depends_on = [local.host_modules, module.talos_image_factory]
}

module "longhorn" {
  source           = "./modules/longhorn"
  longhorn_version = var.longhorn_version

  depends_on = [module.talos_cluster]
}

module "wazuh" {
  source = "./modules/wazuh"

  root_secret_name = var.root_secret_name
  output_folder    = "wazuh-certs-${var.cluster_name}"
  subject          = var.subject

  depends_on = [module.longhorn]
}

module "litmus_chaos" {
  source              = "./modules/litmus-chaos"
  namespace           = var.litmus_namespace
  runtime_environment = var.runtime_environment
  runtime_socket_path = var.runtime_socket_path

  depends_on = [module.longhorn]
}
