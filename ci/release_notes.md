## Breaking changes

* `nginx` auth configuration for `alertmanager`, `grafana` and `prometheus` has been converted to an array to allow configuring multiple users. Use
  * `nginx.alertmanager.auth_users` instead of `nginx.alertmanager.auth_username` and `nginx.alertmanager.auth_password`
  * `nginx.grafana.auth_users` instead of `nginx.grafana.auth_username` and `nginx.grafana.auth_password`
  * `nginx.prometheus.auth_users` instead of `nginx.prometheus.auth_username` and `nginx.prometheus.auth_password`

  An example configuration is:
  ```
  properties:
    nginx:
      alertmanager:
        auth_users:
          - name: admin
            password: ((alertmanager_password))
      grafana:
        auth_users:
          - name: admin
            password: ((grafana_password))
      prometheus:
        auth_users:
          - name: admin
            password: ((prometheus_password))
  ```

* `statsd_exporter` mapping configuration requires now a YAML format. You must convert your mappings configuration to the new format when you upgrade. Please refer to the `statsd_exporter` [release notes](https://github.com/prometheus/statsd_exporter/releases/tag/v0.5.0).

## Updates

* `alertmanager` to [v0.11.0](https://github.com/prometheus/alertmanager/releases/tag/v0.11.0)
* `grafana` to [v4.6.2](https://github.com/grafana/grafana/releases/tag/v4.6.2)
* `rabbitmq_exporter` to [v0.24.0](https://github.com/kbudde/rabbitmq_exporter/releases/tag/v0.24.0)
* `statsd_exporter` to [v0.5.0](https://github.com/prometheus/statsd_exporter/releases/tag/v0.5.0)
