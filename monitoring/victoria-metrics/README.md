# VictoriaMetrics Operator - Single Binary Mode

This directory contains the configuration for deploying VictoriaMetrics Operator in single binary mode using ArgoCD.

## Components

### VictoriaMetrics Operator
- **Chart**: `victoria-metrics-operator` v0.1.3
- **Repository**: https://victoriametrics.github.io/helm-charts/
- **Namespace**: `victoriametrics-operator`

### VictoriaMetrics Single Instance
- **Image**: `victoriametrics/victoria-metrics:v1.96.0`
- **Mode**: Single binary (all-in-one)
- **Storage**: 10Gi Longhorn persistent volume
- **Retention**: 30 days
- **Port**: 8428

### VictoriaLogs Single Instance
- **Image**: `victoriametrics/victorialogs:v1.96.0`
- **Mode**: Single binary for log aggregation
- **Storage**: 5Gi Longhorn persistent volume
- **Retention**: 30 days
- **Port**: 9420

### VLAgent (Log Collection)
- **Image**: `victoriametrics/vlagent:v1.96.0`
- **Purpose**: Collects logs from multiple namespaces
- **Port**: 8429

### VMAlert (Alerting)
- **Image**: `victoriametrics/vmalert:v1.96.0`
- **Purpose**: Evaluates alert rules and sends notifications
- **Port**: 8880

## Features

- **Admission Webhooks**: Enabled with cert-manager for validation
- **Self-Monitoring**: VMScrape configured for operator monitoring
- **Unified Logging**: VictoriaLogs integration for log aggregation
- **Log Collection**: VLAgent for efficient log collection from multiple namespaces
- **Alerting**: VMAlert with pre-configured alert rules
- **Persistent Storage**: Uses Longhorn storage class
- **Security**: Non-root user, security context configured
- **Resource Limits**: Configured CPU and memory limits
- **Cost Efficiency**: Up to 60% less disk usage compared to Prometheus

## Access

Once deployed, VictoriaMetrics will be available at:
- **VictoriaMetrics**: `victoriametrics.victoriametrics-operator.svc.cluster.local:8428`
- **VictoriaLogs**: `victorialogs.victoriametrics-operator.svc.cluster.local:9420`
- **VMAlert**: `vmalert.victoriametrics-operator.svc.cluster.local:8880`
- **VLAgent**: `vlagent.victoriametrics-operator.svc.cluster.local:8429`
- **External**: `https://metrics.vanillax.xyz`
- **Metrics Endpoint**: `/metrics`

## Configuration

The setup includes:
- VictoriaMetrics Operator (manages CRDs and controllers)
- VMSingle instance (single binary mode)
- VLSingle instance (log aggregation)
- VLAgent (log collection from multiple namespaces)
- VMAlert (alerting with pre-configured rules)
- VMScrape (for self-monitoring)
- HTTPRoute (for external access via Gateway API)

## Dependencies

- cert-manager (for admission webhooks)
- Longhorn (for persistent storage)
- Grafana (for visualization - can be integrated separately)

## Documentation

- [VictoriaMetrics Operator Helm Chart](https://docs.victoriametrics.com/helm/victoriametrics-operator/)
- [VMSingle CRD Documentation](https://docs.victoriametrics.com/operator/custom-resources/vmsingle/)
- [VictoriaLogs Documentation](https://docs.victoriametrics.com/victorialogs/)
- [VMAlert Documentation](https://docs.victoriametrics.com/vmalert/)
- [VLAgent Documentation](https://docs.victoriametrics.com/vlagent/) 