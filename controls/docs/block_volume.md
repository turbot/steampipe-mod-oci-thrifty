## Thrifty Block Volume Benchmark

Thrifty developers eliminate their unused and under-utilized block volume resources.
This benchmark focuses on finding resources which are older than thresholds days, have large size,
unused, low usage or auto-tune performance is disabled.

### Variables

| Variable | Description | Default |
| - | - | - |
| boot_and_block_volume_max_size_gb | The maximum size in GB allowed for boot and block volumes. | 100 GB |
| boot_volume_avg_read_write_ops_low | The number of average read/write ops required for boot volumes to be considered infrequently used. This value should be lower than `boot_volume_avg_read_write_ops_high`. | 100 |
| boot_volume_avg_read_write_ops_high | The number of average read/write ops required for boot volumes to be considered frequently used. This value should be higher than `boot_volume_avg_read_write_ops_low`. | 500 |
| block_volume_backup_age_max_days | The maximum number of days a volume backup can be retained. | 90 days |
