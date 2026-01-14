output "alb_hostname" {
  description = "ALB hostname for the reader app"
  value       = var.ingress_enabled ? try(data.kubernetes_ingress_v1.reader[0].status[0].load_balancer[0].ingress[0].hostname, null) : null
}

output "namespace" {
  description = "Namespace where the reader app is deployed"
  value       = var.namespace
}

output "service_name" {
  description = "Service name for the reader app"
  value       = "${var.app_name}-bitwarden-reader"
}
