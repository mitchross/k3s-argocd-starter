# Monitoring Stack Overview

This folder contains manifests and configuration for the full monitoring and logging stack for your k3s home lab, following best practices from the VictoriaMetrics and VictoriaLogs Medium articles.

## Components
- **victoria-metrics/**: Metrics collection, storage, and alerting (Operator, VMSingle, VMAgent, VMAlert, VMRule, etc.)
- **grafana/**: Visualization and dashboards for metrics (auto-provisioned for VictoriaMetrics)
- **victorialogs/**: Centralized log collection and querying (VictoriaLogs)

## Usage
- Deploy each component with Argo CD or Kustomize.
- See each subfolder's README for details and customization options.

## References
- [VictoriaMetrics Operator Docs](https://docs.victoriametrics.com/operator/)
- [VictoriaLogs Docs](https://docs.victoriametrics.com/victorialogs/)
- [Medium: Metrics with VictoriaMetrics](https://medium.com/itnext/kubernetes-monitoring-a-complete-solution-part-3-metrics-using-the-victoria-metrics-k8s-stack-515d64b5f3ba)
- [Medium: Logging with VictoriaLogs](https://medium.com/itnext/kubernetes-monitoring-a-complete-solution-part-8-logging-with-victorialogs-f17c44461034)
