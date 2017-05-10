# Breaking changes

* Fixed the `web.auth_password` property name at the `bosh_exporter`, `bosh_tsdb_exporter`, `cf_exporter`, `firehose_exporter` and `shield_exporter`. If you were using the `auth_pasword` property, now it has been renamed to `auth_password` (note the missing `s` at previous versions).
