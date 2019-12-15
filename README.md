# Cloud-for-fun

Cloud technologies are fun. They speed up projects, ease changes, reduce cost
and improve security and reliability. `Cloud-for-fun` is a set of code samples
to illustrate some of those Cloud technologies. It sustains, with simple tests
and a few of [my blog articles](https://www.carnage.sh/blog). Have a look,
contact me on and open issues if you need...

## Blogs

The `blog` directory contains projects that supports blog entries from
[www.carnage.sh/blog](https://www.carnage.sh/blog). Below is the list
of them with some links to the blog posts:

- [eks-terraform](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/eks-terraform) is an example of an AWS Kubernetes EKS cluster built with Terraform 0.12+,
  see [EKS with terraform 0.12](https://www.carnage.sh/blog/2019-05/eks-terraform)
- [elasticsearch-stack](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/elasticsearch-stack)
  provides an example of managing docker logs with Fluentd, Elasticsearch and
  Grafana. It nicely completes `prometheus-stack`, see
  [Managing logs with Fluentd, ElasticSearch and Grafana](https://www.carnage.sh/blog/2019-01/docker-fluentd-elastic/)
- [kops-aws](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/kops-aws), 
  [knative-serving](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/knative-serving),
  [knative-istio](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/knative-istio),
  [knative-build](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/knative-build),
  and [knative-eventing](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/knative-eventing)
  are a set of resource to show how you can use the various Knative components
- [kubeadm-aws](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/kubeadm-aws)
  provides a set of resources to create a Kubernetes vanilla configuration
  on AWS, see
  [Installing Kubernetes 1.14 with Terraform and Kubeadm](https://www.carnage.sh/blog/2019-04/kubeadm-aws)
- [nlb-security](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/nlb-security) contains
  a set of terraform resources that create a NLB to balance the load with an instance and test how you
  can setup security with security groups on the target instance.
- [prometheus-alert](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/prometheus-alert)
  demonstrates a how to monitor URL and how to notify Ops on Slack. It relies
  on `blackbox` and `alertmanager`, see
  [Monitoring URL and notifying Ops with Prometheus](https://www.carnage.sh/blog/2019-02/prometheus-alert/)
- [prometheus-consul](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/prometheus-consul)
  show how Prometheus can dynamically discover and monitor a service that
  registers in Consul. See
  [Monitoring services with Prometheus and Consul](https://www.carnage.sh/blog/2019-02/prometheus-consul/)
- [prometheus-envoy](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/prometheus-envoy)
  is basically an enhanced version of `prometheus-consul` that relies not only
  on Consul connect but also on Envoy for the same purpose.
- [prometheus-mtls](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/prometheus-mtls)
  relies on Consul Connect to prevent direct acces to Prometheus exporters and
  force mutual authentication with TLS between the server and its exporters... 
- [prometheus-stack](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/prometheus-stack)
  provides an example of an API developed with NodeJS that embeds Prometheus
  custom metrics. It also includes Prometheus and Grafana. see [Prometheus in Action (1/3)](https://www.carnage.sh/blog/2019-01/prometheus-configuration/),
  [(2/3)](https://www.carnage.sh/blog/2019-01/prometheus-application/) and
  [(3/3)](https://www.carnage.sh/blog/2019-01/prometheus-grafana/) for
  some details.
- [red-black](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/red-black)
  provides an example of an API that can be started/stopped, registers in
  consul and is accessible via Traefik. It shows blue/green updates as explained in
  [Red/Black Updates with Consul and Traefik](https://www.carnage.sh/blog/2019-01/red-black-update/)
- [simple-op](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/simple-op) provides
  a simple operator built with `operator-sdk` and documented in
  [Building an Operator with operator-sdk](https://www.carnage.sh/blog/2019-12/building-an-operator) and
  [Deploying an Operator with OLM](https://www.carnage.sh/blog/2019-12/deploying-an-operator).
- [vault-101](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-101)
  is a simple Vault built on top of a Consul cluster. It can easily be used
  to explore some feature from Vault, refer
  [Generate TLS Certificates with Vault](https://www.carnage.sh/blog/2019-01/vault-101/)
- [vault-audit](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-audit)
  is an example of Vault Audit trails being sent into an Elasticsearch with
  fluentd. It provides a whole stack and addresses some of the concerns of
  such an infrastructure, see
  [Managing Vault Audit Trails in Elasticsearch](https://www.carnage.sh/blog/2019-02/vault-audit/)
- [vault-kubernetes](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-kubernetes)
  demonstrates how to use Vault's Kubernetes Authentication Method quite easily. For
  more detailled instructions, see
  [Vault's Kubernetes Authentication](https://www.carnage.sh/blog/2019-02/vault-kubernetes/)
- [vault-mysql](https://github.com/gregoryguillou/cloud-for-fun/tree/master/blog/vault-mysql)
  explains how to use Vault with a database to provide always changing
  passwords and request those on-demand or on application startup, see
  [Rotate database passwords with Vault](https://www.carnage.sh/blog/2019-01/vault-mysql/)
