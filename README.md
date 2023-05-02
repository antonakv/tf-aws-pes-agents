# tf-aws-pes-agents
Terraform Enterprise AWS PES online with agents

This manual is dedicated to Install Terraform Enterprise with 2 agents.

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

## Preparation 

- Clone git repository

```bash
git clone https://github.com/antonakv/tf-aws-pes-agents.git
```

```bash
Cloning into 'tf-aws-pes-agents'...
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 12 (delta 1), reused 3 (delta 0), pack-reused 0
Receiving objects: 100% (12/12), done.
Resolving deltas: 100% (1/1), done.
```

- Change folder to tf-aws-pes-agents

```bash
cd tf-aws-pes-agents
```

- Create file terraform.tfvars with following contents

```
region                  = "eu-north-1"
tfe_license_path        = "upload/license.rli"
cidr_vpc                = "10.5.0.0/16"
cidr_subnet_private_1   = "10.5.1.0/24"
cidr_subnet_private_2   = "10.5.2.0/24"
cidr_subnet_public_1    = "10.5.3.0/24"
cidr_subnet_public_2    = "10.5.4.0/24"
key_name                = "your_aws_region_ssh_key_name"
aws_ami                 = "ami-createdwithpacker1"
agent_ami               = "ami-createdwithpacker2"
db_instance_type        = "db.t3.xlarge"
instance_type           = "t3.2xlarge"
instance_type_agent     = "t3.medium"
release_sequence        = 688
tfe_hostname            = "tfe.my_domain_here.com"
postgres_db_name        = "mydbtfe"
postgres_engine_version = "14.4"
postgres_username       = "postgres"
ssl_cert_path           = "/folder/folder/cert.pem"
ssl_key_path            = "/folder/folder/privkey.pem"
ssl_chain_path          = "/folder/folder/chain.pem"
ssl_fullchain_cert_path = "/folder/folder/fullchain.pem"
domain_name             = "my_domain_here.com"
cloudflare_zone_id      = "zone_id_here"
cloudflare_api_token    = "api_token_here"
lb_ssl_policy           = "ELBSecurityPolicy-2016-08"
agent_token             = "your.atlasv1.agent_token_here"
asg_min_agents          = 0
asg_max_agents          = 0
asg_desired_agents      = 0
aws_az_1                = "eu-north-1b"
aws_az_2                = "eu-north-1c"
```

- Create folder `upload`

```
mkdir upload
```

- Place license file called `license.rli` to the `upload` folder

```
cp license.rli upload
```

## Run terraform code

- Init terraform providers

```bash
terraform init
```

Sample result

```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.2.3"...
- Finding hashicorp/aws versions matching "~> 4.39.0"...
- Finding latest version of hashicorp/random...
- Finding hashicorp/template versions matching "~> 2.2.0"...
- Finding cloudflare/cloudflare versions matching "~> 3.23.0"...
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (signed by HashiCorp)
- Installing hashicorp/aws v4.39.0...
- Installed hashicorp/aws v4.39.0 (signed by HashiCorp)
- Installing hashicorp/random v3.4.3...
- Installed hashicorp/random v3.4.3 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)
- Installing cloudflare/cloudflare v3.23.0...
- Installed cloudflare/cloudflare v3.23.0 (signed by a HashiCorp partner, key ID DE413CEC881C3283)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

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
% terraform apply
data.local_sensitive_file.sslchain: Reading...
data.local_sensitive_file.sslkey: Reading...
data.local_sensitive_file.sslcert: Reading...
data.local_sensitive_file.sslkey: Read complete after 0s [id=09acb2a2afb41c06be034aec46d050cc953b0346]
data.local_sensitive_file.sslcert: Read complete after 0s [id=436bce04dafcfa281fc399e06d694b47582fad83]
data.local_sensitive_file.sslchain: Read complete after 0s [id=35bea03aecd55ca4d525c6b0a45908a19c6986f9]
data.aws_iam_policy_document.instance_role: Reading...
data.aws_iam_policy_document.tfe_asg_discovery: Reading...
data.aws_iam_policy_document.instance_role: Read complete after 0s [id=1903849331]
data.aws_iam_policy_document.tfe_asg_discovery: Read complete after 0s [id=139118870]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

[ Plan results were removed ]

random_id.internal_api_token: Creating...
random_id.registry_session_secret_key: Creating...
random_id.user_token: Creating...
random_id.root_secret: Creating...
random_id.redis_password: Creating...
random_id.install_id: Creating...
random_id.internal_api_token: Creation complete after 0s [id=u1EJpca01FKdbdZZQLcRkw]
random_string.friendly_name: Creating...
random_string.pgsql_password: Creating...
random_id.user_token: Creation complete after 0s [id=3bv2822KSVYUpmwjvjKWZA]
random_id.registry_session_secret_key: Creation complete after 0s [id=CQFtpN_DMicUmbJyV6AZUA]
random_id.registry_session_encryption_key: Creating...
random_string.password: Creating...
random_id.root_secret: Creation complete after 0s [id=wZ4gPCI8Ng6gqCeQa8l5-Q]
random_id.redis_password: Creation complete after 0s [id=lEuR7dujRJt95Lnx57pPIA]
random_id.install_id: Creation complete after 0s [id=0sElDLZeU3E6IZYDixFLYQ]
random_string.pgsql_password: Creation complete after 0s [id=mLBNOkfDJyFtNF9jYLWezIlH]
random_string.friendly_name: Creation complete after 0s [id=tmkm]
random_id.enc_password: Creating...
random_id.registry_session_encryption_key: Creation complete after 0s [id=oudbc1hvUP1GFiHitbSy9A]
random_id.archivist_token: Creating...
random_id.cookie_hash: Creating...
random_string.password: Creation complete after 0s [id=EdBRWeuSSpWx3I0v]
random_id.cookie_hash: Creation complete after 0s [id=H0-CQ4DAysegVnx-gPRTLw]
random_id.enc_password: Creation complete after 0s [id=H809PhNOY1WYNKSdCNpnJA]
random_id.archivist_token: Creation complete after 0s [id=pd2bUFKVcSx1s0JlnhAz4w]
aws_secretsmanager_secret.agent_token: Creating...
aws_secretsmanager_secret.tls_certificate: Creating...
aws_secretsmanager_secret.tls_key: Creating...
aws_vpc.vpc: Creating...
aws_secretsmanager_secret.tfe_license: Creating...
aws_iam_role.instance_role: Creating...
aws_acm_certificate.tfe: Creating...
aws_s3_bucket.tfe_data: Creating...
aws_secretsmanager_secret.tls_certificate: Creation complete after 1s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-tfe_certificate-un63UU]
aws_secretsmanager_secret.tls_key: Creation complete after 1s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-tfe_key-PzBkc0]
aws_secretsmanager_secret.agent_token: Creation complete after 1s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-agent_token-sBKS62]
aws_secretsmanager_secret_version.tls_certificate: Creating...
aws_secretsmanager_secret.tfe_license: Creation complete after 1s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-tfe_license-IDXXV1]
aws_secretsmanager_secret_version.tls_key: Creating...
aws_secretsmanager_secret_version.agent_token: Creating...
aws_secretsmanager_secret_version.tfe_license: Creating...
aws_secretsmanager_secret_version.tls_certificate: Creation complete after 0s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-tfe_certificate-un63UU|C572885D-A725-4D15-A8FC-26E6B0281B11]
aws_secretsmanager_secret_version.agent_token: Creation complete after 0s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-agent_token-sBKS62|458F91F1-AB10-4FA5-8F00-D0DB2DACF75D]
aws_secretsmanager_secret_version.tls_key: Creation complete after 0s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-tfe_key-PzBkc0|462107EA-0F15-4ED4-9A0D-543D4838E137]
aws_secretsmanager_secret_version.tfe_license: Creation complete after 0s [id=arn:aws:secretsmanager:eu-central-1:267023797923:secret:aakulov-tmkm-tfe_license-IDXXV1|0BDCFFA0-4481-4784-AE4F-024B7368E85B]
data.aws_iam_policy_document.secretsmanager: Reading...
data.aws_iam_policy_document.secretsmanager: Read complete after 0s [id=2853503168]
aws_acm_certificate.tfe: Creation complete after 1s [id=arn:aws:acm:eu-central-1:267023797923:certificate/5b17dfc6-b776-4af8-a350-0d494dbe8796]
aws_s3_bucket.tfe_data: Creation complete after 2s [id=aakulov-tmkm-tfe-data]
aws_s3_bucket_public_access_block.tfe_data: Creating...
aws_s3_bucket_acl.tfe_data: Creating...
aws_s3_bucket_versioning.tfe_data: Creating...
aws_iam_role.instance_role: Creation complete after 2s [id=aakulov-tmkm-tfe20221111151409486100000001]
aws_iam_role_policy.tfe_asg_discovery: Creating...
aws_iam_role_policy.secretsmanager: Creating...
aws_iam_instance_profile.tfe: Creating...
data.aws_iam_policy_document.tfe_data: Reading...
data.aws_iam_policy_document.tfe_data: Read complete after 0s [id=3139426674]
aws_s3_bucket_acl.tfe_data: Creation complete after 0s [id=aakulov-tmkm-tfe-data,private]
aws_s3_bucket_public_access_block.tfe_data: Creation complete after 1s [id=aakulov-tmkm-tfe-data]
aws_s3_bucket_policy.tfe_data: Creating...
aws_iam_role_policy.secretsmanager: Creation complete after 1s [id=aakulov-tmkm-tfe20221111151409486100000001:aakulov-tmkm-tfe-secretsmanager]
aws_iam_role_policy.tfe_asg_discovery: Creation complete after 1s [id=aakulov-tmkm-tfe20221111151409486100000001:aakulov-tmkm-tfe-discovery]
aws_iam_instance_profile.tfe: Creation complete after 1s [id=aakulov-tmkm-tfe20221111151411016600000002]
aws_s3_bucket_versioning.tfe_data: Creation complete after 2s [id=aakulov-tmkm-tfe-data]
aws_vpc.vpc: Still creating... [10s elapsed]
aws_s3_bucket_policy.tfe_data: Still creating... [10s elapsed]
aws_vpc.vpc: Creation complete after 13s [id=vpc-07a3f75c947ed8c11]
aws_internet_gateway.igw: Creating...
aws_subnet.subnet_public2: Creating...
aws_subnet.subnet_public1: Creating...
aws_subnet.subnet_private2: Creating...
aws_subnet.subnet_private1: Creating...
aws_vpc_endpoint.s3: Creating...
aws_security_group.lb_sg: Creating...
aws_security_group.public_sg: Creating...
aws_internet_gateway.igw: Creation complete after 0s [id=igw-065ae57d33394c45d]
aws_eip.aws_nat: Creating...
aws_route_table.public: Creating...
aws_subnet.subnet_private1: Creation complete after 1s [id=subnet-075fbb4712c126828]
aws_subnet.subnet_public2: Creation complete after 1s [id=subnet-06d929b2589de8d25]
aws_subnet.subnet_public1: Creation complete after 1s [id=subnet-05b66e472b1f3f022]
aws_subnet.subnet_private2: Creation complete after 1s [id=subnet-03bb712af0d8075ff]
aws_db_subnet_group.tfe: Creating...
aws_eip.aws_nat: Creation complete after 1s [id=eipalloc-08581f78a48580ebe]
aws_nat_gateway.nat: Creating...
aws_route_table.public: Creation complete after 1s [id=rtb-0ccd56a3efa93546b]
aws_route_table_association.public1: Creating...
aws_route_table_association.public2: Creating...
aws_route_table_association.public1: Creation complete after 1s [id=rtbassoc-029a337d80293be3e]
aws_route_table_association.public2: Creation complete after 1s [id=rtbassoc-0e9a427ffbe527e4b]
aws_db_subnet_group.tfe: Creation complete after 2s [id=aakulov-tmkm-db-subnet]
aws_security_group.public_sg: Creation complete after 3s [id=sg-0dba58c581155737e]
aws_security_group.lb_sg: Creation complete after 3s [id=sg-0486e8131787b5b7e]
aws_lb.tfe_lb: Creating...
aws_instance.ssh_jump: Creating...
aws_security_group.internal_sg: Creating...
aws_vpc_endpoint.s3: Creation complete after 6s [id=vpce-0fe042d804235fd75]
aws_security_group.internal_sg: Creation complete after 3s [id=sg-02c84de81ef5d510e]
data.aws_instances.tfe: Reading...
data.aws_instances.tfc_agent: Reading...
aws_launch_configuration.tfc_agent: Creating...
aws_db_instance.tfe: Creating...
data.aws_instances.tfc_agent: Read complete after 0s [id=eu-central-1]
data.aws_instances.tfe: Read complete after 0s [id=eu-central-1]
aws_s3_bucket_policy.tfe_data: Creation complete after 16s [id=aakulov-tmkm-tfe-data]
aws_launch_configuration.tfc_agent: Creation complete after 1s [id=aakulov-tmkm-tfc_agent-launch-configuration20221111151428080700000006]
aws_autoscaling_group.tfc_agent: Creating...
aws_autoscaling_group.tfc_agent: Creation complete after 1s [id=aakulov-tmkm-tfc_agent]
aws_nat_gateway.nat: Still creating... [10s elapsed]
aws_lb.tfe_lb: Still creating... [10s elapsed]
aws_instance.ssh_jump: Still creating... [10s elapsed]
aws_instance.ssh_jump: Creation complete after 13s [id=i-0b03479e6fc387fa9]
aws_eip.ssh_jump: Creating...
aws_db_instance.tfe: Still creating... [10s elapsed]
aws_eip.ssh_jump: Creation complete after 1s [id=eipalloc-0fe6671eb663cae31]
cloudflare_record.tfe_jump: Creating...
cloudflare_record.tfe_jump: Creation complete after 3s [id=ac4023c960ed8a65a8ebc65323b4da17]
aws_nat_gateway.nat: Still creating... [20s elapsed]
aws_lb.tfe_lb: Still creating... [20s elapsed]
aws_db_instance.tfe: Still creating... [20s elapsed]
aws_nat_gateway.nat: Still creating... [30s elapsed]
aws_lb.tfe_lb: Still creating... [30s elapsed]
aws_db_instance.tfe: Still creating... [30s elapsed]
aws_nat_gateway.nat: Still creating... [40s elapsed]
aws_lb.tfe_lb: Still creating... [40s elapsed]
aws_db_instance.tfe: Still creating... [40s elapsed]
aws_nat_gateway.nat: Still creating... [50s elapsed]
aws_lb.tfe_lb: Still creating... [50s elapsed]
aws_db_instance.tfe: Still creating... [50s elapsed]
aws_nat_gateway.nat: Still creating... [1m0s elapsed]
aws_lb.tfe_lb: Still creating... [1m0s elapsed]
aws_db_instance.tfe: Still creating... [1m0s elapsed]
aws_nat_gateway.nat: Still creating... [1m10s elapsed]
aws_lb.tfe_lb: Still creating... [1m10s elapsed]
aws_db_instance.tfe: Still creating... [1m10s elapsed]
aws_nat_gateway.nat: Still creating... [1m20s elapsed]
aws_lb.tfe_lb: Still creating... [1m20s elapsed]
aws_db_instance.tfe: Still creating... [1m20s elapsed]
aws_nat_gateway.nat: Still creating... [1m30s elapsed]
aws_lb.tfe_lb: Still creating... [1m30s elapsed]
aws_nat_gateway.nat: Creation complete after 1m35s [id=nat-08ee7e42a60b68631]
aws_route_table.private: Creating...
aws_db_instance.tfe: Still creating... [1m30s elapsed]
aws_route_table.private: Creation complete after 1s [id=rtb-0cb553f463d9a2106]
aws_route_table_association.private1: Creating...
aws_route_table_association.private2: Creating...
aws_vpc_endpoint_route_table_association.private_s3_endpoint: Creating...
aws_route_table_association.private1: Creation complete after 0s [id=rtbassoc-02cab6c0397334077]
aws_route_table_association.private2: Creation complete after 0s [id=rtbassoc-0ae1e67955b6970c4]
aws_vpc_endpoint_route_table_association.private_s3_endpoint: Creation complete after 0s [id=a-vpce-0fe042d804235fd75807009443]
aws_lb.tfe_lb: Still creating... [1m40s elapsed]
aws_db_instance.tfe: Still creating... [1m40s elapsed]
aws_lb.tfe_lb: Still creating... [1m50s elapsed]
aws_db_instance.tfe: Still creating... [1m50s elapsed]
aws_lb.tfe_lb: Still creating... [2m0s elapsed]
aws_lb.tfe_lb: Creation complete after 2m2s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:loadbalancer/app/aakulov-tmkm-tfe-app-lb/2556b5a5142ffb03]
cloudflare_record.tfe: Creating...
aws_db_instance.tfe: Still creating... [2m0s elapsed]
cloudflare_record.tfe: Creation complete after 3s [id=3ec89a50ea211103f21e972839038465]
aws_db_instance.tfe: Still creating... [2m10s elapsed]
aws_db_instance.tfe: Still creating... [2m20s elapsed]
aws_db_instance.tfe: Still creating... [2m30s elapsed]
aws_db_instance.tfe: Still creating... [2m40s elapsed]
aws_db_instance.tfe: Still creating... [2m50s elapsed]
aws_db_instance.tfe: Still creating... [3m0s elapsed]
aws_db_instance.tfe: Still creating... [3m10s elapsed]
aws_db_instance.tfe: Still creating... [3m20s elapsed]
aws_db_instance.tfe: Still creating... [3m30s elapsed]
aws_db_instance.tfe: Still creating... [3m40s elapsed]
aws_db_instance.tfe: Creation complete after 3m45s [id=terraform-20221111151428084200000007]
aws_instance.tfe: Creating...
aws_instance.tfe: Still creating... [10s elapsed]
aws_instance.tfe: Creation complete after 13s [id=i-084ff5d1ba3d0d8b0]
aws_lb_target_group.tfe_8800: Creating...
aws_lb_target_group.tfe_443: Creating...
aws_lb_target_group.tfe_443: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-tmkm-tfe-tg-443/efcdaaddef51d6d6]
aws_lb_target_group_attachment.tfe_443: Creating...
aws_lb_listener.lb_443: Creating...
aws_lb_target_group.tfe_8800: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-tmkm-tfe-tg-8800/3068c254851561cb]
aws_lb_target_group_attachment.tfe_8800: Creating...
aws_lb_listener.lb_8800: Creating...
aws_lb_target_group_attachment.tfe_443: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-tmkm-tfe-tg-443/efcdaaddef51d6d6-20221111151826697000000009]
aws_lb_target_group_attachment.tfe_8800: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-tmkm-tfe-tg-8800/3068c254851561cb-2022111115182679260000000a]
aws_lb_listener.lb_443: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/app/aakulov-tmkm-tfe-app-lb/2556b5a5142ffb03/bab1de37b77dab8a]
aws_lb_listener_rule.tfe_443: Creating...
aws_lb_listener.lb_8800: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/app/aakulov-tmkm-tfe-app-lb/2556b5a5142ffb03/0f44d11f58718f03]
aws_lb_listener_rule.tfe_8800: Creating...
aws_lb_listener_rule.tfe_443: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener-rule/app/aakulov-tmkm-tfe-app-lb/2556b5a5142ffb03/bab1de37b77dab8a/48d4a3543981c679]
aws_lb_listener_rule.tfe_8800: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener-rule/app/aakulov-tmkm-tfe-app-lb/2556b5a5142ffb03/0f44d11f58718f03/c0d54d12710ff53f]

Apply complete! Resources: 68 added, 0 changed, 0 destroyed.

Outputs:

agent_token = <sensitive>
aws_active_agents_ips = ""
aws_agent_ec2_ids = toset([])
aws_jump_hostname = "tmkmtfejump.domain.cc"
aws_jump_public_ip = "18.196.171.181"
aws_lb_active_target_group_ips = ""
aws_tfe_ec2_ids = toset([])
daemon_password = "xxxxxxxxxxxx"
friendly_name_prefix = "aakulov-tmkm"
internal_sg_id = "sg-02c84de81ef5d510e"
region = "eu-central-1"
ssh_key_name = "aakulov"
subnet_private1_id = "subnet-075fbb4712c126828"
subnet_private2_id = "subnet-03bb712af0d8075ff"
subnet_public1_id = "subnet-05b66e472b1f3f022"
subnet_public2_id = "subnet-06d929b2589de8d25"
tfe_hostname = "tmkmtfe.domain.cc"
url = "https://tmkmtfe.domain.cc/admin/account/new?token=xxxxxxxxxxxx"
vpc_id = "vpc-07a3f75c947ed8c11"

```
