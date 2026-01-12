# Helm release for bitwarden-reader
resource "helm_release" "bitwarden_reader" {
  name       = var.app_name
  repository = "https://k8sforge.github.io/bitwarden-reader-chart"
  chart      = "bitwarden-reader"
  namespace  = var.namespace
  version    = var.chart_version != "" ? var.chart_version : null

  create_namespace = var.create_namespace

  values = [
    yamlencode({
      namespace = {
        name   = var.namespace
        create = var.create_namespace
      }
      image = {
        repository = length(split(":", var.image)) > 1 ? split(":", var.image)[0] : var.image
        tag        = length(split(":", var.image)) > 1 ? split(":", var.image)[1] : "latest"
        pullPolicy = var.image_pull_policy
      }
      replicaCount = var.replicas
      app = {
        secretNames = var.secret_names
      }
      ingress = {
        enabled   = var.ingress_enabled
        className = "alb"
        annotations = var.ingress_enabled ? {
          "alb.ingress.kubernetes.io/scheme"                       = var.ingress_scheme
          "alb.ingress.kubernetes.io/target-type"                  = "ip"
          "alb.ingress.kubernetes.io/listen-ports"                 = "[{\"HTTP\": 80}]"
          "alb.ingress.kubernetes.io/healthcheck-path"             = "/api/v1/health"
          "alb.ingress.kubernetes.io/healthcheck-protocol"         = "HTTP"
          "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
          "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "5"
          "alb.ingress.kubernetes.io/healthy-threshold-count"      = "2"
          "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "3"
        } : {}
        hosts = [{
          host = ""
          paths = [{
            path     = "/"
            pathType = "Prefix"
          }]
        }]
      }
      livenessProbe = {
        httpGet = {
          path = "/api/v1/health"
          port = 8080
        }
        initialDelaySeconds = 60
        periodSeconds       = 30
        timeoutSeconds      = 5
        failureThreshold    = 3
      }
      readinessProbe = {
        httpGet = {
          path = "/api/v1/health"
          port = 8080
        }
        initialDelaySeconds = 60
        periodSeconds       = 10
        timeoutSeconds      = 5
        failureThreshold    = 3
      }
    })
  ]

  depends_on = []
}

data "kubernetes_ingress_v1" "reader" {
  count = var.ingress_enabled ? 1 : 0

  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  depends_on = [helm_release.bitwarden_reader]
}
