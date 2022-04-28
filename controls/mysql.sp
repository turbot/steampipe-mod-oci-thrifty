locals {
  mysql_common_tags = merge(local.oci_thrifty_common_tags, {
    service = "OCI/MySQL"
  })
}

benchmark "mysql" {
  title         = "MySQL Checks"
  description   = "Thrifty developers checks old MySQL DB systems which were created over 90 days ago."
  documentation = file("./controls/docs/mysql.md")
  children = [
    control.mysql_db_system_age_90,
    control.mysql_db_system_low_connection_count,
    control.mysql_db_system_low_usage
  ]

  tags = merge(local.mysql_common_tags, {
    type = "Benchmark"
  })
}

control "mysql_db_system_age_90" {
  title       = "MySQL DB systems created over 90 days ago should be reviewed"
  description = "MySQL DB systems created over 90 days ago should be reviewed and deleted if not required."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when date_part('day', now()-a.time_created) > 90 then 'alarm'
        when date_part('day', now()-a.time_created) > 30 then 'info'
        else 'ok'
      end as status,
      a.title || ' has been in use for ' || date_part('day', now()-a.time_created) || ' days.' as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_mysql_db_system as a
      left join oci_identity_compartment as c on c.id = a.compartment_id
    where
      a.lifecycle_state <> 'DELETED';
  EOT

  tags = merge(local.mysql_common_tags, {
    class = "deprecated"
  })
}

control "mysql_db_system_low_connection_count" {
  title       = "MySQL DB systems with fewer than 2 connections per day should be reviewed"
  description = "These DB systems have very little usage in last 30 days and should be shutdown when not in use."
  severity    = "high"

  sql = <<-EOT
    with mysql_db_usage as (
      select
        id,
        round(sum(maximum)/count(maximum)) as avg_max,
        count(maximum) as days
      from
        oci_mysql_db_system_metric_connections_daily
      where
        metric_name = 'CurrentConnections'
        and date_part('day', now() - timestamp) <= 30
      group by id
    )
    select
      m.id as resource,
      case
        when u.avg_max is null then 'error'
        when u.avg_max = 0 then 'alarm'
        when u.avg_max < 2 then 'info'
        else 'ok'
      end as status,
      case
        when u.avg_max is null then 'Monitoring metrics not available for ' || m.title || '.'
        when u.avg_max = 0 then m.title || ' has not been connected to in the last ' || days || ' day(s).'
        else m.title || ' is averaging ' || u.avg_max || ' max connections/day in the last ' || days || ' day(s).'
      end as reason,
      m.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_mysql_db_system as m
      left join mysql_db_usage as u on u.id = m.id
      left join oci_identity_compartment as c on c.id = m.compartment_id
    where
      m.lifecycle_state <> 'DELETED';
  EOT

  tags = merge(local.mysql_common_tags, {
    class = "unused"
  })
}

control "mysql_db_system_low_usage" {
  title       = "MySQL DB systems with low CPU utilization should be reviewed"
  description = "These DB systems have very little usage in last 30 days and should be shutdown when not in use."
  severity    = "high"

  sql = <<-EOT
    with mysql_db_usage as (
      select
        id,
        round(cast(sum(maximum)/count(maximum) as numeric), 1) as avg_max,
        count(maximum) days
      from
        oci_mysql_db_system_metric_memory_utilization_daily
      where
        date_part('day', now() - timestamp) <=30
      group by
        id
    )
    select
      display_name as resource,
      case
        when avg_max is null then 'error'
        when avg_max <= 25 then 'alarm'
        when avg_max <= 50 then 'info'
        else 'ok'
      end as status,
      case
        when avg_max is null then 'Monitoring metrics not available for ' || i.title || '.'
        else i.title || ' is averaging ' || avg_max || '% max utilization over the last ' || days || ' days.'
      end as reason,
      i.region,
      coalesce(c.name, 'root') as compartment

    from
      oci_mysql_db_system i
      left join mysql_db_usage as u on u.id = i.id
      left join oci_identity_compartment as c on c.id = i.compartment_id
    where i.lifecycle_state <> 'DELETED';
  EOT

  tags = merge(local.mysql_common_tags, {
    class = "unused"
  })
}
