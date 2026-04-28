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
  type        = list(string)
}

variable "dns_servers" {
  description = "List of DNS servers to be pushed to the VPN clients"
  type        = list(string)
}

variable "client_vpn_logs_cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for client VPN logs"
  type        = number
  default     = 365
}

variable "authorization_rules" {
  description = "List of authorization rules for the Client VPN endpoint. Each rule specifies a target_network_cidr and optionally an access_group_id or authorize_all_groups."
  type = list(object({
    target_network_cidr  = string
    access_group_id      = optional(string, null)
    authorize_all_groups = optional(bool, null)
    description          = optional(string, null)
  }))
  default = [{
    target_network_cidr  = "0.0.0.0/0"
    authorize_all_groups = true
  }]

  validation {
    condition = alltrue([
      for rule in var.authorization_rules :
      (rule.access_group_id != null) != (rule.authorize_all_groups == true)
    ])
    error_message = "Each authorization rule must specify either access_group_id or authorize_all_groups = true, but not both."
  }
}

variable "self_service_portal" {
  description = "Enable or disable the self-service portal for the Client VPN endpoint. Valid values: enabled, disabled."
  type        = string
  default     = "disabled"
}