## Fixes

* Ignore smoke-test VMs on `BOSHJobEphemeralDiskPredictWillFill` alerts
* Allow skipping TLS verification when using grafana generic oauth
* Fix prometheus `storage.local.checkpoint-dirty-series-limit` property not being correctly parsed

## Upgrades

* `alertmanager` to [v0.10.0](https://github.com/prometheus/alertmanager/releases/tag/v0.10.0)
* `grafana` to [v4.6.1](https://github.com/grafana/grafana/releases/tag/v4.6.1)
* `prometheus` to [v1.8.2](https://github.com/prometheus/prometheus/releases/tag/v1.8.2)
