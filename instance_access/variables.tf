variable "region" {
  type        = string
  description = "AWS region"
}
variable "domain_name" {
  type        = string
  description = "Domain name"
}
variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare DNS zone id"
  sensitive   = true
}
variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare DNS API token"
  sensitive   = true
}
variable "ssl_cert_path" {
  type        = string
  description = "SSL certificate file path"
}
variable "ssl_fullchain_cert_path" {
  type        = string
  description = "SSL fullchain cert file path"
}
variable "ssl_key_path" {
  type        = string
  description = "SSL key file path"
}
variable "ssl_chain_path" {
  type        = string
  description = "SSL chain file path"
}
variable "lb_ssl_policy" {
  type        = string
  description = "SSL policy for load balancer"
}

