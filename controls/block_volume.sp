locals {
  block_volume_common_tags = merge(local.thrifty_common_tags, {
    service = "block_volume"
  })
}

benchmark "block_volume" {
  title         = "Block Volume Checks"
  description   = "Thrifty developers eliminate unused and under-utilized block & boot volume resources."
  documentation = file("./controls/docs/compute.md")
  tags          = local.block_volume_common_tags
  children = [
    control.boot_and_block_volume_attached_stopped_instance,
    control.boot_volume_low_usage,
    control.block_volume_auto_tune_performance_enabled,
    control.block_volume_backup_age_90,
    control.boot_and_block_volume_large,
    control.boot_and_block_volume_unattached,
  ]
}

control "boot_and_block_volume_attached_stopped_instance" {
  title       = "Block and Boot volumes attached to stopped instances should be reviewed"
  description = "Instances that are stopped may no longer need any volumes attached."
  severity    = "low"

  sql = <<-EOT
    -- Listing core boot volumes and block volumes associated with running instances
    with vols_with_instances as (
      select
        v.instance_id,
        v.volume_id as volume_id
      from
        oci_core_volume_attachment as v
        inner join oci_core_instance as i on i.id = v.instance_id
      where i.lifecycle_state = 'RUNNING'
      union
      select
        b.instance_id,
        b.boot_volume_id as volume_id
      from
        oci_core_boot_volume_attachment as b
        inner join oci_core_instance as i on i.id = b.instance_id
      where i.lifecycle_state = 'RUNNING'
    ),
    -- Listing all volumes of both boot volumes and block volumes
    all_volumes as (
      select
        id,
        compartment_id,
        region,
        display_name
      from
        oci_core_volume
      union
      select
        id,
        compartment_id,
        region,
        display_name
      from
        oci_core_boot_volume
    )
    -- Listing the volumes based on associations
    select
      a.id as resource,
      case
        when v.volume_id is null then 'alarm'
        else 'ok'
      end as status,
      case
        when v.volume_id is null then a.display_name || ' not associated with running instance.'
        else a.display_name || ' associated with running instance.'
      end as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      all_volumes as a
      left join vols_with_instances as v on v.volume_id = a.id
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.block_volume_common_tags, {
    class = "unused"
  })
}

control "boot_volume_low_usage" {
  title       = "Boot volumes with low usage should be reviewed"
  description = "Boot volumes that are unused should be archived and deleted."
  severity    = "low"

  sql = <<-EOT
    with boot_volume_usage as (
      select
        compartment_id,
        id,
        round(avg(max)) as avg_max,
        count(max) as days
      from (
        select
          compartment_id,
          id,
          cast(maximum as numeric) as max
        from
          oci_core_boot_volume_metric_read_ops_daily
        where
          date_part('day', now() - timestamp) <=30
        union
        select
          compartment_id,
          id,
          cast(maximum as numeric) as max
        from
          oci_core_boot_volume_metric_write_ops_daily
        where
          date_part('day', now() - timestamp) <=30
      ) as read_and_write_ops
      group by 1,2
    )
    select
      b.id as resource,
      case
        when b.avg_max <= 100 then 'alarm'
        when b.avg_max <= 500 then 'info'
        else 'ok'
      end as status,
      v.display_name || ' averaging ' || b.avg_max || ' read and write ops over the last ' || b.days || ' days.' as reason,
      v.region,
      coalesce(c.name, 'root') as compartment
    from
      boot_volume_usage as b
      left join oci_core_boot_volume as v on b.id = v.id
      left join oci_identity_compartment as c on c.id = b.compartment_id;
  EOT

  tags = merge(local.block_volume_common_tags, {
    class = "unused"
  })
}

control "block_volume_auto_tune_performance_enabled" {
  title       = "Block volume should be enabled with auto-tune for better performance"
  description = "Block volume auto-tune should be enabled for better performance."
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
      oci_core_volume as a
      left join oci_identity_compartment as c on c.id = a.compartment_id
  EOT

  tags = merge(local.block_volume_common_tags, {
    class = "deprecated"
  })
}

control "block_volume_backup_age_90" {
  title       = "Blcok volume backup created over 90 days ago should be deleted if not required"
  description = "Old backups are likely unneeded and costly to maintain."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when a.time_created > current_timestamp - interval '90 days' then 'ok'
        else 'alarm'
      end as status,
      a.display_name || ' created ' || to_char(a.time_created , 'DD-Mon-YYYY') ||
       ' (' || extract(day from current_timestamp - a.time_created) || ' days).' as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_core_volume_backup as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.block_volume_common_tags, {
    class = "deprecated"
  })
}

control "boot_and_block_volume_large" {
  title       = "Block and Boot volumes with over 100 GB should be resized if too large"
  description = "Large core volumes are unusual, expensive and should be reviewed."
  severity    = "low"

  sql = <<-EOT
    with all_volumes_with_size as (
      select
        id,
        compartment_id,
        region,
        display_name,
        size_in_gbs
      from
        oci_core_volume
      union
      select
        id,
        compartment_id,
        region,
        display_name,
        size_in_gbs
      from
        oci_core_boot_volume
    )
    select
      a.id as resource,
      case
        when a.size_in_gbs <= 100  then 'ok'
        else 'alarm'
      end as status,
        a.display_name || ' with size ' || a.size_in_gbs || ' gb.' as reason,
        a.region,
        coalesce(c.name, 'root') as compartment
    from
      all_volumes_with_size as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.block_volume_common_tags, {
    class = "deprecated"
  })
}

control "boot_and_block_volume_unattached" {
  title       = "Block and Boot volumes attached to stopped instances should be reviewed"
  description = "Instances that are stopped may no longer need any volumes attached."
  severity    = "low"

  sql = <<-EOT
    with vols_with_instances as (
      select
        v.volume_id as volume_id
      from
        oci_core_volume_attachment as v
      union
      select
        b.boot_volume_id as volume_id
      from
        oci_core_boot_volume_attachment as b
    ),
    -- Listing all volumes of type boot and block volumes
    all_volumes as (
      select
        id,
        compartment_id,
        region,
        display_name,
        size_in_gbs
      from
        oci_core_volume
      union
      select
        id,
        compartment_id,
        region,
        display_name,
        size_in_gbs
      from
        oci_core_boot_volume
    )
    -- Listing the volumes based on attachment
    select
      a.id as resource,
      case
        when v.volume_id is null then 'alarm'
        else 'ok'
      end as status,
      case
        when v.volume_id is null then a.display_name || ' of size ' || a.size_in_gbs || 'gb not attached.'
        else a.display_name || ' of size ' || a.size_in_gbs || 'gb attached to instance.'
      end as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      all_volumes as a
      left join vols_with_instances as v on v.volume_id = a.id
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.block_volume_common_tags, {
    class = "unused"
  })
}