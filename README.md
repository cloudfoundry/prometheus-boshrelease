# Prometheus BOSH Release

This is a [BOSH](http://bosh.io/) release for [Prometheus](https://prometheus.io/), [Alertmanager](https://prometheus.io/docs/alerting/alertmanager/), and [Grafana](https://grafana.com/).

It includes the following [prometheus exporters](https://prometheus.io/docs/instrumenting/exporters/): [Blackbox](https://github.com/prometheus/blackbox_exporter), [BOSH](https://github.com/bosh-prometheus/bosh_exporter), [BOSH TSDB](https://github.com/bosh-prometheus/bosh_tsdb_exporter), [cAdvisor](https://github.com/google/cadvisor), [Cloud Foundry](https://github.com/bosh-prometheus/cf_exporter), [Cloud Foundry Firehose](https://github.com/bosh-prometheus/firehose_exporter), [Collectd](https://github.com/prometheus/collectd_exporter), [Consul](https://github.com/prometheus/consul_exporter), [Credhub](https://github.com/orange-cloudfoundry/credhub_exporter), [Elasticsearch](https://github.com/justwatchcom/elasticsearch_exporter), [Graphite](https://github.com/prometheus/graphite_exporter), [HAProxy](https://github.com/prometheus/haproxy_exporter), [InfluxDB](https://github.com/prometheus/influxdb_exporter), [Kubernetes](https://github.com/kubernetes/kube-state-metrics), [Memcached](https://github.com/prometheus/memcached_exporter), [MongoDB](https://github.com/dcu/mongodb_exporter), [MySQL](https://github.com/prometheus/mysqld_exporter), [NATS](https://github.com/lovoo/nats_exporter), [PostgreSQL](https://github.com/wrouesnel/postgres_exporter), [PushGateway](https://github.com/prometheus/pushgateway), [RabbitMQ](https://github.com/kbudde/rabbitmq_exporter), [Redis](https://github.com/oliver006/redis_exporter), [Shield](https://github.com/bosh-prometheus/shield_exporter), [Stackdriver](https://github.com/frodenas/stackdriver_exporter), [Statsd](https://github.com/prometheus/statsd_exporter), [Vault](https://github.com/grapeshot/vault_exporter).

It includes the following [grafana plugins](https://grafana.com/plugins): [clock](https://github.com/grafana/clock-panel), [diagram](https://github.com/jdbranham/grafana-diagram), [histogram](https://github.com/mtanda/grafana-histogram-panel), [piechart](https://github.com/grafana/piechart-panel), [status](https://github.com/Vonage/Grafana_Status_panel), [worldmap](https://github.com/grafana/worldmap-panel), [worldping](https://github.com/raintank/worldping-app).

Questions? Pop in our [slack channel](https://cloudfoundry.slack.com/messages/prometheus/)!

## Table of Contents

* [Usage](https://github.com/bosh-prometheus/prometheus-boshrelease#usage)
  * [Requirements](https://github.com/bosh-prometheus/prometheus-boshrelease#requirements)
  * [Clone the repository](https://github.com/bosh-prometheus/prometheus-boshrelease#clone-the-repository)
  * [Basic deployment](https://github.com/bosh-prometheus/prometheus-boshrelease#basic-deployment)
  * [Using BOSH Service Discovery](https://github.com/bosh-prometheus/prometheus-boshrelease#using-bosh-service-discovery)
  * [Monitoring Cloud Foundry](https://github.com/bosh-prometheus/prometheus-boshrelease#monitoring-cloud-foundry)
    * [Register Cloud Foundry routes](https://github.com/bosh-prometheus/prometheus-boshrelease#register-cloud-foundry-routes)
    * [Use UAA for Grafana authentication](https://github.com/bosh-prometheus/prometheus-boshrelease#use-uaa-for-grafana-authentication)
  * [Operations files](https://github.com/bosh-prometheus/prometheus-boshrelease#operations-files)
  * [Deployment variables and the var-store](https://github.com/bosh-prometheus/prometheus-boshrelease#deployment-variables-and-the-var-store)
* [Contributing](https://github.com/bosh-prometheus/prometheus-boshrelease#contributing)
* [License](https://github.com/bosh-prometheus/prometheus-boshrelease#license)

## Usage

### Requirements

In order to use this BOSH release you will need:

* [BOSH CLI v2](https://bosh.io/docs/cli-v2.html)
* An already deployed [BOSH environment](http://bosh.io/docs/init.html), please check [BOSH deployment security groups](https://github.com/cloudfoundry/bosh-deployment#security-groups) because Prometheus will connect to BOSH (ports: `25555` - Director API, `8443` - UAA API)
* A compatible [cloud-config](http://bosh.io/docs/terminology.html#cloud-config) with a `default` option for `network` and `vm_types` (you can use the example that comes from [cf-deployment](https://github.com/cloudfoundry/cf-deployment/blob/master/iaas-support/bosh-lite/cloud-config.yml))

Although not mandatory, it is recommended to deploy the [node exporter addon](https://github.com/bosh-prometheus/node-exporter-boshrelease) in order to get system metrics.

###  Clone the repository

First, clone this repository into your workspace:

```
git clone https://github.com/bosh-prometheus/prometheus-boshrelease
cd prometheus-boshrelease
export BOSH_ENVIRONMENT=<name>
```

Then checkout to the [release branch](https://github.com/bosh-prometheus/prometheus-boshrelease/releases) you want to use, so manifest files will be in synch with the release version:

```
git checkout v...
```

### Basic deployment

To deploy a basic `prometheus` server with `alertmanager` and `grafana` (but no exporters) use the following command:

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml
```

Once deployed, look for the `nginx` instance IP address:

```
bosh -d prometheus instances
```

You can reach each component's web ui at:
* `alertmanager`: `http://<nginx-ip-address>:9093`
* `grafana`:  `http://<nginx-ip-address>:3000`
* `prometheus`:  `http://<nginx-ip-address>:9090`

Credentials for each components can be located at the `tmp/deployment-vars.yml` file.

### Using BOSH Service Discovery

If you want to use the [BOSH Service Discovery](https://github.com/bosh-prometheus/bosh_exporter/blob/master/FAQ.md#how-can-i-use-the-service-discovery) in order to dynamically discover your exporters then add the [monitor-bosh.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-bosh.yml) op file by running the following command (filling the required variables with your own values):

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  -o manifests/operators/monitor-bosh.yml \
  -v bosh_url= \
  -v bosh_username= \
  -v bosh_password= \
  --var-file bosh_ca_cert= \
  -v metrics_environment=
```

> *NOTE:* `metrics_environment` is an arbitrary name to identify your environment (`test`, `nyc-prod`, ...)

If you have configured your [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment) to use [UAA user management](http://bosh.io/docs/director-users-uaa.html) (via the [uaa.yml](https://github.com/cloudfoundry/bosh-deployment/blob/master/uaa.yml) ops file) we recommend adding the [add-bosh-exporter-uaa-clients.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/bosh/add-bosh-exporter-uaa-clients.yml) op file to your [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment) and then adding the [enable-bosh-uaa.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-bosh-uaa.yml) ops file to the prometheus deployment by running the following command (filling the required variables with your own values):

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  -o manifests/operators/monitor-bosh.yml \
  -o manifests/operators/enable-bosh-uaa.yml \
  -v bosh_url= \
  --var-file bosh_ca_cert= \
  -v metrics_environment=
```

In case you have configured manually an UAA `client_id `for the `bosh_exporter` (different from `bosh_exporter`), then run the following command instead:

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  -o manifests/operators/monitor-bosh.yml \
  -o manifests/operators/enable-bosh-uaa.yml \
  -o manifests/operators/configure-bosh-exporter-uaa-client-id.yml \
  -v bosh_url= \
  -v uaa_bosh_exporter_client_id= \
  -v uaa_bosh_exporter_client_secret= \
  --var-file bosh_ca_cert= \
  -v metrics_environment=
```

### Monitoring Cloud Foundry

If you want to monitor your [Cloud Foundry](https://www.cloudfoundry.org/) platform, first update your [cf-deployment](https://github.com/cloudfoundry/cf-deployment) adding the [add-prometheus-uaa-clients.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/cf/add-prometheus-uaa-clients.yml) op file. This will add the UAA clients required to gather information from the Cloud Foundry [API](https://apidocs.cloudfoundry.org/268/) and [Firehose](https://docs.cloudfoundry.org/loggregator/architecture.html#firehose).

Then add the [monitor-cf.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-cf.yml) ops file by running the following command (filling the required variables with your own values):

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  -o manifests/operators/monitor-bosh.yml \
  -v bosh_url= \
  -v bosh_username= \
  -v bosh_password= \
  --var-file bosh_ca_cert= \
  -v metrics_environment= \
  -o manifests/operators/monitor-cf.yml \
  -v metron_deployment_name= \
  -v system_domain= \
  -v uaa_clients_cf_exporter_secret= \
  -v uaa_clients_firehose_exporter_secret= \
  -v traffic_controller_external_port= \
  -v skip_ssl_verify=
```

>*NOTE:* `metron_deployment_name` property should match the `deployment` property of your `metron_agent` or `loggregator_agent` jobs.
> Use:
>- your `system_domain` (`metron_agent`) for [cf-deployment](https://github.com/cloudfoundry/cf-deployment) before [v2.0.0](https://github.com/cloudfoundry/cf-deployment/releases/tag/v2.0.0)
>- `cf` (`loggregator_agent`) for [cf-deployment](https://github.com/cloudfoundry/cf-deployment) starting from the [v2.0.0](https://github.com/cloudfoundry/cf-deployment/commit/b4e761fa257740a2cbca2574b40ae78bcfe2178b#diff-1c845aa8da14326552b37f043a621ccaR3)
>- `cf` for [Pivotal Application Service](https://network.pivotal.io/products/elastic-runtime)

#### Register Cloud Foundry routes

If you want to access `alertmanager`, `grafana`, and `prometheus` web ui's using your Cloud Foundry system domain instead of IP addresses, then you can register those [routes](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html) inside your Cloud Foundry environment using the  [enable-cf-route-registrar.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-cf-route-registrar.yml) op file by running the following command (filling the required variables with your own values):

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  ...
  -o manifests/operators/enable-cf-route-registrar.yml \
  -v system_domain= \
  -v cf_deployment_name=
```

The op file will register the following routes:

* `https://alertmanager.<cf system domain>`
* `https://grafana.<cf system domain>`
* `https://prometheus.<cf system domain>`

#### Use UAA for Grafana authentication

If you want to allow users registered at your Cloud Foundry environment to access the Grafana dashboards (*Viewer* mode only), first update your [cf-deployment](https://github.com/cloudfoundry/cf-deployment) adding the [add-grafana-uaa-clients.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/cf/add-grafana-uaa-clients.yml) op file. This will add the UAA client required by the Grafana-UAA integration.

Then add the [enable-grafana-uaa.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-grafana-uaa.yml) op file by running the following command (filling the required variables with your own values):

```
bosh -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  ...
  -o manifests/operators/enable-grafana-uaa.yml \
  -v system_domain= \
  -v uaa_clients_grafana_secret= \
  --var-file uaa_ssl.ca= \
  --var-file uaa_ssl.certificate= \
  --var-file uaa_ssl.private_key=
```

### Operations files

Additional [operations files](http://bosh.io/docs/cli-ops-files.html) are located at the [manifests/operators](https://github.com/bosh-prometheus/prometheus-boshrelease/tree/master/manifests/operators) directory. Those files includes a basic configuration, so extra ops files might be needed for additional configuration.

Please review the op files before deploying them to check the requeriments, dependencies and necessary variables.

| File | Description | exporter | dashboards | alerts |
| ---- | ----------- |:--------:|:----------:|:------:|
| [alertmanager-hipchat-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-hipchat-receiver.yml) | Configures a [HipChat](https://www.hipchat.com/) receiver for `alertmanager` | | | |
| [alertmanager-opsgenie-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-opsgenie-receiver.yml) | Configures a [OpsGenie](https://www.opsgenie.com/) receiver for `alertmanager` | | | |
| [alertmanager-pagerduty-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-pagerduty-receiver.yml) | Configures a [PagerDuty](https://www.pagerduty.com/) receiver for `alertmanager` | | | |
| [alertmanager-pushover-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-pushover-receiver.yml) | Configures a [Pushover](https://pushover.net/) receiver for `alertmanager` | | | |
| [alertmanager-slack-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-slack-receiver.yml) | Configures a [Slack](https://slack.com/) receiver for `alertmanager` | | | |
| [alertmanager-victorops-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-victorops-receiver.yml) | Configures a [VictorOps](https://victorops.com/) receiver for `alertmanager` | | | |
| [alertmanager-webhook-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-webhook-receiver.yml) | Configures a generic webhook receiver for `alertmanager` | | | |
| [alertmanager-web-external-url.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-web-external-url.yml) | Configures the URL under which `alertmanager` is externally reachable | | | |
| [configure-bosh-exporter-uaa-client-id.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/configure-bosh-exporter-uaa-client-id.yml) | Configures a custom `bosh_exporter` UAA `client_id` for the [enable-bosh-uaa.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-bosh-uaa.yml) op-file | | | |
| [enable-bosh-uaa.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-bosh-uaa.yml) | Configures [monitor-bosh.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-bosh.yml) to use an UAA client (you must apply the [add-bosh-exporter-uaa-clients.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/bosh/add-bosh-exporter-uaa-clients.yml) op file to your [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)) | | | |
| [enable-cf-api-v3.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-cf-api-v3.yml) | Enables [Cloud Foundry API V3](https://v3-apidocs.cloudfoundry.org/) calls at the `cf_exporter` | | | |
| [enable-cf-route-registrar.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-cf-route-registrar.yml) | Registers `alertmanager`, `grafana`, and `prometheus` as [Cloud Foundry routes](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html) (under your `system domain`) | | | |
| [enable-grafana-uaa.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-grafana-uaa.yml) | Configures `grafana` user authentication to use [Cloud Foundry UAA](https://docs.cloudfoundry.org/concepts/architecture/uaa.html) (you must apply the [add-grafana-uaa-clients.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/cf/add-grafana-uaa-clients.yml) op file to your [cf-deployment](https://github.com/cloudfoundry/cf-deployment)) | | | |
| [enable-grafana-generic-oauth.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-grafana-generic-oauth.yml) | Configures `grafana` user authentication to use a generic OAuth2 provider | | | |
| [enable-proxy-alertmanager.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-alertmanager.yml) | Enables http(s) proxy for `alertmanager` | | | |
| [enable-proxy-blackbox-exporter.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-blackbox-exporter.yml) | Enables http(s) proxy for `blackbox_exporter` | | | |
| [enable-proxy-bosh-exporter.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-bosh-exporter.yml) | Enables http(s) proxy for `bosh_exporter` | | | |
| [enable-proxy-cf-exporter.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-cf-exporter.yml) | Enables http(s) proxy for `cf_exporter` | | | |
| [enable-proxy-firehose-exporter.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-firehose-exporter.yml) | Enables http(s) proxy for `firehose_exporter` | | | |
| [enable-proxy-grafana.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-grafana.yml) | Enables http(s) proxy for `grafana` | | | |
| [enable-proxy-kubernetes.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-alertmanager.yml) | Enables http(s) proxy for `kube_state_metrics_exporter` | | | |
| [enable-proxy-prometheus.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-prometheus.yml) | Enables http(s) proxy for `prometheus` | | | |
| [enable-proxy-shield-exporter.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-shield-exporter.yml) | Enables http(s) proxy for `shield_exporter` | | | |
| [enable-proxy-stackdriver-exporter.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/proxy/enable-proxy-stackdriver-exporter.yml) | Enables http(s) proxy for `stackdriver_exporter` | | | |
| [enable-root-url.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-root-url.yml) | Enables `root_url` for `grafana` | | | |
| [migrate_from_prometheus_1.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/migrations/migrate_from_prometheus_1.yml) | Allows migrating an instance from Prometheus 1.x to Prometheus 2.x | | | |
| [monitor-bosh.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-bosh.yml) | Enables monitoring [BOSH](https://github.com/bosh-prometheus/bosh_exporter) `jobs` and `processes` and enables [Service Discovery](https://github.com/bosh-prometheus/bosh_exporter/blob/master/FAQ.md#how-can-i-use-the-service-discovery) | x | x | x |
| [monitor-cadvisor.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-cadvisor.yml) | Enables monitoring [cAdvisor](https://github.com/google/cadvisor) | x | | |
| [monitor-cf.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-cf.yml) | Enables monitoring [Cloud Foundry](https://www.cloudfoundry.org/) via the [Cloud Foundry](https://github.com/bosh-prometheus/cf_exporter) and [Cloud Foundry Firehose](https://github.com/bosh-prometheus/firehose_exporter) exporters (you must apply the [add-prometheus-uaa-clients.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/cf/add-prometheus-uaa-clients.yml) op file to your [cf-deployment](https://github.com/cloudfoundry/cf-deployment)) | x | x | x |
| [monitor-collectd.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-collectd.yml) | Enables monitoring [Collectd](https://github.com/prometheus/collectd_exporter) | x | | |
| [monitor-concourse.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-concourse.yml) | Enables monitoring [Concourse CI](http://concourse.ci/) >= v3.8.0 (you must apply the [enable-prometheus-metrics.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/concourse/enable-prometheus-metrics.yml) op file to your [concourse-deployment](https://github.com/concourse/concourse-deployment)) | | x | x |
| [monitor-concourse-influxdb.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-concourse-influxdb.yml) | Enables monitoring [Concourse CI](http://concourse.ci/) < v3.8.0. Requires [node exporter](https://github.com/bosh-prometheus/node-exporter-boshrelease) on Concourse VMs (probably as a BOSH add-on) and InfluxDB to be deployed independently and configured as a data source in Grafana as well as Concourse configured to send events to InfluxDB | | x |  |
| [monitor-consul.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-consul.yml) | Enables monitoring [Consul](https://github.com/prometheus/consul_exporter) | x | x | x |
| [monitor-credhub.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-credhub.yml) | Enables monitoring [Credhub](https://github.com/orange-cloudfoundry/credhub_exporter) | x | | x |
| [monitor-elasticsearch.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-elasticsearch.yml) | Enables monitoring [Elasticsearch](https://github.com/justwatchcom/elasticsearch_exporter) | x | x | x |
| [monitor-graphite.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-graphite.yml) | Enables monitoring [Graphite](https://github.com/prometheus/graphite_exporter) | x | | |
| [monitor-haproxy.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-haproxy.yml) | Enables monitoring [HAProxy](https://github.com/prometheus/haproxy_exporter) | x | x | x |
| [monitor-http-probe.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-http-probe.yml) | Enables monitoring HTTP(s) endpoints via the [Blackbox](https://github.com/prometheus/blackbox_exporter) exporter | x | x | x |
| [monitor-influxdb.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-influxdb.yml) | Enables monitoring [InfluxDB](https://github.com/prometheus/influxdb_exporter) | x | | |
| [monitor-kubernetes.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-kubernetes.yml) | Enables monitoring [Kubernetes](https://github.com/kubernetes/kube-state-metrics) | x | x | x |
| [monitor-memcached.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-memcached.yml) | Enables monitoring [Memcached](https://github.com/prometheus/memcached_exporter) | x | | |
| [monitor-mongodb.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-mongodb.yml) | Enables monitoring [MongoDB](https://github.com/dcu/mongodb_exporter) | x | | |
| [monitor-mysql.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-mysql.yml) | Enables monitoring [MySQL](https://github.com/prometheus/mysqld_exporter) | x | x | x |
| [monitor-nats.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-nats.yml) | Enables monitoring [NATS](https://github.com/lovoo/nats_exporter) | x | | |
| [monitor-node.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-node.yml) | Enables monitoring system metrics via the [node exporter](https://github.com/bosh-prometheus/node-exporter-boshrelease) | | x | |
| [monitor-p-rabbitmq.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-p-rabbitmq.yml) | Enables monitoring [RabbitMQ for PCF](https://network.pivotal.io/products/p-rabbitmq/) (requires the [monitor-cf.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-cf.yml) op file) | | x | x |
| [monitor-p-redis.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-p-redis.yml) | Enables monitoring [Redis for PCF](https://network.pivotal.io/products/p-redis/) (requires the [monitor-cf.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-cf.yml) op file) | | x | x |
| [monitor-postgres.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-postgres.yml) | Enables monitoring [PostgreSQL](https://github.com/wrouesnel/postgres_exporter) | x | x | x |
| [monitor-pushgateway.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-pushgateway.yml) | Deploys a [PushGateway](https://github.com/prometheus/pushgateway)  | x | | |
| [monitor-rabbitmq.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-rabbitmq.yml) | Enables monitoring [RabbitMQ](https://github.com/kbudde/rabbitmq_exporter) | x | x | x |
| [monitor-redis.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-redis.yml) | Enables monitoring [Redis](https://github.com/oliver006/redis_exporter) | x | x | x |
| [monitor-shield.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-shield.yml) | Enables monitoring [Shield](https://github.com/bosh-prometheus/shield_exporter) | x | x | x |
| [monitor-stackdriver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-stackdriver.yml) | Enables monitoring [Stackdriver](https://github.com/frodenas/stackdriver_exporter) | x | | |
| [monitor-statsd.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-statsd.yml) | Enables monitoring [Statsd](https://github.com/prometheus/statsd_exporter) | x | | |
| [monitor-vault.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/monitor-vault.yml) | Enables monitoring [Vault](https://github.com/grapeshot/vault_exporter) | x | | x |
| [nginx-vm-extension.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/nginx-vm-extension.yml) | Adds a [VM Extension](http://bosh.io/docs/cloud-config/#vm-extensions) block to the `nginx` instance, useful to attach a Load Balancer| | | |
| [prometheus-web-external-url.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/prometheus-web-external-url.yml) | Configures the URL under which `prometheus` is externally reachable | | | |
| [use-sqlite3.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/use-sqlite3.yml) | Use sqlite3 instead of postgres | | | |

### Deployment variables and the var-store

Some operators files requires additional information to provide environment-specific or sensitive configuration such as various credentials. To do this in the default configuration, we use the `--vars-store`. This flag takes the name of a `yml` file that it will read and write to. Where necessary credential values are not present, it will generate new values based on the type information stored at the different deployment files. Necessary variables that BOSH can't generate need to be supplied as well.
See each particular op files you're using for any additional necessary variables.

See also the [BOSH CLI documentation](http://bosh.io/docs/cli-int.html#value-sources) for more information about ways to supply such additional variables.

## Contributing

Refer to [CONTRIBUTING.md](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/CONTRIBUTING.md).

## License

Apache License 2.0, see [LICENSE](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/LICENSE).
