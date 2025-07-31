# Task: Kubernetes Monitoring Stack (VictoriaMetrics, Grafana, VictoriaLogs, ArgoCD)

## Description
Implement a production-ready, GitOps-managed Kubernetes monitoring stack for K3s (and optionally Talos), using VictoriaMetrics, VictoriaLogs, Grafana, Alertmanager, and Vector/Fluent Bit, with dynamic storage (NFS/Longhorn), secure access, and batteries-included dashboards/alerts/log pipelines.

## Complexity
Level: 4
Type: Complex System

## Technology Stack
- Framework: Kubernetes, Helm, ArgoCD
- Build Tool: Helm, Kustomize (optional overlays)
- Language: YAML, Bash (for scripts)
- Storage: NFS or Longhorn (dynamic PVCs)

## Technology Validation Checkpoints
- [ ] Project initialization command verified (Helm, kubectl, ArgoCD)
- [ ] Required dependencies identified and installed (Helm, kubectl, ArgoCD CLI)
- [ ] Build configuration validated (Helm values, manifests)
- [ ] Hello world verification completed (test install on K3s)
- [ ] Test build passes successfully (all pods healthy, dashboards accessible)

## Status
- [x] Initialization complete
- [x] Planning complete
- [ ] Technology validation complete
- [ ] Implementation steps in progress

## Progress (K3s Metrics to Grafana Parity)
- [x] Validate all ServiceScrapes/NodeScrapes for K3s control plane and nodes
- [ ] Confirm VictoriaMetrics operator and core CRDs are healthy
- [x] Ensure Grafana is provisioned with VictoriaMetrics datasource
- [x] Confirm dashboards for cluster, nodes, pods, workloads are present
- [ ] Validate metrics parity with kube-prometheus-stack (API server, etcd, controller-manager, scheduler, kubelet, cAdvisor, node-exporter, kube-state-metrics, CoreDNS, NGINX)
- [ ] Document/patch any missing metrics or dashboards

## Implementation Plan
1. Bootstrap Monitoring Namespace & Storage
	- Create `monitoring` namespace manifest
	- Define StorageClasses for NFS/Longhorn
2. ArgoCD AppSet Setup
	- Create AppSet manifest for `monitoring/`
3. VictoriaMetrics Stack
	- Add Helm values and overlays for VMCluster, VMAgent, VMAlert, Alertmanager
	- Add ServiceScrapes/NodeScrapes for API server, etcd, kube-controller-manager, kube-scheduler, kubelet, cAdvisor, node-exporter, kube-state-metrics, NGINX, CoreDNS
4. Grafana
	- Add manifests for Grafana deployment, ConfigMaps for datasources/dashboards, HTTPRoute
5. VictoriaLogs & Log Agent
	- Add manifests for VictoriaLogs, Vector/Fluent Bit, and log pipeline configuration
6. Security
	- Add RBAC and NetworkPolicy manifests
7. Backup & Retention
	- Add CronJob for VictoriaMetrics backup
8. Testing & Validation
	- Port-forward or HTTPRoute access for Grafana/VM UI
	- Validate metrics, logs, dashboards, and alerting

## Creative Phases Required
- [ ] Grafana dashboard design
- [ ] Alerting rules (VMAlert/Alertmanager)
- [ ] Log pipeline customization (Vector/Fluent Bit)

## Dependencies
- K3s cluster (or Talos, with overlays)
- Helm, kubectl, ArgoCD installed
- NFS or Longhorn storage available

## Challenges & Mitigations
- Resource constraints: Use minimal resource requests/limits, test on single-node
- Storage compatibility: Provide overlays/examples for both NFS and Longhorn
- K3s vs Talos differences: Document and isolate Talos-specific configs
- Security: Harden with RBAC/NetworkPolicy, test access
