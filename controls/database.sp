locals {
  database_common_tags = merge(local.thrifty_common_tags, {
    service = "database"
  })
}

benchmark "database" {
  title         = "Oracle Database Checks"
  description   = "Thrifty developers checks old autonomous database which were created over 90 days ago."
  documentation = file("./controls/docs/database.md")
  tags          = local.database_common_tags
  children = [
    control.database_autonomous_database_age_90,
    control.database_autonomous_database_low_utilization
  ]
}

control "database_autonomous_database_age_90" {
  title       = "Autonomous database created over 90 days ago should be reviewed"
  description = "Autonomous database created over 90 days ago should be deleted if not required."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when date_part('day', now()-a.time_created) > 90 then 'alarm'
        when date_part('day', now()-a.time_created) > 30 then 'info'
        else 'ok'
      end as status,
      a.title || ' of type ' || a.db_workload || ' has been in use for ' || date_part('day', now()-a.time_created) || ' days.' as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_database_autonomous_database as a
      left join oci_identity_compartment as c on c.id = a.compartment_id
    where
      a.lifecycle_state <> 'DELETED';
  EOT

  tags = merge(local.database_common_tags, {
    class = "deprecated"
  })
}

control "database_autonomous_database_low_utilization" {
  title         = "Autonomous databases with low CPU utilization should be reviewed"
  description   = "Resize or eliminate under utilized autonomous databases."
  severity      = "low"

  sql = <<-EOT
    with database_autonomous_database_utilization as (
      select
        id,
        round(cast(sum(maximum)/count(maximum) as numeric), 1) as avg_max,
        count(maximum) as days
      from
        oci_database_autonomous_database_metric_cpu_utilization_daily
      where
        date_part('day', now() - timestamp) <= 30
      group by id
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
        when avg_max is null then 'Monitoring metrics not available for ' || i.title || '.'
        else i.title || ' averaging ' || avg_max || '% max utilization over the last ' || days || ' day(s).'
      end as reason,
      i.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_database_autonomous_database as i
      left join database_autonomous_database_utilization as u on u.id = i.id
      left join oci_identity_compartment as c on c.id = i.compartment_id;
  EOT

  tags = merge(local.database_common_tags, {
    class = "unused"
  })
}
