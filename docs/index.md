---
repository: "https://github.com/turbot/steampipe-mod-oci-thrifty"
---

# OCI Thrifty Mod

Be Thrifty on OCI! This mod checks for unused resources and opportunities to optimize your spend on OCI.

## References

[OCI](hhttps://www.oracle.com) is a deep and broad platform of public cloud services that enables customers to build and run a wide range of applications in a scalable, secure, highly available, and high-performance environment.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, and codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration.

## Documentation

- **[Benchmarks and controls →](https://hub.steampipe.io/mods/turbot/oci_thrifty/controls)**
- **[Named queries →](https://hub.steampipe.io/mods/turbot/oci_thrifty/queries)**

## Get started

Install the OCI plugin with [Steampipe](https://steampipe.io):
```shell
steampipe plugin install oci
```

Clone:
```sh
git clone git@github.com:turbot/steampipe-mod-oci-thrifty
cd steampipe-mod-oci-thrifty
```

Run all benchmarks:
```shell
steampipe check all
```

Run a specific control:
```shell
steampipe check control.core_instance_long_running
```

### Credentials

This mod uses the credentials configured in the [Steampipe OCI plugin](https://hub.steampipe.io/plugins/turbot/oci).

### Configuration

No extra configuration is required.

## Get involved

* Contribute: [Help wanted issues](https://github.com/turbot/steampipe-mod-oci-thrifty/labels/help%20wanted)
* Community: [Slack channel](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g)