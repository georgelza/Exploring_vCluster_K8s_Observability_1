# Prometheus + Thanos Sidecar + Alertmanager

## What it is

Prometheus is the core metrics collection engine. It scrapes metrics from the Kubernetes cluster every 5 seconds and stores them locally for 12 hours. A Thanos sidecar runs in the same pod and ships completed 2-hour TSDB blocks to RustFS (S3) for long-term storage.

## Namespace

`monitoring`

## Architecture

```
Kubernetes cluster
      │  scrape every 5s
      ▼
  Prometheus ──── 12h local TSDB ────► /prometheus (hostPath PV)
      │
      │  every 2h (completed blocks)
      ▼
  Thanos Sidecar ──────────────────────► RustFS S3 (thanos bucket)
```

## What is scraped

| Job | Target |
|-----|--------|
| `kubernetes-nodes` | Kubelet metrics on all nodes via API server proxy |
| `kubernetes-cadvisor` | Container CPU/memory/network metrics |
| `kubernetes-pods` | Any pod with `prometheus.io/scrape: "true"` annotation |
| `kubernetes-service-endpoints` | Any service with `prometheus.io/scrape: "true"` annotation |
| `kube-state-metrics` | Kubernetes object state (deployments, pods, nodes) |
| `kubernetes-apiservers` | API server metrics |

## Cluster Label

All metrics are tagged with:

```
cluster: my-vc1
replica: prometheus-0
```
This is required by Thanos for deduplication across replicas.

## Sub-path Configuration

Prometheus is served at `/prometheus` via:

- `--web.route-prefix=/prometheus`
- `--web.external-url=/prometheus`

This allows Traefik to route `/prometheus` without stripping the prefix.

## Retention

- Local TSDB: 12 hours (then blocks shipped to RustFS by Thanos sidecar)
- Block duration: 2h min/max (forces regular shipping to object store)

## Storage

hostPath PV on whichever node the pod is scheduled:

- Path: `/data/prometheus` (10Gi)
- An initContainer runs as root to fix permissions before the `nobody` (65534) user starts Prometheus

## Access

```
http://localhost:8080/prometheus
```

Via: `kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80`

## Files

| File | Purpose |
|------|---------|
| `1.prometheus-clusterrole.yaml` | ServiceAccount + ClusterRole + ClusterRoleBinding |
| `2.prometheus-volumes.yaml` | PV + PVC for TSDB storage |
| `3.prometheus-configmap.yaml` | Scrape config + Thanos S3 object store config |
| `4.prometheus-deploy.yaml` | Deployment with Prometheus + Thanos sidecar containers |
| `5.prometheus-service.yaml` | ClusterIP service exposing ports 9090, 10901 (gRPC), 10902 (HTTP) |
