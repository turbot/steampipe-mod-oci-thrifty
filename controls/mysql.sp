locals {
  mysql_common_tags = merge(local.thrifty_common_tags, {
    service = "mysql"
  })
}

benchmark "mysql" {
  title         = "MySQL Checks"
  description   = "Thrifty developers checks old MySQL DB systems which were created over 90 days ago."
  documentation = file("./controls/docs/mysql.md")
  tags          = local.mysql_common_tags
  children = [
    control.mysql_db_system_age_90,
    control.mysql_db_system_low_connection_count
  ]
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
  title         = "MySQL DB systems have fewer than 2 connections per day should be reviewed"
  description   = "These DB systems have very little usage in last 30 days. Should this DB system be shutdown when not in use?"
  severity      = "high"

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
