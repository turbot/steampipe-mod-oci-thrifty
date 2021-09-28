variable "compute_running_instance_age_max_days" {
  type        = number
  description = "The maximum number of days an instance is allowed to run."
}

locals {
  compute_common_tags = merge(local.thrifty_common_tags, {
    service = "compute"
  })
}

benchmark "compute" {
  title         = "Compute Checks"
  description   = "Thrifty developers eliminate unused and under-utilized compute resources."
  documentation = file("./controls/docs/compute.md")
  tags          = local.compute_common_tags
  children = [
    control.compute_instance_long_running,
    control.compute_instance_low_utilization,
    control.compute_instance_monitoring_enabled
  ]
}

control "compute_instance_long_running" {
  title       = "Long running compute instances should be reviewed"
  description = "Instances should ideally be ephemeral and rehydrated frequently, check why these instances have been running for so long."
  severity    = "low"

  sql = <<-EOT
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
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_instance as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  param "compute_running_instance_age_max_days" {
    default = var.compute_running_instance_age_max_days
  }

  tags = merge(local.compute_common_tags, {
    class = "deprecated"
  })
}

control "compute_instance_low_utilization" {
  title       = "Compute instances with low CPU utilization should be reviewed"
  description = "Resize or eliminate under utilized instances."
  severity    = "low"

  sql = <<-EOT
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
        when avg_max < 20 then 'alarm'
        when avg_max < 35 then 'info'
        else 'ok'
      end as status,
      case
        when avg_max is null then 'Metrics not available for ' || i.title || '.'
        else i.title || ' averaging ' || avg_max || '% max utilization over the last ' || days || ' days.'
      end as reason,
      i.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_instance as i
      left join core_instance_utilization as u on u.id = i.id
      left join oci_identity_compartment as c on c.id = i.compartment_id;
  EOT

  tags = merge(local.compute_common_tags, {
    class = "unused"
  })
}

control "compute_instance_monitoring_enabled" {
  title       = "Compute instances should have monitoring enabled"
  description = "The compute instance metrics provide data about the activity level and throughput of the instance. These metrics are required to use features such as autoscaling, metrics, alarms, and notifications with compute instances."
  severity    = "low"

  sql = <<-EOT
      with instance_monitoring as (
      select 
        distinct display_name,
        config
      from 
        oci_core_instance,
        jsonb_array_elements(agent_config -> 'pluginsConfig') config
      where
        config ->> 'name' = 'Compute Instance Monitoring' and
        config ->> 'desiredState' = 'ENABLED'
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
      v.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_instance as v
      left join instance_monitoring as l on v.display_name = l.display_name
      left join oci_identity_compartment as c on c.id = v.compartment_id
    where
      v.lifecycle_state <> 'TERMINATED';
  EOT

  tags = merge(local.compute_common_tags, {
    class = "managed"
  })
}