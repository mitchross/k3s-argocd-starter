# Kube-Prometheus Stack

This folder contains the configuration for deploying the Kube-Prometheus Stack Helm chart for monitoring purposes.

## Components

- **Prometheus**: Collects and stores metrics.
- **Alertmanager**: Handles alerts.
- **Grafana**: Visualizes metrics.
- **Node Exporter**: Collects node-level metrics.
- **kube-state-metrics**: Exposes Kubernetes object state as metrics for cluster monitoring.

## Setup

1. Ensure the namespace `kube-prometheus-stack` exists.
2. Apply the kustomization:
   ```bash
   kubectl apply -k .
   ```

## Configuration

The `values.yaml` file is configured for a single-node, low-resource setup.

## HTTPRoute Configuration

- **Grafana**: Accessible at `grafana.vanillax.xyz`.
- **Prometheus**: Accessible at `prometheus.vanillax.xyz`.

## Usage

- Deploy the stack using Argo CD or Kustomize. The ApplicationSet is configured to deploy the stack to the correct namespace automatically.
- Ensure both `kube-state-metrics` and `node-exporter` are healthy and running to see metrics in Grafana.

## References

- [Prometheus Community Helm Charts](https://prometheus-community.github.io/helm-charts/)
