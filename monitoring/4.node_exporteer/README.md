
## What are Prometheus Exporters

[Prometheus exporters](https://prometheus.io/docs/instrumenting/exporters/) are specialized agents that collect metrics from third-party systems, applications, or infrastructure that do not natively support Prometheus, converting them into a format Prometheus can scrape and store. They act as intermediaries, exposing metrics via an HTTP endpoint (usually /metrics) to enable monitoring of databases, hardware, and services. 

**Key Aspects of Prometheus Exporters:**

- Function: They translate metrics from various sources (MySQL, NGINX, Linux systems) into the Prometheus exposition format.
- Mechanism: Exporters are typically standalone processes (or libraries) that run alongside the target application.
- Pull Model: The Prometheus server periodically scrapes these exporters' HTTP endpoints to retrieve the data.

**Types:**

- Official Exporters: Maintained by the Prometheus team (e.g., Node Exporter for hardware/OS).
- Third-Party Exporters: Created by the community for specific software.

**Common Examples:**
- Node Exporter: Collects system-level metrics (CPU, memory, disk).
- MySQL/Postgres Exporter: Monitors database performance.
- JMX Exporter: Monitors JVM-based applications. 

Exporters are essential for achieving comprehensive observability across a tech stack, avoiding the need to build custom instrumentation from scratch.


## Prometheus Node_Exporter

### What is Node_Exporter

The Prometheus [Node Exporter](https://prometheus.io/docs/guides/node-exporter/) is a lightweight, open-source agent that collects hardware and OS-level metrics (CPU, memory, disk, network) from Linux and Unix-based systems. It exposes these metrics via an HTTP endpoint, allowing Prometheus to scrape and store them for monitoring infrastructure health and performance. 

**Key Details About Node Exporter:**

- Purpose: Provides deep visibility into node-level resource usage (e.g., RAM usage, disk I/O, CPU load).
- Target Systems: Primarily used on Linux/Unix systems, with a windows_exporter available for Windows.
- Deployment: Runs as a single binary directly on the host or as a DaemonSet in Kubernetes to cover all cluster nodes.
- Integration: Collected data is frequently visualized using Grafana dashboards to detect bottlenecks, such as memory leaks or network saturation.
- Metrics: Collects hundreds of metrics, including cpu, disk, memory, and network stats from /proc and /sys filesystems. 

Node Exporter is considered a foundational component in the Prometheus monitoring stack.

[Monitoring Linux host metrics with the Node Exporter](https://prometheus.io/docs/guides/node-exporter/)

## Deployiong on Kubernetes

A couple of notes on why DaemonSet instead of a single pod:Node exporter needs to run on every node to collect that node's host metrics — CPU, memory, disk, network, filesystem. A single pod would only give you metrics for whichever node it lands on. With a DaemonSet, adding a new node to the cluster automatically spawns a node-exporter pod on it, so it shows up.


### Pre Build Grafana Dashboards -> node_exporter

- 1860
- 15172
- 13978

### Further Reading

[System Monitoring with Prometheus, Grafana, and Node Exporter](https://medium.com/@DanialEskandari/system-monitoring-with-prometheus-grafana-and-node-exporter-412027684564)