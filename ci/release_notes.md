## Breaking changes

Control scripts no longer tees the output to syslog and the log files are now written inside the job's log directory.

## Features

* The test alert sent periodically (if enabled) will be tagged with the name `TestAlert`
* Updated `concourse` dashboards with new panels

## Fixes

* Increased `prometheus` stop wait time to allow proper shut down
* Fixed typo at `BOSHJobExtendedUnhealthy`, `BOSHJobProcessExtendedUnhealthy`, and `BOSHTSDBJobExtendedUnhealthy` alert names
* Fixed `ElasticHeapUsage` alert summary and description
* Exclude ephemeral `Pivotal Cloud Foundry Healthwatch` vms from BOSH alerts and dashboards

## Manifests

* [prometheus.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/prometheus.yml) manifest file now uses `persistent_disk` instead of `persistent_disk_types`
* Added [enable-prometheus-metrics.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/concourse/enable-prometheus-metrics.yml) op file to be applied to your [concourse-deployment](https://github.com/concourse/concourse-deployment) to allow gathering metrics directly from `concourse` (>= v3.8.0)
* Added [prometheus-web-external-url.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/prometheus-web-external-url.yml) op file to allow configuring the URL under which `prometheus` is externally reachable
* Fixed [alertmanager-victorops-receiver.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/alertmanager-victorops-receiver.yml) op file to require a `routing_key` variable
* Updated [enable-cf-route-registrar.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/enable-cf-route-registrar.yml) op file to require the `cf_deployment_name` variable (tipically `cf` but may change if you are using [Pivotal Application Service](https://network.pivotal.io/products/elastic-runtime))
* Removed `postgres` release when using [use-sqlite3.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/use-sqlite3.yml) op file
* Upgraded `postgres` release to [v23](https://github.com/cloudfoundry/postgres-release/releases/tag/v23)
* Upgraded `routing` release to [v0.169.0](https://github.com/cloudfoundry/routing-release/releases/tag/0.169.0)

## Updates

* `alertmanager` to [v0.12.0](https://github.com/prometheus/alertmanager/releases/tag/v0.12.0)
* `blackbox_exporter` to [v0.11.0](https://github.com/prometheus/blackbox_exporter/releases/tag/v0.11.0)
* `bosh_exporter` to [v3.0.0](https://github.com/bosh-prometheus/bosh_exporter/releases/tag/v3.0.0)
* `bosh_tsdb_exporter` to [v0.2.0](https://github.com/bosh-prometheus/bosh_tsdb_exporter/releases/tag/v0.2.0)
* `cadvisor` to [v0.28.3](https://github.com/google/cadvisor/releases/tag/v0.28.3)
* `cf_exporter` to [v0.6.0](https://github.com/bosh-prometheus/cf_exporter/releases/tag/v0.6.0)
* `firehose_exporter` to [v5.0.0](https://github.com/bosh-prometheus/firehose_exporter/releases/tag/v5.0.0)
* `grafana` to [v4.6.3](https://github.com/grafana/grafana/releases/tag/v4.6.3)
* `grafana status panel` to [v1.0.7](https://github.com/Vonage/Grafana_Status_panel/releases/tag/1.0.7)
* `grafana diagram panel` to [v1.4.4](https://grafana.com/plugins/jdbranham-diagram-panel?version=1.4.4)
* `grafana pie chart panel` to [v1.1.6](https://grafana.com/plugins/grafana-piechart-panel?version=1.1.6)
* `postgres_exporter` to [v0.4.1](https://github.com/wrouesnel/postgres_exporter/releases/tag/v0.4.1)
* `rabbitmq_exporter` to [v0.25.2](https://github.com/kbudde/rabbitmq_exporter/releases/tag/v0.25.2)
* `redis_exporter` to [v0.14](https://github.com/oliver006/redis_exporter/releases/tag/v0.14)
* `shield_exporter` to [v0.3.0](https://github.com/bosh-prometheus/shield_exporter/releases/tag/v0.3.0)
