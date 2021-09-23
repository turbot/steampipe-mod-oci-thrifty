## Thrifty MySQL Benchmark

Thrifty developers checks old MySQL DB systems. This benchmark focuses on finding MySQL DB systems which are older than 90 days.

### Variables

| Variable | Description | Default |
| - | - | - |
| mysql_db_system_age_max_days | The maximum number of days a MySQL DB system can be running for. | 90 days |
| mysql_db_system_age_warning_days | The maximum number of days set as warning threshold for a DB system. | 30 days |
| mysql_db_system_min_connection_per_day | The minimum number of connections/day a DB system can be processed. | 2 connections/day |
