## Deploying our monitor stack

### Monitor stack Structure

First, below is a depiction of all the manifest files involved.
See below the layout for more detail with regard to the deployment steps.

As you will see, each directory is numbered, defining the deployment order. Each sub directory also includes an additional `README.md` file.

```
|
├── 0.namespaces.yaml
├── Dashboards.md
├── Deploy_core.md
├── Deploy_monitoring.md     <- This file
├── README.md     
|
├── 1.rustfs/
│   ├── 1.rustfs-secret.yaml
│   ├── 2.rustfs-volumes.yaml
│   ├── 3.rustfs-deployment-tcp-probes.yaml
|   ├── 4.rustfs-service.yaml 
│   └── README.md
|
├── 2.thanos/
│   ├── 1.thanos-create-bucket.yml
│   ├── 2.thanos-configmap.yaml
│   ├── 3.thanos-deploy.yaml
│   └── README.md
|
├── 3.prometheus/
│   ├── 1.prometheus-clusterrole.yaml
│   ├── 2.prometheus-volumes.yaml
│   ├── 3.prometheus-configmap.yaml
│   ├── 4.prometheus-deploy.yaml
│   ├── 5.prometheus-service.yaml
│   ├── 6.alertmanager-configmap.yaml
│   ├── 7.alertmanager.yaml
|   ├── 8.alertmanager-service.yaml
│   ├── 9.kube-state-metrics.yaml    
│   └── README.md
|
├── 4.node_exporter/
│   ├── 0.node-exporter.yaml
│   └── README.md
|
├── 5.grafana/
│   ├── 1.grafana-volumes.yaml
│   ├── 2.grafana-configmap.yaml
│   ├── 3.grafana-deploy.yaml
│   ├── 4.grafana-service.yaml
│   └── README.md
|
├── 6.traefik-ingress/
|   ├── 1.traefik-deploy.yaml
|   ├── 2.traefik-deploy-services.yaml
|   └── README.md
|
└── 7.Apps/
    ├── PythonApp/
    |   ├── app-build/
    |   ├── dashboard/
    |   ├── k8s-deploy/
    |   └── README.md
    ├── JavaApp/
    |   ├── app-build/
    |   ├── dashboard/
    |   ├── k8s-deploy/
    |   └── README.md
    ├── GolangApp/
    |   ├── app-build/
    |   ├── dashboard/
    |   ├── k8s-deploy/
    |   └── README.md
    └── README.md

```

### Lets Deploy...

1. Deploy monitoring/0.namespaces.yaml

```bash
# in monitoring directory
kubectl apply 0.namespaces.yaml
kubectl get namespaces
```

2. Deploy monitoring/1.rustfs

```bash
cd monitoring/1.rustfs
kubectl apply -f .
kubectl get all -n data -o wide
```

3. Deploy monitoring/2.thanos

```bash
cd monitoring/2.thanos
kubectl apply -f .
kubectl get all -n monitoring -o wide
```

4. Deploy monitoring/3.prometheus  (includes Alert Manager & enabling Kube-state-metrics)

```bash
cd monitoring/3.prometheus
kubectl apply -f .
kubectl get all -n monitoring -o wide
```

5. Deploy monitoring/4.node_export

```bash
cd monitoring/4.node_exporter
kubectl apply -f .
kubectl get all -n monitoring -o wide
```
6. Deploy monitoring/5.grafana

```bash
cd monitoring/5.grafana
kubectl apply -f .
kubectl get all -n monitoring -o wide
```

7. Test

``` bash
kubectl port-forward service/rustfs-service 9001:9001 -n data
kubectl port-forward service/prometheus-service 9090:9090 -n monitoring 
kubectl port-forward service/alertmanager 9093:9093 -n monitoring 
kubectl port-forward service/thanos-query 9091:9090 -n monitoring 
kubectl port-forward service/grafana 3000:3000 -n monitoring 
```

8. Deploy monitoring/6.traefik-ingress

```bash
cd monitoring/6.traefik-ingress
kubectl apply -f .
kubectl get all -n monitoring -o wide
```

9. Deploy Various Demo Prometheus metric generating apps, see monitoring/7.Apps

```bash
# Python Demo App
cd monitoring/7.Apps
cd PythonApp/app-build
make build
make push
make k-apply

# Golang Demo App
cd GolangApp/app-build
go mod tidy
make build
make push
make k-apply

# Java Demo App
cd JavaApp/app-build
make build
make push
make k-apply
```