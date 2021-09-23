## Thrifty Block Volume Benchmark

Thrifty developers eliminate their unused and under-utilized block volume resources.
This benchmark focuses on finding resources which are older than thresholds days, have large size,
unused, low usage or auto-tune performance is disabled.

### Variables

| Variable | Description | Default |
| - | - | - |
| boot_and_block_volume_max_size_gb | The maximum size in GB allowed for boot an block volumes. | 100 GB |
| block_volume_backup_age_max_days | The maximum number of days a volume backup can be retained for. | 90 days |
