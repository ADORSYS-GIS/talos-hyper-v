resource "helm_release" "litmus" {
  name             = "${var.namespace}-chaos"
  repository       = "https://litmuschaos.github.io/litmus-helm"
  chart            = "litmus"
  namespace        = var.namespace
  create_namespace = true
  version          = "3.24.0"
  timeout          = 900
  wait             = true
  wait_for_jobs    = true

  set {
    name  = "installCRDs"
    value = "false"
  }

  set {
    name  = "portal.frontend.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "mongodb.enabled"
    value = "true"
  }

  set {
    name  = "mongodb.auth.enabled"
    value = "true"
  }

  set {
    name  = "server.waitForMongodb.enabled"
    value = "true"
  }
}

