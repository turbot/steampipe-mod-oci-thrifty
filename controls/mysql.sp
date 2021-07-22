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
