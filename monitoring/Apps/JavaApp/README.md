# Java based prometheus-demo 

## Verify Metrics being published

kubectl port-forward -n prometheus-demo deployment/java-prometheus-demo 8000:8000

### Metrics

curl http://localhost:8000/metrics

### Logs

kubectl logs -n prometheus-demo deployment/java-prometheus-demo -f