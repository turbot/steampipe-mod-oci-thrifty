## v1.0.1 [2024-10-24]

_Bug fixes_

- Renamed `steampipe.spvars.example` files to `powerpipe.ppvars.example` and updated documentation. ([#58](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/58))

## v1.0.0 [2024-10-22]

This mod now requires [Powerpipe](https://powerpipe.io). [Steampipe](https://steampipe.io) users should check the [migration guide](https://powerpipe.io/blog/migrating-from-steampipe).

## v0.11 [2024-03-06]

_Powerpipe_

[Powerpipe](https://powerpipe.io) is now the preferred way to run this mod!  [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)

All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

_Enhancements_

- Focus documentation on Powerpipe commands.
- Show how to combine Powerpipe mods with Steampipe plugins.

## v0.10 [2023-11-03]

_Breaking changes_

- Updated the plugin dependency section of the mod to use `min_version` instead of `version`. ([#49](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/49))

_Bug fixes_

- Fixed dashboard localhost URLs in README and index doc. ([#45](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/45))

## v0.9 [2023-02-10]

_What's new?_

- Added `tags` as dimensions to group and filter findings. (see [var.tag_dimensions](https://hub.steampipe.io/mods/turbot/oci_thrifty/variables)) ([#42](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/42))
- Added `connection_name` and `tenant_id` in the common dimensions to group and filter findings. (see [var.common_dimensions](https://hub.steampipe.io/mods/turbot/oci_thrifty/variables)) ([#42](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/42))

## v0.8 [2023-01-11]

_Bug fixes_

- Fixed the missing query params in `mysql_db_system_low_usage` control. ([#39](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/39)) (Thanks [@marakomer](https://github.com/marakomer) for the contribution!)

## v0.7 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README with new dashboard screenshots and latest format. ([#33](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/33))

## v0.6 [2022-05-02]

_Enhancements_

- Added `category`, `service`, and `type` tags to benchmarks and controls. ([#28](https://github.com/turbot/steampipe-mod-oci-thrifty/pull/28))

## v0.5 [2022-03-29]

_What's new?_

- Added default values to all variables (set to the same values in `steampipe.spvars.example`)
- Added `*.spvars` and `*.auto.spvars` files to `.gitignore`
- Renamed `steampipe.spvars` to `steampipe.spvars.example`, so the variable default values will be used initially. To use this example file instead, copy `steampipe.spvars.example` as a new file `steampipe.spvars`, and then modify the variable values in it. For more information on how to set variable values, please see [Input Variable Configuration](https://hub.steampipe.io/mods/turbot/oci_thrifty#configuration).

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
