# 15.0.0

### Breaking changes

* The grafana password must be explicitelly set (it does not default to `admin` anymore)
* Prometheus properties `prometheus.storage.remote.graphite*`, `prometheus.storage.remote.influxdb*` and `prometheus.storage.remote.opentsdb*` have been removed in favor of the new `prometheus.remote_write` configuration.

### Fixes

* Fix memcached_exporter URL
* Fix several dashboard panels

### Features

* Accept glob patterns in grafana dashboard files
* Add kubernetes pod status alerts
* Add new grafana properties
* Add new alertmanager properties
* Add new consul_exporter properties
* Add new redis_exporter properties

### Upgrades

* prometheus 1.6.0
* cadvisor 0.25.0
* consul_exporter 0.3.0
* grafana 4.2.0
* nginx 1.10.3 (with pcre 8.40)
* postgres_exporter 0.1.2
* rabbitmq_exporter 0.18.0
* redis_exporter 0.10.9.1
