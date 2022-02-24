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
      version = "0.8.1"
    }
  }
}
