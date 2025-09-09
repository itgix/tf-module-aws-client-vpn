The Terraform module is used by the ITGix AWS Landing Zone - https://itgix.com/itgix-landing-zone/


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.client_vpn_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ec2_client_vpn_authorization_rule.client_vpn_auth_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.client_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.client_vpn_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_route.client_vpn_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |
| [aws_security_group.client_vpn_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_group_id"></a> [access\_group\_id](#input\_access\_group\_id) | The ID of the access group for authorization rules. | `string` | n/a | yes |
| <a name="input_client_ipv4_cidr"></a> [client\_ipv4\_cidr](#input\_client\_ipv4\_cidr) | The IPv4 CIDR block to assign to the client VPN endpoint. | `string` | n/a | yes |
| <a name="input_client_vpn_name"></a> [client\_vpn\_name](#input\_client\_vpn\_name) | The name for the Client VPN endpoint. | `string` | n/a | yes |
| <a name="input_destination_cidr_block"></a> [destination\_cidr\_block](#input\_destination\_cidr\_block) | The CIDR block of the destination route. | `list(string)` | n/a | yes |
| <a name="input_enable_connection_logs"></a> [enable\_connection\_logs](#input\_enable\_connection\_logs) | Enable or disable connection logging for the VPN endpoint. | `bool` | n/a | yes |
| <a name="input_identity_provider_arn"></a> [identity\_provider\_arn](#input\_identity\_provider\_arn) | The ARN of the IAM Identity Provider. | `string` | n/a | yes |
| <a name="input_server_certificate_arn"></a> [server\_certificate\_arn](#input\_server\_certificate\_arn) | The ARN of the server certificate for the VPN endpoint. | `string` | n/a | yes |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | Enable or disable split tunneling. | `bool` | n/a | yes |
| <a name="input_target_networks"></a> [target\_networks](#input\_target\_networks) | List of subnet IDs for target network associations. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to create the Client VPN endpoint. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_vpn_endpoint_id"></a> [client\_vpn\_endpoint\_id](#output\_client\_vpn\_endpoint\_id) | The ID of the Client VPN endpoint. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group associated with the Client VPN. |
<!-- END_TF_DOCS -->
