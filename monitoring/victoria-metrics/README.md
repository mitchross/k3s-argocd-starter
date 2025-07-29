# VictoriaMetrics Operator Setup

This directory contains manifests for deploying the VictoriaMetrics Operator and a minimal production-ready monitoring stack using Argo CD and Kustomize.

## Contents
- `kustomization.yaml`: Kustomize entrypoint for Argo CD or manual apply. Installs the operator and CRDs via the official Helm chart.
- `vmsingle.yaml`: Single-node VictoriaMetrics storage instance.
- `vmagent.yaml`: Metric scraper and forwarder.
- `vmalertmanager.yaml`: Alertmanager for notifications.
- `vmalert.yaml`: Alert evaluation and rule engine.
- `vmauth.yaml`: Auth proxy for secure access (configured for Gateway API).
- `vmuser.yaml`: User for accessing VictoriaMetrics UIs and APIs.

## Usage
1. **Deploy with Argo CD or Kustomize**
   - Point Argo CD at this folder, or run:
     ```sh
     kubectl apply -k .
     ```
   - The operator and CRDs are installed automatically via the Helm chart specified in `kustomization.yaml`.

2. **Customize**
   - Adjust resource names, namespaces, or configuration as needed for your environment.
   - The manifests are based on the [official QuickStart guide](https://docs.victoriametrics.com/operator/quick-start/).

## Notes
- The `vmauth.yaml` is configured for Gateway API ingress with the host `victoriametrics.vanillax.xyz` and class `external`. Adjust as needed for your cluster's ingress setup.
- All resources use the `vm` namespace as recommended.
- For more advanced configuration, see the [VictoriaMetrics Operator documentation](https://docs.victoriametrics.com/operator/quick-start/). 