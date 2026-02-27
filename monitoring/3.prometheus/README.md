
## Prometheus Server & Prometheus Alertmanager

- See PM_README.md for more information regarding Prometheus Server.

- See AM_README.md for more information regarding Prometheus Alert Manager.

## Deployment - All in One

### Prequitistes

First we need to make sure we have our required namespaces.

This can be done by executing:

```bash
kubectl apply -f monitoring/namespaces.yaml
```

```bash
cd prometheus
kubectl apply -f .
```

### Monitor

```bash
kubectl get all -n monitor
```

```
prometheus/
├── 1.prometheus-clusterrole.yaml
├── 2.prometheus-volumes.yaml
├── 3.prometheus-configmap.yaml  
├── 4.prometheus-deploy.yaml
├── 5.prometheus-service.yaml
|
├── 6.alertmanager-configmap.yaml
├── 7.alertmanager.yaml
├── 8.alertmanager-service.yaml
|
├── 9.kube-state-metrics.yaml
|
├── AM_README.md
├── PM_README.md
└── README.md
```

## Adding Pods and Nodes to environment

Any pod with the prometheus.io/scrape: "true" annotation and any new node will automatically show up. The scrape configs use Kubernetes service discovery (kubernetes_sd_configs) so they dynamically pick up new targets. No config changes needed.

```bash
cd monitoring

# Then reload prometheus (no restart needed if using --web.enable-lifecycle)
curl -X POST http://localhost:8080/prometheus/-/reload

# or hard restart:
kubectl rollout restart deployment/prometheus-deployment -n monitoring
```