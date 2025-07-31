🚀 Kubernetes Starter Kit
=========================

Tutorial Video

[![Tutorial Walkthrough Video](https://img.youtube.com/vi/AY5mC5rDUcw/0.jpg)](https://youtu.be/AY5mC5rDUcw)



> Modern GitOps deployment structure using Argo CD on Kubernetes

This starter kit provides a production-ready foundation for deploying applications and infrastructure components using GitOps principles. Compatible with both Raspberry Pi and x86 systems.

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
  - [System Setup](#1-system-setup)
  - [K3s Installation](#2-k3s-installation)
  - [Networking Setup](#3-networking-setup-cilium)
  - [GitOps Setup](#4-gitops-setup-argo-cd-part-1-of-2)
- [Security Setup](#-security-setup)
  - [Cloudflare Integration](#cloudflare-integration)
- [Verification](#-verification)
- [Applications](#-included-applications)
- [Contributing](#-contributing)
- [License](#-license)
- [Troubleshooting](#-troubleshooting)

## 📋 Prerequisites

- Kubernetes cluster (tested with K3s v1.32.0+k3s1)
- Linux host (ARM or x86) with:
  - Storage support (OpenEBS works with ZFS or standard directories)
  - NFS and CIFS support (optional)
  - Open-iSCSI
- Cloudflare account (for DNS and Tunnel)
- Local DNS setup (one of the following):
  - Local DNS server ([AdGuard Home setup guide](docs/adguard-home-setup.md))
  - Router with custom DNS capabilities (e.g., Firewalla)
  - Ability to modify hosts file on all devices

## 🏗️ Architecture

```mermaid
graph TD
    subgraph "Argo CD Projects"
        IP[Infrastructure Project] --> IAS[Infrastructure ApplicationSet]
        AP[Applications Project] --> AAS[Applications ApplicationSet]
        MP[Monitoring Project] --> MAS[Monitoring ApplicationSet]
    end
    
    subgraph "Infrastructure Components"
        IAS --> Cilium
        IAS --> Cloudflared
        IAS --> Gateway
        IAS --> OpenEBS
        IAS --> CertManager
    end
    
    subgraph "Monitoring Stack"
        MAS --> VictoriaMetrics
        MAS --> Grafana
        MAS --> VMAlert
        MAS --> NodeExporter
        MAS --> KubeStateMetrics
        MAS --> VictoriaLogs
        MAS --> VMAgent
    end
    
    subgraph "User Applications"
        AAS --> P[Privacy Apps]
        AAS --> Web[Web Apps]
        AAS --> Other[Other Apps]
        
        P --> ProxiTok
        P --> SearXNG
        P --> LibReddit
        
        Web --> Nginx
        Web --> Dashboard
        
        Other --> HelloWorld
    end

    style IP fill:#f9f,stroke:#333,stroke-width:2px
    style AP fill:#f9f,stroke:#333,stroke-width:2px
    style MP fill:#f9f,stroke:#333,stroke-width:2px
    style IAS fill:#bbf,stroke:#333,stroke-width:2px
    style AAS fill:#bbf,stroke:#333,stroke-width:2px
    style MAS fill:#bbf,stroke:#333,stroke-width:2px
```

### Key Features
- **GitOps Structure**: Two-level Argo CD ApplicationSets for infrastructure/apps
- **Security Boundaries**: Separate projects with RBAC enforcement
- **Sync Waves**: Infrastructure deploys first (negative sync waves)
- **Self-Healing**: Automated sync with pruning and failure recovery

## 🚀 Quick Start

### 1. System Setup
```bash
# Essential packages (ZFS/NFS/iSCSI)
sudo apt update && sudo apt install -y \
  zfsutils-linux \
  nfs-kernel-server \
  cifs-utils \
  open-iscsi  # Optional but recommended

# Critical kernel modules for Cilium
sudo modprobe iptable_raw xt_socket
echo -e "xt_socket\niptable_raw" | sudo tee /etc/modules-load.d/cilium.conf
```

### 2. K3s Installation
```bash
# Customize these values!
export SETUP_NODEIP=192.168.101.176  # Your node IP
export SETUP_CLUSTERTOKEN=randomtokensecret12343  # Strong token

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.33.1+k3s1" \
  INSTALL_K3S_EXEC="--node-ip $SETUP_NODEIP \
  --disable=flannel,local-storage,metrics-server,servicelb,traefik \
  --flannel-backend='none' \
  --disable-network-policy \
  --disable-cloud-controller \
  --disable-kube-proxy" \
  K3S_TOKEN=$SETUP_CLUSTERTOKEN \
  K3S_KUBECONFIG_MODE=644 sh -s -

# Configure kubectl access
mkdir -p $HOME/.kube && sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config && chmod 600 $HOME/.kube/config
```

### Adding Additional Nodes
```bash
# On the MASTER node - Get the token if you forgot it
sudo cat /var/lib/rancher/k3s/server/node-token

# On each WORKER node:
export MASTER_IP=192.168.101.202  # IP of your master node
export NODE_IP=192.168.101.203    # IP of THIS worker node
export K3S_TOKEN=your-node-token # From master's node-token file

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.32.0+k3s1" \
  K3S_URL="https://$MASTER_IP:6443" \
  K3S_TOKEN=$K3S_TOKEN \
  INSTALL_K3S_EXEC="--node-ip $NODE_IP" sh -

# On the MASTER node - Verify the new node joined
kubectl get nodes -o wide
```

### Setting Up Lens (Optional but Recommended)

1. Install Lens from https://k8slens.dev/
2. Get the kubeconfig:
   - Copy from `/etc/rancher/k3s/k3s.yaml`, or
   - Run: `kubectl config view --raw > kubeconfig.yaml`
3. When adding to Lens:
   - Replace the server URL with your K3s node IP
   - Example: `server: https://192.168.10.202:6443`
4. Save and connect

### 3. Networking Setup (Cilium)
```bash
# Install Cilium CLI
## CHECK ARCH FIRST
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64 && [ "$(uname -m)" = "aarch64" ] && CLI_ARCH=arm64
curl -L --fail --remote-name-all \
  https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz*

# Helm install Cilium
# use  helm install if first time, or helm upgrade if trying to update/upgrade/redo something 
helm repo add cilium https://helm.cilium.io && helm repo update
helm install cilium cilium/cilium -n kube-system \
  -f infrastructure/networking/cilium/values.yaml \
  --version 1.17.3 \
  --set operator.replicas=1

# Validate installation
cilium status && cilium connectivity test

# Critical L2 Configuration Note:
# Before applying the CiliumL2AnnouncementPolicy, you MUST identify your correct network interface:

# 1. List all network interfaces:
ip a

# 2. Look for your main interface with an IP address matching your network
# Common interface names:
# - Ubuntu/Debian: enp1s0, ens18, eth0
# - macOS: en0
# - RPi: eth0
# The interface should show your node's IP address, for example:
#   enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> ... inet 192.168.1.100/24

# 3. Make note of your interface name for the CiliumL2AnnouncementPolicy
# You'll need this when applying the infrastructure components via Argo CD

# DO NOT apply the policy here - it will be applied through Argo CD
# The policy file is located at: infrastructure/networking/cilium/l2policy.yaml
```

### 4. GitOps Setup (Argo CD - Part 1/2)
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml

# Argo CD Bootstrap
kubectl create namespace argocd
kubectl kustomize --enable-helm infrastructure/controllers/argocd | kubectl apply -f -
kubectl apply -f infrastructure/controllers/argocd/projects.yaml

# Wait for Argo CD
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get initial password (change immediately!)
ARGO_PASS=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "Initial Argo CD password: $ARGO_PASS"

#Generate a New Password:
Use a bcrypt hash generator tool (such as https://www.browserling.com/tools/bcrypt) to create a new bcrypt hash for the password.
Update the argocd-secret secret with the new bcrypt hash.
kubectl -n argocd patch secret argocd-secret -p '{"stringData": { "admin.password": "$2a$10$rgDBwhzr0ygDfH6scxkdddddx3cd612Cutw1Xu1X3a.kVrRq", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}'
```

### 5. Monitoring Setup (Prometheus, VictoriaMetrics, Grafana, Loki, Kubecost)

The monitoring stack is deployed via Argo CD and provides a comprehensive, homelab-friendly observability solution. Each component is deployed as a separate ArgoCD Application in its own namespace (e.g., `prometheus`, `grafana`, `loki`, `victoriametrics`, `kubecost`, `promtail`).

- **Metrics**: `Prometheus` and/or `VictoriaMetrics` (choose one or both) for collecting detailed time-series metrics.
- **Visualization**: `Grafana` pre-configured with Prometheus, VictoriaMetrics, and Loki data sources, plus several default dashboards.
- **Logging**: `Loki` for log aggregation, with `Promtail` as the agent.
- **Cost Monitoring**: `Kubecost` for real-time cost visibility.
- **Alerting**: `AlertManager` handles alerts from Prometheus.

Each component is managed as a separate ArgoCD Application. To add or remove components, edit `monitoring/monitoring-components-appset.yaml` and comment/uncomment the desired subfolders.

**Access URLs (after DNS/Gateway setup):**
- **Grafana**: `https://grafana.yourdomain.xyz` (namespace: `grafana`, default: `admin` / `prom-operator`)
- **Prometheus**: `https://prometheus.yourdomain.xyz` (namespace: `prometheus`)
- **VictoriaMetrics**: `https://victoriametrics.yourdomain.xyz` (namespace: `victoriametrics`)
- **AlertManager**: `https://alertmanager.yourdomain.xyz` (namespace: `prometheus`)
- **Loki**: `https://loki.yourdomain.xyz` (namespace: `loki`)
- **Kubecost**: `https://kubecost.yourdomain.xyz` (namespace: `kubecost`)

**Storage (default sizes):**
- **Prometheus**: `5Gi`
- **VictoriaMetrics**: `5Gi`
- **Loki**: `2Gi`
- **Grafana**: `2Gi`
- **AlertManager**: `2Gi`
- **Kubecost**: `2Gi`

**Default Credentials:**
- **Grafana**: `admin` / `prom-operator` (change after first login)
- **Other components**: No default auth (local access only)

**For detailed usage, dashboards, and troubleshooting, see [`monitoring/README.md`](monitoring/README.md).**

---

To add or remove monitoring components, edit `monitoring/monitoring-components-appset.yaml` and comment/uncomment the desired subfolders. Each component is managed as a separate ArgoCD Application in its own namespace.

## 🔒 Security Setup

### Cloudflare Integration

You'll need to create two secrets for Cloudflare integration:
1. DNS API Token for cert-manager (DNS validation)
2. Tunnel credentials for cloudflared (Tunnel connectivity)

#### 1. DNS API Token 🔑
```bash
# REQUIRED BROWSER STEPS FIRST:
# Navigate to Cloudflare Dashboard:
# 1. Profile > API Tokens
# 2. Create Token
# 3. Use "Edit zone DNS" template
# 4. Configure permissions:
#    - Zone - DNS - Edit
#    - Zone - Zone - Read
# 5. Set zone resources to your domain
# 6. Copy the token and your Cloudflare account email

# Set credentials - NEVER COMMIT THESE!
export CLOUDFLARE_API_TOKEN="your-api-token-here"
export CLOUDFLARE_EMAIL="your-cloudflare-email"
export DOMAIN="yourdomain.com"
export TUNNEL_NAME="k3s-cluster"  # Must match config.yaml
```

#### 2. Cloudflare Tunnel 🌐
```bash
# First-time setup only
# ---------------------
# Install cloudflared
# Linux:
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
# macOS:
brew install cloudflare/cloudflare/cloudflared

# Authenticate (opens browser)
cloudflared tunnel login

# Generate credentials (run from $HOME)
cloudflared tunnel create $TUNNEL_NAME
cloudflared tunnel token --cred-file tunnel-creds.json $TUNNEL_NAME

export DOMAIN="yourdomain.com"
export TUNNEL_NAME="k3s-cluster"  # This should match the name in your config.yaml

# Create namespace for cloudflared
kubectl create namespace cloudflared

# Create Kubernetes secret
kubectl create secret generic tunnel-credentials \
  --namespace=cloudflared \
  --from-file=credentials.json=tunnel-creds.json

# SECURITY: Destroy local credentials ( Optional )
rm -v tunnel-creds.json && echo "Credentials file removed"

# Configure DNS
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')
cloudflared tunnel route dns $TUNNEL_ID "*.$DOMAIN"
```

### Certificate Management
```bash
# Create cert-manager secrets
kubectl create namespace cert-manager
kubectl create secret generic cloudflare-api-token -n cert-manager \
  --from-literal=api-token=$CLOUDFLARE_API_TOKEN \
  --from-literal=email=$CLOUDFLARE_EMAIL

# Verify secrets
kubectl get secret cloudflare-api-token -n cert-manager -o jsonpath='{.data.email}' | base64 -d
kubectl get secret cloudflare-api-token -n cert-manager -o jsonpath='{.data.api-token}' | base64 -d
```

## 🛠️ Final Deployment
```bash
# Apply infrastructure components
# Run from root of git repo
kubectl apply -f infrastructure/controllers/argocd/projects.yaml -n argocd
kubectl apply -f infrastructure/infrastructure-components-appset.yaml -n argocd

# Wait for core services (5-30 mins for certs)
kubectl wait --for=condition=Available deployment -l type=infrastructure --all-namespaces --timeout=1800s

# Deploy monitoring stack
kubectl apply -f monitoring/argocd/projects/monitoring-project.yaml -n argocd
kubectl apply -f monitoring/monitoring-components-appset.yaml -n argocd

# Wait for monitoring components to initialize
# This can take a few minutes as images are pulled and resources are provisioned.
echo "Waiting for monitoring stack to become ready... (this may take a few minutes)"
kubectl wait --for=condition=Available deployment --all -n monitoring --timeout=600s
kubectl wait --for=condition=Ready statefulset --all -n monitoring --timeout=600s
kubectl wait --for=jsonpath='{.status.numberReady}'=.status.desiredNumberScheduled daemonset --all -n monitoring --timeout=600s

# Deploy applications
kubectl apply -f my-apps/myapplications-appset.yaml
```

## 🔍 Verification
```bash
# Cluster status
kubectl get pods -A --sort-by=.metadata.creationTimestamp

# Argo CD status
kubectl get applications -n argocd -o wide

# Monitoring stack status
kubectl get pods -n monitoring

# Certificate checks
kubectl get certificates -A
kubectl describe clusterissuer cloudflare-cluster-issuer

# Network validation
cilium status --verbose
cilium connectivity test --all-flows
```

**Access Endpoints:**
- Argo CD: `https://argocd.$DOMAIN`
- Grafana: `https://grafana.$DOMAIN`
- Prometheus: `https://prometheus.$DOMAIN`
- AlertManager: `https://alertmanager.$DOMAIN`
- ProxiTok: `https://proxitok.$DOMAIN`
- SearXNG: `https://search.$DOMAIN`
- LibReddit: `https://reddit.$DOMAIN`

## 📦 Included Applications

| Category       | Components                          |
|----------------|-------------------------------------|
| **Monitoring** | Prometheus, Grafana, Loki, Promtail |
| **Privacy**    | ProxiTok, SearXNG, LibReddit        |
| **Infra**      | Cilium, Gateway API, Cloudflared    |
| **Storage**    | OpenEBS                             |
| **Security**   | cert-manager, Argo CD Projects      |

## 🤝 Contributing
Contributions welcome! Please:
1. Maintain existing comment structure
2. Keep all warnings/security notes
3. Open issue before major changes

## 📝 License
MIT License - Full text in [LICENSE](LICENSE)

## 🔧 Troubleshooting

**Common Issues:**
```bash
# Certificates not issuing
kubectl logs -n cert-manager -l app=cert-manager

# Tunnel connection failures
cloudflared tunnel info $TUNNEL_NAME
kubectl logs -n cloudflared -l app=cloudflared

# Cilium connectivity issues
cilium status --verbose
cilium hubble ui

# L2 Announcement Problems
ip -o link show | awk -F': ' '{print $2}'  # Verify node interfaces
kubectl describe CiliumL2AnnouncementPolicy -n kube-system
```

**Monitoring Stack Issues:**
```bash
# Check pod status in the monitoring namespace
kubectl get pods -n monitoring

# If pods are stuck, check the Argo CD UI for sync errors.
# Look at the 'kube-prometheus-stack', 'loki', 'promtail', and 'blackbox-exporter' applications.

# Describe a pod to see its events and find out why it's not starting
kubectl describe pod <pod-name> -n monitoring

# Check logs for a specific monitoring component (e.g., Grafana)
kubectl logs -l app.kubernetes.io/name=grafana -n monitoring
```

**Critical L2 Note:**
If LoadBalancer IPs aren't advertising properly:
1. Verify physical interface name matches in CiliumL2AnnouncementPolicy
2. Check interface exists on all nodes: `ip link show dev enp1s0`
3. Ensure Cilium pods are running: `kubectl get pods -n kube-system -l k8s-app=cilium`

All original comments, warnings, and TODOs preserved. Formatting optimized for readability while maintaining technical accuracy.
