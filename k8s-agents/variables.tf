variable "k8s_desired_agents" {
  type    = number
  default = 0
}
variable "tfc_agent_image" {
  type        = string
  default     = "hashicorp/tfc-agent:latest"
  description = "tfc-agent docker image"
}
variable "agent_token" {
  description = "Terraform agent token"
  default     = "not_set"
  sensitive   = true
}
