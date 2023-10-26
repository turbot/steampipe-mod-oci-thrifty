// Benchmarks and controls for specific services should override the "service" tag
locals {
  oci_thrifty_common_tags = {
    category = "Cost"
    plugin   = "oci"
    service  = "OCI"
  }
}

variable "common_dimensions" {
  type        = list(string)
  description = "A list of common dimensions to add to each control."
  # Define which common dimensions should be added to each control.
  # - connection_name (_ctx ->> 'connection_name')
  # - region
  # - tenant_id
  default     = [ "region" ]
}

variable "tag_dimensions" {
  type        = list(string)
  description = "A list of tags to add as dimensions to each control."
  # A list of tag names to include as dimensions for resources that support
  # tags (e.g.  "Department", "Environment"). Default to empty since tag names are
  # a personal choice.
  default     = []
}

locals {

  common_dimensions_qualifier_sql = <<-EOQ
  %{~ if contains(var.common_dimensions, "connection_name") }, __QUALIFIER___ctx ->> 'connection_name'%{ endif ~}
  %{~ if contains(var.common_dimensions, "region") }, __QUALIFIER__region%{ endif ~}
  %{~ if contains(var.common_dimensions, "tenant_id") }, __QUALIFIER__tenant_id%{ endif ~}
  EOQ

  common_dimensions_qualifier_global_sql = <<-EOQ
  %{~ if contains(var.common_dimensions, "connection_name") }, __QUALIFIER___ctx ->> 'connection_name'%{ endif ~}
  %{~ if contains(var.common_dimensions, "tenant_id") }, __QUALIFIER__tenant_id%{ endif ~}
  EOQ

  tag_dimensions_qualifier_sql = <<-EOQ
  %{~ for dim in var.tag_dimensions },  __QUALIFIER__tags ->> '${dim}' as "${replace(dim, "\"", "\"\"")}"%{ endfor ~}
  EOQ

}

locals {

  # Local internal variable with the full SQL select clause for common
  # dimensions and tag dimensions. Do not edit directly.

  common_dimensions_sql = replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "")
  common_dimensions_global_sql = replace(local.common_dimensions_qualifier_global_sql, "__QUALIFIER__", "")
  tag_dimensions_sql = replace(local.tag_dimensions_qualifier_sql, "__QUALIFIER__", "")
}

mod "oci_thrifty" {
  # hub metadata
  title         = "Oracle Cloud Infrastructure Thrifty"
  description   = "Are you a Thrifty Oracle Cloud developer? This Steampipe mod checks your OCI account(s) to check for unused and under utilized resources."
  color         = "#F80000"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/oci-thrifty.svg"
  categories    = ["oci", "cost", "thrifty", "public cloud"]

  opengraph {
    title       = "Thrifty mod for Oracle Cloud Infrastructure"
    description = "Are you a Thrifty Oracle Cloud dev? This Steampipe mod checks your OCI account(s) for unused and under-utilized resources."
    image       = "/images/mods/turbot/oci-thrifty-social-graphic.png"
  }

  requires {
    plugin "oci" {
      min_version = "0.8.1"
    }
  }
}
