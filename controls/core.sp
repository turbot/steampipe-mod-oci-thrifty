locals {
  core_common_tags = merge(local.thrifty_common_tags, {
    service = "core"
  })
}

benchmark "core" {
  title         = "core Checks"
  description   = "Thrifty developers eliminate unused and under-utilized core resources."
  documentation = file("./controls/docs/core.md")
  tags          = local.core_common_tags
  children = [
    control.core_volume_auto_tune_performance_enabled,
    control.core_instance_long_running,
    control.core_volume_backup_age_90
  ]
}

control "core_volume_auto_tune_performance_enabled" {
  title       = "Block volume should be enabled with auto-tune for performance"
  description = "Block volume auto-tune should be enabled for performance."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when is_auto_tune_enabled then 'ok'
        else 'alarm'
      end as status,
      case
        when is_auto_tune_enabled then a.title || ' auto-tune volume performance enabled.'
        else a.title || ' auto-tune volume performance disabled.'
      end as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_volume a
      left join oci_identity_compartment as c on c.id = a.compartment_id
  EOT

  tags = merge(local.core_common_tags, {
    class = "deprecated"
  })
}

control "core_instance_long_running" {
  title       = "Long running instances should be reviewed"
  description = "Instances should ideally be ephemeral and rehydrated frequently, check why these instances have been running for so long."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when date_part('day', now() - a.time_created) > 90 then 'alarm'
        else 'ok'
      end as status,
      a.title || ' has been running ' || date_part('day', now() - a.time_created) || ' days.' as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_instance a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.core_common_tags, {
    class = "deprecated"
  })
}

control "core_volume_backup_age_90" {
  title       = "Volume backup created over 90 days ago should be deleted if not required"
  description = "Old backups are likely unneeded and costly to maintain."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when a.time_created > current_timestamp - interval '90 days' then 'ok'
        else 'alarm'
      end as status,
      a.display_name || ' created at ' || a.time_created || '.' as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_volume_backup a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.core_common_tags, {
    class = "deprecated"
  })
}