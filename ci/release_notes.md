## Breaking changes

Control scripts no longer tees the output to syslog and the log files are now written inside the job's log directory.

## Features

* The test alert sent periodically (if enabled) will be tagged with the name `TestAlert`
* Added [prometheus-web-external-url.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/prometheus-web-external-url.yml) op file to configures the URL under which `prometheus` is externally reachable

### Updates

* `alertmanager` to [v0.12.0](https://github.com/prometheus/alertmanager/releases/tag/v0.12.0)
* `blackbox_exporter` to [v0.11.0](https://github.com/prometheus/blackbox_exporter/releases/tag/v0.11.0)
* `bosh_exporter` to [v2.4.5](https://github.com/bosh-prometheus/bosh_exporter/releases/tag/v2.4.5)
* `bosh_tsdb_exporter` to [v0.1.1](https://github.com/bosh-prometheus/bosh_tsdb_exporter/releases/tag/v0.1.1)
* `cf_exporter` to [v0.5.2](https://github.com/bosh-prometheus/cf_exporter/releases/tag/v0.5.2)
* `firehose_exporter` to [v4.2.6](https://github.com/bosh-prometheus/firehose_exporter/releases/tag/v4.2.6)
* `grafana` to [v4.6.3](https://github.com/grafana/grafana/releases/tag/v4.6.3)
* `rabbitmq_exporter` to [v0.25.2](https://github.com/kbudde/rabbitmq_exporter/releases/tag/v0.25.2)
* `redis_exporter` to [v0.14](https://github.com/oliver006/redis_exporter/releases/tag/v0.14)
* `shield_exporter` to [v0.2.2](https://github.com/bosh-prometheus/shield_exporter/releases/tag/v0.2.2)
