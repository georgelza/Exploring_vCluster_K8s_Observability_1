## How to: Exploring K8S on vCluster, Deploying a Observability stack - part 1

Welcome to [The Rabbit Hole](https://medium.com/@georgelza/list/the-rabbit-hole-0df8e3155e33)

The idea, deploy a Observability stack on our K8S cluster hosted on our vCluster environment.

This will be the first in a two part series. 

- Part 1 being the deployment of our base Monitoring stack comprised out of: Prometheus, Grafana and Thanos, with RustFS as backing object storage for Thanos, and 

- Part 2 in which we will be expanding our stack to include Log Analytics capabilities via [ElasticSearch](https://www.elastic.co).

As mentioned above, I'm using RustFS as object store, instead of MinIO, well because MinIO decided to walk away from everything thats open source, community driven and Apache foundation values based. Time to find another Object store... so here we go.


BLOG: [Exploring K8S on vCluster, Deploying a Observability stack](???)

GIT: [Exploring_vCluster_K8s_Observability_1](https://github.com/georgelza/Exploring_vCluster_K8s_Observability_1.git)

This Blog follows two previous blogs where we introduced [vCluster](https://github.com/loft-sh/vcluster) as a base for localised Kubernetes environment.

See: 

- [How to: Web apps on Kubernetes deployed on vCluster, configured with Traefik App Proxy and Ingress Controllers](https://medium.com/@georgelza/how-to-web-apps-on-kubernetes-deployed-on-vcluster-configured-with-traefik-app-proxy-and-ingress-c79cfea7111c)

- [Exploring vCluster as solution to running K8S locally inside Docker](https://medium.com/@georgelza/exploring-vcluster-as-solution-to-running-k8s-locally-inside-docker-6ea233c67726)


We'll be using the same vCluster & Kubernetes cluster deployment as per previous Blogs.


## Deployment and Building Our Examples

We have this **README.md** files, covering the overview and then **Deploy.md** covering the high level deployment. The more detail regarding our deployment of our monitoring stacks is covered in **README.md** files located in each of the subdirectories under the `monitoring/*` directory.


Next See `Deploy.md` - Which will go into a bit more detail how to deploy the stack.



## vCluster Project Pages

- [vCluster](https://github.com/loft-sh/vcluster)

- [Full Quickstart Guide](https://www.vcluster.com/docs/vcluster/#deploy-vcluster)

- [Slack Seerver](https://slack.loft.sh/)

- [VIND](https://github.com/loft-sh/vind)


## Supporting Background Information

- [Prometheus](https://prometheus.io)
- [Grafana](https://grafana.com)
- [Thanos](https://thanos.io)
- [RustFS](https://rustfs.com)
- [Traefik](https://traefik.io/traefik)


## THE END

And like that we’re done with our little trip down another Rabbit Hole, Till next time.

Thanks for following. 

Whats next… Hmm, thinking of maybe taking this stack and adding some Log Analytics... [Elastic](https://www.elastic.co)

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

