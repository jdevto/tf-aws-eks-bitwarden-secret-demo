# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name               = var.cluster_name
  cluster_name       = var.cluster_name
  availability_zones = ["${var.region}a", "${var.region}b"]

  tags = merge(local.common_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name          = local.cluster_name
  cluster_version       = var.cluster_version
  enable_ebs_csi_driver = var.enable_ebs_csi_driver
  # Cluster control plane can use both public and private subnets
  subnet_ids = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  # Node groups should be in private subnets only for security
  node_subnet_ids = module.vpc.private_subnet_ids
  vpc_id          = module.vpc.vpc_id

  tags = local.common_tags
}

# Bitwarden Secrets Manager Module
module "bitwarden" {
  source = "./modules/bitwarden"

  organization_id = var.bitwarden_organization_id
  access_token    = var.bitwarden_access_token

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_ca_data
  cluster_name     = module.eks.cluster_name

  tags = local.common_tags

  depends_on = [
    module.vpc,
    module.eks
  ]
}

# Bitwarden Secret Sync Modules
# Create a module instance for each secret in bitwarden_secrets map
module "bitwarden_secrets" {
  source   = "./modules/bitwarden-secret"
  for_each = var.bitwarden_secrets

  name            = each.key
  namespace       = module.bitwarden.secrets_namespace
  organization_id = var.bitwarden_organization_id
  secret_id       = each.value

  access_token_secret_name = module.bitwarden.auth_secret_name
  access_token_secret_key  = "token"

  tags = local.common_tags

  depends_on = [
    module.vpc,
    module.eks,
    module.bitwarden
  ]
}

# Bitwarden Reader Demo Web App
# Demonstrates reading secrets synced from Bitwarden to Kubernetes
module "bitwarden_reader" {
  source = "./modules/bitwarden-reader"

  namespace        = module.bitwarden.secrets_namespace
  create_namespace = false
  secret_names = var.bitwarden_reader_secret_names != null ? var.bitwarden_reader_secret_names : (
    [for name, module in module.bitwarden_secrets : module.kubernetes_secret_name]
  )

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_ca_data
  cluster_name     = module.eks.cluster_name

  ingress_enabled = var.bitwarden_reader_ingress_enabled
  ingress_scheme  = var.bitwarden_reader_ingress_scheme

  tags = local.common_tags

  depends_on = [
    module.vpc,
    module.eks,
    module.bitwarden_secrets
  ]
}
