## Thrifty MySQL Benchmark

Thrifty developers checks old MySQL DB systems. This benchmark focuses on finding MySQL DB systems which are older than 90 days.

### Variables

| Variable | Description | Default |
| - | - | - |
| mysql_db_system_age_max_days | The maximum number of days a MySQL DB system is allowed to run. | 90 days |
| mysql_db_system_age_warning_days | The number of days after which a DB system set a warning. | 30 days |
| mysql_db_system_min_connections_per_day | The minimum number of client sessions that are connected per day to the DB system. | 2 connections/day |
