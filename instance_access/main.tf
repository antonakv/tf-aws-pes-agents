data "terraform_remote_state" "activeactive-agents" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

data "aws_instances" "tfe" {
  instance_tags = {
    Name = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-asg-tfe"
  }
  filter {
    name   = "instance.group-id"
    values = [data.terraform_remote_state.activeactive-agents.outputs.internal_sg_id]
  }
  instance_state_names = ["running"]
}

data "aws_instances" "tfc_agent" {
  instance_tags = {
    Name = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-asg-tfc_agent"
  }
  filter {
    name   = "instance.group-id"
    values = [data.terraform_remote_state.activeactive-agents.outputs.internal_sg_id]
  }
  instance_state_names = ["running"]
}

data "aws_instance" "tfe" {
  for_each    = toset(data.aws_instances.tfe.ids)
  instance_id = each.value
}

data "aws_instance" "tfc_agent" {
  for_each    = toset(data.aws_instances.tfc_agent.ids)
  instance_id = each.value
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "aws_lb" "tfe_ssh_lb" {
  for_each           = toset(data.aws_instances.tfe.ids)
  name               = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-ssh-${replace(data.aws_instance.tfe[each.value].private_ip, ".", "-")}"
  load_balancer_type = "network"
  subnets            = [data.terraform_remote_state.activeactive-agents.outputs.subnet_public1_id, data.terraform_remote_state.activeactive-agents.outputs.subnet_public2_id]
}

resource "aws_lb_target_group" "tfe_ssh" {
  for_each = toset(data.aws_instances.tfe.ids)
  name     = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-ssh-${replace(data.aws_instance.tfe[each.value].private_ip, ".", "-")}"
  port     = 22
  protocol = "TCP"
  vpc_id   = data.terraform_remote_state.activeactive-agents.outputs.vpc_id
  health_check {
    protocol            = "TCP"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "tfe_ssh" {
  for_each          = toset(data.aws_instances.tfe.ids)
  load_balancer_arn = aws_lb.tfe_ssh_lb[each.key].arn
  port              = 22
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_ssh[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "tfe_ssh" {
  for_each         = toset(data.aws_instances.tfe.ids)
  target_group_arn = aws_lb_target_group.tfe_ssh[each.key].arn
  target_id        = each.key
  port             = 22
}


resource "aws_lb_target_group" "tfe_netdata" {
  for_each = toset(data.aws_instances.tfe.ids)
  name     = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-netdata-${replace(data.aws_instance.tfe[each.value].private_ip, ".", "-")}"
  port     = 19999
  protocol = "TCP"
  vpc_id   = data.terraform_remote_state.activeactive-agents.outputs.vpc_id
  health_check {
    protocol            = "TCP"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "tfe_netdata" {
  for_each          = toset(data.aws_instances.tfe.ids)
  load_balancer_arn = aws_lb.tfe_ssh_lb[each.key].arn
  port              = 19999
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_netdata[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "tfe_netdata" {
  for_each         = toset(data.aws_instances.tfe.ids)
  target_group_arn = aws_lb_target_group.tfe_netdata[each.key].arn
  target_id        = each.key
  port             = 19999
}


resource "cloudflare_record" "tfe_ssh" {
  for_each = toset(data.aws_instances.tfe.ids)
  zone_id  = var.cloudflare_zone_id
  name     = replace(data.aws_instance.tfe[each.value].private_ip, ".", "-")
  type     = "CNAME"
  ttl      = 1
  value    = aws_lb.tfe_ssh_lb[each.key].dns_name
}

resource "aws_lb" "tfc_agent_ssh_lb" {
  for_each           = toset(data.aws_instances.tfc_agent.ids)
  name               = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-ssh-${replace(data.aws_instance.tfc_agent[each.value].private_ip, ".", "-")}"
  load_balancer_type = "network"
  subnets            = [data.terraform_remote_state.activeactive-agents.outputs.subnet_public1_id, data.terraform_remote_state.activeactive-agents.outputs.subnet_public2_id]
}

resource "aws_lb_target_group" "tfc_agent_ssh" {
  for_each = toset(data.aws_instances.tfc_agent.ids)
  name     = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-ssh-${replace(data.aws_instance.tfc_agent[each.value].private_ip, ".", "-")}"
  port     = 22
  protocol = "TCP"
  vpc_id   = data.terraform_remote_state.activeactive-agents.outputs.vpc_id
  health_check {
    protocol            = "TCP"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "tfc_agent_ssh" {
  for_each          = toset(data.aws_instances.tfc_agent.ids)
  load_balancer_arn = aws_lb.tfc_agent_ssh_lb[each.key].arn
  port              = 22
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfc_agent_ssh[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "tfc_agent_ssh" {
  for_each         = toset(data.aws_instances.tfc_agent.ids)
  target_group_arn = aws_lb_target_group.tfc_agent_ssh[each.key].arn
  target_id        = each.key
  port             = 22
}

resource "aws_lb_target_group" "tfc_agent_netdata" {
  for_each = toset(data.aws_instances.tfc_agent.ids)
  name     = "${data.terraform_remote_state.activeactive-agents.outputs.friendly_name_prefix}-netdata-${replace(data.aws_instance.tfc_agent[each.value].private_ip, ".", "-")}"
  port     = 19999
  protocol = "TCP"
  vpc_id   = data.terraform_remote_state.activeactive-agents.outputs.vpc_id
  health_check {
    protocol            = "TCP"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "tfc_agent_netdata" {
  for_each          = toset(data.aws_instances.tfc_agent.ids)
  load_balancer_arn = aws_lb.tfc_agent_ssh_lb[each.key].arn
  port              = 19999
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfc_agent_netdata[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "tfc_agent_netdata" {
  for_each         = toset(data.aws_instances.tfc_agent.ids)
  target_group_arn = aws_lb_target_group.tfc_agent_netdata[each.key].arn
  target_id        = each.key
  port             = 19999
}

resource "cloudflare_record" "tfc_agent_ssh" {
  for_each = toset(data.aws_instances.tfc_agent.ids)
  zone_id  = var.cloudflare_zone_id
  name     = replace(data.aws_instance.tfc_agent[each.value].private_ip, ".", "-")
  type     = "CNAME"
  ttl      = 1
  value    = aws_lb.tfc_agent_ssh_lb[each.key].dns_name
}

output "ssh_agent_host_names" {
  value = {
    for k, v in cloudflare_record.tfc_agent_ssh : k => "${v.name}.${var.domain_name}"
  }
}

output "ssh_tfe_host_names" {
  value = {
    for k, v in cloudflare_record.tfe_ssh : k => "${v.name}.${var.domain_name}"
  }
}
