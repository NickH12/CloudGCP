<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,100:1a73e8&height=180&section=header&text=Cloud%20GCP%20-%20GitOps%20Pipeline&fontSize=34&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Terraform%20%7C%20GCP%20%7C%20Kubernetes%20%7C%20ArgoCD%20%7C%20NGINX&descAlignY=58&descSize=16" width="100%"/>

</div>

An end-to-end cloud infrastructure project provisioned on GCP using Terraform, with containerized workloads running on Kubernetes and GitOps-based continuous deployment managed by ArgoCD. The goal was to build a real, hand-off-ready infrastructure - not just a demo.

---

## Architecture Overview

```
GitHub Repository
       |
       v
Terraform - provisions GCP infrastructure
       |
       v
GCP (VPC, compute instances, firewall rules)
       |
       v
Kubernetes cluster
       |
       |-- myapp-service  (exposed via NGINX Ingress at docker.local)
       |
       |-- ArgoCD         (exposed via NGINX Ingress at argo.local)
                |
                v
         Watches the repo - syncs cluster state automatically on every push
```

---

## Infrastructure

### Terraform - GCP
All infrastructure is provisioned as code - nothing was created manually in the GCP console.

- VPC networking and firewall rules configured for cluster traffic
- Compute instances provisioned and managed through Terraform modules
- IAM bindings defined in code for reproducible permission management
- Full infrastructure teardown and re-provisioning possible with a single command

### Kubernetes
The application and ArgoCD run as separate workloads on the cluster, each in their own namespace.

| Resource | Namespace | Exposed At |
|---|---|---|
| myapp-service | default | `docker.local` |
| ArgoCD server | argocd | `argo.local` |

### NGINX Ingress Controller
Two ingress resources handle external routing:

- **myapp ingress** - routes all traffic from `docker.local` to `myapp-service` on port 80
- **ArgoCD ingress** - routes traffic from `argo.local` to the ArgoCD server on port 443, with backend HTTPS and SSL passthrough configured via annotations

### ArgoCD - GitOps
ArgoCD watches this repository and automatically syncs the cluster state on every push to `main`. No manual `kubectl apply` needed after the initial setup.

---

## Tech Stack

| Layer | Tool |
|---|---|
| Cloud Provider | GCP (Google Cloud Platform) |
| Infrastructure as Code | Terraform |
| Container Orchestration | Kubernetes |
| GitOps / CD | ArgoCD |
| Ingress Controller | NGINX |
| Containerization | Docker |

---

## Getting Started

### Prerequisites
- GCP account with billing enabled
- `terraform` CLI installed
- `kubectl` configured
- `helm` installed (for ArgoCD)

### Provision Infrastructure

```bash
# Clone the repo
git clone https://github.com/NickH12/CloudGCP
cd CloudGCP

# Initialize and apply Terraform
cd terraform
terraform init
terraform apply
```

### Deploy ArgoCD

```bash
# Create namespace and install ArgoCD via Helm
kubectl create namespace argocd
helm install argo-cd argo/argo-cd -n argocd

# Apply ArgoCD ingress
kubectl apply -f argo-ingress.yml
```

### Deploy the Application

```bash
# Apply ingress for the main app
kubectl apply -f ingress.yml
```

Once ArgoCD is running and pointed at the repo, any push to `main` will automatically sync the cluster to match the desired state.

---

## Key Takeaways

- Learned how to treat infrastructure as code - every resource is versioned, reproducible, and destroyable
- Understood the difference between imperative deployment (`kubectl apply`) and declarative GitOps (ArgoCD watching a repo)
- Configured dual ingress routing for two separate services on the same cluster with different protocols (HTTP for app, HTTPS passthrough for ArgoCD)
- Gained hands-on experience with the full GCP - Terraform - Kubernetes - ArgoCD stack end to end

---

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1a73e8,100:1a1a2e&height=120&section=footer" width="100%"/>
</div>
