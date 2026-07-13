# Task Tracking App

A full-stack task tracking platform scaffolded for local development and Kubernetes deployment.

## Stack

- Frontend: ReactJS + Vite
- Backend: FastAPI + SQLAlchemy
- Database: MySQL container
- Platform: Kubernetes
- IaC: Terraform reusable AWS modules for VPC, security groups, CloudWatch, EKS, EC2, ECR, S3, KMS, IAM, and the AWS Load Balancer Controller
- CI: GitHub Actions
- CD: Argo CD
- Security: Checkov, Trivy, SonarQube
- Monitoring/logging: Prometheus, Grafana, Fluentd, Elasticsearch, Kibana

## Local Development

```bash
docker compose up --build
```

Services:

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API docs: http://localhost:8000/docs
- MySQL: localhost:3306

## Repository Layout

```text
backend/                 FastAPI service
frontend/                React app
infra/terraform/         Reusable Terraform module and dev environment
k8s/                     Kubernetes manifests
argocd/                  Argo CD application manifests
monitoring/              Prometheus, Grafana, Fluentd, ELK manifests
.github/workflows/       CI pipeline with scans and build checks
```

## Deployment Flow

1. Terraform provisions the Kubernetes platform.
2. GitHub Actions validates, scans, builds, and can publish images.
3. Argo CD syncs Kubernetes manifests from this repository.
4. Prometheus/Grafana handle metrics, Fluentd ships logs to Elasticsearch/Kibana.

## Kubernetes Namespaces

- `frontend`: React frontend service and ingress
- `backend`: FastAPI service and backend secrets
- `database`: MySQL StatefulSet, service, and database secrets
- `security`: reserved for security platform resources and policies
- `monitoring`: Prometheus, Grafana, Fluentd, Elasticsearch, and Kibana

## ECR Image Publishing

The CI workflow can push images to Amazon ECR on pushes to `dev`.

Configure these GitHub repository variables:

- `AWS_REGION`

Configure this GitHub repository secret:

- `ROLE_TO_ASSUME`

The workflow provisions the dev ECR repositories from Terraform, reads the repository names from Terraform outputs, and pushes both `$GITHUB_SHA` and `latest` tags for each image.
Task Tracking App Deployed with Kubernetes
