# Kube-Prometheus Stack

This folder contains the configuration for deploying the Kube-Prometheus Stack Helm chart for monitoring purposes, following best practices from the VictoriaMetrics and VictoriaLogs Medium articles.

## Components

- **Prometheus**: Collects and stores metrics.
- **Alertmanager**: Handles alerts.
- **Grafana**: Visualizes metrics.
- **Node Exporter**: Collects node-level metrics.
- **kube-state-metrics/**: Exposes Kubernetes object state as metrics for cluster monitoring (deployed in kube-system)
- **victoria-metrics/**: Metrics collection, storage, and alerting (Operator, VMSingle, VMAgent, VMAlert, VMRule, etc.)
- **victorialogs/**: Centralized log collection and querying (VictoriaLogs)

## Setup

1. Ensure the namespace `monitoring` exists.
2. Apply the kustomization:
   ```bash
   kubectl apply -k .
   ```

## Configuration

The `values.yaml` file is configured for a single-node setup.

## Usage
- Deploy each component with Argo CD or Kustomize. The ApplicationSet is configured to deploy each component to the correct namespace automatically.
- If you do not see metrics in Grafana, ensure both `kube-state-metrics` and `node-exporter` are healthy and running in their respective namespaces.
- See each subfolder's README for details and customization options.

## References
- [VictoriaMetrics Operator Docs](https://docs.victoriametrics.com/operator/)
- [VictoriaLogs Docs](https://docs.victoriametrics.com/victorialogs/)
- [Medium: Metrics with VictoriaMetrics](https://medium.com/itnext/kubernetes-monitoring-a-complete-solution-part-3-metrics-using-the-victoria-metrics-k8s-stack-515d64b5f3ba)
- [Medium: Logging with VictoriaLogs](https://medium.com/itnext/kubernetes-monitoring-a-complete-solution-part-8-logging-with-victorialogs-f17c44461034)
