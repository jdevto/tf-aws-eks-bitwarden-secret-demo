# output "cluster_name" {
#   description = "Name of the EKS cluster"
#   value       = module.eks.cluster_name
# }

# output "cluster_endpoint" {
#   description = "Endpoint for EKS control plane"
#   value       = module.eks.cluster_endpoint
# }

# output "k8s_inspector_url" {
#   description = "URL to access k8s-inspector application (check ingress for ALB hostname)"
#   value = var.enable_bitwarden_demo_app ? (
#     "http://k8s-inspector.${module.bitwarden.secrets_namespace}.svc.cluster.local"
#   ) : null
# }

# output "k8s_inspector_namespace" {
#   description = "Namespace where k8s-inspector is deployed"
#   value       = var.enable_bitwarden_demo_app ? module.bitwarden.secrets_namespace : null
# }

# output "bitwarden_reader_url" {
#   description = "URL to access the Bitwarden reader demo app"
#   value       = var.enable_bitwarden_reader ? module.bitwarden_reader.app_url : null
# }

# output "bitwarden_reader_alb_hostname" {
#   description = "ALB hostname for the Bitwarden reader app"
#   value       = var.enable_bitwarden_reader ? module.bitwarden_reader.alb_hostname : null
# }
