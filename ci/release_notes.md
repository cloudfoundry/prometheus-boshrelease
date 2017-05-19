## Breaking changes

* All **Alerts** have been moved from `packages` to `job templates` to allow parametrization. Update your deployment manifest replacing `/var/vcap/packages/*_alerts/*.json` to `/var/vcap/jobs/*_alerts/*.json`.
* All **Dashboards** have been moved from `packages` to `job templates` to allow parametrization. Update your deployment manifest replacing `/var/vcap/packages/*_dashboards/*.json` to `/var/vcap/jobs/*_dashboards/*.json`.
* The probe SSL alerts at `probe.alerts` have been moved to `ssl.alerts`.

## Features

* All **Alerts** have been parametrized. You can now specify via manifest file the `evaluation_time` and `thresholds`.
