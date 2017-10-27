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

## Upgrades

* `alertmanager` to v0.9.1
* `blackbox_exporter` to v0.10.0
* `firehose_exporter` to v4.2.5
* `fontconfig` to v2.12.6
* `freetype` to v2.8.1
* `golang` to v1.9.2
* `grafana` to v4.6.0
* `kube-state-metrics` to v1.1.0
* `prometheus` to v1.8.1
* `rabbitmq_exporter` to v0.23.0
