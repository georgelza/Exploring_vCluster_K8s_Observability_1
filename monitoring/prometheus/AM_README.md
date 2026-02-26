# Alertmanager

## What it is

Alertmanager receives firing alerts from Prometheus, deduplicates and groups them, and routes them to notification channels. In this stack it is configured to send alerts to a Slack webhook.

## Namespace
`monitoring`

## Configuration

Alerts from Prometheus with `severity: slack` label are routed to the `slack-notifications` receiver. All other alerts go to the `null` receiver (silenced).

To enable Slack notifications, replace the webhook URL in `1.alertmanager.yaml`:

```yaml
api_url: 'https://hooks.slack.com/services/REPLACE_WITH_YOUR_WEBHOOK'
```

## Sub-path Configuration

Alertmanager is served behind Traefik at `/alertmanager`. Unlike Prometheus, Grafana, and Thanos, Alertmanager does **not** natively handle sub-path routing, so Traefik strips the `/alertmanager` prefix before forwarding:
- `--web.route-prefix=/` (serves at root internally)
- `--web.external-url=http://0.0.0.0:9093/alertmanager` (for correct link generation)
- Traefik `strip-alertmanager` middleware removes the prefix

## Access

```
http://localhost:8080/alertmanager
```
Via: `kubectl port-forward service/traefik1 -n ingress-traefik1 8080:80`

## Files
| File | Purpose |
|------|---------|
| `6.alertmanager-configmap.yaml` | ConfigMap for Prometheus server and Alert Manager |
| `7.alertmanager.yaml` | Deployment |
| `8.alertmanager-service.yaml` | Service (all-in-one) |
