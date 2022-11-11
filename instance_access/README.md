# tf-aws-activeactive-agents instance_access

This manual is dedicated to Forward ssh and netdata ports to TFE and TFE agent instances
using AWS Network Load Balancer.

## Requirements

- Hashicorp terraform recent version installed
[Terraform installation manual](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- git installed
[Git installation manual](https://git-scm.com/download/mac)

- Amazon AWS account credentials saved in .aws/credentials file
[Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

- Configured CloudFlare DNS zone for domain `my-domain-here.com`
[Cloudflare DNS zone setup](https://developers.cloudflare.com/dns/zone-setups/full-setup/setup/)

- SSL certificate and SSL key files for the corresponding domain name
[Certbot manual](https://certbot.eff.org/instructions)

- Created Amazon EC2 key pair for Linux instance
[Creating a public hosted zone](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

- Provisioned with github.com/antonakv/tf-aws-activeactive-agents Terraform Enterprise active-active
[https://github.com/antonakv/tf-aws-activeactive-agents](https://github.com/antonakv/tf-aws-activeactive-agents.git)

## Preparation 

- Change folder to tf-aws-activeactive-agents

```bash
cd instance_access
```

- Create file terraform.tfvars with following contents

```
region                  = "eu-central-1"
ssl_cert_path           = "/letsencrypt-ssl-cert/config/live/domain.cc/cert.pem"
ssl_key_path            = "/letsencrypt-ssl-cert/config/live/domain.cc/privkey.pem"
ssl_chain_path          = "/letsencrypt-ssl-cert/config/live/domain.cc/chain.pem"
ssl_fullchain_cert_path = "/letsencrypt-ssl-cert/config/live/domain.cc/fullchain.pem"
domain_name             = "domain.cc"
cloudflare_zone_id      = "xxxxxxxxxxxxxxxx"
cloudflare_api_token    = "xxxxxxxxxxxxxxxx"
lb_ssl_policy           = "ELBSecurityPolicy-2016-08"
```

## Run terraform code

- In the same folder you were before, run 

```bash
terraform init
```

Sample result

```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.52"...
- Finding hashicorp/tls versions matching "~> 3.1.0"...
- Finding hashicorp/template versions matching "~> 2.2.0"...
- Installing hashicorp/aws v3.66.0...
- Installed hashicorp/aws v3.66.0 (signed by HashiCorp)
- Installing hashicorp/tls v3.1.0...
- Installed hashicorp/tls v3.1.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

- Run the `terraform apply`

Expected result:

```
instance_access % terraform apply  --auto-approve  
data.terraform_remote_state.activeactive-agents: Reading...
data.terraform_remote_state.activeactive-agents: Read complete after 0s
data.aws_instances.tfe: Reading...
data.aws_instances.tfc_agent: Reading...
data.aws_instance.tfc_agent["i-09dd898af0a43233b"]: Reading...
data.aws_instance.tfc_agent["i-00aa4638c1a27fda3"]: Reading...
data.aws_instance.tfe["i-0873f751b1ae11ec6"]: Reading...
data.aws_instance.tfe["i-0fdcd8868d5dc5351"]: Reading...
data.aws_instances.tfc_agent: Read complete after 0s [id=eu-central-1]
data.aws_instances.tfe: Read complete after 0s [id=eu-central-1]
data.aws_instance.tfe["i-0fdcd8868d5dc5351"]: Read complete after 1s [id=i-0fdcd8868d5dc5351]
data.aws_instance.tfc_agent["i-00aa4638c1a27fda3"]: Read complete after 1s [id=i-00aa4638c1a27fda3]
data.aws_instance.tfe["i-0873f751b1ae11ec6"]: Read complete after 1s [id=i-0873f751b1ae11ec6]
data.aws_instance.tfc_agent["i-09dd898af0a43233b"]: Read complete after 1s [id=i-09dd898af0a43233b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb" "tfc_agent_ssh_lb" {
      + arn                              = (known after apply)
      + arn_suffix                       = (known after apply)
      + dns_name                         = (known after apply)
      + enable_cross_zone_load_balancing = false
      + enable_deletion_protection       = false
      + id                               = (known after apply)
      + internal                         = (known after apply)
      + ip_address_type                  = (known after apply)
      + load_balancer_type               = "network"
      + name                             = "aakulov-pctm-ssh-10-5-2-247"
      + security_groups                  = (known after apply)
      + subnets                          = [
          + "subnet-04e42bf486262680f",
          + "subnet-0ac460b1e59fadb77",
        ]
      + tags_all                         = (known after apply)
      + vpc_id                           = (known after apply)
      + zone_id                          = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"] will be created
  + resource "aws_lb" "tfc_agent_ssh_lb" {
      + arn                              = (known after apply)
      + arn_suffix                       = (known after apply)
      + dns_name                         = (known after apply)
      + enable_cross_zone_load_balancing = false
      + enable_deletion_protection       = false
      + id                               = (known after apply)
      + internal                         = (known after apply)
      + ip_address_type                  = (known after apply)
      + load_balancer_type               = "network"
      + name                             = "aakulov-pctm-ssh-10-5-1-121"
      + security_groups                  = (known after apply)
      + subnets                          = [
          + "subnet-04e42bf486262680f",
          + "subnet-0ac460b1e59fadb77",
        ]
      + tags_all                         = (known after apply)
      + vpc_id                           = (known after apply)
      + zone_id                          = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb" "tfe_ssh_lb" {
      + arn                              = (known after apply)
      + arn_suffix                       = (known after apply)
      + dns_name                         = (known after apply)
      + enable_cross_zone_load_balancing = false
      + enable_deletion_protection       = false
      + id                               = (known after apply)
      + internal                         = (known after apply)
      + ip_address_type                  = (known after apply)
      + load_balancer_type               = "network"
      + name                             = "aakulov-pctm-ssh-10-5-1-152"
      + security_groups                  = (known after apply)
      + subnets                          = [
          + "subnet-04e42bf486262680f",
          + "subnet-0ac460b1e59fadb77",
        ]
      + tags_all                         = (known after apply)
      + vpc_id                           = (known after apply)
      + zone_id                          = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb" "tfe_ssh_lb" {
      + arn                              = (known after apply)
      + arn_suffix                       = (known after apply)
      + dns_name                         = (known after apply)
      + enable_cross_zone_load_balancing = false
      + enable_deletion_protection       = false
      + id                               = (known after apply)
      + internal                         = (known after apply)
      + ip_address_type                  = (known after apply)
      + load_balancer_type               = "network"
      + name                             = "aakulov-pctm-ssh-10-5-2-79"
      + security_groups                  = (known after apply)
      + subnets                          = [
          + "subnet-04e42bf486262680f",
          + "subnet-0ac460b1e59fadb77",
        ]
      + tags_all                         = (known after apply)
      + vpc_id                           = (known after apply)
      + zone_id                          = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # aws_lb_listener.tfc_agent_netdata["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb_listener" "tfc_agent_netdata" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 19999
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfc_agent_netdata["i-09dd898af0a43233b"] will be created
  + resource "aws_lb_listener" "tfc_agent_netdata" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 19999
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfc_agent_ssh["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb_listener" "tfc_agent_ssh" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 22
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfc_agent_ssh["i-09dd898af0a43233b"] will be created
  + resource "aws_lb_listener" "tfc_agent_ssh" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 22
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfe_netdata["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb_listener" "tfe_netdata" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 19999
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfe_netdata["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb_listener" "tfe_netdata" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 19999
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfe_ssh["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb_listener" "tfe_ssh" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 22
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.tfe_ssh["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb_listener" "tfe_ssh" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 22
      + protocol          = "TCP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_target_group.tfc_agent_netdata["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb_target_group" "tfc_agent_netdata" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-netdata-10-5-2-247"
      + port                               = 19999
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfc_agent_netdata["i-09dd898af0a43233b"] will be created
  + resource "aws_lb_target_group" "tfc_agent_netdata" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-netdata-10-5-1-121"
      + port                               = 19999
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfc_agent_ssh["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb_target_group" "tfc_agent_ssh" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-ssh-10-5-2-247"
      + port                               = 22
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfc_agent_ssh["i-09dd898af0a43233b"] will be created
  + resource "aws_lb_target_group" "tfc_agent_ssh" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-ssh-10-5-1-121"
      + port                               = 22
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfe_netdata["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb_target_group" "tfe_netdata" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-netdata-10-5-1-152"
      + port                               = 19999
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfe_netdata["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb_target_group" "tfe_netdata" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-netdata-10-5-2-79"
      + port                               = 19999
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfe_ssh["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb_target_group" "tfe_ssh" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-ssh-10-5-1-152"
      + port                               = 22
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group.tfe_ssh["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb_target_group" "tfe_ssh" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-pctm-ssh-10-5-2-79"
      + port                               = 22
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "TCP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-09313fbbd8f99f074"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = "traffic-port"
          + protocol            = "TCP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # aws_lb_target_group_attachment.tfc_agent_netdata["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb_target_group_attachment" "tfc_agent_netdata" {
      + id               = (known after apply)
      + port             = 19999
      + target_group_arn = (known after apply)
      + target_id        = "i-00aa4638c1a27fda3"
    }

  # aws_lb_target_group_attachment.tfc_agent_netdata["i-09dd898af0a43233b"] will be created
  + resource "aws_lb_target_group_attachment" "tfc_agent_netdata" {
      + id               = (known after apply)
      + port             = 19999
      + target_group_arn = (known after apply)
      + target_id        = "i-09dd898af0a43233b"
    }

  # aws_lb_target_group_attachment.tfc_agent_ssh["i-00aa4638c1a27fda3"] will be created
  + resource "aws_lb_target_group_attachment" "tfc_agent_ssh" {
      + id               = (known after apply)
      + port             = 22
      + target_group_arn = (known after apply)
      + target_id        = "i-00aa4638c1a27fda3"
    }

  # aws_lb_target_group_attachment.tfc_agent_ssh["i-09dd898af0a43233b"] will be created
  + resource "aws_lb_target_group_attachment" "tfc_agent_ssh" {
      + id               = (known after apply)
      + port             = 22
      + target_group_arn = (known after apply)
      + target_id        = "i-09dd898af0a43233b"
    }

  # aws_lb_target_group_attachment.tfe_netdata["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb_target_group_attachment" "tfe_netdata" {
      + id               = (known after apply)
      + port             = 19999
      + target_group_arn = (known after apply)
      + target_id        = "i-0873f751b1ae11ec6"
    }

  # aws_lb_target_group_attachment.tfe_netdata["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb_target_group_attachment" "tfe_netdata" {
      + id               = (known after apply)
      + port             = 19999
      + target_group_arn = (known after apply)
      + target_id        = "i-0fdcd8868d5dc5351"
    }

  # aws_lb_target_group_attachment.tfe_ssh["i-0873f751b1ae11ec6"] will be created
  + resource "aws_lb_target_group_attachment" "tfe_ssh" {
      + id               = (known after apply)
      + port             = 22
      + target_group_arn = (known after apply)
      + target_id        = "i-0873f751b1ae11ec6"
    }

  # aws_lb_target_group_attachment.tfe_ssh["i-0fdcd8868d5dc5351"] will be created
  + resource "aws_lb_target_group_attachment" "tfe_ssh" {
      + id               = (known after apply)
      + port             = 22
      + target_group_arn = (known after apply)
      + target_id        = "i-0fdcd8868d5dc5351"
    }

  # cloudflare_record.tfc_agent_ssh["i-00aa4638c1a27fda3"] will be created
  + resource "cloudflare_record" "tfc_agent_ssh" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "10-5-2-247"
      + proxiable       = (known after apply)
      + ttl             = 1
      + type            = "CNAME"
      + value           = (known after apply)
      + zone_id         = "36b3ef5080f2c6f91e5136854e9f29fb"
    }

  # cloudflare_record.tfc_agent_ssh["i-09dd898af0a43233b"] will be created
  + resource "cloudflare_record" "tfc_agent_ssh" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "10-5-1-121"
      + proxiable       = (known after apply)
      + ttl             = 1
      + type            = "CNAME"
      + value           = (known after apply)
      + zone_id         = "36b3ef5080f2c6f91e5136854e9f29fb"
    }

  # cloudflare_record.tfe_ssh["i-0873f751b1ae11ec6"] will be created
  + resource "cloudflare_record" "tfe_ssh" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "10-5-1-152"
      + proxiable       = (known after apply)
      + ttl             = 1
      + type            = "CNAME"
      + value           = (known after apply)
      + zone_id         = "36b3ef5080f2c6f91e5136854e9f29fb"
    }

  # cloudflare_record.tfe_ssh["i-0fdcd8868d5dc5351"] will be created
  + resource "cloudflare_record" "tfe_ssh" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "10-5-2-79"
      + proxiable       = (known after apply)
      + ttl             = 1
      + type            = "CNAME"
      + value           = (known after apply)
      + zone_id         = "36b3ef5080f2c6f91e5136854e9f29fb"
    }

Plan: 32 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ssh_agent_host_names = {
      + i-00aa4638c1a27fda3 = "10-5-2-247.akulov.cc"
      + i-09dd898af0a43233b = "10-5-1-121.akulov.cc"
    }
  + ssh_tfe_host_names   = {
      + i-0873f751b1ae11ec6 = "10-5-1-152.akulov.cc"
      + i-0fdcd8868d5dc5351 = "10-5-2-79.akulov.cc"
    }
aws_lb_target_group.tfe_netdata["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_target_group.tfe_ssh["i-0fdcd8868d5dc5351"]: Creating...
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Creating...
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Creating...
aws_lb_target_group.tfe_ssh["i-0873f751b1ae11ec6"]: Creating...
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_target_group.tfc_agent_ssh["i-09dd898af0a43233b"]: Creating...
aws_lb_target_group.tfc_agent_netdata["i-09dd898af0a43233b"]: Creating...
aws_lb_target_group.tfc_agent_netdata["i-00aa4638c1a27fda3"]: Creating...
aws_lb_target_group.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creating...
aws_lb_target_group.tfe_ssh["i-0fdcd8868d5dc5351"]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-2-79/dc0f95ef87369c9b]
aws_lb_target_group.tfe_netdata["i-0873f751b1ae11ec6"]: Creating...
aws_lb_target_group.tfc_agent_netdata["i-00aa4638c1a27fda3"]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-netdata-10-5-2-247/81db9e9725f40aa8]
aws_lb_target_group.tfe_ssh["i-0873f751b1ae11ec6"]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-1-152/e9322a4010762f43]
aws_lb_target_group_attachment.tfe_ssh["i-0873f751b1ae11ec6"]: Creating...
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Creating...
aws_lb_target_group.tfc_agent_netdata["i-09dd898af0a43233b"]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-netdata-10-5-1-121/90d7b40ca02768b3]
aws_lb_target_group_attachment.tfe_netdata["i-0873f751b1ae11ec6"]: Creating...
aws_lb_target_group_attachment.tfe_ssh["i-0873f751b1ae11ec6"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-1-152/e9322a4010762f43-20220907083122167900000001]
aws_lb_target_group_attachment.tfe_netdata["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_target_group_attachment.tfe_netdata["i-0873f751b1ae11ec6"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-1-152/e9322a4010762f43-20220907083122212200000002]
aws_lb_target_group.tfe_netdata["i-0fdcd8868d5dc5351"]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-netdata-10-5-2-79/158db62e519ccd71]
aws_lb_target_group_attachment.tfe_ssh["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_target_group_attachment.tfe_netdata["i-0fdcd8868d5dc5351"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-2-79/dc0f95ef87369c9b-20220907083122272800000003]
aws_lb_target_group_attachment.tfe_ssh["i-0fdcd8868d5dc5351"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-2-79/dc0f95ef87369c9b-20220907083122381800000004]
aws_lb_target_group.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-2-247/9dc7f58b2e4644b4]
aws_lb_target_group.tfe_netdata["i-0873f751b1ae11ec6"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-netdata-10-5-1-152/3836988eff852dd9]
aws_lb_target_group.tfc_agent_ssh["i-09dd898af0a43233b"]: Creation complete after 3s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-1-121/5811fcb7cbceae9d]
aws_lb_target_group_attachment.tfc_agent_netdata["i-00aa4638c1a27fda3"]: Creating...
aws_lb_target_group_attachment.tfc_agent_ssh["i-09dd898af0a43233b"]: Creating...
aws_lb_target_group_attachment.tfc_agent_netdata["i-09dd898af0a43233b"]: Creating...
aws_lb_target_group_attachment.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creating...
aws_lb_target_group_attachment.tfc_agent_ssh["i-09dd898af0a43233b"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-1-121/5811fcb7cbceae9d-20220907083123752300000005]
aws_lb_target_group_attachment.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-2-247/9dc7f58b2e4644b4-20220907083123758200000006]
aws_lb_target_group_attachment.tfc_agent_netdata["i-09dd898af0a43233b"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-1-121/5811fcb7cbceae9d-20220907083123803100000007]
aws_lb_target_group_attachment.tfc_agent_netdata["i-00aa4638c1a27fda3"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-pctm-ssh-10-5-2-247/9dc7f58b2e4644b4-20220907083123819000000008]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [10s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [10s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [20s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [20s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [30s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [30s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [30s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [30s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [40s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [40s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [40s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [40s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [50s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [50s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [50s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [50s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [1m0s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [1m0s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [1m0s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [1m0s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [1m10s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [1m10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [1m10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [1m10s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [1m20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [1m20s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [1m20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [1m20s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [1m30s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [1m30s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [1m30s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [1m30s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [1m40s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [1m40s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [1m40s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [1m40s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [1m50s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [1m50s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [1m50s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [1m50s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [2m0s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [2m0s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [2m0s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [2m0s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [2m10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [2m10s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [2m10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [2m10s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [2m20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [2m20s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [2m20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [2m20s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Still creating... [2m30s elapsed]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [2m30s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [2m30s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [2m30s elapsed]
aws_lb.tfc_agent_ssh_lb["i-09dd898af0a43233b"]: Creation complete after 2m32s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:loadbalancer/net/aakulov-pctm-ssh-10-5-1-121/dbcf025d5ffa3bd1]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Still creating... [2m40s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Still creating... [2m40s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [2m40s elapsed]
aws_lb.tfe_ssh_lb["i-0873f751b1ae11ec6"]: Creation complete after 2m42s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:loadbalancer/net/aakulov-pctm-ssh-10-5-1-152/2718b37800a511cb]
aws_lb.tfe_ssh_lb["i-0fdcd8868d5dc5351"]: Creation complete after 2m42s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:loadbalancer/net/aakulov-pctm-ssh-10-5-2-79/0d8b94a9b3c44e01]
cloudflare_record.tfe_ssh["i-0873f751b1ae11ec6"]: Creating...
cloudflare_record.tfe_ssh["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_listener.tfe_netdata["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_listener.tfe_ssh["i-0fdcd8868d5dc5351"]: Creating...
aws_lb_listener.tfe_netdata["i-0873f751b1ae11ec6"]: Creating...
aws_lb_listener.tfe_ssh["i-0873f751b1ae11ec6"]: Creating...
aws_lb_listener.tfe_ssh["i-0fdcd8868d5dc5351"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-2-79/0d8b94a9b3c44e01/9098635fdf36554a]
aws_lb_listener.tfe_netdata["i-0fdcd8868d5dc5351"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-2-79/0d8b94a9b3c44e01/43222dfd71002af5]
aws_lb_listener.tfe_netdata["i-0873f751b1ae11ec6"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-1-152/2718b37800a511cb/a8f535d24757e1fe]
aws_lb_listener.tfe_ssh["i-0873f751b1ae11ec6"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-1-152/2718b37800a511cb/aae17f45fa74a675]
cloudflare_record.tfe_ssh["i-0873f751b1ae11ec6"]: Creation complete after 2s [id=b85520aecedc84dfe5741191dbb4de7b]
cloudflare_record.tfe_ssh["i-0fdcd8868d5dc5351"]: Creation complete after 2s [id=71fff8cecb36221af53d546926304350]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [2m50s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [3m0s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Still creating... [3m10s elapsed]
aws_lb.tfc_agent_ssh_lb["i-00aa4638c1a27fda3"]: Creation complete after 3m12s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:loadbalancer/net/aakulov-pctm-ssh-10-5-2-247/175ff8cdb9cbe3e6]
cloudflare_record.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creating...
cloudflare_record.tfc_agent_ssh["i-09dd898af0a43233b"]: Creating...
aws_lb_listener.tfc_agent_ssh["i-09dd898af0a43233b"]: Creating...
aws_lb_listener.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creating...
aws_lb_listener.tfc_agent_netdata["i-00aa4638c1a27fda3"]: Creating...
aws_lb_listener.tfc_agent_netdata["i-09dd898af0a43233b"]: Creating...
aws_lb_listener.tfc_agent_netdata["i-09dd898af0a43233b"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-1-121/dbcf025d5ffa3bd1/03ff3d1525ea9d67]
aws_lb_listener.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-2-247/175ff8cdb9cbe3e6/4f4fe6a347295bbb]
aws_lb_listener.tfc_agent_ssh["i-09dd898af0a43233b"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-1-121/dbcf025d5ffa3bd1/7fbf1a8dd8e39d3d]
aws_lb_listener.tfc_agent_netdata["i-00aa4638c1a27fda3"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/net/aakulov-pctm-ssh-10-5-2-247/175ff8cdb9cbe3e6/e5f3d501dfead15d]
cloudflare_record.tfc_agent_ssh["i-00aa4638c1a27fda3"]: Creation complete after 1s [id=5baa09eff3bbf2673e0193b61428baeb]
cloudflare_record.tfc_agent_ssh["i-09dd898af0a43233b"]: Creation complete after 2s [id=3f5e22d6b46d34e7ea7c452991fd3a55]

Apply complete! Resources: 32 added, 0 changed, 0 destroyed.

Outputs:

ssh_agent_host_names = {
  "i-00aa4638c1a27fda3" = "10-5-2-247.akulov.cc"
  "i-09dd898af0a43233b" = "10-5-1-121.akulov.cc"
}
ssh_tfe_host_names = {
  "i-0873f751b1ae11ec6" = "10-5-1-152.akulov.cc"
  "i-0fdcd8868d5dc5351" = "10-5-2-79.akulov.cc"
}
```
