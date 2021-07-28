## Thrifty Compute Benchmark

Thrifty developers eliminate their unused and under-utilized Compute resources.
This benchmark focuses on finding resources that have not been restarted
recently, have old backups, have unused public IPs or auto-tune performance is disabled.

### Default Thresholds

- [Long running instance threshold (90 Days)](https://hub.steampipe.io/mods/turbot/oci_thrifty/controls/control.compute_instance_long_running)
- [Volume backup age threshold (90 Days)](https://hub.steampipe.io/mods/turbot/oci_thrifty/controls/control.compute_volume_backup_age_90)
- [Volumes that are large (> 100 GB)](https://hub.steampipe.io/mods/turbot/oci_thrifty/controls/control.compute_volume_large)
