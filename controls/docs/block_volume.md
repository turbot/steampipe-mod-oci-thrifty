## Thrifty Block Volume Benchmark

Thrifty developers eliminate their unused and under-utilized block volume resources.
This benchmark focuses on finding resources which are older than thresholds days, have large size,
unused, low usage or auto-tune performance is disabled.

### Default Thresholds

- [Volume backup age threshold (90 Days)](https://hub.steampipe.io/mods/turbot/oci_thrifty/controls/control.compute_volume_backup_age_90)
- [Volumes that are large (> 100 GB)](https://hub.steampipe.io/mods/turbot/oci_thrifty/controls/control.compute_volume_large)
