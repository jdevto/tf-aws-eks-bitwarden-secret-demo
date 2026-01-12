# Terraform AWS EKS Bitwarden Secrets Manager Demo

A complete Terraform configuration demonstrating how to integrate [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/) with Amazon EKS workloads. This repository provides a production-ready setup for syncing secrets from Bitwarden to Kubernetes using the [Bitwarden Secrets Manager Kubernetes Operator](https://bitwarden.com/help/secrets-manager-kubernetes-operator/).

## Overview

This Terraform configuration deploys:

- **AWS EKS Cluster** - Managed Kubernetes cluster on AWS
- **Bitwarden Secrets Manager Operator** - Kubernetes operator that syncs secrets from Bitwarden to Kubernetes
- **BitwardenSecret CRDs** - Custom resources defining which secrets to sync
- **Bitwarden Reader Demo App** - Web application demonstrating how to read synced secrets

## Architecture

```plaintext
┌─────────────────────────────────┐
│  Bitwarden Secrets Manager      │
│  (Cloud-based secret store)     │
└──────────────┬──────────────────┘
               │
               │ API (Access Token)
               ↓
┌─────────────────────────────────┐
│  Bitwarden Operator             │
│  (Kubernetes Operator)          │
│  - Watches BitwardenSecret CRDs │
│  - Syncs secrets to K8s         │
└──────────────┬──────────────────┘
               │
               │ Creates/Updates
               ↓
┌─────────────────────────────────┐
│  Kubernetes Secrets             │
│  (example-secret, etc.)         │
└──────────────┬──────────────────┘
               │
               │ Reads
               ↓
┌─────────────────────────────────┐
│  Bitwarden Reader App           │
│  (Demo web application)         │
│  - Web UI to view secrets       │
│  - REST API endpoints           │
└─────────────────────────────────┘
```

## Features

- ✅ **Complete EKS Setup** - VPC, EKS cluster, node groups, and add-ons
- ✅ **Bitwarden Integration** - Automated secret syncing via Kubernetes operator
- ✅ **Helm-based Deployment** - Uses official Helm charts for operator and reader app
- ✅ **ALB Ingress** - Public/private ALB for accessing the demo application
- ✅ **RBAC Configuration** - Proper Kubernetes RBAC for secure secret access
- ✅ **Multiple Secrets Support** - Sync multiple secrets with a simple map configuration
- ✅ **Production Ready** - Includes health checks, resource limits, and best practices

## Prerequisites

- **AWS Account** with appropriate permissions
- **Terraform** >= 1.0
- **kubectl** configured to access the EKS cluster
- **Helm** 3.x (for managing releases)
- **Bitwarden Secrets Manager** account with:
  - Organization ID
  - Machine account access token
  - Secrets created in Bitwarden

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd tf-aws-eks-bitwarden-secret-demo
```

### 2. Configure Variables

Create or update `terraform.tfvars`:

```hcl
# AWS Configuration
region         = "ap-southeast-2"
cluster_name   = "bitwarden-demo"
cluster_version = "1.34"

# Bitwarden Configuration
bitwarden_organization_id = "your-org-id"
bitwarden_access_token     = "your-access-token"  # Sensitive

# Secrets to Sync
bitwarden_secrets = {
  example-secret  = "ca058f55-8898-4fbc-99d8-b3cc016b31ac"
  example-secret2 = "7df59617-e031-4b2d-bf76-b3cf00721b76"
}

# Reader App Configuration
bitwarden_reader_ingress_enabled = true
bitwarden_reader_ingress_scheme  = "internet-facing"
```

### 3. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access the Demo Application

After deployment, get the ALB URL:

```bash
# Get the ALB hostname
terraform output -json | jq -r '.bitwarden_reader_alb_hostname.value'

# Or via kubectl
kubectl get ingress -n bitwarden-secrets bitwarden-reader \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Visit the URL in your browser to see the Bitwarden Reader demo application.

## Configuration

### Main Variables

| Variable | Description | Default | Required |
| -------- | ----------- | ------- | -------- |
| `region` | AWS region | `ap-southeast-2` | No |
| `cluster_name` | EKS cluster name | `test` | No |
| `cluster_version` | Kubernetes version | `1.34` | No |
| `bitwarden_organization_id` | Bitwarden organization ID | - | Yes |
| `bitwarden_access_token` | Bitwarden access token | - | Yes |
| `bitwarden_secrets` | Map of secret names to secret IDs | `{}` | No |
| `bitwarden_reader_ingress_enabled` | Enable ALB ingress | `true` | No |
| `bitwarden_reader_ingress_scheme` | ALB scheme | `internet-facing` | No |

### Bitwarden Secrets Configuration

The `bitwarden_secrets` variable is a map where:

- **Key**: Kubernetes secret name (e.g., `example-secret`)
- **Value**: Bitwarden secret ID (UUID)

```hcl
bitwarden_secrets = {
  example-secret  = "ca058f55-8898-4fbc-99d8-b3cc016b31ac"
  api-credentials = "another-secret-id-here"
  database-password = "yet-another-secret-id"
}
```

The Kubernetes secret key name will automatically match the secret name. For example, `example-secret` will create a Kubernetes secret with key `example-secret`.

## Modules

### `modules/vpc`

Creates the VPC, subnets, and networking components for the EKS cluster.

### `modules/eks`

Deploys the EKS cluster, node groups, and add-ons (EBS CSI driver, etc.).

### `modules/bitwarden`

Deploys the Bitwarden Secrets Manager Kubernetes Operator using Helm. Creates:

- Operator namespace
- Secrets namespace
- Kubernetes secret with access token
- Helm release for the operator

### `modules/bitwarden-secret`

Manages a single `BitwardenSecret` CRD that syncs one secret from Bitwarden to Kubernetes.

**Usage:**

```hcl
module "bitwarden_secrets" {
  source   = "./modules/bitwarden-secret"
  for_each = var.bitwarden_secrets

  name            = each.key
  namespace       = "bitwarden-secrets"
  organization_id = var.bitwarden_organization_id
  secret_id       = each.value

  access_token_secret_name = "bitwarden-auth-token"
  access_token_secret_key  = "token"
}
```

### `modules/bitwarden-reader`

Deploys the Bitwarden Reader demo application using the [bitwarden-reader Helm chart](https://k8sforge.github.io/bitwarden-reader-chart/).

**Features:**

- Web UI to view synced secrets
- REST API endpoints
- Sync status from BitwardenSecret CRDs
- ALB ingress support

**Usage:**

```hcl
module "bitwarden_reader" {
  source = "./modules/bitwarden-reader"

  namespace        = "bitwarden-secrets"
  create_namespace = false
  secret_names     = ["example-secret", "example-secret2"]

  ingress_enabled = true
  ingress_scheme  = "internet-facing"
}
```

## Outputs

The configuration provides the following outputs:

- `bitwarden_reader_alb_hostname` - ALB hostname for accessing the demo app
- `bitwarden_reader_namespace` - Namespace where the reader app is deployed

Access outputs with:

```bash
terraform output bitwarden_reader_alb_hostname
```

## How It Works

### 1. Secret Sync Flow

1. **BitwardenSecret CRD Created** - Terraform creates a `BitwardenSecret` custom resource
2. **Operator Watches** - The Bitwarden operator watches for new/updated CRDs
3. **Secret Fetched** - Operator fetches the secret from Bitwarden using the access token
4. **Kubernetes Secret Created** - Operator creates/updates a Kubernetes secret
5. **Application Reads** - Applications can read the secret like any other Kubernetes secret

### 2. Reading Secrets

The Bitwarden Reader demo app demonstrates how to read synced secrets:

- **Kubernetes API** - Reads secrets via Kubernetes API
- **CRD Status** - Reads sync status from BitwardenSecret CRD
- **Web UI** - Displays secrets in a user-friendly interface

## Troubleshooting

### Operator Not Syncing Secrets

1. Check operator logs:

   ```bash
   kubectl logs -n bitwarden-secrets-operator -l app.kubernetes.io/name=bitwarden-secrets-manager-operator
   ```

2. Verify access token:

   ```bash
   kubectl get secret -n bitwarden-secrets bitwarden-auth-token -o jsonpath='{.data.token}' | base64 -d
   ```

3. Check BitwardenSecret CRD status:

   ```bash
   kubectl get bitwardensecret -n bitwarden-secrets example-secret -o yaml
   ```

### Reader App Not Accessible

1. Check ingress status:

   ```bash
   kubectl get ingress -n bitwarden-secrets
   kubectl describe ingress -n bitwarden-secrets bitwarden-reader
   ```

2. Verify ALB controller is installed:

   ```bash
   kubectl get deployment -n kube-system aws-load-balancer-controller
   ```

3. Check pod status:

   ```bash
   kubectl get pods -n bitwarden-secrets -l app.kubernetes.io/name=bitwarden-reader
   kubectl logs -n bitwarden-secrets -l app.kubernetes.io/name=bitwarden-reader
   ```

### Secrets Not Appearing

1. Verify secrets are synced:

   ```bash
   kubectl get secrets -n bitwarden-secrets
   kubectl get secret -n bitwarden-secrets example-secret -o yaml
   ```

2. Check CRD sync status:

   ```bash
   kubectl get bitwardensecret -n bitwarden-secrets -o wide
   ```

3. Trigger manual sync:

   ```bash
   kubectl annotate bitwardensecret example-secret -n bitwarden-secrets \
     force-sync="$(date +%s)" --overwrite
   ```

## Security Considerations

- **Access Token** - Store `bitwarden_access_token` securely (use Terraform Cloud/Enterprise or AWS Secrets Manager)
- **RBAC** - The reader app has minimal RBAC (read-only for secrets and CRDs)
- **Network** - Use internal ALB for production (`ingress_scheme = "internal"`)
- **Secrets** - Never commit `terraform.tfvars` with sensitive values to version control

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: This will delete the EKS cluster and all associated resources. Ensure you have backups if needed.

## References

- [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/)
- [Bitwarden Kubernetes Operator Documentation](https://bitwarden.com/help/secrets-manager-kubernetes-operator/)
- [Bitwarden Reader Helm Chart](https://k8sforge.github.io/bitwarden-reader-chart/)
- [k8s-bitwarden-reader Source](https://github.com/platformfuzz/k8s-bitwarden-reader)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

## License

See [LICENSE](LICENSE) file for details.
