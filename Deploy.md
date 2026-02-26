## Multi Node Kubernetes cluster on vCluster, 3 Web Apps sharing single Traefik Application Proxy and seperate Ingress's Controllers

See `vcluster.yaml`

## Step 1. Create a vCluster in Docker (automatically connects)

```bash
sudo vcluster create my-vc1 --values vcluster.yaml
```

## Step 2. Verify it's working

```bash
kubectl get nodes
kubectl get namespaces
```

Lets Label our nodes correctly, little attention to detail

```bash
kubectl label node worker-1 worker-2 worker-3 node-role.kubernetes.io/worker=worker
```

Notice the difference.

```bash
kubectl get nodes
```


## STEP 3: Install Traefik open-source HTTP Application/Reverse proxy 

```bash
echo "Installing Traefik with ClusterIP..."

helm upgrade --install traefik1 traefik \
  --repo https://helm.traefik.io/traefik \
  --namespace ingress-traefik1 --create-namespace \
  --set service.type=ClusterIP \
  --set ingressClass.name=traefik1
```

By using a ClusterIP it allows us to run one kubectl port-forward onto the cluster, through which we can then access all the services exposed.


## STEP 4: Deploy our Monitoring Stack.

So I'm using Manifest files on purpose, it's easier to read and easier to follow how things are are plugged together.
Nothing stopping you from doing the below using one of the various HELM deploy guides. 

NOTE: Traefik was deployed at the cluster build using HELM chart.

Next See: **monitoring/README.md** for detail.


├── deploy.sh
├── teardown.sh
├── namespaces.yaml
├── README.md
|
├── Apps/
|   ├── PythonApp/
|   |   ├── app-build/
|   |   ├── k8s-deploy/
│   |   └── README.md
|   ├── JavaApp/
|   |   ├── app-build/
|   |   ├── k8s-deploy/
│   |   └── README.md
|   ├── GolangApp/
|   |   ├── app-build/
|   |   ├── k8s-deploy/
│   |   └── README.md
│   └── README.md
|
├── rustfs/
│   ├── 1.rustfs-secret.yaml
│   ├── 2.rustfs-volumes.yaml
│   ├── 3.rustfs-deployment-tcp-probes.yaml
|   ├── 4.rustfs-service.yaml 
│   └── README.md
|
├── thanos/
│   ├── 1.thanos-create-bucket.yml
│   ├── 2.thanos-configmap.yaml
│   ├── 3.thanos-deploy.yaml
│   └── README.md
|
├── prometheus/
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
├── node_exporter/
│   ├── 0.node-exporter.yaml
│   └── README.md
|
├── grafana/
│   ├── 1.grafana-volumes.yaml
│   ├── 2.grafana-configmap.yaml
│   ├── 3.grafana-deploy.yaml
│   ├── 4.grafana-service.yaml
│   └── README.md
|
└── traefik-ingress/
│   ├── 1.traefik-deploy.yaml
    ├── 2.traefik-deploy-services.yaml
    └── README.md
