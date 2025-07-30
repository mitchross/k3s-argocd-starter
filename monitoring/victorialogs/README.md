# VictoriaLogs Setup

This directory contains manifests for deploying VictoriaLogs for centralized log collection and querying in your Kubernetes cluster.

## Contents
- `kustomization.yaml`: Kustomize entrypoint for Argo CD or manual apply. Installs VictoriaLogs and related resources.
- `deployment.yaml`: VictoriaLogs deployment manifest (or Helm values if using Helm).
- `service.yaml`: Service for VictoriaLogs UI/API access.
- `httproute.yaml`: Gateway API HTTPRoute for external access to VictoriaLogs.

## Usage
1. **Deploy with Argo CD or Kustomize**
   - Point Argo CD at this folder, or run:
     ```sh
     kubectl apply -k .
     ```
2. **Configure Log Ingestion**
   - Set up log shipping from workloads (e.g., using Fluent Bit, Vector, or VictoriaMetrics agent).
   - Update scrape configs as needed for your environment.

3. **Access Logs**
   - Use the VictoriaLogs UI or API for querying and troubleshooting.

## References
- [VictoriaLogs Documentation](https://docs.victoriametrics.com/victorialogs/)
- [Medium Article: Logging with VictoriaLogs](https://medium.com/itnext/kubernetes-monitoring-a-complete-solution-part-8-logging-with-victorialogs-f17c44461034)
