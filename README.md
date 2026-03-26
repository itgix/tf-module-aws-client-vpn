The Terraform module is used by the ITGix AWS Landing Zone - https://itgix.com/itgix-landing-zone/

# AWS Client VPN Terraform Module

This module creates an AWS Client VPN endpoint with SSO (IAM Identity Provider) authentication, target network associations, and authorization rules.

Part of the [ITGix AWS Landing Zone](https://itgix.com/itgix-landing-zone/).

## Resources Created

- AWS Client VPN endpoint
- Security group for the VPN endpoint
- Target network associations
- Authorization rules
- VPN routes

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `client_vpn_name` | The name for the Client VPN endpoint | `string` | — | yes |
| `server_certificate_arn` | The ARN of the server certificate for the VPN endpoint | `string` | — | yes |
| `enable_connection_logs` | Enable or disable connection logging for the VPN endpoint | `bool` | — | yes |
| `split_tunnel` | Enable or disable split tunneling | `bool` | — | yes |
| `vpc_id` | The ID of the VPC in which to create the Client VPN endpoint | `string` | — | yes |
| `target_networks` | List of subnet IDs for target network associations | `list(string)` | — | yes |
| `access_group_id` | The ID of the access group for authorization rules | `string` | — | yes |
| `identity_provider_arn` | The ARN of the IAM Identity Provider | `string` | — | yes |
| `client_ipv4_cidr` | The IPv4 CIDR block to assign to the client VPN endpoint | `string` | — | yes |
| `destination_cidr_block` | The CIDR blocks of the destination routes | `list(string)` | — | yes |
| `dns_servers` | List of DNS servers to be pushed to the VPN clients | `list(string)` | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `client_vpn_endpoint_id` | The ID of the Client VPN endpoint |
| `security_group_id` | The ID of the security group associated with the Client VPN |

## Usage Example

```hcl
module "client_vpn" {
  source = "path/to/tf-module-aws-client-vpn"

  client_vpn_name        = "my-client-vpn"
  server_certificate_arn = "arn:aws:acm:eu-central-1:123456789012:certificate/abc-123"
  enable_connection_logs = true
  split_tunnel           = true
  vpc_id                 = "vpc-0abc1234def567890"
  target_networks        = ["subnet-aaa111", "subnet-bbb222"]
  access_group_id        = "group-id-from-identity-center"
  identity_provider_arn  = "arn:aws:iam::123456789012:saml-provider/my-idp"
  client_ipv4_cidr       = "10.100.0.0/16"
  destination_cidr_block = ["10.0.0.0/8"]
  dns_servers            = ["10.0.0.2"]
}
```
