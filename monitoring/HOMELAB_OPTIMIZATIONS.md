# Homelab Optimizations for Monitoring Stack

## Overview

This document summarizes the optimizations made to the monitoring stack for NUC + RPi5 homelab environments.

## Resource Optimizations

### Prometheus Stack

#### Before (Production)
- **Prometheus**: 2Gi memory, 2000m CPU
- **Storage**: 20Gi PVC
- **Retention**: 30 days
- **Scrape Interval**: 30s

#### After (Homelab)
- **Prometheus**: 1Gi memory, 1000m CPU
- **Storage**: 5Gi PVC
- **Retention**: 7 days
- **Scrape Interval**: 60s

### Loki Stack

#### Before (Production)
- **Deployment Mode**: SimpleScalable (multiple replicas)
- **Components**: Separate read/write/backend pods
- **MinIO**: LoadBalancer service type

#### After (Homelab)
- **Deployment Mode**: SingleBinary (single pod)
- **Components**: All-in-one deployment
- **MinIO**: ClusterIP service type

### Tempo Stack

#### Before (Production)
- **Query Frontend**: 2 replicas, 512Mi memory
- **Ingester**: 3 replicas, 2Gi memory
- **Querier**: 2 replicas, 1Gi memory
- **Memcached**: Enabled with 2 replicas
- **Storage**: 10Gi PVC

#### After (Homelab)
- **Query Frontend**: 1 replica, 256Mi memory
- **Ingester**: 1 replica, 1Gi memory
- **Querier**: 1 replica, 512Mi memory
- **Memcached**: Disabled
- **Storage**: 2Gi PVC

### Promtail Stack

#### Before (Production)
- **Memory**: 512Mi limit
- **CPU**: 500m limit
- **Storage**: 1Gi PVC

#### After (Homelab)
- **Memory**: 256Mi limit
- **CPU**: 200m limit
- **Storage**: 500Mi PVC

## Performance Optimizations

### Scrape Intervals
- **Production**: 30s intervals for high-frequency monitoring
- **Homelab**: 60s intervals to reduce resource usage

### Evaluation Intervals
- **Production**: 30s for responsive alerting
- **Homelab**: 60s to reduce CPU usage

### Storage Compression
- Enabled WAL compression for Prometheus
- Reduced storage requirements by ~60%

## Component Optimizations

### Disabled Components (Lightweight Config)
For very resource-constrained setups, these components can be disabled:
- `kubeControllerManager`: Disabled
- `kubeScheduler`: Disabled  
- `kubeEtcd`: Disabled
- `defaultDashboardsEnabled`: false
- `plugins`: Empty array

### Reduced Replicas
- All components use single replicas where possible
- Eliminates redundancy for small clusters
- Reduces resource usage by ~50%

## Memory Usage Comparison

### Production Configuration
```
Prometheus:    4Gi
Grafana:       512Mi
AlertManager:  512Mi
Loki:          2Gi (3 replicas)
Tempo:         4Gi (multiple components)
Promtail:      512Mi
Total:         ~12Gi
```

### Homelab Configuration
```
Prometheus:    1Gi
Grafana:       256Mi
AlertManager:  128Mi
Loki:          256Mi (single binary)
Tempo:         1Gi (single replica)
Promtail:      256Mi
Total:         ~3Gi
```

## Storage Usage Comparison

### Production Configuration
```
Prometheus:    20Gi
Grafana:       5Gi
AlertManager:  2Gi
Loki:          10Gi
Tempo:         10Gi
Promtail:      1Gi
Total:         ~48Gi
```

### Homelab Configuration
```
Prometheus:    5Gi
Grafana:       2Gi
AlertManager:  1Gi
Loki:          2Gi
Tempo:         2Gi
Promtail:      500Mi
Total:         ~12Gi
```

## Recommendations

### For NUC + RPi5 Setup
1. **Use the standard homelab configuration** (current `values.yaml`)
2. **Monitor resource usage** with the provided alerts
3. **Scale up if needed** based on actual usage patterns

### For Very Resource-Constrained Setup
1. **Use the lightweight configuration** (`values-lightweight.yaml`)
2. **Disable optional components** as needed
3. **Consider external storage** for long-term data retention

### Monitoring Your Monitoring Stack
```bash
# Check resource usage
kubectl top pods -n prometheus-stack
kubectl top pods -n loki-stack
kubectl top pods -n tempo-stack
kubectl top pods -n promtail-stack

# Check storage usage
kubectl get pvc -A

# Check for alerts
kubectl get prometheusrules -n prometheus-stack
```

## Migration Path

### From Production to Homelab
1. Backup existing data if needed
2. Update `values.yaml` with homelab settings
3. Apply changes via ArgoCD
4. Monitor resource usage

### From Homelab to Lightweight
1. Copy `values-lightweight.yaml` to `values.yaml`
2. Apply changes via ArgoCD
3. Verify all components are working
4. Monitor for any missing functionality

## Troubleshooting

### High Resource Usage
1. Check if lightweight config is needed
2. Reduce scrape intervals further
3. Disable optional components
4. Consider external storage for long-term data

### Storage Issues
1. Reduce retention periods
2. Enable data compression
3. Use external storage (Thanos)
4. Implement data lifecycle policies

### Performance Issues
1. Increase resource limits if hardware allows
2. Optimize PromQL queries
3. Use recording rules for expensive queries
4. Enable query result caching 