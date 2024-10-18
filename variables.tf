variable "client_vpn_name" {
  description = "The name for the Client VPN endpoint."
  type        = string
}

variable "server_certificate_arn" {
  description = "The ARN of the server certificate for the VPN endpoint."
  type        = string
}

variable "enable_connection_logs" {
  description = "Enable or disable connection logging for the VPN endpoint."
  type        = bool
}

variable "split_tunnel" {
  description = "Enable or disable split tunneling."
  type        = bool
}

variable "vpc_id" {
  description = "The ID of the VPC in which to create the Client VPN endpoint."
  type        = string
}

variable "target_networks" {
  description = "List of subnet IDs for target network associations."
  type        = list(string)
}

variable "access_group_id" {
  description = "The ID of the access group for authorization rules."
  type        = string
}

variable "identity_provider_arn" {
  description = "The ARN of the IAM Identity Provider."
  type        = string
}

variable "client_ipv4_cidr" {
  description = "The IPv4 CIDR block to assign to the client VPN endpoint."
  type        = string
}

variable "destination_cidr_block" {
  description = "The CIDR block of the destination route."
  type        = string
}