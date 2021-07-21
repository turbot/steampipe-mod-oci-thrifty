locals {
  nosql_common_tags = merge(local.thrifty_common_tags, {
    service = "nosql"
  })
}

benchmark "nosql" {
  title         = "NoSQL Checks"
  description   = "Thrifty developers review NoSQL tables with stale data."
  documentation = file("./controls/docs/nosql.md")
  tags          = local.nosql_common_tags
  children = [
    control.nosql_table_stale_data,
  ]
}

control "nosql_table_stale_data" {
  title       = "NoSQL tables with stale data should be reviewed"
  description = "If the data has not changed in 90 days, the table should be reviewed."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when date_part('day', now()-(time_updated::timestamptz)) > 90 then 'alarm'
        else 'ok'
      end as status,
      a.title || ' was changed ' || date_part('day', now()-(time_updated::timestamptz)) || ' day(s) ago.' as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_nosql_table as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.nosql_common_tags, {
    class = "deprecated"
  })
}
