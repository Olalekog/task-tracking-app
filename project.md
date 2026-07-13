# Task Tracking App Project Plan

## Project Goal

Build and deploy a production-ready task tracking application with a React frontend, FastAPI backend, MySQL database, Kubernetes platform, Terraform infrastructure, GitHub Actions CI, Argo CD deployment, security scanning, and observability.

## Scope

The project includes application development, containerization, infrastructure provisioning, Kubernetes deployment, GitOps delivery, security validation, and monitoring/logging.

## Architecture Summary

- Frontend: ReactJS served by Nginx
- Backend: FastAPI REST API
- Database: MySQL container for local development and Kubernetes StatefulSet for cluster deployment
- Infrastructure: AWS resources managed by Terraform modules
- Platform: Kubernetes on EKS
- CI: GitHub Actions
- CD: Argo CD
- Security: Checkov, Trivy, SonarQube
- Monitoring: Prometheus, Grafana, Fluentd, Elasticsearch, Kibana

## Terraform Modules

- VPC: networking, subnets, route tables, internet gateway, NAT gateway
- Security Group: reusable ingress and egress rules
- ALB: application load balancer, listener, target group
- CloudWatch: log groups and metric alarms
- Kubernetes: EKS cluster and worker node group
- EC2: optional compute instances
- ECR: encrypted frontend and backend image repositories
- S3: encrypted artifact bucket
- KMS: encryption key and alias
- IAM: reusable IAM roles, managed policy attachments, inline policies, and optional instance profiles

## Phase 1: Application Foundation

Deliverables:

- React frontend with task board UI
- FastAPI backend with task CRUD endpoints
- MySQL integration with SQLAlchemy
- Health and metrics endpoints
- Local Docker Compose environment

Acceptance Criteria:

- Frontend can create, update, view, and delete tasks
- Backend exposes `/healthz`, `/metrics`, and task API routes
- Local services run through `docker compose up --build`
- Backend code compiles successfully

## Phase 2: Containerization

Deliverables:

- Frontend Dockerfile
- Backend Dockerfile
- Nginx frontend config
- Docker Compose service wiring

Acceptance Criteria:

- Frontend container serves the React app
- Backend container runs FastAPI through Uvicorn
- MySQL container is reachable by the backend
- Containers use environment variables for configuration

## Phase 3: Infrastructure as Code

Deliverables:

- Reusable Terraform modules
- Dev environment composition
- Terraform provider lock file
- Terraform documentation
- ECR repositories for frontend and backend images

Acceptance Criteria:

- `terraform fmt -check -recursive infra/terraform` passes
- `terraform validate` passes from `infra/terraform/environments/dev`
- No environment-specific values are buried inside reusable modules
- Infrastructure settings can be overridden through variables
- ECR repository URLs are exposed as Terraform outputs

## Phase 4: Kubernetes Platform Deployment

Deliverables:

- Namespace manifests for frontend, backend, database, security, and monitoring
- Backend Deployment and Service
- Frontend Deployment and Service
- MySQL StatefulSet and Service
- Secrets and ingress manifests
- Kustomize configuration

Acceptance Criteria:

- Kubernetes manifests apply successfully with Kustomize
- Frontend, backend, database, security, and monitoring resources are separated by namespace
- Backend and frontend run as stateless deployments
- MySQL persists data through a volume claim
- Ingress exposes frontend and API routes

## Phase 5: GitOps Deployment

Deliverables:

- Argo CD Application manifest
- Repository path configuration for Kubernetes manifests
- Automated sync policy

Acceptance Criteria:

- Argo CD can sync the `k8s` directory
- Drift is corrected through self-heal
- Removed resources are pruned when deleted from Git

## Phase 6: CI Pipeline

Deliverables:

- GitHub Actions workflow
- Frontend build check
- Backend compile/import check
- Terraform validation
- Checkov scan
- Trivy scan
- SonarQube scan
- ECR image push on `dev`

Acceptance Criteria:

- Pull requests trigger CI
- Pushes to `dev` trigger CI
- Security scans publish useful results
- SonarQube runs when required secrets are configured
- Frontend and backend images are tagged with commit SHA and `latest`

## Phase 7: Security Hardening

Deliverables:

- Checkov IaC scanning
- Trivy filesystem and image scanning
- SonarQube code quality scanning
- Kubernetes resource requests and limits
- Non-root backend container user
- KMS encryption for supported AWS resources

Acceptance Criteria:

- Critical and high findings are reviewed
- Secrets are not committed as production values
- S3 public access is blocked
- EKS secrets are encrypted with KMS

## Phase 8: Observability

Deliverables:

- Prometheus deployment and scrape configuration
- Grafana deployment
- Fluentd DaemonSet
- Elasticsearch and Kibana manifests
- RBAC for monitoring components

Acceptance Criteria:

- Prometheus discovers annotated pods
- Grafana can use Prometheus as a data source
- Fluentd forwards Kubernetes logs to Elasticsearch
- Kibana can search application and platform logs

## Phase 9: Release Preparation

Deliverables:

- Replace placeholder image repositories
- Replace placeholder domain names
- Replace development secret values
- Configure GitHub repository secrets
- Configure GitHub repository variables for AWS region and ECR repositories
- Configure Argo CD repository access
- Confirm AWS credentials and Terraform backend strategy

Acceptance Criteria:

- Images are published to the selected registry
- Kubernetes manifests reference real image tags
- Argo CD syncs from the correct repository
- Terraform state is stored remotely and encrypted

## Key Commands

```bash
docker compose up --build
```

```bash
cd infra/terraform/environments/dev
terraform init
terraform validate
terraform plan -var-file=dev.tfvars
```

```bash
kubectl apply -k k8s
kubectl apply -k monitoring
kubectl apply -f argocd/task-tracking-app.yaml
```

## Risks and Mitigations

- Placeholder values remain in deployment files: track them before production release.
- MySQL StatefulSet is suitable for learning and development, but production should use a managed database or a highly available MySQL operator.
- EKS control plane node count is managed by AWS and cannot be directly set like self-managed Kubernetes.
- Monitoring manifests are a lightweight baseline; production should use Helm charts or operators for Prometheus, Grafana, and Elastic.
- Terraform state must be moved to a remote encrypted backend before team usage.

## Milestone Checklist

- [ ] Local app runs successfully
- [ ] Container images build successfully
- [ ] Terraform validates successfully
- [ ] AWS infrastructure plans successfully
- [ ] Kubernetes app deploys successfully
- [ ] Argo CD syncs successfully
- [ ] CI pipeline passes on pull request
- [ ] Security findings are reviewed
- [ ] Monitoring and logging are reachable
- [ ] Production placeholders are replaced
