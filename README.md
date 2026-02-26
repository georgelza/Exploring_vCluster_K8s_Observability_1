## How to: Exploring K8S on vCluster, Deploying a Observability stack - part 1

Welcome to [The Rabbit Hole](https://medium.com/@georgelza/list/the-rabbit-hole-0df8e3155e33)

The idea, deploy a Observability stack on our [K8s](https://kubernetes.io/) cluster hosted on our [vCluster](https://github.com/loft-sh/vcluster) environment.

This will be the first in a two part series. 

### Overview

- **Part 1** being the deployment of our base Monitoring stack comprised out of: [Prometheus](https://prometheus.io), [Grafana](https://grafana.com) and [Thanos](https://thanos.io), with [RustFS](https://rustfs.com) as backing object storage for Thanos, fronted by [Traefik](https://traefik.io/traefik) as Application Proxy and,

- **Part 2** in which we will be expanding our stack to include Log Analytics capabilities via [ElasticSearch](https://www.elastic.co).

So this might not all make sense now, but as you deploy the stack the diagram will come clear.

The project deploys multiple components making up a Observability stack, Prometheus, Grafana, Thanos for Federation, RustFS as Object store for Thanos, Traefik as Application Proxy. We have 2 inbound routes, Everything and RustFS (There are some hard coded values in the RustFS stack that stops us from using a path routing like what we will be doing for the other components).

Then we have three applications, all doing exactly the same, just in 3 languages, generating Prometheus metrics to be scraped.
The apps also expose logs, but that is for another day -> ;) -> Part 2...

<img src="blog-doc/diagrams/SuperLabv4.0.png" alt="Our Build" width="450" height="350">

As mentioned above, I'm using [RustFS](https://rustfs.com) as object store, instead of the common MinIO, well because MinIO decided to walk away from everything thats open source, community driven and [Apache Foundation](https://www.apache.org) values based. 

Time to find another Object Store... so here we go.

This Blog follows two previous blogs where we introduced [vCluster](https://github.com/loft-sh/vcluster) as a base for localised [Kubernetes](https://kubernetes.io/) environment.

BLOG: [Exploring K8S on vCluster, Deploying a Observability stack](???)

GIT: [Exploring_vCluster_K8s_Observability_1](https://github.com/georgelza/Exploring_vCluster_K8s_Observability_1.git)

Previous Blogs, See: 

1. [Exploring vCluster as solution to running K8S locally inside Docker](https://medium.com/@georgelza/exploring-vcluster-as-solution-to-running-k8s-locally-inside-docker-6ea233c67726)
  
2. [How to: Web apps on Kubernetes deployed on vCluster, configured with Traefik App Proxy and Ingress Controllers](https://medium.com/@georgelza/how-to-web-apps-on-kubernetes-deployed-on-vcluster-configured-with-traefik-app-proxy-and-ingress-c79cfea7111c)


We'll be using the same [vCluster](https://github.com/loft-sh/vcluster) & [Kubernetes](https://kubernetes.io/) cluster deployment as per previous Blogs.


## Deployment and Building Our Examples

We have this **README.md** files, covering the overview and then **Deploy.md** covering the high level deployment. The more detail regarding our deployment of our monitoring stacks is covered in **README.md** files located in each of the subdirectories under the `monitoring/*` directory.

We also have three [Prometheus](https://prometheus.io) metric data generators in the form of [Python](https://www.python.org), [Java](https://www.java.com/en/) and [Golang](https://go.dev) applications, in addition to [Grafana](https://grafana.com) dashboards to visualize the generated metrics. 

See: `monitoring/Apps/README.md`,


Next See: `Deploy.md` - Which will go into a bit more detail on how to deploy the entire stack.


## Summary

No Application, System, solution, however you want to name it, frame it should ever be deployed without a end to end Observability stack, Observability being when you collect analyse and visualize metrics and logs together. 

You don't know what good and bad looks likes with proper metrics and logs. Observability is also critical when it comes to "FinOps" in that it defines if your system is over sized, it's also instrumental in predictive sizing, which leads to budgeting.


### vCluster Project Pages

- [vCluster](https://github.com/loft-sh/vcluster)

- [Full Quickstart Guide](https://www.vcluster.com/docs/vcluster/#deploy-vcluster)

- [Slack Seerver](https://slack.loft.sh/)

- [VIND](https://github.com/loft-sh/vind)


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

Whats next… Hmm, lets see, as per above, Part 2, lets take this stack a little further and add some Log Analytics capability by way of [Elastic](https://www.elastic.co).


### The Rabbit Hole

<img src="blog-doc/diagrams/rabbithole.jpg" alt="Our Build" width="450" height="350">


## ABOUT ME

I’m a techie, a technologist, always curious, love data, have for as long as I can remember always worked with data in one form or the other, Database admin, Database product lead, data platforms architect, infrastructure architect hosting databases, backing it up, optimizing performance, accessing it. Data data data… it makes the world go round.
In recent years, pivoted into a more generic Technology Architect role, capable of full stack architecture.

### By: George Leonard

- georgelza@gmail.com
- https://www.linkedin.com/in/george-leonard-945b502/
- https://medium.com/@georgelza



<img src="blog-doc/diagrams/TechCentralFeb2020-george-leonard.jpg" alt="Me" width="400" height="400">

