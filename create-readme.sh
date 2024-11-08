#!/bin/bash

cat > README.md <<EOL
# Kubernetes Starter Kit

This starter kit provides a basic structure and configuration for deploying applications and infrastructure components on a Kubernetes cluster using Argo CD for GitOps-style deployment.

## Prerequisites

- A running Kubernetes cluster (e.g., K3s)

## Setting up Cilium

1. Install the Cilium CLI:
   \`\`\`
   CILIUM_CLI_VERSION=\$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
   CLI_ARCH=\$(uname -m)
   if [ "\$CLI_ARCH" = "aarch64" ]; then
     CLI_ARCH="arm64"
   fi
   curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/\${CILIUM_CLI_VERSION}/cilium-linux-\${CLI_ARCH}.tar.gz
   sudo tar xzvfC cilium-linux-\${CLI_ARCH}.tar.gz /usr/local/bin
   rm cilium-linux-\${CLI_ARCH}.tar.gz
   \`\`\`

   This will download and install the latest version of the Cilium CLI.

2. Set the API server IP and port:
   \`\`\`
   API_SERVER_IP=192.168.10.11
   API_SERVER_PORT=6443
   \`\`\`

   Replace \`192.168.10.11\` with the IP address of your Kubernetes API server and \`6443\` with the appropriate port.

3. Install Cilium using the Cilium CLI:
   \`\`\`
   cilium install \\
     --version 1.16.3 \\
     --set k8sServiceHost=\${API_SERVER_IP} \\
     --set k8sServicePort=\${API_SERVER_PORT} \\
     --set kubeProxyReplacement=true \\
     --helm-set=operator.replicas=1
   \`\`\`

   This command installs Cilium version 1.16.3 with the specified configuration options.

4. Apply the Gateway API CRDs:
   \`\`\`
   kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml
   \`\`\`

   This command installs the experimental Gateway API CRDs required for Cilium.

5. Verify that Cilium is running:
   \`\`\`
   kubectl get pods -n kube-system -l k8s-app=cilium
   \`\`\`

   You should see the Cilium pods in the \`kube-system\` namespace with a status of \`Running\`.

6. Apply the Cilium configuration:
   \`\`\`
   kubectl apply -k infrastructure/networking/cilium
   \`\`\`

   This command applies the Cilium configuration specified in the \`infrastructure/networking/cilium\` directory.

7. Apply the Gateway API configuration:
   \`\`\`
   kubectl apply -k infrastructure/networking/gateway
   \`\`\`

   This command applies the Gateway API configuration specified in the \`infrastructure/networking/gateway\` directory.

## Setting up Argo CD

1. Install Argo CD on your Kubernetes cluster:
   \`\`\`
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   \`\`\`

   This will create a new namespace called \`argocd\` and deploy the Argo CD components.

2. Access the Argo CD web UI:
   \`\`\`
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   \`\`\`

   Open your web browser and visit \`https://localhost:8080\`. The default username is \`admin\`, and the password can be obtained by running:
   \`\`\`
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   \`\`\`

3. Apply the Argo CD application and project manifests:
   \`\`\`
   kubectl apply -k argocd/
   \`\`\`

   This will create the necessary applications and projects in Argo CD to manage the deployment of applications and infrastructure components.

4. In the Argo CD web UI, synchronize the \`networking\` application to deploy the networking components.

5. Synchronize the other applications in the Argo CD web UI to deploy your applications.

## Application Structure

The starter kit has the following directory structure:

- \`apps/\`: Contains the Kubernetes manifests for each application.
  - \`hello-world/\`: A simple "Hello, World!" application.
  - \`homepage-dashboard/\`: A customizable homepage dashboard application.
  - \`libreddit/\`: A lightweight Reddit front-end application.

- \`argocd/\`: Contains the Argo CD application and project manifests.
  - \`apps/\`: Application manifests for deploying applications.
  - \`infrastructure/\`: Application manifests for deploying infrastructure components.

- \`infrastructure/\`: Contains the infrastructure-related manifests.
  - \`networking/\`: Manifests for networking components.
    - \`cilium/\`: Manifests for Cilium configuration.
    - \`gateway/\`: Manifests for the Gateway API configuration.
  - \`openebs/\`: Manifests for OpenEBS local persistent storage.

## Customization

- Modify the application manifests in the \`apps/\` directory to fit your specific requirements.
- Update the \`argocd/\` manifests to match your repository URL and branch.
- Customize the Cilium configuration in \`infrastructure/networking/cilium/\` based on your networking requirements.

EOL

echo "README.md file generated successfully!"