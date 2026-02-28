## How to: Exploring K8S on vCluster, Deploying a Observability stack - part 1

Welcome to [The Rabbit Hole](https://medium.com/@georgelza/list/the-rabbit-hole-0df8e3155e33)

When you’re building applications on Kubernetes, observability isn’t optional, it’s foundational. You need metrics to know if things are healthy, dashboards to spot trends, alerting to catch problems early, and long-term storage to answer questions about what happened last week or last month.

In this two-part series, we’ll deploy a complete observability stack on a local Kubernetes cluster powered by [vCluster](https://github.com/loft-sh/vcluster). No cloud account required. No VMs. Just Docker and a few commands.

- Part 1 (this post): [Prometheus](https://prometheus.io), [Grafana](https://grafana.com), [Thanos](https://thanos.io), [RustFS](https://rustfs.com), and [Traefik](https://traefik.io/traefik)

- Part 2: Adding log analytics with [ElasticSearch](https://www.elastic.co)

All source code is available at [georgelza/Exploring_vCluster_K8s_Observability_1](https://github.com/georgelza/Exploring_vCluster_K8s_Observability_1.git).

### Why vCluster for This?

[vCluster](https://github.com/loft-sh/vcluster) with the Docker driver gives you a multi-node Kubernetes cluster running entirely in Docker containers. For this project, that means a control plane and three worker nodes  enough capacity to run the full observability stack alongside demo workloads  all created with a single command:

```bash
vcluster create my-vc1 -f vcluster.yaml
```

The `vcluster.yaml` configures a 3-worker-node cluster:

```yaml
controlPlane:
  distro:
    k8s:
      version: "v1.35.0"
experimental:
  docker:
    nodes:
    - name: "worker-1"
    - name: "worker-2"
    - name: "worker-3"
```

That’s it. In under a minute, you have a fully functional Kubernetes cluster with multiple nodes, ready to host real workloads. When you’re done for the day, `vcluster pause my-vc1` frees up resources. `vcluster resume my-vc1` picks up right where you left off.


### What We’re Deploying

Here’s the full stack:

### Component Breakdown

```
Component                   What It Does

Prometheus                  Scrapes metrics from all workloads, nodes, and Kubernetes internals
Alertmanager                Handles alerts triggered by Prometheus rules
Thanos                      Provides long-term metric storage and a unified query layer across Prometheus instances
RustFS                      S3-compatible object store that backs Thanos for durable metric retention
Grafana                     Dashboards and visualization — connects to both Prometheus and Thanos as data sources
Traefik                     Ingress proxy routing all UIs through a single entry point on port 8080
```

<img src="blog-doc/diagrams/SuperLabv4.0.png" alt="Our Build" width="450" height="350">

### A Note on RustFS

You might be wondering why [RustFS](https://rustfs.com) instead of the more common MinIO. MinIO moved away from open-source licensing in a direction that doesn’t align with Apache Foundation values. RustFS is a drop-in S3-compatible replacement that stays true to open-source principles.

[RustFS](https://rustfs.com) does have one quirk: its web console has hard-coded paths, so it runs on its own port (:9001/rustfs) rather than routing through Traefik alongside everything else.

### Three Demo Applications

The stack includes three applications that generate custom Prometheus metrics — implemented in Python, Java, and Go:

```
Application                 Language            Metrics Library

python-prometheus-demo      Python              prometheus_client
java-prometheus-demo        Java                Micrometer
golang-prometheus-demo      Go                  promhttp
```

All three do the same thing: expose an HTTP endpoint with custom metrics that Prometheus scrapes. This gives you real data flowing through the entire pipeline — from scrape to storage to dashboard.

Pre-built Grafana dashboards are included for each application. See monitoring/Dashboards.md for screenshots and import instructions.
Each application also emits structured logs — that’s the foundation for Part 2 where we add Elasticsearch.


## The Bigger Picture

This project is part of a series building up a complete local Kubernetes development environment:

1. [Running K8s Locally with vCluster Inside Docker](https://medium.com/@georgelza/exploring-vcluster-as-solution-to-running-k8s-locally-inside-docker-6ea233c67726) — The foundation: setting up vCluster as a local dev environment

2. [Web Apps on vCluster with Traefik and Ingress](https://medium.com/@georgelza/how-to-web-apps-on-kubernetes-deployed-on-vcluster-configured-with-traefik-app-proxy-and-ingress-c79cfea7111c) — Deploying applications with proper ingress routing

3. Observability Stack, Part 1 (this post) — Metrics, dashboards, and long-term storage

4. Observability Stack, Part 2 (coming next) — Log analytics with Elasticsearch

By the end of the series, you have a local environment with application hosting, ingress routing, metrics collection, dashboarding, alerting, long-term metric storage, and log analytics. That’s a genuinely useful development platform — and it all runs on your laptop.

## Why Observability Matters

No system should go to production without end-to-end observability. You need metrics and logs working together to understand what’s happening. Without them, you don’t know what “good” looks like, which means you can’t spot when things go bad.
Observability also drives FinOps — it tells you whether your system is oversized, feeds into capacity planning, and informs budgeting. It’s not just an engineering concern; it’s a business one.

This project gives you working examples of all the pieces. Take the ingress patterns from the earlier posts, combine them with the demo applications and monitoring stack here, and you have the building blocks for a real application with proper observability baked in from day one.

## Deploying the Stack

The deployment follows a specific order since components depend on each other:

```
namespaces → rustfs → thanos → prometheus → node-exporter → grafana → traefik → demo apps
```

Each component, as per above can be deployed using `kubectl apply -f .` in the numbered directories found under `./monitoring`. Tear down is accomplished by executing `kubectl delete -f .` in the reverse order.

### Step by step

The deployment has been divided into 2 sections, Core deployment and Monitoring deployment.

For the complete step-by-step walkthrough, start with  `monitoring/README.md`.

- The Core is our Generic vCluster/Kubernetes Cluster and our Traefik Application Proxy. see `monitoring/Deploy_core.md`
- The Monitoring deployment then deploys our stack as per above onto our core Kubernetes cluster. see `monitoring/Deploy_monitoring.md`

See `mv-vc1/*` for screengrabs of each step executed and terminal output, additionally `monitoring/Dashboards.md` have example **node_exporter** and **Kubernetes** Grafana dashboards.


## What’s Next

**Part 2** adds [Elasticsearch](https://www.elastic.co) for log analytics. Combined with the metrics stack from **Part 1**, you’ll have a complete observability platform — metrics, dashboards, alerting, long-term storage, and log search — all running locally on [vCluster](https://github.com/loft-sh/vcluster).



### vCluster Project Pages

- [vCluster](https://github.com/loft-sh/vcluster)
- [Full Quickstart Guide](https://www.vcluster.com/docs/vcluster/#deploy-vcluster)
- [Slack Server](https://slack.loft.sh/)
- [VIND, vCluster in Docker](https://github.com/loft-sh/vind)


### Supporting Background Information

- [Prometheus](https://prometheus.io)
- [Grafana](https://grafana.com)
- [Thanos](https://thanos.io)
- [RustFS](https://rustfs.com)
- [Traefik](https://traefik.io/traefik)
- [Kubernetes](https://kubernetes.io/)


## THE END

And like that we’re done with our little trip down another Rabbit Hole, Till next time. 

Thanks for following. 


### The Rabbit Hole

<img src="blog-doc/diagrams/rabbithole.jpg" alt="Our Build" width="450" height="350">


### ABOUT ME

I’m a techie, a technologist, always curious, love data, have for as long as I can remember always worked with data in one form or the other, Database admin, Database product lead, data platforms architect, infrastructure architect hosting databases, backing it up, optimizing performance, accessing it. Data data data… it makes the world go round.
In recent years, pivoted into a more generic Technology Architect role, capable of full stack architecture.

### By: George Leonard

- georgelza@gmail.com
- https://www.linkedin.com/in/george-leonard-945b502/
- https://medium.com/@georgelza



<img src="blog-doc/diagrams/TechCentralFeb2020-george-leonard.jpg" alt="Me" width="400" height="400">

