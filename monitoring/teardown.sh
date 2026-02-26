#!/bin/bash
# =============================================================================
# Full Stack Teardown Script
# Removes all resources in reverse deployment order
# WARNING: PVs and hostPath data on nodes are preserved (see note at end)
# =============================================================================
echo "============================================="
echo " Starting Full Stack Teardown"
echo "============================================="

# =============================================================================
# 10. TRAEFIK INGRESS
# =============================================================================
echo ""
echo "Removing Traefik IngressRoutes..."
kubectl delete -f traefik-ingress/2.traefik-deploy-services.yaml --ignore-not-found
kubectl delete -f traefik-ingress/1.traefik-deploy.yaml --ignore-not-found
echo "✓ Traefik removed"

# =============================================================================
# 9. GRAFANA
# =============================================================================
echo ""
echo "Removing Grafana..."
kubectl delete -f grafana/4.grafana-service.yaml --ignore-not-found
kubectl delete -f grafana/3.grafana-deploy.yaml --ignore-not-found
kubectl delete -f grafana/2.grafana-configmap.yaml --ignore-not-found
kubectl delete -f grafana/1.grafana-volumes.yaml --ignore-not-found
echo "✓ Grafana removed"

# =============================================================================
# 8. NODE EXPORTER
# =============================================================================
echo ""
echo "Removing Node Exporter..."
kubectl delete -f node-exporter/0.node-exporter.yaml --ignore-not-found
echo "✓ Node Exporter removed"

# =============================================================================
# 7. KUBE-STATE-METRICS
# =============================================================================
echo ""
echo "Removing kube-state-metrics..."
kubectl delete -f prometheus/9.kube-state-metrics.yaml --ignore-not-found
echo "✓ kube-state-metrics removed"

# =============================================================================
# 6. ALERTMANAGER
# =============================================================================
echo ""
echo "Removing Alertmanager..."
kubectl delete -f prometheus/8.alertmanager-service.yaml --ignore-not-found
kubectl delete -f prometheus/7.alertmanager.yaml --ignore-not-found
kubectl delete -f prometheus/6.alertmanager-configmap.yaml --ignore-not-found
echo "✓ Alertmanager removed"

# =============================================================================
# 5. PROMETHEUS + THANOS SIDECAR
# =============================================================================
echo ""
echo "Removing Prometheus..."
kubectl delete -f prometheus/5.prometheus-service.yaml --ignore-not-found
kubectl delete -f prometheus/4.prometheus-deploy.yaml --ignore-not-found
kubectl delete -f prometheus/3.prometheus-configmap.yaml --ignore-not-found
kubectl delete -f prometheus/2.prometheus-volumes.yaml --ignore-not-found
kubectl delete -f prometheus/1.prometheus-clusterrole.yaml --ignore-not-found
echo "✓ Prometheus removed"

# =============================================================================
# 4. THANOS COMPONENTS
# =============================================================================
echo ""
echo "Removing Thanos components..."
kubectl delete -f thanos/3.thanos-deploy.yaml --ignore-not-found
kubectl delete -f thanos/2.thanos-configmap.yaml --ignore-not-found
echo "✓ Thanos removed"

# =============================================================================
# 3. THANOS BUCKET JOB
# =============================================================================
echo ""
echo "Removing Thanos bucket job..."
kubectl delete -f thanos/1.thanos-create-bucket.yaml --ignore-not-found
echo "✓ Thanos bucket job removed"

# =============================================================================
# 2. RUSTFS
# =============================================================================
echo ""
echo "Removing RustFS..."
kubectl delete -f rustfs/4.rustfs-service.yaml --ignore-not-found
kubectl delete -f rustfs/3.rustfs-deployment.yaml --ignore-not-found
kubectl delete -f rustfs/2.rustfs-volumes.yaml --ignore-not-found
kubectl delete -f rustfs/1.rustfs-secret.yaml --ignore-not-found
echo "✓ RustFS removed"

# =============================================================================
# 1. NAMESPACES (last — deleting a namespace removes everything in it)
# Commented out by default to avoid accidental data loss.
# Uncomment if you want a full clean slate.
# =============================================================================
# echo ""
# echo "Removing namespaces..."
# kubectl delete -f namespaces/namespaces.yaml --ignore-not-found
# echo "✓ Namespaces removed"

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "============================================="
echo " Teardown Complete"
echo "============================================="
echo ""
echo "Note: hostPath data on nodes is preserved at:"
echo "  /data/prometheus"
echo "  /data/grafana"
echo "  /data/rustfs/data"
echo "  /data/rustfs/logs"
echo ""
echo "To fully clean node data (run on each node or via debug pod):"
echo "  kubectl debug node/<node-name> -it --image=busybox -- chroot /host sh"
echo "  rm -rf /data/prometheus /data/grafana /data/rustfs"
