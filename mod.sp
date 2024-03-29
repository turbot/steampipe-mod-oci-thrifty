mod "oci_thrifty" {
  # Hub metadata
  title         = "Oracle Cloud Infrastructure Thrifty"
  description   = "Are you a Thrifty Oracle Cloud developer? This mod checks your OCI account(s) to check for unused and under utilized resources using Powerpipe and Steampipe."
  color         = "#F80000"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/oci-thrifty.svg"
  categories    = ["oci", "cost", "thrifty", "public cloud"]

  opengraph {
    title       = "Powerpipe mod for Oracle Cloud Infrastructure Thrifty"
    description = "Are you a Thrifty Oracle Cloud developer? This mod checks your OCI account(s) to check for unused and under utilized resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/oci-thrifty-social-graphic.png"
  }

  requires {
    plugin "oci" {
      min_version = "0.8.1"
    }
  }
}
