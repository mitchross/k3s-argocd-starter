# Monitoring Stack Documentation

## Overview

This monitoring stack provides comprehensive observability for your Kubernetes cluster with the following components:

**OPTIMIZED FOR HOMELAB (NUC + RPi5)**
- Reduced resource requirements for small clusters
- Shorter retention periods to save storage
- Single replica deployments where possible
- Minimal storage requirements

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notification
- **Loki**: Log aggregation and storage
- **Promtail**: Log collection agent
- **Tempo**: Distributed tracing
- **Node Exporter**: Node-level metrics
- **kube-state-metrics**: Kubernetes state metrics

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │    │   Kubernetes    │    │   Infrastructure │
│                 │    │   Components    │    │   Components    │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Promtail                                │
│                    (Log Collection)                           │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Loki                                   │
│                    (Log Storage)                              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Grafana                                  │
│                   (Visualization)                             │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Prometheus                                │
│                   (Metrics Storage)                           │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AlertManager                                │
│                   (Alert Routing)                             │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### Prometheus Stack (`prometheus-stack`)

**Purpose**: Core metrics collection and storage
**Components**:
- Prometheus Server
- Grafana Dashboard
- AlertManager
- Node Exporter
- kube-state-metrics

**Configuration**:
- Retention: 7 days (optimized for homelab)
- Storage: 5Gi Longhorn PVC (reduced for homelab)
- Scrape Interval: 60s (reduced frequency for performance)
- Evaluation Interval: 60s

**Access URLs**:
- Grafana: `https://grafana.vanillax.xyz`
- Prometheus: `https://prometheus.vanillax.xyz`
- AlertManager: `https://alertmanager.vanillax.xyz`

### Loki Stack (`loki-stack`)

**Purpose**: Log aggregation and storage
**Components**:
- Loki Server
- MinIO (S3-compatible storage)
- Gateway

**Configuration**:
- Retention: 7 days
- Storage: MinIO with S3 backend
- Deployment Mode: SingleBinary (optimized for homelab)

**Access URL**:
- Loki: `https://loki.vanillax.xyz`

### Tempo Stack (`tempo-stack`)

**Purpose**: Distributed tracing
**Components**:
- Tempo Server
- Grafana Agent
- Gateway

**Configuration**:
- Retention: 24 hours
- Storage: 2Gi Longhorn PVC (optimized for homelab)
- OTLP receivers enabled
- Single replica deployment

**Access URL**:
- Tempo: `https://tempo.vanillax.xyz`

### Promtail Stack (`promtail-stack`)

**Purpose**: Log collection agent
**Components**:
- Promtail DaemonSet
- ServiceAccount with RBAC

**Configuration**:
- Collects logs from all pods
- Sends to Loki
- Positions tracking for log continuity
- Optimized resource usage for homelab

## Security Features

### Network Policies

The monitoring stack includes comprehensive network policies that:

1. **Restrict Prometheus Access**: Only allows scraping from authorized targets
2. **Secure Grafana**: Limits access to Prometheus and Loki data sources
3. **Protect AlertManager**: Controls notification endpoints
4. **Isolate Components**: Prevents unauthorized cross-component communication

### Security Contexts

All components run with:
- Non-root users
- Read-only filesystems where possible
- Dropped capabilities
- Proper resource limits

## Alerts

### Critical Alerts
- Node not ready
- Pod crash looping
- Prometheus target down
- Configuration reload failures

### Warning Alerts
- High memory/CPU usage
- Disk space issues
- ArgoCD sync problems
- Application health issues

### Custom Alerts
- Longhorn storage health
- Cilium network issues
- Application-specific metrics

## Troubleshooting

### Common Issues

#### 1. Prometheus Not Scraping Targets

```bash
# Check Prometheus targets
kubectl port-forward -n prometheus-stack svc/kube-prometheus-stack-prometheus 9090:9090

# Check ServiceMonitor status
kubectl get servicemonitors -n prometheus-stack

# Check Prometheus logs
kubectl logs -n prometheus-stack -l app.kubernetes.io/name=prometheus
```

#### 2. Grafana Not Loading Dashboards

```bash
# Check Grafana logs
kubectl logs -n prometheus-stack -l app.kubernetes.io/name=grafana

# Verify data source connections
kubectl get configmap -n prometheus-stack kube-prometheus-stack-grafana -o yaml
```

#### 3. Loki Not Receiving Logs

```bash
# Check Promtail status
kubectl get pods -n promtail-stack

# Check Promtail logs
kubectl logs -n promtail-stack -l app.kubernetes.io/name=promtail

# Verify Loki connectivity
kubectl port-forward -n loki-stack svc/loki-gateway 3100:80
```

#### 4. AlertManager Not Sending Notifications

```bash
# Check AlertManager configuration
kubectl get secret -n prometheus-stack alertmanager-kube-prometheus-stack-alertmanager -o yaml

# Check AlertManager logs
kubectl logs -n prometheus-stack -l app.kubernetes.io/name=alertmanager
```

### Performance Tuning

#### High Memory Usage
1. Reduce scrape intervals (already set to 60s for homelab)
2. Increase resource limits if needed
3. Optimize PromQL queries
4. Enable WAL compression

#### High CPU Usage
1. Reduce evaluation intervals (already set to 60s for homelab)
2. Use recording rules for expensive queries
3. Optimize ServiceMonitor selectors
4. Enable query result caching

#### For Very Resource-Constrained Setups
If you need even more resource savings, use the lightweight configuration:
```bash
# Copy the lightweight config
cp monitoring/prometheus-stack/values-lightweight.yaml monitoring/prometheus-stack/values.yaml
```

#### Storage Issues
1. Increase PVC sizes
2. Enable data compression
3. Adjust retention periods
4. Use external storage (Thanos)

## Best Practices

### 1. Resource Management
- Set appropriate resource limits (optimized for homelab)
- Monitor resource usage with alerts
- Scale components based on cluster size
- Use horizontal pod autoscaling
- Consider lightweight config for very small clusters

### 2. Security
- Change default passwords
- Use network policies
- Enable RBAC
- Regular security updates

### 3. Data Retention
- Configure appropriate retention periods
- Use external storage for long-term data
- Implement data lifecycle policies
- Regular backup procedures

### 4. Monitoring the Monitor
- Monitor the monitoring stack itself
- Set up alerts for monitoring components
- Regular health checks
- Performance monitoring

## Maintenance

### Regular Tasks

1. **Weekly**:
   - Review alert history
   - Check resource usage
   - Update dashboards

2. **Monthly**:
   - Review and update alert rules
   - Check for component updates
   - Validate backup procedures

3. **Quarterly**:
   - Performance review
   - Security audit
   - Capacity planning

### Updates

To update components:

```bash
# Update Helm chart versions in kustomization.yaml
# Apply changes via ArgoCD
kubectl apply -f monitoring/monitoring-components-appset.yaml
```

## Access and Credentials

### Default Credentials

⚠️ **IMPORTANT**: Change these passwords immediately!

- **Grafana**: `admin` / `CHANGE_ME_TO_SECURE_PASSWORD`
- **Prometheus**: No authentication (behind Gateway)
- **AlertManager**: No authentication (behind Gateway)

### Changing Passwords

```bash
# Generate bcrypt hash for new password
# Update the secret in prometheus-stack namespace
kubectl patch secret -n prometheus-stack kube-prometheus-stack-grafana \
  -p '{"stringData": {"admin-password": "NEW_BCRYPT_HASH"}}'
```

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review component logs
3. Check ArgoCD sync status
4. Verify network policies
5. Review resource usage

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Tempo Documentation](https://grafana.com/docs/tempo/)
- [AlertManager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/) 