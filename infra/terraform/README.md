# Terraform

This directory contains reusable Terraform modules and environment folders that compose them.

## Modules

- `vpc`: VPC, subnets, internet gateway, NAT gateway, and route tables
- `security-group`: reusable security group and rules
- `aws-load-balancer-controller`: Helm-installed controller for Kubernetes `Ingress` resources that create AWS Application Load Balancers
- `cloudwatch`: log groups and metric alarms
- `kubernetes`: EKS cluster and managed worker node group
- `ec2`: optional EC2 instances
- `ecr`: encrypted container image repositories and lifecycle policies
- `s3`: encrypted artifact/state-style bucket
- `kms`: customer-managed encryption key and alias
- `iam`: reusable IAM roles, managed policy attachments, inline policies, and optional instance profiles

The requested three control plane nodes are represented by EKS control plane networking across three availability zones. EKS does not expose direct management of control plane node count; AWS runs the managed control plane. The worker node group is configured from variables and defaults to two desired nodes.

Configuration values are supplied through each environment's `variables.tf` file and overridden by its matching tfvars file.

The `dev` environment stores Terraform state in the existing S3 bucket `react-js-application-terraform-state-866934333672` using the key `task-tracking-app/dev/terraform.tfstate`.

Terraform uses the active AWS credentials for S3 backend access. AWS provider role assumption is optional through `aws_assume_role_arn`; CI sets it to an empty value because GitHub Actions already assumes `ROLE_TO_ASSUME`.

## Environments

- `environments/dev`: development, state key `task-tracking-app/dev/terraform.tfstate`
- `environments/uat`: UAT, state key `task-tracking-app/uat/terraform.tfstate`
- `environments/production`: production, state key `task-tracking-app/production/terraform.tfstate`

## Usage

Dev:

```bash
cd infra/terraform/environments/dev
terraform init
terraform validate
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

UAT:

```bash
cd infra/terraform/environments/uat
terraform init
terraform validate
terraform plan -var-file=uat.tfvars
terraform apply -var-file=uat.tfvars
```

Production:

```bash
cd infra/terraform/environments/production
terraform init
terraform validate
terraform plan -var-file=production.tfvars
terraform apply -var-file=production.tfvars
```

After apply:

```bash
aws eks update-kubeconfig --region us-east-1 --name task-tracking-dev-eks
```

## ECR Images

The `dev` environment creates ECR repositories for the backend and frontend images. Repository names and lifecycle settings are controlled by `ecr_repositories` in `environments/dev/variables.tf`.

After Terraform apply, use the `ecr_repository_urls` output to confirm the created repositories.
