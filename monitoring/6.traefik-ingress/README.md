
## Traefik Ingress

## What is Traefik?

(As Per Traefik site)...

[Traefik](https://traefik.io/traefik) is a leading modern open source reverse proxy and ingress controller that makes deploying services and APIs easy. Traefik integrates with your existing infrastructure components and configures itself automatically and dynamically.

### Simplified Operation, Complex Deployments

Traefik is designed to be as simple as possible to operate, but capable of handling large, highly-complex deployments across a wide range of environments and protocols in public, private, and hybrid clouds.

### Enhanced with Powerful Middleware Suite

Traefik also comes with a powerful set of middlewares that enhance its capabilities to include load balancing, API gateway, orchestrator ingress, and more.

## Deployment

```bash
cd monitoring/traefik-ingress
kubectl apply -f .
```

### Verify

```bash
kubectl get ingressroute -n ingress-traefik1

kubectl get middleware -n ingress-traefik1

```

### Summary

```
traefik-ingress/
├── 1.traefik-deploy.yaml           ← Deployment + Service (rustfs-console entrypoint on :9001)
└── 2.traefik-deploy-services.yaml  ← monitoring-ingress + rustfs-console-ingress

kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80

kubectl port-forward service/traefik1 -n ingress-traefik1 9001:9001
```

```bash
Browse to http://localhost:8080/prometheus
Browse to http://localhost:8080/grafana
Browse to http://localhost:8080/alertmanager
Browse to http://localhost:8080/thanos
Browse to http://localhost:9001/rustfs
```

Here's a summary of what's deployed and accessible via http://localhost:8080:

```
Service             URL                                  Notes 
Prometheus          :8080/prometheus                     12h local retention, ships to RustFS every 2h
Grafana             :8080/grafana                        Thanos as datasource, dashboard 18283 loaded
Alertmanager        :8080/alertmanager                   Slack webhook configured
Thanos Query        :8080/thanos                         Fans out across sidecar + store gateway
```

Here's a summary of what's deployed and accessible via http://localhost:9001:

```
Service             URL                                  Notes 
RustFS Console      :9001/rustfs/console/index.html      S3-compatible object store
```

### Key lessons learned

- RustFS uses `RUSTFS_ACCESS_KEY/SECRET_KEY` not `MinIO` env var names, no server subcommand, requires --console-enable flag
- Prometheus hostPath volumes need an initContainer chmod before the nobody user can write
- Thanos sidecar requires external_labels in Prometheus config or it refuses to start
- Traefik v3 blocks ExternalName services — use allowCrossNamespace with direct service references instead
- Services with their own sub-path handling (Prometheus, Grafana, Thanos) must not have strip-prefix middleware applied


### Next steps you might want to consider:

- Replace prom/prometheus:latest and grafana/grafana:latest with pinned versions for reproducibility
- Update the Slack webhook URL in the Alertmanager configmap
- Replace rustadmin/rustadmin credentials with something secure