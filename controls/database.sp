variable "autonomous_database_age_max_days" {
  type        = number
  description = "The maximum number of days autonomous databases are allowed to run."
  default     = 90
}

variable "autonomous_database_age_warning_days" {
  type        = number
  description = "The number of days autonomous databases can be running before sending a warning."
  default     = 30
}

variable "autonomous_database_avg_cpu_utilization_high" {
  type        = number
  description = "The average CPU utilization required for autonomous databases to be considered frequently used. This value should be higher than autonomous_database_avg_cpu_utilization_low."
  default     = 35
}

variable "autonomous_database_avg_cpu_utilization_low" {
  type        = number
  description = "The average CPU utilization required for autonomous databases to be considered infrequently used. This value should be lower than autonomous_database_avg_cpu_utilization_high."
  default     = 25
}

locals {
  database_common_tags = merge(local.oci_thrifty_common_tags, {
    service = "OCI/Database"
  })
}

benchmark "database" {
  title         = "Database Checks"
  description   = "Thrifty developers checks old autonomous database which were created over 90 days ago."
  documentation = file("./controls/docs/database.md")
  children = [
    control.database_autonomous_database_low_utilization,
    control.database_autonomous_database_max_age
  ]

  tags = merge(local.database_common_tags, {
    type = "Benchmark"
  })
}

control "database_autonomous_database_max_age" {
  title       = "Old Autonomous databases should be reviewed"
  description = "Old autonomous databases should be deleted if not required."
  severity    = "low"

  sql = <<-EOQ
    select
      a.id as resource,
      case
        when date_part('day', now()-a.time_created) > $1 then 'alarm'
        when date_part('day', now()-a.time_created) > $2 then 'info'
        else 'ok'
      end as status,
      a.title || ' of type ' || a.db_workload || ' has been in use for ' || date_part('day', now()-a.time_created) || ' days.' as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
    from
      oci_database_autonomous_database as a
      left join oci_identity_compartment as c on c.id = a.compartment_id
    where
      a.lifecycle_state <> 'DELETED';
  EOQ

  param "autonomous_database_age_max_days" {
    description = "The maximum number of days autonomous databases are allowed to run."
    default     = var.autonomous_database_age_max_days
  }

  param "autonomous_database_age_warning_days" {
    description = "The number of days autonomous databases can be running before sending a warning."
    default     = var.autonomous_database_age_warning_days
  }

  tags = merge(local.database_common_tags, {
    class = "deprecated"
  })
}

control "database_autonomous_database_low_utilization" {
  title       = "Autonomous databases with low CPU utilization should be reviewed"
  description = "Resize or eliminate under utilized autonomous databases."
  severity    = "low"

  sql = <<-EOQ
    with database_autonomous_database_utilization as (
      select
        id,
        round(cast(sum(maximum)/count(maximum) as numeric), 1) as avg_max,
        count(maximum) as days
      from
        oci_database_autonomous_db_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <= 30
      group by id
    )
    select
      i.id as resource,
      case
        when avg_max is null then 'error'
        when avg_max < $1 then 'alarm'
        when avg_max < $2 then 'info'
        else 'ok'
      end as status,
      case
        when avg_max is null then 'Monitoring metrics not available for ' || i.title || '.'
        else i.title || ' averaging ' || avg_max || '% max utilization over the last ' || days || ' day(s).'
      end as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "i.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "i.")}
    from
      oci_database_autonomous_database as i
      left join database_autonomous_database_utilization as u on u.id = i.id
      left join oci_identity_compartment as c on c.id = i.compartment_id;
  EOQ

  param "autonomous_database_avg_cpu_utilization_low" {
    description = "The average CPU utilization required for autonomous databases to be considered infrequently used. This value should be lower than autonomous_database_avg_cpu_utilization_high."
    default     = var.autonomous_database_avg_cpu_utilization_low
  }

  param "autonomous_database_avg_cpu_utilization_high" {
    description = "The average CPU utilization required for autonomous databases to be considered frequently used. This value should be higher than autonomous_database_avg_cpu_utilization_low."
    default     = var.autonomous_database_avg_cpu_utilization_high
  }

  tags = merge(local.database_common_tags, {
    class = "unused"
  })
}
