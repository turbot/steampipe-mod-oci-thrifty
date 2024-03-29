locals {
  budget_common_tags = merge(local.oci_thrifty_common_tags, {
    service = "OCI/Budget"
  })
}

benchmark "budget" {
  title         = "Budget Checks"
  description   = "Thrifty developers check that a budget alert rule is set for each compartments, including the root compartment."
  documentation = file("./controls/docs/budget.md")
  children = [
    control.budget_alert_count
  ]

  tags = merge(local.budget_common_tags, {
    type = "Benchmark"
  })
}

control "budget_alert_count" {
  title       = "Budget alerts should be set for each compartment"
  description = "Budget alerts should be set for each compartment, including the root compartment, to monitor costs."
  severity    = "low"

  sql = <<-EOQ
    with compartment_with_budget as (
      select
        id,
        'root' as name,
        'ACTIVE' as lifecycle_state,
        tenant_id,
        _ctx
      from
        oci_identity_tenancy
      union
      select
        id,
        name,
        lifecycle_state,
        tenant_id,
        _ctx
      from
        oci_identity_compartment
    )
    select
      c.id as resource,
      case
        when a.alert_rule_count is null then 'alarm'
        when a.alert_rule_count >= 1 and a.reset_period = 'MONTHLY' then 'ok'
        else 'alarm'
      end as status,
      case
        when a.alert_rule_count is null then c.name || ' has no scheduled budget.'
        else a.display_name || ' has scheduled budget with ' || a.reset_period || ' reset period.'
      end as reason,
      coalesce(c.name, 'root') as compartment
      ${replace(local.common_dimensions_qualifier_global_sql, "__QUALIFIER__", "c.")}
    from
      compartment_with_budget as c
      left join oci_budget_budget as a on a.targets ?& array[c.id]
    where
      c.lifecycle_state = 'ACTIVE';
  EOQ

  tags = merge(local.budget_common_tags, {
    class = "managed"
  })
}
