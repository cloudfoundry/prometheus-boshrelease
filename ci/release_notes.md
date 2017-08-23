# Features

* Added CF Application alerts
* Added state, buildpack & instances to CF Apps dashboard
* Added Service Bindings to CF Summary dashboard
* Added Service Bindings and Service Plans to Prometheus CF Exporter dashboard

# Fixes

* Fixes rendered PNG of grafana pannels (missing `fontconfig` dependency required by `PhantomJS`)

# Upgrades

* `cf_exporter` to v0.5.1

# CI

The CI system has been upgraded:

* uses `bosh2`
* automatically runs `testflight-pr` job on pull requests
* automatically fetches new prometheus & various exporters and adds as blobs
