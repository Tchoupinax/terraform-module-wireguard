# terraform-module-wireguard

![Terraform Version](https://img.shields.io/badge/terraform-≈_1.1.9-blueviolet)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.client](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.server](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.clean-local](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.configure-wireguard-server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_wireguard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [local_file.client_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.client_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.server_private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.server_public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [template_file.client_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.server_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CIDR"></a> [CIDR](#input\_CIDR) | Provide the network to use for the VPN. | `string` | `"10.42.42.42/0"` | no |
| <a name="input_clients_count"></a> [clients\_count](#input\_clients\_count) | Provide the number of client you want. | `number` | `1` | no |
| <a name="input_clients_name"></a> [clients\_name](#input\_clients\_name) | Provide the name you want for your clients. | `list(string)` | `null` | no |
| <a name="input_depends_on_"></a> [depends\_on\_](#input\_depends\_on\_) | Resource dependency of this module. | `list(string)` | `null` | no |
| <a name="input_server_ssh_ip"></a> [server\_ssh\_ip](#input\_server\_ssh\_ip) | The reachable ip on which wireguard's server will be installed. | `string` | n/a | yes |
| <a name="input_server_ssh_private_key"></a> [server\_ssh\_private\_key](#input\_server\_ssh\_private\_key) | The private ssh key to use to access the server via SSH. | `string` | n/a | yes |
| <a name="input_server_ssh_user"></a> [server\_ssh\_user](#input\_server\_ssh\_user) | The user to use to access the server via SSH. | `string` | `"root"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clients_configs"></a> [clients\_configs](#output\_clients\_configs) | The list of all generated clients |
<!-- END_TF_DOCS -->

terraform-docs markdown table --output-file README.md --output-mode inject .

qrencode -t ansiutf8 < modules/wireguard/live/client1.conf

mkdir -p /usr/local/etc/wireguard/
cp ./modules/wireguard/live/client1.conf /usr/local/etc/wireguard/wg0.conf
wg-quick up wg0
wg-quick down wg0
