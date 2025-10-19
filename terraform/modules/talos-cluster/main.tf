resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = var.controlplane_endpoints
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = { for idx, ip in var.controlplane_endpoints : "talos-cp${idx + 1}" => ip }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value
  config_patches = var.talos_vip != "" ? [
    templatefile("${path.module}/templates/controlplane_patch.yaml", {
      hostname                 = each.key
      ip_addr                  = each.value
      talos_vip                = var.talos_vip
      ip_range                 = var.ip_range
      registry_mirror_endpoint = var.registry_mirror_endpoint
      ntp_server               = var.ntp_server

    })
  ] : []
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = { for idx, ip in var.worker_endpoints : "talos-wk${idx + 1}" => ip }


  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value

  config_patches = var.talos_vip != "" ? [
    templatefile("${path.module}/templates/worker_patch.yaml", {
      hostname                 = each.key
      ip_addr                  = each.value
      talos_installer          = var.talos_installers[each.value]
      registry_mirror_endpoint = var.registry_mirror_endpoint
      ntp_server               = var.ntp_server
    })
  ] : []
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
  node                 = var.controlplane_endpoints[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controlplane_endpoints[0]
}

data "talos_cluster_health" "this" {
  depends_on = [
    talos_cluster_kubeconfig.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = var.controlplane_endpoints
  endpoints            = [var.talos_vip]
  worker_nodes         = var.worker_endpoints
}
