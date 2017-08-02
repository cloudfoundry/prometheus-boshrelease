## Breaking changes

* The `Application Events` collector at the `cf_exporter` has been removed, and consequently all alerts and dashboards with references to their metrics have been updated or removed (`cf_apps_events.json`)

## Features

* Added kubernetes memory and cpu request alerts
* Prometheus job allows to specify inline custom rules

## Fixes

* Adds route prefix to the alertmanager url when configured
* Fixes a bug at the `bosh_exporter` where Basic Auth was not honored when enabled
* Fixes a bug at the `firehose_exporter` where Basic Auth was not honored when enabled
* Fixes a data race panic at the `firehose_exporter`

## Upgrades

* `alertmanager` to v0.8.0
* `blackbox_exporter` to v0.7.0
* `bosh_exporter` to v2.4.3
* `cf_exporter` to v0.5.0
* `elasticsearch_exporter` to v1.0.1
* `firehose_exporter` to v4.2.3
* `grafana` to v4.4.1
* `influxdb_exporter` to v0.1.0
* `redis_exporter` to v0.11.3
* `shield_exporter` to v0.2.1
* `stackdriver_exporter` to v0.1.1
