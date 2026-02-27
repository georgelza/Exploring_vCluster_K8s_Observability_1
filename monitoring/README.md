## Deploying our K8S Observability stack

Below are the high level steps that we will be following.

For each of the below see the local `README.md` file located in the specific directory:

To deploy the stack you can execute the below command in each of the below directories

```bash
kubectl apply -f .
```

1. Deploy monitoring/0.namespaces.yaml

```bash
kubectl get all namespaces
```

2. Deploy monitoring/1.rustfs

```bash
kubectl get all -n data -o wide
```

3. Deploy monitoring/2.thanos

```bash
# For all the below deployments you can monitor using the below command
kubectl get all -n monitoring -o wide
```

4. Deploy monitoring/3.prometheus  (includes Alert Manager & enabling Kube-state-metrics)

5. Deploy monitoring/4.node_export

6. Deploy monitoring/5.grafana

7. Test

- kubectl port-forward service/rustfs-service 9001:9001 -n data
- kubectl port-forward service/prometheus-service 9090:9090 -n monitoring 
- kubectl port-forward service/alertmanager 9093:9093 -n monitoring 
- kubectl port-forward service/thanos-query 9091:9090 -n monitoring 
- kubectl port-forward service/grafana 3000:3000 -n monitoring 

8. Deploy monitoring/6.traefik-ingress

9. Deploy Various Demo Prometheus metric generating apps, see monitoring/7.Apps

For now, first Read the `Deploy.md` in this same directory.


## Other online Examples covering similar stack

- [Deploy Prometheus and Grafana on Kubernetes using Helm](https://medium.com/@gayatripawar401/deploy-prometheus-and-grafana-on-kubernetes-using-helm-5aa9d4fbae66)

- [How to Integrate Prometheus and Grafana on Kubernetes Using Helm](https://semaphore.io/blog/prometheus-grafana-kubernetes-helm)

- [How to Set Up Prometheus and Grafana in Kubernetes with Alertmanager and Slack Alerts](https://lenshq.io/blog/prometheus-grafana-kubernetes) 

- [DevOps Made Simple: A Beginner’s Guide to Monitoring Kubernetes Clusters with Prometheus & Grafana](https://dev.to/yash_sonawane25/devops-made-simple-a-beginners-guide-to-monitoring-kubernetes-clusters-with-prometheus-grafana-mgm)

- [Building a Scalable Monitoring Stack: Prometheus, Thanos and Grafana on Kubernetes](https://medium.com/@danielmehrani/building-a-centralized-monitoring-stack-prometheus-thanos-and-grafana-on-kubernetes-128190bdcec8)

- [Deploying Thanos on Kubernetes](https://medium.com/@amit151993/deploying-thanos-on-kubernetes-c3c5587614a7)
