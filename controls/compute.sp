variable "compute_instance_avg_cpu_utilization_high" {
  type        = number
  description = "The average CPU utilization required for instances to be considered frequently used. This value should be higher than compute_instance_avg_cpu_utilization_low."
  default     = 35
}

variable "compute_instance_avg_cpu_utilization_low" {
  type        = number
  description = "The average CPU utilization required for instances to be considered infrequently used. This value should be lower than compute_instance_avg_cpu_utilization_high."
  default     = 20
}

variable "compute_running_instance_age_max_days" {
  type        = number
  description = "The maximum number of days instances are allowed to run."
  default     = 90
}

locals {
  compute_common_tags = merge(local.oci_thrifty_common_tags, {
    service = "OCI/Compute"
  })
}

benchmark "compute" {
  title         = "Compute Checks"
  description   = "Thrifty developers eliminate unused and under-utilized compute resources."
  documentation = file("./controls/docs/compute.md")
  children = [
    control.compute_instance_long_running,
    control.compute_instance_low_utilization,
    control.compute_instance_monitoring_enabled
  ]

  tags = merge(local.compute_common_tags, {
    type = "Benchmark"
  })
}

control "compute_instance_long_running" {
  title       = "Long running compute instances should be reviewed"
  description = "Instances should ideally be ephemeral and rehydrated frequently, check why these instances have been running for so long."
  severity    = "low"

  sql = <<-EOQ
    select
      a.id as resource,
      case
        when a.lifecycle_state <> 'RUNNING' then 'skip'
        when date_part('day', now() - a.time_created) > $1 then 'alarm'
        else 'ok'
      end as status,
      case
        when a.lifecycle_state <> 'RUNNING' then a.title || ' in ' || a.lifecycle_state || ' state.'
        else a.title || ' has been running ' || date_part('day', now() - a.time_created) || ' days.'
      end as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
    from
      oci_core_instance as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOQ

  param "compute_running_instance_age_max_days" {
    description = "The maximum number of days instances are allowed to run."
    default     = var.compute_running_instance_age_max_days
  }

  tags = merge(local.compute_common_tags, {
    class = "deprecated"
  })
}

control "compute_instance_low_utilization" {
  title       = "Compute instances with low CPU utilization should be reviewed"
  description = "Resize or eliminate under utilized instances."
  severity    = "low"

  sql = <<-EOQ
    with core_instance_utilization as (
      select
        id,
        round(cast(sum(maximum)/count(maximum) as numeric), 1) as avg_max,
        count(maximum) days
      from
        oci_core_instance_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <=30
      group by
        id
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
        when avg_max is null then 'Metrics not available for ' || i.title || '.'
        else i.title || ' averaging ' || avg_max || '% max utilization over the last ' || days || ' days.'
      end as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "i.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "i.")}
    from
      oci_core_instance as i
      left join core_instance_utilization as u on u.id = i.id
      left join oci_identity_compartment as c on c.id = i.compartment_id;
  EOQ

  param "compute_instance_avg_cpu_utilization_low" {
    description = "The average CPU utilization required for instances to be considered infrequently used. This value should be lower than compute_instance_avg_cpu_utilization_high."
    default     = var.compute_instance_avg_cpu_utilization_low
  }

  param "compute_instance_avg_cpu_utilization_high" {
    description = "The average CPU utilization required for instances to be considered frequently used. This value should be higher than compute_instance_avg_cpu_utilization_low."
    default     = var.compute_instance_avg_cpu_utilization_high
  }

  tags = merge(local.compute_common_tags, {
    class = "unused"
  })
}

control "compute_instance_monitoring_enabled" {
  title       = "Compute instances should have monitoring enabled"
  description = "The compute instance metrics provide data about the activity level and throughput of the instance. These metrics are required to use features such as autoscaling, metrics, alarms, and notifications with compute instances."
  severity    = "low"

  sql = <<-EOQ
      with instance_monitoring as (
      select
        distinct display_name,
        config
      from
        oci_core_instance,
        jsonb_array_elements(agent_config -> 'pluginsConfig') as config
      where
        config ->> 'name' = 'Compute Instance Monitoring'
        and config ->> 'desiredState' = 'ENABLED'
    )
    select
      v.id as resource,
      case
        when l.display_name is null then 'alarm'
        else 'ok'
      end as status,
      case
        when l.display_name is null then v.title || ' logging disabled.'
        else v.title || ' logging enabled.'
      end as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "v.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "v.")}
    from
      oci_core_instance as v
      left join instance_monitoring as l on v.display_name = l.display_name
      left join oci_identity_compartment as c on c.id = v.compartment_id
    where
      v.lifecycle_state <> 'TERMINATED';
  EOQ

  tags = merge(local.compute_common_tags, {
    class = "managed"
  })
}
