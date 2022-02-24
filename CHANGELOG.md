## v0.4 [2022-02-24]

_Enhancements_

- Updated the inline query of `database_autonomous_database_low_utilization` control to use the new `oci_database_autonomous_db_metric_cpu_utilization_daily` table instead of old `oci_database_autonomous_database_metric_cpu_utilization_daily` table ([#19](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/19))

## v0.3 [2021-09-30]

_What's new?_

- Added: Input variables have been added to Block, Compute, Database, MySQL, and NoSQL controls to allow different thresholds to be passed in. To get started, please see [OCI Thrifty Configuration](https://hub.steampipe.io/mods/turbot/oci_thrifty#configuration). For a list of variables and their default values, please see [steampipe.spvars](https://github.com/turbot/steampipe-mod-oci-thrifty/blob/main/steampipe.spvars).

## v0.2 [2021-09-27]

_What's new?_

- New control added:
  - compute_instance_monitoring_enabled

_Enhancements_

- The title of the mod has been updated from `Oracle Cloud Thrifty` to `Oracle Cloud Infrastructure Thrifty`

_Bug fixes_

- `block_volume_auto_tune_performance_enabled` control will no longer evaluate terminated block volumes

## v0.1 [2021-08-04]

_What's new?_

- Added: Initial Block Volume, Budget, Compute, Database, MySQL, Network, NoSQL, and Object Storage benchmarks
