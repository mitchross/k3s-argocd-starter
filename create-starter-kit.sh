#!/bin/bash

# Create the directory structure
mkdir -p k3s-argocd-starter/{apps/{hello-world,homepage-dashboard,libreddit},argocd/{apps,infrastructure},infrastructure/{networking/{cilium,gateway},openebs}}

# Create the files

# apps/hello-world
cat > k3s-argocd-starter/apps/hello-world/deployment.yaml <<EOL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
EOL

cat > k3s-argocd-starter/apps/hello-world/http-route.yaml <<EOL
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: HTTPRoute
metadata:
  name: hello-world
spec:
  parentRefs:
  - name: gateway
  hostnames:
  - "hello-world.example.com"
  rules:
  - matches:
    - path:
        type: Prefix
        value: /
    backendRefs:
    - name: hello-world
      port: 8080
EOL

cat > k3s-argocd-starter/apps/hello-world/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- http-route.yaml
EOL

cat > k3s-argocd-starter/apps/hello-world/service.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: hello-world
spec:
  selector:
    app: hello-world
  ports:
  - port: 8080
    targetPort: 8080
EOL

# apps/homepage-dashboard
cat > k3s-argocd-starter/apps/homepage-dashboard/deployment.yaml <<EOL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: homepage-dashboard
spec:
  replicas: 1
  selector:
    matchLabels:
      app: homepage-dashboard
  template:
    metadata:
      labels:
        app: homepage-dashboard
    spec:
      containers:
      - name: homepage-dashboard
        image: ghcr.io/benphelps/homepage:latest
        ports:
        - containerPort: 3000
        volumeMounts:
        - name: config
          mountPath: /app/config
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: homepage-config
EOL

cat > k3s-argocd-starter/apps/homepage-dashboard/http-route.yaml <<EOL
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: HTTPRoute
metadata:
  name: homepage-dashboard
spec:
  parentRefs:
  - name: gateway
  hostnames:
  - "homepage.example.com"
  rules:
  - matches:
    - path:
        type: Prefix
        value: /
    backendRefs:
    - name: homepage-dashboard
      port: 3000
EOL

cat > k3s-argocd-starter/apps/homepage-dashboard/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- http-route.yaml
- pvc.yaml
- ns.yaml
EOL

cat > k3s-argocd-starter/apps/homepage-dashboard/ns.yaml <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: homepage-dashboard
EOL

cat > k3s-argocd-starter/apps/homepage-dashboard/pvc.yaml <<EOL
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: homepage-config
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: openebs-localpv
EOL

cat > k3s-argocd-starter/apps/homepage-dashboard/service.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: homepage-dashboard
spec:
  selector:
    app: homepage-dashboard
  ports:
  - port: 3000
    targetPort: 3000
EOL

# apps/libreddit
cat > k3s-argocd-starter/apps/libreddit/deployment.yaml <<EOL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: libreddit
spec:
  replicas: 1
  selector:
    matchLabels:
      app: libreddit
  template:
    metadata:
      labels:
        app: libreddit
    spec:
      containers:
      - name: libreddit
        image: spikecodes/libreddit:latest
        ports:
        - containerPort: 8080
EOL

cat > k3s-argocd-starter/apps/libreddit/http-route.yaml <<EOL
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: HTTPRoute
metadata:
  name: libreddit
spec:
  parentRefs:
  - name: gateway
  hostnames:
  - "libreddit.example.com"
  rules:
  - matches:
    - path:
        type: Prefix
        value: /
    backendRefs:
    - name: libreddit
      port: 8080
EOL

cat > k3s-argocd-starter/apps/libreddit/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- http-route.yaml
- ns.yaml
EOL

cat > k3s-argocd-starter/apps/libreddit/ns.yaml <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: libreddit
EOL

cat > k3s-argocd-starter/apps/libreddit/service.yaml <<EOL
apiVersion: v1
kind: Service
metadata:
  name: libreddit
spec:
  selector:
    app: libreddit
  ports:
  - port: 8080
    targetPort: 8080
EOL

# argocd/apps
cat > k3s-argocd-starter/argocd/apps/applications.yaml <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: applications
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/k3s-argocd-starter.git
    targetRevision: HEAD
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL

cat > k3s-argocd-starter/argocd/apps/networking.yaml <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: networking
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/k3s-argocd-starter.git
    targetRevision: HEAD
    path: infrastructure/networking
  destination:
    server: https://kubernetes.default.svc
    namespace: networking
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL

# argocd
cat > k3s-argocd-starter/argocd/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- project.yaml
- apps/applications.yaml
- apps/networking.yaml
EOL

cat > k3s-argocd-starter/argocd/project.yaml <<EOL
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: default
  namespace: argocd
spec:
  sourceRepos:
  - '*'
  destinations:
  - namespace: '*'
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
EOL

# infrastructure/networking/cilium
cat > k3s-argocd-starter/infrastructure/networking/cilium/cilium-values.yaml <<EOL
# Add Cilium values here
EOL

cat > k3s-argocd-starter/infrastructure/networking/cilium/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- namespace.yaml
EOL

cat > k3s-argocd-starter/infrastructure/networking/cilium/namespace.yaml <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: networking
EOL

# infrastructure/networking/gateway
cat > k3s-argocd-starter/infrastructure/networking/gateway/gateway.yaml <<EOL
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: Gateway
metadata:
  name: gateway
spec:
  gatewayClassName: default
  listeners:
  - hostname: "*.example.com"
    port: 80
    protocol: HTTP
    routes:
      kind: HTTPRoute
EOL

cat > k3s-argocd-starter/infrastructure/networking/gateway/gateway-class.yaml <<EOL
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: GatewayClass
metadata:
  name: default
spec:
  controllerName: gateway-controller
EOL

cat > k3s-argocd-starter/infrastructure/networking/gateway/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gateway.yaml
- gateway-class.yaml
EOL

# infrastructure/openebs
cat > k3s-argocd-starter/infrastructure/openebs/kustomization.yaml <<EOL
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- namespace.yaml
- operator.yaml
- localpv-storageclass.yaml
EOL

cat > k3s-argocd-starter/infrastructure/openebs/localpv-storageclass.yaml <<EOL
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: openebs-localpv
parameters:
  storageType: hostpath
  basePath: /var/openebs/local
provisioner: openebs.io/local
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOL

cat > k3s-argocd-starter/infrastructure/openebs/namespace.yaml <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: openebs
EOL

cat > k3s-argocd-starter/infrastructure/openebs/operator.yaml <<EOL
# Add the OpenEBS operator YAML manifests here
# You can obtain the manifests from the OpenEBS documentation or Helm chart
EOL

# README.md
cat > k3s-argocd-starter/README.md <<EOL
# Kubernetes Starter Kit

This starter kit provides a basic structure and configuration for deploying applications and infrastructure components on a Kubernetes cluster using Argo CD for GitOps-style deployment.

## Prerequisites

- A running Kubernetes cluster (e.g., K3s)

## Getting Started

1. Clone this repository:
   \`\`\`
   git clone https://github.com/your-username/k3s-argocd-starter.git
   \`\`\`

2. Install Argo CD on your Kubernetes cluster:
   \`\`\`
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   \`\`\`

   This will create a new namespace called \`argocd\` and deploy the Argo CD components.

3. Access the Argo CD web UI:
   \`\`\`
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   \`\`\`

   Open your web browser and visit \`https://localhost:8080\`. The default username is \`admin\`, and the password can be obtained by running:
   \`\`\`
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   \`\`\`

4. Apply the Argo CD application and project manifests:
   \`\`\`
   kubectl apply -k argocd/
   \`\`\`

   This will create the necessary applications and projects in Argo CD to manage the deployment of applications and infrastructure components.

## Setting up Cilium

1. Install Cilium on your Kubernetes cluster:
   \`\`\`
   kubectl create namespace networking
   kubectl apply -f infrastructure/networking/cilium/namespace.yaml
   kubectl apply -f infrastructure/networking/cilium/cilium-values.yaml
   helm repo add cilium https://helm.cilium.io/
   helm install cilium cilium/cilium --version 1.13.0 --namespace networking -f infrastructure/networking/cilium/cilium-values.yaml
   \`\`\`

   This will create a new namespace called \`networking\` and deploy Cilium using the provided configuration.

2. Verify that Cilium is running:
   \`\`\`
   kubectl get pods -n networking
   \`\`\`

   You should see the Cilium pods in a \`Running\` state.

3. Apply the Gateway API manifests:
   \`\`\`
   kubectl apply -k infrastructure/networking/gateway
   \`\`\`

   This will deploy the Gateway API components.

4. In the Argo CD web UI, you should see the applications defined in the \`argocd\` directory. Click on the "Sync" button for each application to deploy them to your Kubernetes cluster.

5. Once the applications are synced and deployed, you can access them using the hostnames specified in the \`http-route.yaml\` files.

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
- Customize the Cilium configuration in \`infrastructure/networking/cilium/\` based on your networking requirements