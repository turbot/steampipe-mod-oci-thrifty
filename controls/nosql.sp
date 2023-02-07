variable "nosql_table_stale_data_max_days" {
  type        = number
  description = "The maximum number of days table data can be unchanged before it is considered stale."
  default     = 90
}

locals {
  nosql_common_tags = merge(local.oci_thrifty_common_tags, {
    service = "OCI/NoSQL"
  })
}

benchmark "nosql" {
  title         = "NoSQL Checks"
  description   = "Thrifty developers review NoSQL tables with stale data."
  documentation = file("./controls/docs/nosql.md")
  children = [
    control.nosql_table_stale_data
  ]

  tags = merge(local.nosql_common_tags, {
    type = "Benchmark"
  })
}

control "nosql_table_stale_data" {
  title       = "NoSQL tables with stale data should be reviewed"
  description = "If the data has not changed recently and has become stale, the table should be reviewed."
  severity    = "low"

  sql = <<-EOQ
    select
      a.id as resource,
      case
        when date_part('day', now()-(time_updated::timestamptz)) > $1 then 'alarm'
        else 'ok'
      end as status,
      a.title || ' was changed ' || date_part('day', now()-(time_updated::timestamptz)) || ' day(s) ago.' as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
      ${replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
    from
      oci_nosql_table as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOQ

  param "nosql_table_stale_data_max_days" {
    description = "The maximum number of days table data can be unchanged before it is considered stale."
    default     = var.nosql_table_stale_data_max_days
  }

  tags = merge(local.nosql_common_tags, {
    class = "deprecated"
  })
}