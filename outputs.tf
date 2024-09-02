output "client_vpn_endpoint_id" {
  description = "The ID of the Client VPN endpoint."
  value       = aws_ec2_client_vpn_endpoint.client_vpn.id
}

output "security_group_id" {
  description = "The ID of the security group associated with the Client VPN."
  value       = aws_security_group.client_vpn_sg.id
}