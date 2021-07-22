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
