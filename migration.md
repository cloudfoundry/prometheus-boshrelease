# Migration Guide to Prometheus3

## Background

With release `v31.0.0` Prometheus v3 will be introduced.
As the in-place update is supported from Prometheus v2 to Prometheus v3, not like for Prometheus v1 to Prometheus v2,
we made the decision to not introduce another dedicated job for Prometheus v3 but start using the original `prometheus` job again.
With the update to a version `v31.0.0` or greater your existing `prometheus2` `instance_group` gets migrated to an `instance_group` called `prometheus`.
By using the `migrated_from` property we ensure that the persistent disk is kept during this migration.

## Prerequisits

- Make sure to update to `v30.9.0` before updating to `v31.0.0` or greater
- You should have at least `50%` free persistent disk space before the update, if not please scale your disk (you can scale down after the migration)

## What is the update doing?
During the update we migrate the `instance_group` called `prometheus2` to the `instance_group` called `prometheus`.
By adding the `migration_from` property to the manifest, we ensure that the persistent disk of `prometheus2` does not get lost but attached to the `prometheus` `instance_group`.

Next step is that we copy the folder `prometheus2` on the persistent disk to a folder called `prometheus` so that Prometheus v3 is able to find your data.
This is done during pre-start. That is the reason why we need at least 50% of free disk space. 

Like this we still have the possibility to rollback afterwards.

Copying is only done if the `prometheus` directory does not exist under `/var/vcap/store`. If the deployment failed during `pre-start`, please check the troubleshooting section on how to continue from here.

The latest version of Prometheus v3 starts including your data.

If everything looks good, feel free to delete the `prometheus2` folder on the persistent disk (under `/var/vcap/store`) and downscale your disk again (if it was upscaled before).

## What do I need to do?
If you do not write your own ops file, nothing.
If you write your own ops files, make sure to adapt them to reference `prometheus` as `instance_group` and `job` instead of `prometheus2`. 

## Rollback
If you face issues and want to rollback to a version smaller than `v31.0.0` make sure to add the `migrated_from: [prometheus]` property to your manifest, otherwise your persistent disk will be gone and with it all your data.
Such an ops file could look like this:

```
- type: replace
  path: /instance_groups/name=prometheus2/migrated_from?/-
  value:
    name: prometheus
```

## Troubleshooting
If the `pre-start` job fails due to `"no space on device left"` you need to scale your persistent disk and ensure to remove the `prometheus` folder under `/var/vcap/store`, otherwise the `pre-start` will not try to copy your `prometheus2` data again.
