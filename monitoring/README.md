# Kubernetes Monitoring & Logging Starter Stack (2025 Edition)

## Overview

This monitoring stack is designed for home labs, small clusters, and anyone new to Kubernetes who wants a "just works" experience. It includes:

- **Prometheus**: Classic metrics collection, best for learning and compatibility.
- **VictoriaMetrics**: Modern, high-performance, drop-in replacement for Prometheus.
- **Grafana**: Powerful dashboards and visualization, preloaded with the best Kubernetes dashboards.
- **Loki + Promtail**: Log aggregation and search, integrated with Grafana.
- **Kubecost (optional)**: Cost monitoring for those curious about resource usage and cost allocation.

You can deploy both Prometheus and VictoriaMetrics at the same time, or just one. All components are installed via Helm charts with minimal, beginner-friendly configuration.

---

## Quickstart: Deploy the Stack

### 1. Prerequisites
- Kubernetes cluster (k3s, kind, minikube, etc.)
- `kubectl` and [`kustomize`](https://kubectl.docs.kubernetes.io/installation/kustomize/) installed
- (Optional) [Helm](https://helm.sh/) if you want to install components individually

### 2. Deploy Everything (Recommended)
```sh
cd monitoring
kubectl apply -k .
```
This will install **Prometheus, VictoriaMetrics, Grafana, Loki, Promtail, and Kubecost** into the `monitoring` namespace.

> **Tip:** To install only some components, comment out lines in `monitoring/kustomization.yaml`.

### 3. Access the Dashboards
- **Grafana:**
  - `kubectl port-forward svc/grafana 3000:80 -n monitoring`
  - Open [http://localhost:3000](http://localhost:3000)
  - **Default login:** `admin` / `prom-operator`
- **Prometheus:**
  - `kubectl port-forward svc/prometheus-kube-prometheus-stack-prometheus 9090:9090 -n monitoring`
  - Open [http://localhost:9090](http://localhost:9090)
- **VictoriaMetrics UI:**
  - `kubectl port-forward svc/victoriametrics-vmsingle 8428:8428 -n monitoring`
  - Open [http://localhost:8428/vmui](http://localhost:8428/vmui)
- **Loki (logs via Grafana):**
  - Use the **Explore** tab in Grafana (Loki is preconfigured as a data source)
- **Kubecost:**
  - `kubectl port-forward svc/kubecost-cost-analyzer 9090:9090 -n monitoring`
  - Open [http://localhost:9090](http://localhost:9090)

---

## How to Switch or Remove Metrics Backends
- **Both Prometheus and VictoriaMetrics are installed by default.**
- To use only one, comment out the other in `kustomization.yaml` and re-apply:
  - Comment out `- prometheus/` or `- victoriametrics/`
- Grafana is preconfigured for both. You can select the data source in each dashboard.

---

## Powerful Preloaded Dashboards
All dashboards are preloaded in Grafana! No manual import needed.

- **K8S Dashboard EN 20250125** ([ID: 15661](https://grafana.com/grafana/dashboards/15661))
  - Cluster, node, pod, and network metrics
- **Kubernetes Cluster Monitoring** ([ID: 10000](https://grafana.com/grafana/dashboards/10000))
  - Cluster health, resource usage, SLOs
- **Kubernetes - Cluster Overview** ([ID: 12202](https://grafana.com/grafana/dashboards/12202))
  - Single-page cluster summary
- **Kubernetes Monitoring Overview** ([ID: 14623](https://grafana.com/grafana/dashboards/14623))
  - Drill-down from cluster to pod
- **Kubernetes Monitoring Dashboard** ([ID: 12740](https://grafana.com/grafana/dashboards/12740))
  - Pod/container stats, cAdvisor metrics

> **Tip:** Use the dashboard search in Grafana to find these by name or ID.

---

## Log Exploration (Loki + Promtail)
- All pod logs are collected by Promtail and sent to Loki.
- In Grafana, go to the **Explore** tab, select the **Loki** data source, and start querying logs.
- Example LogQL query: `{namespace="default"}`
- Filter by pod, container, label, or search for error messages.

---

## Cost Monitoring (Kubecost)
- Kubecost provides real-time cost visibility for your cluster.
- Access via port-forward (see above) or expose via Ingress/Service as needed.
- See which namespaces, workloads, or nodes are using the most resources and estimate costs.

---

## Default Credentials
- **Grafana:** `admin` / `prom-operator`
  - Change via the UI or by editing `grafana/values.yaml` before install.
- **Prometheus, VictoriaMetrics, Loki, Kubecost:** No default auth (local access only). Secure with Ingress or network policies for production.

---

## Troubleshooting & Tips
- **Pods not starting?** Check `kubectl get pods -n monitoring` and `kubectl describe pod ...` for errors.
- **No data in dashboards?** Make sure Prometheus or VictoriaMetrics pods are running and ServiceMonitors are discovered.
- **No logs in Grafana?** Check Promtail and Loki pods, and ensure logs are being scraped.
- **Want to add your own dashboards?** Place JSON files in `grafana/dashboards/` and re-apply.
- **Want to add alerts?** Use PrometheusRule or VMRule CRDs, or add alerting rules in the respective values.yaml.

---

## Learn More
- [Prometheus Docs](https://prometheus.io/docs/)
- [VictoriaMetrics Docs](https://docs.victoriametrics.com/)
- [Grafana Docs](https://grafana.com/docs/)
- [Loki Docs](https://grafana.com/docs/loki/)
- [Kubecost Docs](https://docs.kubecost.com/)
- [Kubernetes Monitoring Tutorials (YouTube)](https://www.youtube.com/results?search_query=kubernetes+monitoring+prometheus+grafana)

---

## FAQ & Encouragement
- **Do I need to edit a lot of YAML?** No! Only `kustomization.yaml` if you want to enable/disable components.
- **Can I run this on a single VM or Raspberry Pi?** Yes! All resource requests are tuned for home labs.
- **Is this production-ready?** It's perfect for learning and home labs. For production, add Ingress, auth, and network policies.
- **Can I experiment and break things?** Absolutely! This stack is for learning. Try things, break things, and learn by doing.

---

**Happy monitoring! Your Kubernetes journey just got a lot easier.** 