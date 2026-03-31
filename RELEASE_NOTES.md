# Release Notes

## Breaking Changes in v4.0.0

### Authorization Rules

The single authorization rule resource (`aws_ec2_client_vpn_authorization_rule.client_vpn_auth_rule`) has been removed in favor of a flexible multi-rule resource (`aws_ec2_client_vpn_authorization_rule.client_vpn_auth_rules`).

**What changed:**
- The `access_group_id` variable has been removed.
- A new `authorization_rules` variable accepts a list of objects, allowing multiple authorization rules per endpoint.
- Each rule must specify either `access_group_id` or `authorize_all_groups = true`, but not both.

**Default behavior:**
If `authorization_rules` is not set, the module defaults to a single rule that authorizes all groups on `0.0.0.0/0`, matching the previous default behavior.

### Migration Steps

1. Update your module source to the latest version and run `terraform init -upgrade`.

2. Replace the `access_group_id` variable with `authorization_rules`:

   **Before:**
   ```hcl
   module "client_vpn" {
     source          = "path/to/tf-module-aws-client-vpn"
     access_group_id = "your-group-id"
     # ...
   }
   ```

   **After:**
   ```hcl
   module "client_vpn" {
     source = "path/to/tf-module-aws-client-vpn"
     authorization_rules = [
       {
         target_network_cidr = "0.0.0.0/0"
         access_group_id     = "your-group-id"
       }
     ]
     # ...
   }
   ```

3. Move the Terraform state from the old resource to the new one to avoid destroying and recreating the rule:

   ```bash
   terraform state mv \
     'module.<your_module_name>.aws_ec2_client_vpn_authorization_rule.client_vpn_auth_rule[0]' \
     'module.<your_module_name>.aws_ec2_client_vpn_authorization_rule.client_vpn_auth_rules["0"]'
   ```

4. Run `terraform plan` and verify that no authorization rules are being destroyed or recreated.

### CloudWatch Log Stream

The CloudWatch Log Stream is now managed as a dedicated Terraform resource (`aws_cloudwatch_log_stream.client_vpn_logs`) instead of being implicitly created by the VPN endpoint. This resolves persistent state drift on the `connection_log_options.cloudwatch_log_stream` attribute.

**Migration note:** If upgrading an existing deployment, Terraform will attempt to create the log stream resource. Since the stream already exists (created previously by the VPN endpoint), you can import it into state:

```bash
terraform import \
  'module.<your_module_name>.aws_cloudwatch_log_stream.client_vpn_logs[0]' \
  '<log_group_name>:<stream_name>'
```

For example:
```bash
terraform import \
  'module.<your_module_name>.aws_cloudwatch_log_stream.client_vpn_logs[0]' \
  'my-client-vpn-logs:my-client-vpn-stream'
```

### Migrating from Per-Account VPNs to a Single Shared Services VPN

Previously, the module was called with `for_each` over a map of environments, creating a separate Client VPN in each workload account (dev, stage, prod). The new approach creates a single Client VPN in the shared-services account with multiple authorization rules to control access per environment.

#### Old tfvars (per-account VPNs)

```hcl
client_vpns = {
  dev = {
    enable_split_tunnel    = false
    enable_connection_logs = false
    access_group_id        = "fc..."
    client_ipv4_cidr       = "192.168.8.0/22"
    destination_cidr_block = [""]
    dns_servers            = ["10.3.0.2"]
  }
  stage = {
    enable_split_tunnel    = false
    enable_connection_logs = false
    access_group_id        = "fce..."
    client_ipv4_cidr       = "192.168.32.0/22"
    destination_cidr_block = [""]
    dns_servers            = ["10.4.0.2"]
  }
  prod = {
    enable_split_tunnel    = false
    enable_connection_logs = false
    access_group_id        = "fce..."
    client_ipv4_cidr       = "192.168.64.0/22"
    destination_cidr_block = [""]
    dns_servers            = ["10.5.0.2"]
  }
}
```

#### New tfvars (single VPN in shared-services)

The `for_each` and `client_vpns` map are no longer needed. Instead, define a single module call with all environment CIDRs as destination routes and authorization rules:

```hcl
client_vpn_name        = "shared-services-vpn"
enable_connection_logs = true
split_tunnel           = true
client_ipv4_cidr       = "192.168.8.0/22"
dns_servers            = ["10.6.0.2"] # DNS server in the shared-services VPC
destination_cidr_block = [
  "10.3.0.0/16", # dev
  "10.4.0.0/16", # stage
  "10.5.0.0/16"  # prod
]

authorization_rules = [
  {
    description         = "Allow Dev access"
    target_network_cidr = "10.3.0.0/16"
    access_group_id     = "fc..."  # Dev group from IAM Identity Center
  },
  {
    description         = "Allow Stage access"
    target_network_cidr = "10.4.0.0/16"
    access_group_id     = "fce..." # Stage group from IAM Identity Center
  },
  {
    description         = "Allow Prod access"
    target_network_cidr = "10.5.0.0/16"
    access_group_id     = "fce..." # Prod group from IAM Identity Center
  }
]
```

**Key differences:**
- No more `for_each` — a single module call replaces the per-environment map.
- `access_group_id` moves from a top-level variable into the `authorization_rules` list, allowing per-environment group control from a single VPN.
- The VPN is deployed in the shared-services account with target network associations to subnets that have connectivity (e.g. via Transit Gateway) to the workload VPCs.
