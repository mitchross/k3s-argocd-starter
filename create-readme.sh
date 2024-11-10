#!/bin/bash

cat << 'EOF' > README.md
# 🚀 Kubernetes Starter Kit

> Modern GitOps deployment structure using Argo CD on Kubernetes

This starter kit provides a production-ready foundation for deploying applications and infrastructure components using GitOps principles.

## 🏗️ Architecture

```mermaid
flowchart TB
    subgraph GitRepo["🗄️ Git Repository"]
        apps["📦 Apps Directory"]
        infra["🔧 Infrastructure Directory"]
        argocd["⚓ ArgoCD Directory"]
    end

    subgraph K8sCluster["☸️ Kubernetes Cluster"]
        subgraph InfraLayer["🔋 Infrastructure Layer"]
            cilium["🌐 Cilium Networking"]
            gateway["🚪 Gateway API"]
            openebs["💾 OpenEBS Storage"]
        end
        
        subgraph ArgoCD["🎯 Argo CD"]
            controller["🎮 Application Controller"]
            appsets["📚 ApplicationSets"]
        end

        subgraph Applications["🎁 Applications"]
            hello["👋 Hello World App"]
            homepage["🏠 Homepage Dashboard"]
            redlib["📱 Redlib"]
        end
    end

    GitRepo -- "syncs" --> ArgoCD
    ArgoCD -- "manages" --> InfraLayer
    ArgoCD -- "deploys" --> Applications
    cilium -- "provides networking" --> Applications
    gateway -- "routes traffic" --> Applications
    openebs -- "provides storage" --> Applications
```

## 📋 Prerequisites

- ☸️ Kubernetes cluster (e.g., K3s)
- 🎮 kubectl CLI
- ⚓ Helm
- 🔄 Git

## 🚀 Installation

### 1. Clone Repository 
\`\`\`bash
git clone https://github.com/your-username/k3s-argocd-starter.git
cd k3s-argocd-starter
\`\`\`

### 2. Deploy Storage Layer
\`\`\`bash
kubectl create namespace openebs
kubectl apply -k infrastructure/storage/openebs/
\`\`\`

### 3. Configure Networking
\`\`\`bash
kubectl create namespace networking
kubectl apply -k infrastructure/networking/cilium/
\`\`\`

### 4. Install Argo CD
\`\`\`bash
kubectl create namespace argocd
kubectl apply -k infrastructure/controllers/argocd/
\`\`\`

### 5. Access Argo CD UI
\`\`\`bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
\`\`\`

Get initial admin password:
\`\`\`bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
\`\`\`

Access UI: https://localhost:8080
- Username: admin
- Password: (from command above)

## 📁 Project Structure

### 📦 Applications
- `hello-world/`: Simple test application
- `homepage-dashboard/`: Cluster dashboard
- `redlib/`: Reddit frontend

### 🔧 Infrastructure
- `networking/`: Cilium & Gateway API configuration
- `storage/`: OpenEBS configuration
- `controllers/`: Argo CD setup

## 🔒 Security Features

### 1. Container Security
- Non-root containers
- Read-only filesystem
- Minimal capabilities

### 2. Network Security
- Cilium network policies
- Gateway API ingress control
- Optional mTLS support

### 3. Storage Security
- Secure persistent volumes
- Proper permissions

## 🛠️ Configuration

### 1. Domain Settings
Edit \`apps/*/http-route.yaml\`:
\`\`\`yaml
spec:
  hostnames:
  - "your-app.your-domain.com"
\`\`\`

### 2. Network Configuration
Edit \`infrastructure/networking/cilium/cilium-values.yaml\`:
- IP pools
- Network settings

### 3. Storage Configuration
Edit \`infrastructure/storage/openebs/localpv-storageclass.yaml\`:
- Storage parameters
- Capacity settings

## 🔍 Troubleshooting

### 1. Argo CD Status
\`\`\`bash
kubectl get applications -n argocd
\`\`\`

### 2. Network Status
\`\`\`bash
kubectl get pods -n networking
cilium status
\`\`\`

### 3. Gateway Routes
\`\`\`bash
kubectl get gateways,httproutes -A
\`\`\`

## 🤝 Contributing

- Submit issues
- Fork the repository
- Create pull requests

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---
Built for production Kubernetes deployments
EOF

echo "📄 README.md has been generated"