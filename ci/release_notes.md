## Breaking changes

Starting at v4.5, [Grafana ](https://grafana.com/) exposes internal metrics using a [prometheus](https://prometheus.io/) format, therefore, the `grafana_exporter` job is not necessary anymore and has been removed from this [BOSH](http://bosh.io/) release.

Consequently, the `grafana_alerts` job has also been removed, as it only contains alerts related to the `grafana_exporter`.

The `grafana_dashboards` have been updated to use the metric names that come directly from [Grafana ](https://grafana.com/), but the `prometheus_grafana_exporter.json` dashboard has been removed for the same reasons explained before.

If you were using the [manifest](https://github.com/cloudfoundry-community/prometheus-boshrelease/blob/master/manifests/prometheus.yml) and [operator files](https://github.com/cloudfoundry-community/prometheus-boshrelease/tree/master/manifests/operators) from this [BOSH](http://bosh.io/) release, no change is needed, as they have been updated appropriately.

## Fixes

* Fixed a typo at the "CF: Garden Linux" dashboard

## Manifests

* Added `use-sqlite3.yml` op file to use `sqlite3` instead of `postgres` for the Grafana database
* Added `alertmanager-web-external-url.yml` op file to allow configuring the URL under which `alertmanager` is externally reachable
* Fixed `monitor-postgres.yml` op file
* Upgraded `postgres` release to v21
* Upgraded `cf-routing` release to v0.165.0 at `route-registrar.yml` op file

## Upgrades

* `alertmanager` to [v0.9.1](https://github.com/prometheus/alertmanager/releases/tag/v0.9.1)
* `blackbox_exporter` to [v0.10.0](https://github.com/prometheus/blackbox_exporter/releases/tag/v0.10.0)
* `cadvisor` to [v0.27.2](https://github.com/google/cadvisor/releases/tag/v0.27.2)
* `firehose_exporter` to [v4.2.5](https://github.com/cloudfoundry-community/firehose_exporter/releases/tag/v4.2.5)
* `fontconfig` to v2.12.6
* `freetype` to v2.8.1
* `golang` to v1.9.2
* `grafana` to [v4.6.0](https://github.com/grafana/grafana/releases/tag/v4.6.0)
* Grafana `Diagram` panel plugin to 1461bd2
* Grafana `Pie Chart` panel plugin to 34386db
* Grafana `Status` panel plugin to [v1.0.5](https://github.com/Vonage/Grafana_Status_panel/releases/tag/1.0.5)
* Grafana `World Map` panel plugin to v0.0.21
* Grafana `World Ping` panel plugin to cd92ae1
* `kube-state-metrics` to [v1.1.0](https://github.com/kubernetes/kube-state-metrics/releases/tag/v1.1.0)
* `postgres_exporter` to [v0.3.0](https://github.com/wrouesnel/postgres_exporter/releases/tag/v0.3.0)
* `prometheus` to [1.8.1](https://github.com/prometheus/prometheus/releases/tag/v1.8.1)
* `rabbitmq_exporter` to [v0.23.0](https://github.com/kbudde/rabbitmq_exporter/releases/tag/v0.23.0)
* `redis_exporter` to [v0.13](https://github.com/oliver006/redis_exporter/releases/tag/v0.13)
