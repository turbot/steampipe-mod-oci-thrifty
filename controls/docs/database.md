## Thrifty Database Benchmark

Thrifty developers checks old autonomous databases. This benchmark focuses on finding autonomous databases which are older than 90 days.

### Variables

| Variable | Description | Default |
| - | - | - |
| autonomous_database_age_max_days | The maximum number of days an autonomous database is allowed to run. | 90 days |
| autonomous_database_age_warning_days | The number of days after which an autonomous database set a warning. | 30 days |
| autonomous_database_avg_cpu_utilization_low | The average CPU utilization required for autonomous databases to be considered infrequently used. This value should be lower than `autonomous_database_avg_cpu_utilization_high`. | 20% |
| autonomous_database_avg_cpu_utilization_high | The average CPU utilization required for autonomous databases to be considered frequently used. This value should be higher than `autonomous_database_avg_cpu_utilization_low`. | 35% |
