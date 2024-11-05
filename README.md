# Kubernetes Starter Kit

This starter kit provides a basic structure and configuration for deploying applications on a Kubernetes cluster using Argo CD for GitOps-style deployment.

## Prerequisites

- A running Kubernetes cluster (e.g., K3s)
- OpenEBS installed on the cluster for local persistent storage

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

4. Install OpenEBS on your Kubernetes cluster by applying the manifests in the `infrastructure/openebs` directory:
   ```
   kubectl apply -k infrastructure/openebs
   ```

5. Create the necessary namespaces for the applications:
   ```
   kubectl create namespace homepage-dashboard
   kubectl create namespace libreddit
   ```

6. Apply the Argo CD application and project manifests:
   ```
   kubectl apply -f argocd/
   ```

7. In the Argo CD web UI, you should see the applications defined in the `argocd` directory. Click on the "Sync" button for each application to deploy them to your Kubernetes cluster.

8. Access the deployed applications using the hostnames specified in the `http-route.yaml` files.

## Application Structure

The starter kit has the following directory structure:

- `apps/`: Contains the Kubernetes manifests for each application.
  - `hello-world/`: A simple "Hello, World!" application.
  - `homepage-dashboard/`: A customizable homepage dashboard application.
  - `libreddit/`: A lightweight Reddit front-end application.

- `argocd/`: Contains the Argo CD application and project manifests.

- `infrastructure/`: Contains the infrastructure-related manifests.
  - `gateway/`: Manifests for the Gateway API configuration.
  - `openebs/`: Manifests for OpenEBS local persistent storage.

## Customization

- Modify the application manifests in the `apps/` directory to fit your specific requirements.
- Update the `argocd/` manifests to match your repository URL and branch.
- Customize the Gateway API configuration in `infrastructure/gateway/` to match your desired hostnames and routing rules.
- Adjust the OpenEBS configuration in `infrastructure/openebs/` if needed.

## Learn More

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [OpenEBS Documentation](https://docs.openebs.io/)
- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
