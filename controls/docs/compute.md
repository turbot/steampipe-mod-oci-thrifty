## Thrifty Compute Benchmark

Thrifty developers eliminate their unused and under-utilized core compute resources.
This benchmark focuses on finding resources that have been older than thresholds days and low CPU utilization.

### Variables

| Variable | Description | Default |
| - | - | - |
| compute_instance_avg_cpu_utilization_high | The average CPU utilization required for instances to be considered frequently used. This value should be higher than `compute_instance_avg_cpu_utilization_low`. | 35% |
| compute_instance_avg_cpu_utilization_low | The average CPU utilization required for instances to be considered infrequently used. This value should be lower than `compute_instance_avg_cpu_utilization_high`. | 20% |
| compute_running_instance_age_max_days | The maximum number of days instances are allowed to run. | 90 days |
