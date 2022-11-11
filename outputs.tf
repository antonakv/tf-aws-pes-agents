output "aws_jump_hostname" {
  value       = cloudflare_record.tfe_jump.name
  description = "SSH jump hostname"
}
output "aws_jump_public_ip" {
  value       = aws_instance.ssh_jump.public_ip
  description = "SSH jump public ip"
}
output "url" {
  value       = "https://${local.tfe_hostname}/admin/account/new?token=${random_id.user_token.hex}"
  description = "Login URL and token"
}
output "tfe_hostname" {
  value       = local.tfe_hostname
  description = "TFE fqdn"
}
output "ssh_key_name" {
  value       = var.key_name
  description = "SSH key name"
}
output "aws_lb_active_target_group_ips" {
  value       = join(", ", data.aws_instances.tfe.private_ips)
  description = "TFE EC2 hosts in the AWS LB target group"
}
output "aws_active_agents_ips" {
  value       = join(", ", data.aws_instances.tfc_agent.private_ips)
  description = "Agent hosts in the autoscaling group"
}
output "aws_tfe_ec2_ids" {
  value       = toset(data.aws_instances.tfe.ids)
  description = "TFE EC2 host ids"
}
output "aws_agent_ec2_ids" {
  value       = toset(data.aws_instances.tfc_agent.ids)
  description = "Agent EC2 host ids"
}
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID of aws vpc"
}
output "internal_sg_id" {
  value       = aws_security_group.internal_sg.id
  description = "ID of internal security group"
}
output "friendly_name_prefix" {
  value       = local.friendly_name_prefix
  description = "Friendly name prefix"
}
output "subnet_public1_id" {
  value       = aws_subnet.subnet_public1.id
  description = "ID of aws public subnet 1"
}
output "subnet_public2_id" {
  value       = aws_subnet.subnet_public2.id
  description = "ID of aws public subnet 2"
}
output "subnet_private1_id" {
  value       = aws_subnet.subnet_private1.id
  description = "ID of aws private subnet 1"
}
output "subnet_private2_id" {
  value       = aws_subnet.subnet_private2.id
  description = "ID of aws private subnet 2"
}
output "region" {
  value       = var.region
  description = "AWS region"
}
output "agent_token" {
  value       = var.agent_token
  description = "Agent token"
  sensitive   = true
}
