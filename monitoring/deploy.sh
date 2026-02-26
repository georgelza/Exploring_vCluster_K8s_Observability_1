#!/bin/bash
# =============================================================================
# Full Stack Deployment Script
# Prometheus + Thanos + Grafana + Alertmanager + RustFS + Traefik
# kube-state-metrics + node-exporter
#
# Usage: bash deploy.sh
#
# Access after deploy (two port-forwards needed):
#   kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80 &
#   kubectl port-forward service/traefik1 -n ingress-traefik1 9001:9001 &
#
#   http://localhost:8080/prometheus
#   http://localhost:8080/grafana
#   http://localhost:8080/alertmanager
#   http://localhost:8080/thanos
#   http://localhost:9001/rustfs/console/index.html  (Firefox only)
# =============================================================================
set -e

echo "============================================="
echo " Starting Full Stack Deployment"
echo "============================================="

# =============================================================================
# 1. NAMESPACES
# =============================================================================
echo ""
echo "[1/10] Creating namespaces..."
kubectl apply -f namespaces/namespaces.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/monitoring --timeout=30s
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/data --timeout=30s
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/ingress-traefik1 --timeout=30s
echo "✓ Namespaces ready"

# =============================================================================
# 2. RUSTFS
# =============================================================================
echo ""
echo "[2/10] Deploying RustFS..."
kubectl apply -f rustfs/1.rustfs-secret.yaml
kubectl apply -f rustfs/2.rustfs-volumes.yaml
kubectl apply -f rustfs/3.rustfs-deployment.yaml
kubectl apply -f rustfs/4.rustfs-service.yaml
kubectl rollout status deployment/rustfs -n data --timeout=120s
echo "✓ RustFS ready"

# =============================================================================
# 3. THANOS BUCKET
# =============================================================================
echo ""
echo "[3/10] Creating thanos bucket in RustFS..."
kubectl apply -f thanos/1.thanos-create-bucket.yaml
kubectl wait --for=condition=complete job/create-thanos-bucket -n data --timeout=60s
kubectl logs -n data job/create-thanos-bucket
echo "✓ Thanos bucket ready"

# =============================================================================
# 4. THANOS COMPONENTS
# Deploy thanos-objstore-config first — needed by sidecar, store gateway, compactor
# =============================================================================
echo ""
echo "[4/10] Deploying Thanos components..."
kubectl apply -f thanos/2.thanos-configmap.yaml
kubectl apply -f thanos/3.thanos-deploy.yaml
kubectl rollout status deployment/thanos-query -n monitoring --timeout=120s
kubectl rollout status deployment/thanos-store-gateway -n monitoring --timeout=120s
kubectl rollout status deployment/thanos-compactor -n monitoring --timeout=120s
echo "✓ Thanos components ready"

# =============================================================================
# 5. PROMETHEUS + THANOS SIDECAR
# =============================================================================
echo ""
echo "[5/10] Deploying Prometheus + Thanos Sidecar..."
kubectl apply -f prometheus/1.prometheus-clusterrole.yaml
kubectl apply -f prometheus/2.prometheus-volumes.yaml
kubectl apply -f prometheus/3.prometheus-configmap.yaml
kubectl apply -f prometheus/4.prometheus-deploy.yaml
kubectl apply -f prometheus/5.prometheus-service.yaml
kubectl rollout status deployment/prometheus-deployment -n monitoring --timeout=180s
echo "✓ Prometheus + Thanos Sidecar ready"

# =============================================================================
# 6. ALERTMANAGER
# =============================================================================
echo ""
echo "[6/10] Deploying Alertmanager..."
kubectl apply -f prometheus/6.alertmanager-configmap.yaml
kubectl apply -f prometheus/7.alertmanager.yaml
kubectl apply -f prometheus/8.alertmanager-service.yaml
kubectl rollout status deployment/alertmanager -n monitoring --timeout=120s
echo "✓ Alertmanager ready"

# =============================================================================
# 7. KUBE-STATE-METRICS
# =============================================================================
echo ""
echo "[7/10] Deploying kube-state-metrics..."
kubectl apply -f prometheus/9.kube-state-metrics.yaml
kubectl rollout status deployment/kube-state-metrics -n kube-system --timeout=120s
echo "✓ kube-state-metrics ready"

# =============================================================================
# 8. NODE EXPORTER
# Deployed after Prometheus so scraping begins immediately on startup
# =============================================================================
echo ""
echo "[8/10] Deploying Node Exporter..."
kubectl apply -f node-exporter/0.node-exporter.yaml
kubectl rollout status daemonset/node-exporter -n monitoring --timeout=120s
echo "✓ Node Exporter ready"

# =============================================================================
# 9. GRAFANA
# =============================================================================
echo ""
echo "[9/10] Deploying Grafana..."
kubectl apply -f grafana/1.grafana-volumes.yaml
kubectl apply -f grafana/2.grafana-configmap.yaml
kubectl apply -f grafana/3.grafana-deploy.yaml
kubectl apply -f grafana/4.grafana-service.yaml
kubectl rollout status deployment/grafana -n monitoring --timeout=120s
echo "✓ Grafana ready"

# =============================================================================
# 10. TRAEFIK INGRESS
# Note: Traefik deployment itself (traefik1) is managed separately via Helm.
# This step only applies the IngressRoutes and Middlewares.
# If rebuilding Traefik from scratch apply 1.traefik-deploy.yaml first.
# =============================================================================
echo ""
echo "[10/10] Applying Traefik IngressRoutes..."
kubectl apply -f traefik-ingress/1.traefik-deploy.yaml
kubectl apply -f traefik-ingress/2.traefik-deploy-services.yaml
echo "✓ Traefik IngressRoutes ready"

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "============================================="
echo " Deployment Complete!"
echo "============================================="
echo ""
echo "Start port-forwards:"
echo "  kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80 &"
echo "  kubectl port-forward service/traefik1 -n ingress-traefik1 9001:9001 &"
echo ""
echo "Access:"
echo "  Prometheus    → http://localhost:8080/prometheus"
echo "  Grafana       → http://localhost:8080/grafana       (admin/admin)"
echo "  Alertmanager  → http://localhost:8080/alertmanager"
echo "  Thanos        → http://localhost:8080/thanos"
echo "  RustFS UI     → http://localhost:9001/rustfs/console/index.html  (Firefox only)"
echo ""
echo "Grafana setup:"
echo "  1. Import dashboard ID 18283"
echo "  2. Select Thanos as datasource"
echo "  3. Set cluster variable to: my-vc1"
echo ""
kubectl get all -n monitoring
echo ""
kubectl get all -n data
echo ""
kubectl get all -n ingress-traefik1