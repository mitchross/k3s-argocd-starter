🚀 Kubernetes Starter Kit

WORK IN PROGRESS ITS ALL BROKE DONT USE

> Modern GitOps deployment structure using Argo CD on Kubernetes

This starter kit provides a production-ready foundation for deploying applications and infrastructure components using GitOps principles.

## 🏗️ Architecture

This repository follows a three-level GitOps structure:

```
/
├── root-argocd-app.yml     (Level 1 - Root App of Apps)
├── appsets/                (Level 2 - ApplicationSets)
│   ├── infrastructure-appset.yaml
│   └── apps-appset.yaml    (future application deployments)
└── apps/                   (Level 3 - Actual manifests)
    ├── infrastructure/
    │   ├── networking/
    │   │   ├── cilium/
    │   │   ├── cloudflared/
    │   │   └── gateway/
    │   └── storage/
    └── applications/       (future application deployments)
```

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
k3s kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/experimental-install.yaml

# Install Cilium using values from apps/infrastructure/networking/cilium/cilium-values.yaml
cilium install \
  --version 1.16.5 \
  --set kubeProxyReplacement=true \
  --helm-set=operator.replicas=1

# Verify installation
cilium status

cd infrastructure/networking/cilium
cilium upgrade -f cilium-values.yaml

# Apply custom configuration
k3s kubectl apply -k apps/infrastructure/networking/cilium/

# Verify Cilium is running properly
cilium connectivity test
```

### 4. Install ArgoCD and Setup GitOps 🎯

```bash
# Install ArgoCD with custom configuration
k3s kubectl kustomize --enable-helm infrastructure/controllers/argocd | k3s kubectl apply -f -



# Wait for ArgoCD pods to be ready
k3s kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd

k3s kubectl apply -f infrastructure-components-appset.yaml -n argocd
k3s kubectl apply -f applications-appset.yaml -n argocd

```

This will set up the complete GitOps structure:
1. Root application manages ApplicationSets
2. Infrastructure ApplicationSet manages core components
3. Future application deployments will be managed separately

## ☁️ External Services Setup

### Cloudflare Setup

You'll need to create two secrets for Cloudflare integration:
1. DNS API Token for cert-manager (DNS validation)
2. Tunnel credentials for cloudflared (Tunnel connectivity)

#### 1. Create DNS API Token 🔑
```bash
# Navigate to Cloudflare Dashboard:
# 1. Profile > API Tokens
# 2. Create Token
# 3. Use "Edit zone DNS" template
# 4. Configure permissions:
#    - Zone - DNS - Edit
#    - Zone - Zone - Read
# 5. Set zone resources to your domain

# Set your credentials as environment variables
export CLOUDFLARE_API_TOKEN="your-api-token-here"
export CLOUDFLARE_EMAIL="your-cloudflare-email"

# Create the secret for cert-manager
kubectl create secret generic cloudflare-api-token \
  --namespace cert-manager \
  --from-literal=api-token=$CLOUDFLARE_API_TOKEN \
  --from-literal=email=$CLOUDFLARE_EMAIL \
  --dry-run=client -o yaml | kubectl apply -f -
```

#### 2. Setup Cloudflare Tunnel 🌐
```bash
# Install cloudflared
brew install cloudflare/cloudflare/cloudflared  # macOS
# or
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Login to Cloudflare (this will open a browser)
cloudflared tunnel login

# Set your domain
export DOMAIN="yourdomain.com"

# Create tunnel and store its name
export TUNNEL_NAME="k3s-cluster"
cloudflared tunnel create $TUNNEL_NAME

# Create namespace for cloudflared
kubectl create namespace cloudflared

# Get tunnel credentials and create Kubernetes secret
cloudflared tunnel token --cred-file tunnel-creds.json $TUNNEL_NAME
kubectl create secret generic tunnel-credentials \
  --namespace=cloudflared \
  --from-file=credentials.json=tunnel-creds.json

# Clean up credentials file
rm tunnel-creds.json

# Configure DNS (*.yourdomain.com will point to your tunnel)
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')
cloudflared tunnel route dns $TUNNEL_ID "*.$DOMAIN"

# Verify your tunnel
cloudflared tunnel list
```

After completing these steps, you'll have:
1. A cert-manager secret with your Cloudflare API token and email
2. A cloudflared secret with your tunnel credentials
3. DNS routing configured for your domain through the tunnel
