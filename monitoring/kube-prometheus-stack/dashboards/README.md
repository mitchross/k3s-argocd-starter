# Custom Grafana Dashboards

This directory contains custom Grafana dashboard JSON files that will be automatically loaded into Grafana.

## Adding New Dashboards (GitOps Method)

1. **Download JSON**: Export or download dashboard JSON files from:
   - [Grafana Community Dashboards](https://grafana.com/grafana/dashboards/)
   - [Kubernetes Dashboards](https://grafana.com/grafana/dashboards/?search=kubernetes)
   - [Prometheus Dashboards](https://grafana.com/grafana/dashboards/?search=prometheus)

2. **Place in dashboards/**: Put the `.json` files in this directory

3. **Update kustomization.yaml**: Add the new dashboard to the `configMapGenerator.files` list:
   ```yaml
   configMapGenerator:
   - name: custom-dashboards
     files:
     - dashboards/k3s-cluster-overview.json
     - dashboards/your-new-dashboard.json  # Add this line
     options:
       labels:
         grafana_dashboard: "1"
   ```

4. **Commit & Push**: ArgoCD will automatically sync and load the new dashboard

## File Naming Convention

- Use descriptive names: `k3s-cluster-overview.json`
- Use kebab-case: `longhorn-storage-dashboard.json`
- Include source info if helpful: `node-exporter-full.json`

## How It Works

- **Kustomize generates ConfigMaps** from JSON files automatically
- **Grafana sidecar discovers** ConfigMaps with `grafana_dashboard: "1"` label
- **Dashboards auto-import** into Grafana with Prometheus datasource
- **Changes trigger updates** when ConfigMaps change

## Current Dashboards

- `k3s-cluster-overview.json` - Basic CPU and memory metrics for K3s cluster
