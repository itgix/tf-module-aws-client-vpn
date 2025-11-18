resource "aws_security_group" "client_vpn_sg" {
  name        = "${var.client_vpn_name}-sg"
  description = "Security group for the Client VPN endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow UDP 443 inbound from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "client_vpn_logs" {
  count = var.enable_connection_logs ? 1 : 0
  name  = "${var.client_vpn_name}-logs"
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "${var.client_vpn_name} VPN endpoint"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_ipv4_cidr
  vpc_id                 = var.vpc_id
  authentication_options {
    type                           = "federated-authentication"
    saml_provider_arn              = var.identity_provider_arn
    self_service_saml_provider_arn = var.identity_provider_arn
  }
  connection_log_options {
    enabled               = var.enable_connection_logs
    cloudwatch_log_group  = var.enable_connection_logs ? aws_cloudwatch_log_group.client_vpn_logs[0].name : null
    cloudwatch_log_stream = "${var.client_vpn_name}-stream"
  }
  dns_servers        = var.dns_servers // e.g. ["1.1.1.1", "1.0.0.1"]
  split_tunnel       = var.split_tunnel
  transport_protocol = "udp"
  vpn_port           = 443
  security_group_ids = [aws_security_group.client_vpn_sg.id]

  tags = {
    Name = "ITGix Landing Zone - ${var.client_vpn_name}"
  }

  lifecycle {
    // Terraform keeps detecting this as a state drift no matter how manny times we apply it
    ignore_changes = [
      connection_log_options[0].cloudwatch_log_stream,
    ]
  }
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association" {
  count = length(var.target_networks)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.target_networks[count.index]
}

resource "aws_ec2_client_vpn_route" "client_vpn_routes" {
  for_each = { for idx, cidr_subnet_pair in setproduct(var.destination_cidr_block, var.target_networks) : "${cidr_subnet_pair[0]}_${cidr_subnet_pair[1]}" => cidr_subnet_pair }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  destination_cidr_block = var.split_tunnel ? each.value[0] : "0.0.0.0/0"
  target_vpc_subnet_id   = each.value[1]
}

resource "aws_ec2_client_vpn_authorization_rule" "client_vpn_auth_rule" {
  count = 1

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = "0.0.0.0/0"
  access_group_id        = var.access_group_id
}
