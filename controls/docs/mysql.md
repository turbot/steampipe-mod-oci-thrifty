## Thrifty MySQL Benchmark

Thrifty developers checks old MySQL DB systems. This benchmark focuses on finding MySQL DB systems which are older than 90 days.

### Variables

| Variable | Description | Default |
| - | - | - |
| mysql_db_system_age_max_days | The maximum number of days DB systems are allowed to run. | 90 days |
| mysql_db_system_age_warning_days | The number of days DB systems can be running before sending a warning. | 30 days |
| mysql_db_system_avg_connections | The minimum number of average connections per day required for DB systems to be considered in-use. | 2 connections/day |
| mysql_db_system_avg_cpu_utilization_low | The average CPU utilization required for DB systems to be considered infrequently used. This value should be lower than `mysql_db_system_avg_cpu_utilization_high`. | 25% |
| mysql_db_system_avg_cpu_utilization_high | The average CPU utilization required for DB systems to be considered frequently used. This value should be higher than `mysql_db_system_avg_cpu_utilization_low`. | 50% |
