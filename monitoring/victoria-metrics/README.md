# VictoriaMetrics Operator Setup

This directory contains manifests for deploying the VictoriaMetrics Operator and a minimal production-ready monitoring stack using Argo CD and Kustomize.

## Contents
- `kustomization.yaml`: Kustomize entrypoint for Argo CD or manual apply. Installs the operator and CRDs via the official Helm chart.
- `vmsingle.yaml`: Single-node VictoriaMetrics storage instance (`vmsingle`).
- `vmagent.yaml`: Metric scraper and forwarder (`vmagent`).
- `vmalertmanager.yaml`: Alertmanager for notifications (`vmalertmanager`).
- `vmalert.yaml`: Alert evaluation and rule engine (`vmalert`).
- `vmauth.yaml`: Auth proxy for secure access (`vmauth`).
- `vmuser.yaml`: User for accessing VictoriaMetrics UIs and APIs (`vmuser`).
- `httproute.yaml`: Gateway API HTTPRoute for external access to VictoriaMetrics via your internal gateway.

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
   - The HTTPRoute (`httproute.yaml`) is set up for the domain `victoriametrics.vanillax.xyz` and uses the internal gateway. Update the hostname or gateway reference as needed for your cluster.
   - **Note:** The internal service name for VMSingle is `vmsingle-vmsingle.victoria-metrics.svc` (not `vmsingle.victoria-metrics.svc`). Use this in all remoteWrite/remoteRead URLs.

## Notes
- All resources use the `victoria-metrics` namespace for clarity and consistency.
- Ingress is handled by the Gateway API HTTPRoute, not by an ingress block in the VMAuth resource.
- For more advanced configuration, see the [VictoriaMetrics Operator documentation](https://docs.victoriametrics.com/operator/quick-start/). 