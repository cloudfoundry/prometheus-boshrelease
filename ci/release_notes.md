
### Breaking changes

* `node_exporter` has been removed from this release. Please use the [Prometheus Node Exporter BOSH Release](https://github.com/cloudfoundry-community/node-exporter-boshrelease).
* `postgres_exporter` now defaults to port `9187`

### Features:

* Added `mongodb_exporter` job
* Added proxy env vars to `alertmanager`, `blackbox_exporter` and `github_exporter` jobs
* Added a new dashboard: system overview linked to bosh
* `cf_exporter` can now be configured to use a `client-id` and `client-secret`

### Fixes:

* Fixed `nats_exporter` address property
* Fixed alerting for diego low remaining memory

### Upgrades:

* blackbox_exporter 0.4.0
* bosh_exporter 2.1.3
* cf_exporter 0.3.0
* grafana 4.1.1
* kube-state-metrics (027547c)
* postgres_exporter (2c6594e)
* prometheus 1.5.0
* rabbitmq_exporter 0.17.1
* redis_exporter 0.10.5
* histogram-panel grafana plugin (a595d97)
* worldping-app grafana plugin (e410265)
