# Container Platform

## Overview

Built for DevOps, Platform Engineers, and SREs, this solution streamlines cluster management by eliminating operational overhead, automating deployments at scale, and enforcing consistency across environments—whether using a distributed or hub-and-spoke architecture.

Reduce complexity, embrace automation, and accelerate delivery with a scalable, self-healing, and declarative approach to Kubernetes management.

## Documentation

For a complete understanding on how the platform work visit: <https://appvia.github.io/kubernetes-platform/>

## Scope and Intent

### Why This Pattern?

Managing multiple Kubernetes clusters across different environments presents challenges in consistency, scalability, and automation. This solution provides:

- **Standardized provisioning** – Automate cluster creation with Infrastructure as Code (IaC)
- **GitOps-based management** – Declarative, version-controlled deployments using ArgoCD
- **Flexible architectures** – Support for both distributed and hub-and-spoke models
- **Secure multi-cluster operations** – Enforce policies, RBAC, and secrets management at scale
- **Tenant Applications** – Provides tenant consumers an easy way to onboard their workloads

### Platform Tenets

Too often, platforms are designed from a purely technical standpoint, packed with cutting-edge tools and complex abstractions—yet they fail to deliver a great developer experience. They become rigid, overwhelming, and unintuitive, forcing teams to navigate layers of complexity just to deploy and operate their workloads.

This is where strong platform tenets come in:

- **Treat the platform as a product, not just infrastructure**—it should have clear users, a roadmap, and continuous improvements
- **Focus on developer experience**—make workflows intuitive and efficient
- **Provide self-service capabilities** for developers to deploy and manage workloads independently
- **Ensure guardrails, not gates**—provide secure defaults but allow flexibility when needed
- **Optimize for usability and maintainability**, not just technical capability
- **Reduce cognitive load** by abstracting unnecessary infrastructure details
- **Follow opinionated defaults** but allow extensibility for advanced use cases

## Architecture

### Supported Patterns

#### Distributed Architecture

- Independent clusters per environment/team
- Decentralized management and operations
- High isolation and autonomy

#### Hub-and-Spoke Architecture

- Central management cluster
- Spoke clusters for workloads
- Centralized policy enforcement

### Key Components

- **Kubernetes Clusters** - Multi-region, multi-environment support
- **GitOps Workflow** - ArgoCD for declarative deployments
- **Policy Management** - OPA Gatekeeper for policy enforcement
- **Service Mesh** - Istio for traffic management and security
- **Monitoring & Observability** - Prometheus, Grafana, and Jaeger
- **Security** - RBAC, network policies, and secrets management

## Getting Started

### Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured
- kubectl installed
- ArgoCD CLI (optional)

### Quick Start

1. **Move the Container Platform**

Move the files from exmaples/platform into the base directory.

```bash
$ tree -d
.
├── examples
│   ├── infrastructure
│   └── platform
│       ├── assets
│       └── values
├── scripts
└── values

8 directories
$ pwd
github.com/appvia/terraform-aws-infrastructure-template
```

Copy the files into the base.

```shell
cp -r examples/platform .
```

2. Tenant Repository

Next we need to define the [workloads repository](https://appvia.github.io/kubernetes-platform/architecture/overview/) (referred to as Tenant Repository). Update the `values/productions.tfvars`

```shell
# The name of the repository used to store the workload definitions 
#workloads_repository_name = UPDATE ME
```

Choose a repository name within your Github organization. This can be referenced by mutliple clusters i.e. dev and prod, and is used for platform features, application deployments and promotions.

3. **Access your clusters**:

```bash
# Configure kubectl for your clusters
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

4. Commit Changes

Commit the changes and allow the terraform pipeline to provision the platform.

## Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|:--------:|
| `AWS_REGION` | Primary AWS region | `us-west-2` | Yes |
| `CLUSTER_NAME` | EKS cluster name | `platform-cluster` | Yes |
| `ENVIRONMENT` | Environment name | `dev` | Yes |

### Terraform Variables

See `variables.tf` for complete variable documentation.

## Usage Patterns

### For Platform Teams

- **Cluster Provisioning**: Automate EKS cluster creation with consistent configuration
- **Policy Enforcement**: Deploy OPA Gatekeeper policies across all clusters
- **GitOps Setup**: Configure ArgoCD for declarative application management
- **Monitoring**: Set up observability stack for cluster and application monitoring

### For Development Teams

- **Application Deployment**: Use GitOps workflow to deploy applications
- **Environment Management**: Leverage consistent environments across dev/staging/prod
- **Self-Service**: Access to standardized deployment patterns and templates
- **Security**: Benefit from platform-enforced security policies

### For Operations Teams

- **Multi-Cluster Management**: Centralized view and management of all clusters
- **Disaster Recovery**: Automated backup and recovery procedures
- **Scaling**: Horizontal and vertical scaling capabilities
- **Compliance**: Built-in compliance and audit capabilities

## Best Practices

### Security

- Enable Pod Security Standards
- Implement network policies
- Use RBAC for fine-grained access control
- Encrypt secrets at rest and in transit
- Regular security scanning and updates

### Operations

- Monitor cluster health and resource usage
- Implement proper backup strategies
- Use GitOps for all deployments
- Follow the principle of least privilege
- Document all customizations and changes

### Development

- Use consistent naming conventions
- Implement proper resource limits and requests
- Follow GitOps best practices
- Test changes in non-production environments first
- Use platform-provided templates and patterns

## Troubleshooting

### Common Issues

1. **Cluster Creation Failures**
   - Check AWS service limits
   - Verify IAM permissions
   - Review CloudFormation events

2. **GitOps Sync Issues**
   - Verify repository access
   - Check ArgoCD application status
   - Review sync policies

3. **Policy Violations**
   - Check OPA Gatekeeper logs
   - Review policy configurations
   - Verify resource specifications

### Debugging

Enable detailed logging:

```bash
export TF_LOG=DEBUG
terraform apply
```

Check cluster status:

```bash
kubectl get nodes
kubectl get pods -A
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (<https://terraform-docs.io/user-guide/installation/>)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster to provision | `string` | n/a | yes |
| <a name="input_cluster_path"></a> [cluster\_path](#input\_cluster\_path) | The name of the cluster | `string` | n/a | yes |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | The ID of the GitHub App | `string` | n/a | yes |
| <a name="input_github_app_installation_id"></a> [github\_app\_installation\_id](#input\_github\_app\_installation\_id) | The installation ID of the GitHub App | `string` | n/a | yes |
| <a name="input_github_app_private_key"></a> [github\_app\_private\_key](#input\_github\_app\_private\_key) | The private key of the GitHub App | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_workloads_repository_name"></a> [workloads\_repository\_name](#input\_workloads\_repository\_name) | The name of the repository used to store the workload definitions | `string` | n/a | yes |
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster. This is required if you use a different IAM Role for Terraform Plan actions. | <pre>map(object({<br/>    ## The list of kubernetes groups to associate the principal with<br/>    kubernetes_groups = optional(list(string))<br/>    ## The list of kubernetes users to associate the principal with<br/>    principal_arn = string<br/>    ## The list of kubernetes users to associate the principal with<br/>    policy_associations = optional(map(object({<br/>      ## The policy arn to associate with the principal<br/>      policy_arn = string<br/>      ## The access scope for the policy i.e. cluster or namespace<br/>      access_scope = object({<br/>        ## The namespaces to apply the policy to<br/>        namespaces = optional(list(string))<br/>        ## The type of access scope i.e. cluster or namespace<br/>        type = string<br/>      })<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_argocd_repositories"></a> [argocd\_repositories](#input\_argocd\_repositories) | A collection of repository secrets to add to the argocd namespace | <pre>map(object({<br/>    ## The description of the repository<br/>    description = string<br/>    ## An optional password for the repository<br/>    password = optional(string, null)<br/>    ## The secret to use for the repository<br/>    secret = optional(string, null)<br/>    ## The secret manager ARN to use for the secret<br/>    secret_manager_arn = optional(string, null)<br/>    ## An optional SSH private key for the repository<br/>    ssh_private_key = optional(string, null)<br/>    ## The URL for the repository<br/>    url = string<br/>    ## An optional username for the repository<br/>    username = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_platform"></a> [enable\_platform](#input\_enable\_platform) | Indicates we should install the platform | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | The public access to the cluster endpoint | `bool` | `true` | no |
| <a name="input_github_template"></a> [github\_template](#input\_github\_template) | The owner of the GitHub template | <pre>object({<br/>    owner      = string<br/>    repository = string<br/>  })</pre> | <pre>{<br/>  "owner": "appvia",<br/>  "repository": "container-platform-template"<br/>}</pre> | no |
| <a name="input_hub_account_id"></a> [hub\_account\_id](#input\_hub\_account\_id) | When using a hub deployment options, this is the account where argocd is running | `string` | `null` | no |
| <a name="input_hub_account_role"></a> [hub\_account\_role](#input\_hub\_account\_role) | The role to use for the hub account | `string` | `"argocd-pod-identity-hub"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The version of the cluster to provision | `string` | `"1.32"` | no |
| <a name="input_pod_identity"></a> [pod\_identity](#input\_pod\_identity) | The pod identity configuration | <pre>map(object({<br/>    ## Indicates if we should enable the pod identity<br/>    enabled = optional(bool, true)<br/>    ## The namespace to deploy the pod identity to<br/>    description = optional(string, null)<br/>    ## The service account to deploy the pod identity to<br/>    service_account = optional(string, null)<br/>    ## The managed policy ARNs to attach to the pod identity<br/>    managed_policy_arns = optional(map(string), {})<br/>    ## The permissions boundary ARN to use for the pod identity<br/>    permissions_boundary_arn = optional(string, null)<br/>    ## The namespace to deploy the pod identity to<br/>    namespace = optional(string, null)<br/>    ## The name of the pod identity role<br/>    name = optional(string, null)<br/>    ## Additional policy statements to attach to the pod identity role<br/>    policy_statements = optional(list(object({<br/>      sid       = optional(string, null)<br/>      actions   = optional(list(string), [])<br/>      resources = optional(list(string), [])<br/>      effect    = optional(string, null)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_revision_overrides"></a> [revision\_overrides](#input\_revision\_overrides) | The revision overrides to use for the platform and tenant repositories | `map(string)` | `{}` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The ID of the VPC to deploy the cluster into | `string` | `"lz-main"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id where the pipeline is running |
| <a name="output_region"></a> [region](#output\_region) | The region where the pipeline is running |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags to apply to all resources |
<!-- END_TF_DOCS -->
