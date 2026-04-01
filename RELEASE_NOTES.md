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

