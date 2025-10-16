# Kubernetes Platform Infrastructure Template

A production-ready Infrastructure as Code (IaC) template for deploying and managing Kubernetes platforms using Terraform and GitOps. This template provides a complete foundation for teams to build, deploy, and operate containerized applications at scale.

## 🎯 Target Audience

This template is designed for:

- **Developers** who need to deploy applications to Kubernetes
- **Embedded DevOps Engineers** managing platform infrastructure
- **Platform Teams** building internal developer platforms
- **SRE Teams** operating production Kubernetes environments

## 🏗️ Architecture Overview

This template implements a **GitOps-first** approach to Kubernetes platform management, providing:

- **Infrastructure as Code**: Complete Terraform-based infrastructure provisioning
- **GitOps Workflow**: ArgoCD-driven application deployments
- **Multi-Environment Support**: Dev, staging, and production environments
- **Security by Default**: RBAC, network policies, and secrets management
- **Observability**: Built-in monitoring and logging capabilities

### Directory Structure

```text
platform/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                  # Core EKS cluster and platform modules
│   ├── variables.tf             # Configuration variables
│   ├── values/                  # Environment-specific configurations
│   │   ├── dev.tfvars          # Development environment
│   │   └── prod.tfvars         # Production environment
│   └── README.md               # Terraform documentation
└── release/                     # GitOps Configuration
    ├── clusters/               # Cluster definitions
    │   ├── dev.yaml           # Development cluster config
    │   └── prod.yaml          # Production cluster config
    ├── config/                # Platform addon configurations
    │   └── argo-cd/           # ArgoCD configuration
    └── workloads/             # Application workloads
        ├── applications/      # Business applications
        └── system/           # Platform system components
```

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.0.0
- **AWS CLI** configured with appropriate permissions
- **kubectl** for cluster interaction
- **Git** for version control

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd terraform-aws-infrastructure-template

# Copy the platform template
cp -r examples/platform .

# Navigate to the platform directory
cd platform
```

### 2. Configure Your Environment

Update the environment-specific variables in `terraform/values/dev.tfvars`:

```hcl
# Basic cluster configuration
cluster_name = "my-platform-dev"
environment  = "development"

# GitHub integration
github_app_id                = "your-github-app-id"
github_app_installation_id   = "your-installation-id"
github_app_private_key       = "your-private-key"

# Workload repository (where your applications live)
workloads_repository_name = "my-org/my-workloads"

# Tags for resource management
tags = {
  Environment = "development"
  Team        = "platform"
  Project     = "my-platform"
}
```

### 3. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file="values/dev.tfvars"

# Apply the configuration
terraform apply -var-file="values/dev.tfvars"
```

### 4. Access Your Cluster

```bash
# Configure kubectl
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify cluster access
kubectl get nodes
kubectl get pods -A
```

## 📋 Configuration Guide

### Infrastructure Configuration

The `terraform/` directory contains all infrastructure definitions:

#### Core Components

- **EKS Cluster**: Managed Kubernetes cluster with latest features
- **Networking**: VPC, subnets, and security groups
- **Security**: IAM roles, policies, and access management
- **GitOps**: ArgoCD for application deployment
- **Monitoring**: Prometheus, Grafana, and logging stack

#### Key Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `cluster_name` | EKS cluster name | `my-platform-dev` |
| `kubernetes_version` | Kubernetes version | `1.32` |
| `workloads_repository_name` | GitOps repository | `my-org/workloads` |
| `enable_platform` | Install platform addons | `true` |

### GitOps Configuration

The `release/` directory contains GitOps configurations:

#### Cluster Definitions (`clusters/`)

Each YAML file defines a cluster configuration:

```yaml
cluster_name: dev
cloud_vendor: aws
environment: development
tenant_repository: https://github.com/my-org/workloads.git
platform_repository: https://github.com/appvia/kubernetes-platform.git
labels:
  enable_cert_manager: "true"
  enable_cilium: "true"
  enable_external_secrets: "true"
```

#### Application Workloads (`workloads/`)

Deploy applications using Helm charts:

```yaml
# workloads/applications/my-app/dev.yaml
helm:
  repository: https://my-helm-repo.com
  chart: my-application
  version: "1.2.3"
namespace:
  name: my-app
  pod_security: restricted
```

## 🔧 Usage Patterns

### For Developers

#### Deploying Applications

1. **Create Application Configuration**:

   ```bash
   # Create your application config
   mkdir -p release/workloads/applications/my-app
   cat > release/workloads/applications/my-app/dev.yaml << EOF
   helm:
     repository: https://my-helm-repo.com
     chart: my-application
     version: "1.2.3"
   namespace:
     name: my-app
   EOF
   ```

2. **Commit and Deploy**:

   ```bash
   git add release/workloads/applications/my-app/
   git commit -m "Add my-application to dev environment"
   git push origin main
   ```

3. **Monitor Deployment**:

   ```bash
   # Check ArgoCD application status
   kubectl get applications -n argocd
   
   # View application pods
   kubectl get pods -n my-app
   ```

#### Environment Promotion

Promote applications between environments by copying configurations:

```bash
# Promote from dev to staging
cp release/workloads/applications/my-app/dev.yaml \
   release/workloads/applications/my-app/staging.yaml

# Update version for production
sed -i 's/version: "1.2.3"/version: "1.2.4"/' \
   release/workloads/applications/my-app/prod.yaml
```

### For Platform Teams

#### Managing Platform Addons

Configure platform components in `release/config/`:

```yaml
# release/config/argo-cd/all.yaml
argocd:
  server:
    config:
      url: https://argocd.my-platform.com
  rbac:
    policy.default: role:readonly
```

#### Cluster Scaling

Update cluster configuration for scaling:

```hcl
# terraform/values/prod.tfvars
kubernetes_version = "1.32"
availability_zones = 3

# Enable additional features
enable_platform = true
```

#### Security Configuration

Configure access control:

```hcl
# terraform/values/prod.tfvars
access_entries = {
  developers = {
    principal_arn = "arn:aws:iam::123456789012:role/Developers"
    kubernetes_groups = ["developers"]
    policy_associations = {
      developer-policy = {
        policy_arn = "arn:aws:eks:us-west-2:123456789012:cluster/my-platform-prod/eks:pod-execution-role"
        access_scope = {
          type = "namespace"
          namespaces = ["dev-*", "staging-*"]
        }
      }
    }
  }
}
```

## 🛡️ Security Features

### Built-in Security

- **Pod Security Standards**: Enforced at the namespace level
- **Network Policies**: Cilium-based network segmentation
- **RBAC**: Role-based access control for all resources
- **Secrets Management**: External Secrets Operator for secure secret handling
- **Image Security**: Container image scanning and policy enforcement

### Security Best Practices

1. **Use Least Privilege**: Configure minimal required permissions
2. **Enable Pod Security**: Use `restricted` pod security standards
3. **Network Segmentation**: Implement network policies for application isolation
4. **Secret Rotation**: Use External Secrets for automatic secret rotation
5. **Regular Updates**: Keep platform components updated

## 📊 Monitoring and Observability

### Built-in Monitoring

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Dashboards and visualization
- **Jaeger**: Distributed tracing
- **Fluentd**: Log aggregation
- **AlertManager**: Alert routing and management

### Accessing Dashboards

```bash
# Port-forward to access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Access Grafana at http://localhost:3000
# Default credentials: admin/prom-operator
```

## 🔄 GitOps Workflow

### Application Lifecycle

1. **Development**: Developers create application configurations
2. **Review**: Pull requests are reviewed by platform team
3. **Merge**: Changes are merged to main branch
4. **Sync**: ArgoCD automatically syncs changes to clusters
5. **Monitor**: Platform team monitors deployment health

### Branch Strategy

```text
main
├── feature/new-application
├── feature/update-config
└── hotfix/critical-fix
```

## 🚨 Troubleshooting

### Common Issues

#### Cluster Access Issues

```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify cluster exists
aws eks describe-cluster --name <cluster-name>

# Update kubeconfig
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

#### Application Deployment Issues

```bash
# Check ArgoCD application status
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd

# Check application pods
kubectl get pods -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

#### Infrastructure Issues

```bash
# Check Terraform state
terraform show

# Verify AWS resources
aws eks list-clusters
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=<cluster-name>"
```

### Debugging Commands

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
terraform apply

# Check cluster health
kubectl get nodes
kubectl get pods -A
kubectl top nodes
kubectl top pods -A
```

## 📚 Additional Resources

### Documentation

- [Kubernetes Platform Documentation](https://appvia.github.io/kubernetes-platform/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Ready to get started?** Follow the [Quick Start](#-quick-start) guide above to deploy your first Kubernetes platform!
