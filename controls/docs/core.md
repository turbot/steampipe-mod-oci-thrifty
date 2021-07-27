## Thrifty Core Benchmark

Thrifty developers eliminate their unused and under-utilized core resources.
This benchmark focuses on finding resources that have not been restarted
recently, have old backups, have unused public IPs or auto-tune performance is disabled.

### Default Thresholds

- [Long running instance threshold (90 Days)](https://github.com/turbot/steampipe-mod-oci-thrifty/blob/main/controls/core.sp#L56)
- [Volume backup age threshold (90 Days)](https://github.com/turbot/steampipe-mod-oci-thrifty/blob/main/controls/core.sp#L81)
- [Volumes that are large (> 100 GB)](https://github.com/turbot/steampipe-mod-oci-thrifty/blob/main/controls/core.sp#L132)
