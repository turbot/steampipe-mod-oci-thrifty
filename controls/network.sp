locals {
  network_common_tags = merge(local.oci_thrifty_common_tags, {
    service = "OCI/VCN"
  })
}

benchmark "network" {
  title         = "Network Checks"
  description   = "Thrifty developers eliminate unused and under-utilized network resources."
  documentation = file("./controls/docs/network.md")
  children = [
    control.network_public_ip_unattached
  ]

  tags = merge(local.network_common_tags, {
    type = "Benchmark"
  })
}

control "network_public_ip_unattached" {
  title       = "Unused reserved public IP addresses should be removed"
  description = "Unattached reserved public IP addresses cost money and should be released."
  severity    = "low"

  sql = <<-EOQ
    select
      a.id as resource,
      case
        when a.lifecycle_state = 'AVAILABLE'  then 'alarm'
        else 'ok'
      end as status,
      a.display_name || ' in ' || a.lifecycle_state || ' state.' as reason,
      a.scope,
      coalesce(c.name, 'root') as compartment
      ${replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "a.")}
    from
      oci_core_public_ip as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOQ

  tags = merge(local.network_common_tags, {
    class = "unused"
  })
}
