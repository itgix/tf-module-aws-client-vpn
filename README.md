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
| `identity_provider_arn` | The ARN of the IAM Identity Provider | `string` | — | yes |
| `client_ipv4_cidr` | The IPv4 CIDR block to assign to the client VPN endpoint | `string` | — | yes |
| `destination_cidr_block` | List of destination routes (see below) | `list(object)` | — | yes |
| `dns_servers` | List of DNS servers to be pushed to the VPN clients | `list(string)` | — | yes |
| `authorization_rules` | List of Objects that define authorization rules (see below) | `list(object)` | See below | no |
| `client_vpn_logs_cloudwatch_log_group_retention_in_days` | Retention period of the logs in the CloudWatch Log Group | `number` | 365 | no |

### `destination_cidr_block` Object

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cidr` | The destination CIDR block of the route | `string` | — | yes |
| `description` | A description for the route | `string` | `null` | no |

### `authorization_rules` Object

Each object in the list accepts the following attributes. Either `access_group_id` or `authorize_all_groups = true` must be set, but not both.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `target_network_cidr` | The CIDR block of the network to which the authorization rule applies | `string` | — | yes |
| `access_group_id` | The ID of the IAM Identity Center group to grant access | `string` | `null` | no |
| `authorize_all_groups` | Set to `true` to authorize all groups | `bool` | `null` | no |
| `description` | A description for the authorization rule | `string` | `null` | no |

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
  identity_provider_arn  = "arn:aws:iam::123456789012:saml-provider/my-idp"
  client_ipv4_cidr       = "10.100.0.0/16"
  destination_cidr_block = [
    {
      cidr        = "10.0.0.0/8"
      description = "Allow access to internal networks"
    }
  ]
  dns_servers            = ["10.0.0.2"]
  authorization_rules    = [
    {
      description          = "Allow access to Dev"
      target_network_cidr  = "10.3.0.0/16"
      authorize_all_groups = true // One of the `authorize_all_groups = true` or `access_group_id` should be set, but not both 
      #access_group_id      = "1234abcd-1234-12ab-ab12-abcd1234abcd" //The groups are manually created in IAM Identity Center in the Management account
    },
    {
      description          = "Allow access to Stage"
      target_network_cidr  = "10.4.0.0/16"
      #authorize_all_groups = true // One of the `authorize_all_groups = true` or `access_group_id` should be set, but not both
      access_group_id      = "5678efgh-5678-56ef-ef56-efgh5678efgh" //The groups are manually created in IAM Identity Center in the Management account
    },
    {
      description          = "Allow access to Prod"
      target_network_cidr  = "10.5.0.0/16"
      #authorize_all_groups = true // One of the `authorize_all_groups = true` or `access_group_id` should be set, but not both
      access_group_id      = "4321dcba-4321-43dc-dc43-dcba4321dcba" //The groups are manually created in IAM Identity Center in the Management account
    }
  ]

  client_vpn_logs_cloudwatch_log_group_retention_in_days = 365
}
```
