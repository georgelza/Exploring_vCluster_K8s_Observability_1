## Thanos

### What it is

[Thanos](https://thanos.io) extends Prometheus with long-term storage and global query capability.

[Thanos](https://thanos.io) is an open-source CNCF project that extends Prometheus - Monitoring to create a highly available, global-querying, and long-term storage monitoring system. It runs alongside Prometheus, utilizing object storage (e.g., S3, GCS) for data retention, while allowing you to query multiple Prometheus instances from one place.

It consists of four components in this stack:

```
Prometheus Pod
└── Thanos Sidecar ──────────────────────────────► RustFS S3 (thanos bucket)
                                                         │
                                                         ▼
Grafana ──► Thanos Query ◄── Thanos Store Gateway ◄─────┘
                │
                └──► Prometheus Sidecar (live data, last 2h)

RustFS S3 ◄──► Thanos Compactor (background: compact + downsample)
```

### Namespace

`monitoring`

## Components

### Thanos Sidecar (runs inside Prometheus pod)

- Watches Prometheus TSDB for completed 2-hour blocks
- Uploads blocks to RustFS `thanos` bucket
- Exposes a gRPC endpoint so Thanos Query can read recent data

### Thanos Query

- The single query endpoint used by Grafana
- Fan-out: queries both the sidecar (recent data) and Store Gateway (historical data)
- Deduplicates results from multiple replicas using `replica` label
- Served at `/thanos` via `--web.external-prefix=/thanos`

### Thanos Store Gateway

- Reads historical TSDB blocks from RustFS S3
- Exposes gRPC endpoint for Thanos Query
- Caches block metadata in memory (data dir is emptyDir — metadata only, not block data)

### Thanos Compactor

- Runs continuously (`--wait`) in the background
- Compacts and downsamples blocks in RustFS for efficient long-term storage
- Retention policy:
  - Raw data: 30 days
  - 5-minute downsampled: 90 days
  - 1-hour downsampled: 365 days

## Object Store Config

Defined in `prometheus/3.prometheus-configmap.yaml` as `thanos-objstore-config` ConfigMap, mounted into sidecar, store gateway, and compactor:

```yaml
type: S3
config:
  bucket: thanos
  endpoint: rustfs-service.data.svc.cluster.local:9000
  access_key: rustadmin
  secret_key: rustadmin
  insecure: true
```

## Sub-path Configuration

Thanos Query is served at `/thanos` via:
- `--web.external-prefix=/thanos`
- `--web.prefix-header=X-Forwarded-Prefix`

No Traefik strip middleware needed — Thanos handles the prefix itself.

## Access

```
http://localhost:8080/thanos
```

Via: `kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80`

## Files

| File | Purpose |
|------|---------|
| `1.thanos-create-bucket.yaml` | One-off Job to create the `thanos` bucket in RustFS |
| `2.thanos-configmap.yaml` | Configmap for Thanos deployment |
| `3.thanos-deploy.yaml` | Query + Store Gateway + Compactor deployments and services |


## Deployment

### Prequitistes

First we need to make sure we have our required namespaces.

This can be done by executing:

```bash
kubectl apply -f monitoring/namespaces.yaml
```

## Deploying Thanos stack

Followed by executing the below from inside the `monitoring/thanos` directory,

```bash
cd monitoring/thanos
kubectl apply -f .
```