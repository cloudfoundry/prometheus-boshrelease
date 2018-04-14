### Breaking changes

#### Prometheus v2

Prometheus has been upgraded to [v2](https://prometheus.io/blog/2017/11/08/announcing-prometheus-2-0/), and
contains a number of [backwards incompatible changes](https://prometheus.io/docs/prometheus/2.0/migration/):

* The recording and alerting rules have been migrated from a custom format to the ubiquitous YAML format. All alert rules in this BOSH release have been updated to the new format. If you are using your own rules and/or alerts (via the `prometheus.custom_rules` property or collocating your own BOSH release and adding them via the `prometheus.rule_files` property), you will need to adapt them to the new format. See this [example](https://prometheus.io/docs/prometheus/2.0/migration/#recording-rules-and-alerts) for more information.

* Prometheus v2 comes with a new storage subsystem that is incompatible with the Prometheus v1 data format. To retain access to your historic monitoring data, the [official recommendation](https://prometheus.io/docs/prometheus/2.0/migration/#storage) is to run a non-scraping Prometheus instance running at least version 1.8.1 in parallel with your Prometheus 2.0 instance, and have the new server read existing data from the old one via the remote read protocol. A [migrate_from_prometheus_1.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/migrations/migrate_from_prometheus_1.yml) op-file has been created based on this recommendation. Please follow these steps in order to upgrade your deployment to Prometheus v2 if you want to retain access to historical data:

    1. Upgrade your existing deployment to use the Prometheus BOSH release [v21.1.1](https://github.com/bosh-prometheus/prometheus-boshrelease/releases/tag/v21.1.1).
    2. After the above deployment succeeds, add the [migrate_from_prometheus_1.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/migrations/migrate_from_prometheus_1.yml) op-file to your deployment. This will create a new `prometheus2` instance running Prometheus v2 and all the exporters, and it will preserve the old `prometheus` instance updating it to be a non-scrapping Prometheus. The new `prometheus2` instance will be automatically configured to use the `prometheus` instance as a remote read instance.
    3. Once the Prometheus v1 data is no longer relevant (typically after 15 days, unless you are using a custom `prometheus.storage.local.retention` property value or if you want to keep data longer than that), remove the [migrate_from_prometheus_1.yml](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/migrations/migrate_from_prometheus_1.yml) op-file from your deployment and the old `prometheus` instance (and the persistent disk holding the historical data) will be automatically deleted alongside the remote read.

#### Grafana v5

Grafana has been upgraded to [v5](http://docs.grafana.org/guides/whats-new-in-v5/). There are two new features that may affect dashboards, specially if you are using your own dashboards:

* The dashboard [grid layout engine](http://docs.grafana.org/reference/dashboard/#panel-size-position) has changed. All dashboards will be automatically upgraded to a new positioning system when you load them in v5. Dashboards saved in v5 will not work in older versions of Grafana.

* Grafana allows organizing dashboards in [folders](http://docs.grafana.org/reference/dashboard_folders/). A new property in this BOSH release has been added to support this feature, and the [manifest files](https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/) have been updated accordingly to store all dashboards inside folders. If you are collocating dashboards from an external BOSH release and using the `grafana.prometheus.dashboard_files` property, all those dashboards will be located at the `default` folder, but if you prefer to use a different folder, adapt your manifest files to use the new property:

    ```
    grafana.prometheus.dashboard_folders:
      description: "Array of grafana folders and dashboard json file locations or glob patterns"
      example:
        - name: "My Dashboards"
          files:
            - "/var/vcap/packages/my_dashboards/*"
    ```

#### Misc

* The [github_exporter](https://github.com/infinityworks/github-exporter) has been removed

### Features

* Upgraded to Prometheus v2
* Upgraded to Grafana v5
* Allow organizing `grafana` dashboard in folders
* Allow setting custom headers in nginx config
* Allow `prometheus` job to use a proxy
* Allow `kube-state-metrics` job to use a proxy
* Allow `kube-state-metrics` job to get properties from [cfcf](https://docs-cfcr.cfapps.io/) via BOSH links
* Updated `kubernetes` dashboards
* Added alerts for `RabbitMQ for PCF` queue depth
* Added dashboards compatible with `loggregator` version `101.4`
* Service name for `CF Apps` alerts is now configurable

### Fixes

* Fixes app request at `cloudfoundry` dashboards
* Fixes `expr` for unassigned shards and node count at `elasticsearch` dashboards
* Fixes a problem with a `grafana` script not being compatible with CentOS stemcells

### Manifests

* Added [migrate_from_prometheus_1.yml]((https://github.com/bosh-prometheus/prometheus-boshrelease/blob/master/manifests/operators/migrations/migrate_from_prometheus_1.yml)) op-file to allows migrations from Prometheus v1
* All `grafana` dashboards are now store inside folders
* The alertmanager `slack` configuration now sends alerts when they are resolved
* `monitor-kubernetes` op file now enables kubernetes `API servers` and `kubelets` service discovery
* Added op files to enable proxy properties on several components
* `cf_exporter` client uses now read only privileges (`cloud_controller.admin_read_only`)
* Bump `cf-routing` release to [v0.174.0](https://github.com/cloudfoundry/routing-release/releases/tag/0.174.0)
* Bump `postgres` relase to [v28](https://github.com/cloudfoundry/postgres-release/releases/tag/v28)

### Upgrades

* `alertmanager` to [v0.14.0](https://github.com/prometheus/alertmanager/releases/tag/v0.14.0)
* `blackbox_exporter` to [v0.12.0](https://github.com/prometheus/blackbox_exporter/releases/tag/v0.12.0)
* `bosh_exporter` to [v3.0.1](https://github.com/bosh-prometheus/bosh_exporter/releases/tag/v3.0.1)
* `cf_exporter` to [v0.6.2](https://github.com/bosh-prometheus/cf_exporter/releases/tag/v0.6.2)
* `firehose_exporter` to [v5.0.3](https://github.com/bosh-prometheus/firehose_exporter/releases/tag/v5.0.3)
* `grafana` to [v5.0.4](https://github.com/grafana/grafana/releases/tag/v5.0.4)
* `Grafana Status panel` to [v1.0.8](https://github.com/Vonage/Grafana_Status_panel/releases/tag/1.0.8)
* `Grafana Pie Chart panel` to `a07f6cf`
* `kube-state-metrics` to [v1.3.0](https://github.com/kubernetes/kube-state-metrics/releases/tag/v1.3.0)
* `memcached_exporter` to [v0.4.1](https://github.com/prometheus/memcached_exporter/releases/tag/v0.4.1)
* `pcre` to `v8.42`
* `postgres_exporter` to [v0.4.5](https://github.com/wrouesnel/postgres_exporter/releases/tag/v0.4.5)
* `prometheus` to [v2.2.1](https://github.com/prometheus/prometheus/releases/tag/v2.2.1)
* `rabbitmq_exporter` to [0.27.0](https://github.com/kbudde/rabbitmq_exporter/releases/tag/v0.27.0)
* `redis_exporter` to [0.17.2](https://github.com/oliver006/redis_exporter/releases/tag/v0.17.2)
* `stackdriver_exporter` to [v0.5.1](https://github.com/frodenas/stackdriver_exporter/releases/tag/v0.5.1)
