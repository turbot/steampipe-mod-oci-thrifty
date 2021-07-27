locals {
  objectstorage_common_tags = merge(local.thrifty_common_tags, {
    service = "objectstorage"
  })
}

benchmark "objectstorage" {
  title         = "Object Storage Checks"
  description   = "Thrifty developers ensure their Object Storage buckets have managed lifecycle policies."
  documentation = file("./controls/docs/objectstorage.md")
  tags          = local.objectstorage_common_tags
  children = [
    control.objectstorage_bucket_without_lifecycle_policy
  ]
}

control "objectstorage_bucket_without_lifecycle_policy" {
  title       = "Object Storage buckets should have lifecycle policies"
  description = "Object Storage buckets should have a lifecycle policy associated for data retention."
  severity    = "low"

  sql = <<-EOT
    select
      a.id as resource,
      case
        when a.object_lifecycle_policy ->> 'items' is null then 'alarm'
        when object_lifecycle_policy -> 'items' @> '[{"isEnabled": true}]' then 'ok'
        else 'alarm'
      end as status,
      case
        when object_lifecycle_policy ->> 'items' is null then a.title || ' has no lifecycle policy.'
        when object_lifecycle_policy -> 'items' @> '[{"isEnabled": true}]' then a.title || ' has lifecycle policy.'
        else a.title || ' has disabled lifecycle policy.'
      end as reason,
      a.region,
      coalesce(c.name, 'root') as compartment
    from
      oci_objectstorage_bucket as a
      left join oci_identity_compartment as c on c.id = a.compartment_id;
  EOT

  tags = merge(local.objectstorage_common_tags, {
    class = "managed"
  })
}
