## Grafana

### What it is

Grafana is the visualisation layer. It queries Thanos Query (which fans out to both the live Prometheus sidecar and historical data from RustFS) to display dashboards.

### Namespace

`monitoring`

### Datasource

Thanos Query is auto-provisioned as the default datasource on startup via ConfigMap. The URL points to:

```
http://thanos-query.monitoring.svc.cluster.local:9090
```

This means all queries go through Thanos, giving you both real-time and historical data in the same dashboard.

### Dashboard

Dashboard **18283** (Kubernetes All-in-One Cluster Monitoring) is imported manually after first login:

1. Go to **Dashboards → Import**
2. Enter ID `18283`
3. Select the **Thanos** datasource

### Sub-path Configuration

Grafana is served at `/grafana` via environment variables:

- `GF_SERVER_ROOT_URL` — tells Grafana its public URL includes `/grafana`
- `GF_SERVER_SERVE_FROM_SUB_PATH=true` — enables sub-path serving

No Traefik strip middleware needed — Grafana handles the prefix itself.

### Storage

hostPath PV on whichever node the pod is scheduled:

- Path: `/data/grafana` (5Gi)
- Persists dashboards, users, and settings across pod restarts
- An initContainer runs as root to fix permissions before the grafana user (472) starts

### Grafana No-Data Troubleshooting

If dashboards show "No data":

1. Go to **Connections → Data Sources** → verify Thanos datasource is green
2. On dashboard 18283, check the **cluster** variable dropdown shows `my-vc1`
3. If dropdown is empty: **Dashboard Settings → Variables** → confirm datasource is set to `Thanos` (not Prometheus)

### Access

```
http://localhost:8080/grafana
```

Via: `kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80`

Default credentials: `admin` / `admin` (change on first login)

### Files

| File | Purpose |
|------|---------|
| `1.grafana-volumes-configmap.yaml` | PV + PVC + datasource provisioning ConfigMap |
| `2.grafana-deploy.yaml` | Deployment + Service |


## Deployment

### Prequitistes

First we need to make sure we have our required namespaces.

This can be done by executing:

```bash
kubectl apply -f monitoring/namespaces.yaml
```

Make sure prometheus/9.kube-state-metrics.yaml was rolled out and that 

If successfull:

```bash
kubectl get pods -n kube-system | grep kube-state
```
kube-state-metrics-############   1/1     Running   0          8m51s

```bash
kubectl rollout status deployment/kube-state-metrics -n kube-system
```

responds with 'deployment "kube-state-metrics" successfully rolled out'


### Deploying

```bash
cd monitoring/grafana
kubectl apply -f .
```

### Example Dashboards / Configuring Grafana Dashboard

-- 18283 or 15661

Datasource : for 18283 point both:

- DS_PROMETHEUS — the main metrics datasource
- DS_SERVICEMONITOR — used for service monitor / scrape target queries

Kubernetes All-in-one Cluster Monitoring queries metrics across your whole cluster, and Thanos Query is the unified query layer that fans out across both:

- Live data → via the Prometheus sidecar (last 2 hours in TSDB)
- Historical data → via the Store Gateway (everything older, stored in RustFS)

For all other dashboards always point them at the Thanos datasource.

### Grafana Dashboards

- [Grafana Supplied Dashboards](https://grafana.com/grafana/dashboards/)

- [Modern set of Grafana Dashboards for Kubernetes](https://medium.com/@dotdc/a-set-of-modern-grafana-dashboards-for-kubernetes-4b989c72a4b2)
  