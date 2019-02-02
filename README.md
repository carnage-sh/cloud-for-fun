# Cloud-for-fun

Cloud technologies are fun. They speed up projects, ease changes, reduce cost
and improve security and reliability. `Cloud-for-fun` is a set of code samples
to illustrate some of those Cloud technologies. It sustains, with simple tests
and a few of [my blog articles](https://gregoryguillou.github.io). Have a look,
contact me on and open issues if you need...

## Blogs

The `blog` directory contains projects that supports blog entries from
[gregoryguillou.github.io](https://gregoryguillou.github.io). This is a short
summary:

- [elasticsearch-stack](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/elasticsearch-stack)
  provides an example of log management with Fluentd, Elasticsearch
  and Grafana. It nicely completes `prometheus-stack` for logs. It provides a
  custom dashboard that displays a graph, a gauge and a table with messages
  from Elasticsearch. It also shows how to parse/enrich data as part of the
  fluentd capture pipeline.
- [prometheus-stack](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/prometheus-stack)
  provides an example of an API developed with NodeJS that embeds Prometheus
  custom metrics. It also includes Prometheus and Grafana as part of a Docker
  Compose definition file.
- [red-black](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/red-black)
  provides an example of an API that can be started/stopped, registers in
  consul and is accessible via Traefik. It shows blue/green updates in
  action.
- [vault-101](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-101)
  is a simple Vault built on top of a Consul cluster. It can easily be used
  to explore some feature from Vault.
- [vault-audit](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-audit)
  is an example of Vault Audit trails being sent into an Elasticsearch with
  fluentd. It provides a whole stack and addresses some of the concerns of
  such an infrastructure.
- [vault-mysql](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-mysql)
  explains how to use Vault with a database to provide always changing
  passwords and request those on-demand or on application startup
