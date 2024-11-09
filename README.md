# Kubernetes Starter Kit

This starter kit provides a basic structure and configuration for deploying applications and infrastructure components on a Kubernetes cluster using Argo CD for GitOps-style deployment.

## Prerequisites

- A running Kubernetes cluster (e.g., K3s)

## Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/your-username/k3s-argocd-starter.git
   ```

2. Install Argo CD on your Kubernetes cluster:
   ```
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

   This will create a new namespace called `argocd` and deploy the Argo CD components.

3. Access the Argo CD web UI:
   ```
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

   Open your web browser and visit `https://localhost:8080`. The default username is `admin`, and the password can be obtained by running:
   ```
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

4. Apply the Argo CD application and project manifests:
   ```
   kubectl apply -k argocd/
   ```

   This will create the necessary applications and projects in Argo CD to manage the deployment of applications and infrastructure components.

## Setting up Cilium

1. Install Cilium on your Kubernetes cluster:
   ```
   kubectl create namespace networking
   kubectl apply -f infrastructure/networking/cilium/namespace.yaml
   kubectl apply -f infrastructure/networking/cilium/cilium-values.yaml
   helm repo add cilium https://helm.cilium.io/
   helm install cilium cilium/cilium --version 1.13.0 --namespace networking -f infrastructure/networking/cilium/cilium-values.yaml
   ```

   This will create a new namespace called `networking` and deploy Cilium using the provided configuration.

2. Verify that Cilium is running:
   ```
   kubectl get pods -n networking
   ```

   You should see the Cilium pods in a `Running` state.

3. Apply the Gateway API manifests:
   ```
   kubectl apply -k infrastructure/networking/gateway
   ```

   This will deploy the Gateway API components.

4. In the Argo CD web UI, you should see the applications defined in the `argocd` directory. Click on the "Sync" button for each application to deploy them to your Kubernetes cluster.

5. Once the applications are synced and deployed, you can access them using the hostnames specified in the `http-route.yaml` files.

## Application Structure

The starter kit has the following directory structure:

- `apps/`: Contains the Kubernetes manifests for each application.
  - `hello-world/`: A simple "Hello, World!" application.
  - `homepage-dashboard/`: A customizable homepage dashboard application.
  - `libreddit/`: A lightweight Reddit front-end application.

- `argocd/`: Contains the Argo CD application and project manifests.
  - `apps/`: Application manifests for deploying applications.
  - `infrastructure/`: Application manifests for deploying infrastructure components.

- `infrastructure/`: Contains the infrastructure-related manifests.
  - `networking/`: Manifests for networking components.
    - `cilium/`: Manifests for Cilium configuration.
    - `gateway/`: Manifests for the Gateway API configuration.
  - `openebs/`: Manifests for OpenEBS local persistent storage.

## Customization

- Modify the application manifests in the `apps/` directory to fit your specific requirements.
- Update the `argocd/` manifests to match your repository URL and branch.
- Customize the Cilium configuration in `infrastructure/networking/cilium/` based on your networking requirements
