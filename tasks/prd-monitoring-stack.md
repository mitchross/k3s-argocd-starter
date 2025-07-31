# PRD: Kubernetes Monitoring Stack (K3s & Talos Flexible, GitOps, Homelab Optimized)

## 1. Introduction/Overview
This document defines the requirements for a self-hosted, open-source Kubernetes monitoring stack, based on Ryan Jacobs' architecture, but adapted for K3s (primary) and Talos (optional). The solution is GitOps-native (ArgoCD), supports both NFS and Longhorn storage, and is optimized for homelab/small hardware.

## 2. Goals & Objectives
- Provide a complete, cost-free monitoring stack for K3s (and optionally Talos)
- All configuration managed in Git, deployed via ArgoCD AppSet
- Support both NFS and Longhorn for dynamic storage
- Collect metrics from all relevant K3s control plane components (API server, etcd, kube-controller-manager, kube-scheduler) and nodes
- Plug-and-play Grafana dashboards/datasources (managed as code)
- HTTPRoute-based access for Grafana/Alertmanager
- Batteries-included, but extensible for custom targets/dashboards/log pipelines
- Resource-efficient for single-node, low-power hardware

## 3. User Stories & Personas
- As a homelab operator, I want a monitoring stack that works out-of-the-box on K3s, so I can monitor my cluster with minimal manual setup.
- As a GitOps user, I want all monitoring configuration tracked in Git and deployed by ArgoCD, so I have full auditability and easy rollbacks.
- As a tinkerer, I want to add custom scrape targets and dashboards, so I can extend monitoring as my needs grow.

## 4. Functional Requirements
- Helm-based deployment of VictoriaMetrics stack (metrics), VictoriaLogs (logs), Grafana (dashboards), Alertmanager/vmalert (alerting), Vector (log agent)
- All manifests/Helm values stored in `monitoring/` folder, managed by ArgoCD AppSet
- StorageClass selection for NFS or Longhorn, with dynamic PVC provisioning
- ServiceMonitors/VMServiceScrapes for K3s control plane (API server, etcd, kube-controller-manager, kube-scheduler) and nodes
- Grafana dashboards and datasources managed as code (ConfigMaps or Helm values)
- HTTPRoute manifests for Grafana and Alertmanager
- RBAC and network policies for secure operation
- Default resource requests/limits suitable for NUC/RPi/small VMs

## 5. Non-Functional Requirements
- No commercial/cloud dependencies
- No additional cost
- Single-node friendly, but extensible to multi-node
- Minimal manual post-install steps

## 6. System Architecture
- All monitoring components deployed in `monitoring` namespace
- ArgoCD AppSet watches `monitoring/` for changes
- VictoriaMetrics operator manages metrics stack
- VictoriaLogs + Vector for log aggregation
- Grafana for dashboards, Alertmanager/vmalert for alerting
- HTTPRoute for external access

## 7. Data Requirements
- Metrics and logs stored on NFS or Longhorn PVCs
- Retention: default 15 days (configurable)

## 8. Integration Points
- ArgoCD for GitOps
- K3s API for metrics
- StorageClass for NFS/Longhorn

## 9. Performance Requirements
- Default resource requests/limits: 100-300m CPU, 128-512Mi RAM per component
- Storage: 10-100Gi per PVC (configurable)

## 10. Security Considerations
- RBAC for all monitoring components
- NetworkPolicy to restrict access to monitoring namespace
- HTTPRoute with authentication (optional, future)

## 11. Migration Strategy
- All stateful data in PVCs; upgrade via Helm/ArgoCD
- Talos-specific configs in overlays, not default

## 12. Success Metrics
- All metrics/logs visible in Grafana within 30 minutes of deployment
- No manual steps required post-ArgoCD sync
- <500Mi RAM used on single-node cluster

## 13. Open Questions
- Should we provide example dashboards for common apps (NGINX, etc.)?
- Should we include example alert rules for homelab scenarios?

---

**Status:** Draft. Please review and suggest changes or additions.

---

## 14. Implementation Details & Example Manifests

### 14.1 Namespace Creation
```yaml
apiVersion: v1
kind: Namespace
metadata:
	name: monitoring
	labels:
		name: monitoring
```

### 14.2 Helm Installation (Recommended)
```bash
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update
helm install victoria-metrics-k8s-stack vm/victoria-metrics-k8s-stack \
	--namespace monitoring \
	--create-namespace \
	-f values-k8s-stack.yaml
```

### 14.3 Example values-k8s-stack.yaml (Key Excerpts)
```yaml
vmcluster:
	enabled: true
	spec:
		replicationFactor: 2
		retentionPeriod: "14d"
		vmselect:
			replicaCount: 2
			resources:
				requests:
					cpu: 100m
					memory: 128Mi
				limits:
					cpu: 500m
					memory: 512Mi
		vminsert:
			replicaCount: 2
			resources:
				requests:
					cpu: 100m
					memory: 128Mi
				limits:
					cpu: 500m
					memory: 512Mi
		vmstorage:
			replicaCount: 2
			resources:
				requests:
					cpu: 200m
					memory: 512Mi
				limits:
					cpu: 1000m
					memory: 2Gi
			storage:
				volumeClaimTemplate:
					spec:
						resources:
							requests:
								storage: 20Gi
						storageClassName: <nfs-or-longhorn>
```

### 14.4 Core Monitoring Components
- **VMCluster**: Highly available VictoriaMetrics cluster for metrics storage.
- **VMAgent**: Scrapes metrics from K3s control plane, nodes, and workloads.
- **Node Exporter**: DaemonSet for node-level metrics.
- **kube-state-metrics**: Deployment for Kubernetes object state metrics.
- **VMAlert & Alertmanager**: Alerting pipeline with example rules.
- **Grafana**: Dashboards, provisioned with ConfigMaps for datasources.
- **VictoriaLogs**: Log aggregation and storage.
- **Fluent Bit/Vector**: Log shipping agents (choose based on preference).

### 14.5 Example ServiceScrapes
See the main YAML for `VMServiceScrape` and `VMNodeScrape` objects for API server, kubelet, cAdvisor, node-exporter, kube-state-metrics, and common apps (NGINX, CoreDNS, etcd).

### 14.6 Security & Network Policies
- Example `NetworkPolicy` provided to restrict access to monitoring namespace.
- RBAC for all monitoring components (see YAML for ClusterRole/Binding).

### 14.7 Storage Classes
- Example StorageClass YAMLs for NFS, Longhorn, and cloud providers.
- All PVCs reference a configurable StorageClass.

### 14.8 Backup & Retention
- Example CronJob for VictoriaMetrics backup to S3-compatible storage.
- Retention period set in VMCluster and VLogs specs.

### 14.9 Operational Notes
- All manifests/Helm values should be stored in the `monitoring/` folder and managed by ArgoCD AppSet.
- Use provided troubleshooting commands to verify pod and service health.
- Access Grafana and VictoriaMetrics UI via port-forward or HTTPRoute.

### 14.10 Quick Install Script
See provided Bash script for automated Helm install and post-install access instructions.

---

This section provides actionable YAML and Helm configuration structure for a production-ready, GitOps-managed Kubernetes monitoring stack using VictoriaMetrics, Grafana, Alertmanager, and VictoriaLogs, as described in the referenced articles. Adjust resource limits, storage classes, and alert rules as needed for your environment.
