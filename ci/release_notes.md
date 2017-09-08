## Manifests

* Added `enable-bosh-uaa.yml` ops file to enable BOSH UAA authentication
* Added `monitor-concourse-influxdb.yml` ops file to monitor Concourse using an external InfluxDB
* Fixed `add-prometheus-uaa-clients.yml` ops file to add `scope` to clients (required by newer versions of UAA)
* Fixed `add-grafana-uaa-clients.yml` ops file to add `redirect-uri` to client (required by newer versions of UAA)

## Fixes

* Fixed `cadvisor` binary not having execution permissions
* Fixed `bosh_exporter` leaking tcp connections

## Upgrades

* `bosh_exporter` to v2.4.4
* `stackdriver_exporter` to v0.4.0
