# AWS EKS Deployment — Terraform + ArgoCD + Prometheus + Grafana + MySQL

full production-like setup on EKS, everything provisioned with terraform and deployed via gitops using argocd. monitoring with prometheus & grafana.

---

## what this does

spins up an EKS cluster on AWS from scratch using terraform, deploys a java app with mysql backend, sets up argocd to watch the git repo and auto-deploy on push, and monitors everything with prometheus + grafana.

---

## infra (terraform)

- VPC `10.0.0.0/16`
- 2 public subnets across 2 AZs
- internet gateway + route tables
- security groups (cluster + nodes)
- IAM roles for EKS and node group
- EKS cluster: `project-cluster`
- node group: 4x t3.micro, autoscaling min=2 max=5

---

## project structure

```
eks/
├── main.tf
├── variables.tf
├── output.tf
├── terraform.tfstate
├── deployment.yaml
├── svc.yaml
├── db.yaml
├── prometheus-configmap.yaml
├── prometheus-deployment.yaml
├── grafana-deployment.yaml
└── argocd-mainfast.yaml
```

---

## how to run

**1. init and apply terraform**

```bash
terraform init
terraform apply -auto-approve
```

**2. connect kubectl to the cluster**

```bash
aws eks update-kubeconfig --region us-east-1 --name project-cluster
```

**3. deploy everything**

```bash
kubectl apply -f db.yaml
kubectl apply -f prometheus-configmap.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f grafana-deployment.yaml
kubectl apply -f deployment.yaml
kubectl apply -f svc.yaml
```

**4. enable argocd gitops**

```bash
kubectl apply -f argocd-mainfast.yaml
```

get the argocd admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

---

## monitoring

port-forward to access locally:

```bash
# prometheus
kubectl port-forward svc/prometheus 9091:9090

# grafana
kubectl port-forward svc/grafana 3005:3000
```

grafana default login: `admin / admin`

---

## kubernetes components

- **db.yaml** — mysql 8, database: `twitterdb`, service on port 3306
- **deployment.yaml** — java app, nodeport/loadbalancer service
- **prometheus** — v2.52, clusterip, config from configmap
- **grafana** — v11, clusterip, port 3000
- **argocd-mainfast.yaml** — watches git repo, auto-deploys on any push

---

## security

- SSH access restricted to your IP only (`<your-ip>/32`)
- prometheus and grafana are clusterip — not exposed publicly
- mysql is internal only

---

## screenshots

| | |
|---|---|
| all resources | ![](screens/all-resources.png) |
| app running | ![](screens/app.png) |
| argocd dashboard | ![](screens/argo.jpg) |
| terraform output | ![](screens/tf-out.png) |
| load balancer | ![](screens/llb.png) |
| prometheus | ![](screens/prometheus.png) |
| grafana | ![](screens/grafana.png) |
| metrics | ![](screens/metrics.png) |
| port-forward | ![](screens/portforward.png) |
