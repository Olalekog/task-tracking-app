# Architecture

## End-to-End Architecture

```mermaid
flowchart TB
  user[User / Browser]
  dns[Public DNS<br/>task-tracking.example.com]

  subgraph github[GitHub]
    repo[Source Repository]
    actions[GitHub Actions CI]
    checks[Build, Terraform Validate,<br/>Checkov, Trivy, SonarQube]
    approval[Manual Production Approval<br/>GitHub Environment: production]
    prodMerge[Merge to production]
  end

  subgraph aws[AWS Account]
    subgraph iac[Infrastructure Provisioned by Terraform]
      vpc[VPC across 3 AZs]
      publicSubnets[Public Subnets]
      privateSubnets[Private Subnets]
      alb[Application Load Balancer<br/>public entry point]
      eks[EKS Cluster]
      nodes[Managed Node Group]
      ecr[ECR Repositories<br/>backend + frontend]
      kms[KMS Key]
      s3[S3 Artifact Bucket]
      cw[CloudWatch Log Groups]
      iam[IAM Roles and Policies]
    end

    subgraph cluster[EKS Runtime Platform]
      subgraph frontendNs[frontend namespace]
        ingress[ALB-backed Kubernetes Ingress<br/>frontend path only]
        frontendSvc[frontend Service]
        frontendPod[React Frontend Pods<br/>nginx serving Vite build]
        backendExternal[ExternalName Service<br/>backend.backend.svc.cluster.local]
      end

      subgraph backendNs[backend namespace]
        backendSvc[backend Service]
        backendPods[FastAPI Backend Pods<br/>SQLAlchemy + PyMySQL]
        backendSecret[backend-secret<br/>DATABASE_URL]
      end

      subgraph databaseNs[database namespace]
        mysqlSvc[Headless MySQL Service]
        mysql[MySQL StatefulSet<br/>mysql:8.4]
        pvc[PersistentVolumeClaim<br/>mysql-data]
        mysqlSecret[mysql-secret<br/>database credentials]
        seed[mysql-init ConfigMap<br/>001-seed-tasks.sql]
      end

      subgraph monitoringNs[monitoring namespace]
        prometheus[Prometheus]
        grafana[Grafana]
        fluentd[Fluentd DaemonSet]
        elastic[Elasticsearch]
        kibana[Kibana]
      end
    end

    subgraph cd[GitOps Delivery]
      argocd[Argo CD Application]
      manifests[Kubernetes Manifests<br/>k8s/ + monitoring/]
      rendered[Terraform-rendered Deployment Manifests<br/>generated/k8s per environment]
    end
  end

  user --> dns --> alb --> ingress --> frontendSvc --> frontendPod
  frontendPod -->|internal /api proxy| backendExternal --> backendSvc --> backendPods
  backendPods -->|DATABASE_URL| backendSecret
  backendPods -->|SQL over 3306| mysqlSvc --> mysql
  mysql --> pvc
  mysql --> mysqlSecret
  seed -->|mounted at /docker-entrypoint-initdb.d| mysql

  repo --> actions --> checks
  actions -->|push dev images| ecr
  repo -->|dev to uat PR| checks
  repo -->|uat to production PR| approval
  approval --> prodMerge
  prodMerge --> argocd

  iac --> vpc
  vpc --> publicSubnets
  vpc --> privateSubnets
  publicSubnets --> alb
  privateSubnets --> nodes
  eks --> nodes
  kms --> eks
  kms --> ecr
  kms --> s3
  cw --> eks
  iam --> eks
  iam --> nodes

  argocd --> manifests --> cluster
  rendered --> manifests
  ecr --> frontendPod
  ecr --> backendPods

  prometheus -->|scrapes /metrics| backendPods
  grafana --> prometheus
  fluentd -->|ships logs| elastic --> kibana
```

## Promotion Flow

```mermaid
flowchart LR
  feature[Feature Work]
  dev[dev branch]
  uat[uat branch]
  prod[production branch]
  ciDev[CI on push to dev<br/>Build + scan + push images]
  prUat[PR: dev to uat<br/>Validation checks]
  prProd[PR: uat to production]
  gate[Manual approval gate<br/>GitHub production environment]
  deploy[Argo CD syncs manifests<br/>to EKS]

  feature --> dev
  dev --> ciDev
  dev --> prUat --> uat
  uat --> prProd --> gate --> prod
  prod --> deploy
  uat --> deploy
```

## Runtime Request Flow

```mermaid
sequenceDiagram
  participant User
  participant ALB as Application Load Balancer
  participant Frontend as React/nginx Frontend
  participant API as FastAPI Backend
  participant DB as MySQL StatefulSet

  User->>ALB: GET /
  ALB->>Frontend: Route to frontend service only
  Frontend-->>User: React application
  User->>ALB: GET /api/tasks
  ALB->>Frontend: Route to frontend service only
  Frontend->>API: Proxy /api/tasks internally
  API->>DB: SELECT tasks
  DB-->>API: Task rows
  API-->>User: JSON task list
  User->>ALB: PATCH /api/tasks/{id}
  ALB->>Frontend: Route to frontend service only
  Frontend->>API: Proxy update internally
  API->>DB: UPDATE tasks
  DB-->>API: Commit
  API-->>User: Updated task
```

## Runtime

The task tracking app uses a React frontend, FastAPI backend, and MySQL database. Frontend and backend containers are stateless and can scale horizontally. MySQL runs as a local container for development and as a Kubernetes StatefulSet in the included manifests.

The frontend is served by nginx and calls the backend through `/api` routes. In Kubernetes, public traffic enters through an AWS Application Load Balancer and routes only to the frontend service. The frontend nginx container proxies `/api` requests to the internal backend service through the frontend namespace `ExternalName` service. The backend reads `DATABASE_URL` from `backend-secret` and connects to MySQL through the headless `mysql` service in the database namespace.

Fresh MySQL databases are initialized with `database/init/001-seed-tasks.sql` locally and with the `mysql-init` ConfigMap in Kubernetes. The script creates the `tasks` table if needed and inserts sample tasks for `todo`, `in_progress`, and `done`.

## Platform

Terraform provisions an AWS EKS cluster with networking across three availability zones and a managed node group with two desired worker nodes.

The Terraform environments (`dev`, `uat`, and `production`) provision the shared platform pattern with environment-specific names, CIDR ranges, ECR repositories, KMS encryption, CloudWatch log groups, and worker node settings. Each environment also accepts `backend_image_url` and `frontend_image_url` through tfvars and renders deployment manifests from templates.

Terraform installs the AWS Load Balancer Controller into EKS with Helm and an IRSA-backed service account. The Kubernetes ingress uses `ingressClassName: alb`, allowing the controller to create and manage the public Application Load Balancer that forwards traffic only to the frontend service.

## Delivery

GitHub Actions validates application builds, Terraform, Dockerfiles, Kubernetes manifests, and source quality. Argo CD continuously syncs the Kubernetes manifests from the repository.

The branch promotion model is:

- Pushes to `dev` run validation and publish backend/frontend images to ECR.
- Pull requests from `dev` to `uat` run UAT validation.
- Pull requests from `uat` to `production` pause at the `production` GitHub Environment approval gate.

## Security

Checkov scans Terraform, Kubernetes, Dockerfiles, and GitHub Actions. Trivy scans the repository filesystem and built images. SonarQube analysis runs when `SONAR_TOKEN` and `SONAR_HOST_URL` repository secrets are configured.

Kubernetes secrets hold database connection values and MySQL credentials. EKS uses KMS-backed encryption for configured cluster resources, and ECR repositories use KMS encryption with image scanning enabled.

## Observability

Prometheus scrapes annotated pods, Grafana visualizes metrics, and Fluentd ships Kubernetes logs to Elasticsearch for Kibana search and dashboards.
