# 🚀 Kubernetes Starter Kit

> Modern GitOps deployment structure using Argo CD on Kubernetes

This starter kit provides a production-ready foundation for deploying applications and infrastructure components using GitOps principles.

## 🏗️ Architecture

## 🏃 Getting Started

### 1. System Dependencies
```bash
# Install required system packages
sudo apt install zfsutils-linux nfs-kernel-server cifs-utils open-iscsi
sudo apt install --reinstall zfs-dkms

# Install 1Password CLI (follow instructions at https://1password.com/downloads/command-line/)
```

### 2. Install K3s 🎯
```bash
export SETUP_NODEIP=192.168.100.176
export SETUP_CLUSTERTOKEN=randomtokensecret1234

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.32.0+k3s1" \
  INSTALL_K3S_EXEC="--node-ip $SETUP_NODEIP \
  --disable=flannel,local-storage,metrics-server,servicelb,traefik \
  --flannel-backend='none' \
  --disable-network-policy \
  --disable-cloud-controller \
  --disable-kube-proxy" \
  K3S_TOKEN=$SETUP_CLUSTERTOKEN \
  K3S_KUBECONFIG_MODE=644 sh -s -

# Setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
chmod 600 $HOME/.kube/config
```

### 3. Install Cilium 🔄
```bash
# Install Cilium CLI
# Replace ARCH with arm64 or amd64
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=arm64
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz

# Install Gateway API CRDs first
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/experimental-install.yaml

# Install Cilium using values from infrastructure/networking/cilium/cilium-values.yaml
cilium install \
  --version 1.16.5 \
  --set kubeProxyReplacement=true \
  --helm-set=operator.replicas=1

# Verify installation
cilium status

# Apply custom configuration
kubectl apply -k infrastructure/networking/cilium/

# Verify Cilium is running properly
cilium connectivity test
```

### 4. Install ArgoCD 🎯

# Install ArgoCD with our custom configuration
k3s kubectl kustomize --enable-helm infrastructure/controllers/argocd | k3s kubectl apply -f -

#let argo manage argo
kubectl apply -f argocd/apps/argocd-appset.yaml 

#let argo manage infrastructure
kubectl apply -f argocd/apps/infrastructure-appset.yaml 


---

External services

☁️ Cloudflare Setup
Required Tokens
DNS API Token 🔑
Used by cert-manager for DNS01 challenges
Permissions needed:

Zone - DNS - Edit
Zone - Zone - Read
Tunnel Token 🌐

Used by cloudflared for tunnel authentication
Created automatically when setting up the tunnel
Setup Steps
Create DNS API Token 🔧

# Navigate to Cloudflare Dashboard:
# 1. Profile > API Tokens
# 2. Create Token
# 3. Use "Edit zone DNS" template
# 4. Configure permissions:
#    - Zone - DNS - Edit
#    - Zone - Zone - Read
# 5. Set zone resources to your domain
Create Cloudflare Tunnel 🚇

# Install cloudflared
brew install cloudflare/cloudflare/cloudflared  # macOS
# or
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Login to Cloudflare
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create k3s-cluster

# Get tunnel credentials and create Kubernetes secret
cloudflared tunnel token --cred-file tunnel-creds.json k3s-cluster
kubectl create namespace cloudflared
kubectl create secret generic tunnel-credentials \
  --namespace=cloudflared \
  --from-file=credentials.json=tunnel-creds.json

# Clean up credentials file
rm tunnel-creds.json

Configure DNS Records 📡

# Get tunnel ID
TUNNEL_ID=$(cloudflared tunnel list | grep k3s-cluster | awk '{print $1}')

# Create DNS record
cloudflared tunnel route dns $TUNNEL_ID "*.yourdomain.com"