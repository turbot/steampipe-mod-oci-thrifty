locals {
  budget_common_tags = merge(local.thrifty_common_tags, {
    service = "budget"
  })
}

benchmark "budget" {
  title         = "Budget Checks"
  description   = "Thrifty developers checks budget alert rule is set for each compartments including root."
  documentation = file("./controls/docs/budget.md")
  tags          = local.budget_common_tags
  children = [
    control.budget_alert_count,
  ]
}

control "budget_alert_count" {
  title       = "Check budget alert set for each compartment including root"
  description = "Budget alert should be set for each compartment including root to monitor cost."
  severity    = "low"

  sql = <<-EOT
    with compartment_with_budget as (
      select
        id,
        'root' as name,
        'ACTIVE' as lifecycle_state
      from
        oci_identity_tenancy
      union
      select
        id,
        name,
        lifecycle_state
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
        else a.display_name || ' with scheduled budget ' || a.reset_period || '.'
      end as reason,
      coalesce(c.name, 'root') as compartment
    from
      compartment_with_budget as c
      left join oci_budget_budget as a on a.targets ?& array[c.id]
    where
      c.lifecycle_state = 'ACTIVE';
  EOT

  tags = merge(local.core_common_tags, {
    class = "managed"
  })
}