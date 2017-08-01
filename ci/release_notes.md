## Fixes

* Adds route prefix to the alertmanager url when configured
* Fixes a bug at the `firehose_exporter` where Basic Auth was not honored when enabled
* Fixes a data race panic at the `firehose_exporter`

## Upgrades

* `firehose_exporter` to v4.2.3
* `shield_exporter` to v0.2.1
