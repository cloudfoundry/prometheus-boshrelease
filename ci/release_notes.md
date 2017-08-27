## Features

* `grafana` job optionally consumes a `database` job

## Manifest

* Default manifest now deploys a `database` job (to persist `grafana` data and state)
* `monitor_cf` operator file now places the `firehose_exporter` at a separate vm to allow scaling

## Upgrades

* `kube_state_metrics` to v1.0.1
* `stackdriver_exporter` to v0.3.0
