# TeamCity Server

This module provisions a TeamCity server instance and a Postgres server on the same instance. Data
is persisted in a separate GCE disk that is protected against deletion via Terraform's lifecycle
rule.

## Prepare custom IAM role

This module support generate Let's Encrypt SSL certificate using Cloud DNS validation. It requires the service account of TeamCity server instance has permission to update DNS. You can create custom IAM role by following [this document](https://certbot-dns-google.readthedocs.io/en/stable/#credentials), or just simply set `custom_dns_editor_role_enabled = true` in your Terraform variable.

## Packer Template

You need to build a GCE image for this module to use. We provide a [Packer](http://www.packer.io/) with template in [`packer/`](packer/).

Build the image with `packer build` and provide the necessary variables. Example command:

```
packer build -var project_id=<project-id> -var zone=<zone> -var network_project_id=<network-project-id> -var subnetwork=<subnet-name> template.pkr.hcl
```

## Preparing the Data Disk

When the data disk is first created, it contains no file system and needs to be formatted.

When you first apply this module, you should apply with the
[`-target`](https://www.terraform.io/docs/commands/apply.html#target-resource) flag to only target
the disk resource `google_compute_disk.teamcity_server_data` first.

Then, create an instance using the Cloud console or `gcloud` and attach this disk to the instance.
Follow the instructions
[here](https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting) to format the
disk.

## Setting up TeamCity

When setting up TeamCity for the first time, you can provide it with the following settings for
connecting to the local Postgres server:

- URI: `postgres`
- User: `postgres`
- Password: `p@ssw0rd`
- Database: `postgres`

The local Postgres server is not accessible from outside the instance. If you prefer, you can use
your own Postgres database elsewhere.

## Server logs

In the server instance,
```
tail -f /var/log/startup-script.log
```

## Terraform

Included Terraform Module will help you provision TeamCity easily.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow\_stopping\_for\_update | f true, allows Terraform to stop the instance to update its properties. If you try to update a property that requires stopping the instance without setting this field, the update will fail. | string | `"true"` | no |
| boot\_disk\_family | Image family to search for boot disk | string | `"teamcity-server"` | no |
| boot\_disk\_image | Use this image as the boot disk instead of the default family | string | `""` | no |
| boot\_disk\_image\_project | Project containing the boot disk image if different from `project_id` | string | `""` | no |
| boot\_disk\_size\_gb | Size of the boot disk in GB | string | `"50"` | no |
| boot\_disk\_type | Type of the boot disk | string | `"pd-standard"` | no |
| data\_disk\_name | Name of the data disk | string | `"teamcity-server-data"` | no |
| data\_disk\_size | Size of the data disk in GB | string | `"100"` | no |
| data\_disk\_type | Type of the data disk to create | string | `"pd-ssd"` | no |
| description | Description for resources | string | `"TeamCity Server"` | no |
| labels | Labels of the instance | map | `<map>` | no |
| machine\_type | Machine type of the instance | string | `"n1-standard-1"` | no |
| metadata | Metadata for the instances | map | `<map>` | no |
| name | Base name of resources | string | `"teamcity-server"` | no |
| network\_ip | Static internal IP if needed | string | `""` | no |
| project\_id | Project ID for resources | string | n/a | yes |
| subnetwork |  | string | `"Subnetwork to attach the instance to"` | no |
| tags | Tags for the instance | list | `<list>` | no |
| teamcity\_image | TeamCity image to run | string | `"jetbrains/teamcity-server"` | no |
| teamcity\_memory\_options | Memory options for TeamCity. See https://confluence.jetbrains.com/display/TCD18/Installing+and+Configuring+the+TeamCity+Server#InstallingandConfiguringtheTeamCityServer-SettingUpMemorysettingsforTeamCityServer | string | `"-Xmx1024m"` | no |
| teamcity\_port | Port to expose TeamCity | string | `"80"` | no |
| teamcity\_tag | TeamCity image tag to run | string | `"2018.2.2"` | no |
| zone | Zone to launch instance in | string | n/a | yes |
| region | Default region for GCP | string | n/a | yes |
| snapshot\_days\_in\_cycle | Days between snapshots | number | 1 | no |
| snapshot\_start\_time | Time of snapshot | string | `"20:00"` | no |
| max\_retention\_days | Maximum age of the snapshot that is allowed to be kept | number | 5 | no |
| custom\_dns\_editor\_role\_enabled | Allow TeamCity server update CloudDNS to generate or renew Letsencrypt ceritificate | bool | `false` | no |
| custom\_dns\_editor\_role\_id | DNS Editor role ID | string | `"dns.editor"` | no |
| custom\_dns\_editor\_role\_title | DNS Editor role tittle | string | `"DNS Editor"` | no |
| custom\_dns\_editor\_role\_description | DNS Editor role description | string | `"DNS Editor role description"` | no |
| custom\_dns\_editor\_role\_id | DNS Editor role permission | list(string) | `["dns.changes.create", "dns.changes.get", "dns.changes.list", "dns.managedZones.list", "dns.resourceRecordSets.create", "dns.resourceRecordSets.delete", "dns.resourceRecordSets.get", "dns.resourceRecordSets.list", "dns.resourceRecordSets.update"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_self\_link | Self link of the instance |
| private\_ip | Private IP address of the instance |
| public\_ip | Private IP address of the instance |
| service\_account\_email | Email address of the service account used for the instance |
