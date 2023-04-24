locals {
  friendly_name_prefix = "aakulov-${random_string.friendly_name.id}"
  tfe_hostname         = "${random_string.friendly_name.id}${var.tfe_hostname}"
  replicated_config = {
    BypassPreflightChecks        = true
    DaemonAuthenticationType     = "password"
    DaemonAuthenticationPassword = random_string.password.result
    ImportSettingsFrom           = "/etc/ptfe-settings.json"
    LicenseFileLocation          = "/etc/tfe-license.rli"
    TlsBootstrapHostname         = local.tfe_hostname
    TlsBootstrapCert             = "/var/lib/tfe/certificate.pem"
    TlsBootstrapKey              = "/var/lib/tfe/key.pem"
    TlsBootstrapType             = "server-path"
    LogLevel                     = "info"
    ReleaseSequence              = var.release_sequence
  }
  # values on the tfe_config must be string with "" used
  tfe_config = {
    archivist_token = {
      value = random_id.archivist_token.hex
    }
    aws_instance_profile = {
      value = "1"
    }
    cookie_hash = {
      value = random_id.cookie_hash.hex
    }
    capacity_concurrency = {
      value = "10"
    }
    capacity_memory = {
      value = "512"
    }
    enable_active_active = {
      value = "0"
    }
    enable_metrics_collection = {
      value = "1"
    }
    enc_password = {
      value = random_id.enc_password.hex
    }
    extra_no_proxy = {
      value = join(",",
        ["127.0.0.1",
          "169.254.169.254",
          "secretsmanager.${var.region}.amazonaws.com",
          local.tfe_hostname,
        var.cidr_vpc]
      )
    }
    force_tls = {
      value = "1"
    }
    hairpin_addressing = {
      value = "0"
    }
    hostname = {
      value = local.tfe_hostname
    }
    iact_subnet_list = {
      value = "0.0.0.0/0"
    }
    iact_subnet_time_limit = {
      value = "unlimited"
    }
    install_id = {
      value = random_id.install_id.hex
    }
    internal_api_token = {
      value = random_id.internal_api_token.hex
    }
    pg_dbname = {
      value = var.postgres_db_name
    }
    pg_netloc = {
      value = aws_db_instance.tfe.endpoint
    }
    pg_password = {
      value = random_string.pgsql_password.result
    }
    pg_user = {
      value = var.postgres_username
    }
    placement = {
      value = "placement_s3"
    }
    production_type = {
      value = "external"
    }
    redis_host = {
      value = ""
    }
    redis_pass = {
      value = random_id.redis_password.hex
    }
    redis_port = {
      value = "6380"
    }
    redis_use_password_auth = {
      value = "0"
    }
    redis_use_tls = {
      value = "0"
    }
    registry_session_encryption_key = {
      value = random_id.registry_session_encryption_key.hex
    }
    registry_session_secret_key = {
      value = random_id.registry_session_secret_key.hex
    }
    root_secret = {
      value = random_id.root_secret.hex
    }
    s3_bucket = {
      value = aws_s3_bucket.tfe_data.id
    }
    s3_region = {
      value = var.region
    }
    user_token = {
      value = random_id.user_token.hex
    }
  }
  tfe_user_data = templatefile(
    "templates/installtfe.sh.tpl",
    {
      replicated_settings = base64encode(jsonencode(local.replicated_config))
      tfe_settings        = base64encode(jsonencode(local.tfe_config))
      cert_secret_id      = aws_secretsmanager_secret.tls_certificate.id
      key_secret_id       = aws_secretsmanager_secret.tls_key.id
      license_secret_id   = aws_secretsmanager_secret.tfe_license.id
      region              = var.region
      docker_config       = filebase64("files/daemon.json")
    }
  )
  tfc_agent_user_data = templatefile(
    "templates/installagent.sh.tpl",
    {
      region           = var.region
      tfcagent_service = filebase64("files/tfc-agent.service")
      agent_token_id   = aws_secretsmanager_secret.agent_token.id
      tfe_hostname     = local.tfe_hostname
    }
  )
}

data "local_sensitive_file" "sslcert" {
  filename = var.ssl_cert_path
}

data "local_sensitive_file" "sslkey" {
  filename = var.ssl_key_path
}

data "local_sensitive_file" "sslchain" {
  filename = var.ssl_chain_path
}

data "aws_instances" "tfe" {
  instance_tags = {
    Name = "${local.friendly_name_prefix}-tfe"
  }
  filter {
    name   = "instance.group-id"
    values = [aws_security_group.internal_sg.id]
  }
  instance_state_names = ["running"]
}

data "aws_instances" "tfc_agent" {
  instance_tags = {
    Name = "${local.friendly_name_prefix}-tfc_agent"
  }
  filter {
    name   = "instance.group-id"
    values = [aws_security_group.internal_sg.id]
  }
  instance_state_names = ["running"]
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "random_id" "archivist_token" {
  byte_length = 16
}

resource "random_id" "cookie_hash" {
  byte_length = 16
}

resource "random_id" "enc_password" {
  byte_length = 16
}

resource "random_id" "install_id" {
  byte_length = 16
}

resource "random_id" "internal_api_token" {
  byte_length = 16
}

resource "random_id" "root_secret" {
  byte_length = 16
}

resource "random_id" "registry_session_secret_key" {
  byte_length = 16
}

resource "random_id" "registry_session_encryption_key" {
  byte_length = 16
}

resource "random_id" "user_token" {
  byte_length = 16
}

resource "random_string" "password" {
  length  = 16
  special = false
}

data "aws_iam_policy_document" "secretsmanager" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [aws_secretsmanager_secret_version.tfe_license.secret_id, aws_secretsmanager_secret_version.tls_certificate.secret_id, aws_secretsmanager_secret_version.tls_key.secret_id, aws_secretsmanager_secret_version.agent_token.secret_id]
    sid       = "AllowSecretsManagerSecretAccess"
  }
}

resource "aws_iam_role_policy" "secretsmanager" {
  policy = data.aws_iam_policy_document.secretsmanager.json
  role   = aws_iam_role.instance_role.id
  name   = "${local.friendly_name_prefix}-tfe-secretsmanager"
}

data "aws_iam_policy_document" "tfe_asg_discovery" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:Describe*"
    ]

    resources = ["*"]
  }
}

resource "random_string" "friendly_name" {
  length  = 4
  upper   = false
  numeric = false
  special = false
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${local.friendly_name_prefix}-tfe"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

resource "aws_iam_instance_profile" "tfe" {
  name_prefix = "${local.friendly_name_prefix}-tfe"
  role        = aws_iam_role.instance_role.name
}

resource "aws_secretsmanager_secret" "tfe_license" {
  description             = "The TFE license"
  name                    = "${local.friendly_name_prefix}-tfe_license"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "tfe_license" {
  secret_binary = filebase64(var.tfe_license_path)
  secret_id     = aws_secretsmanager_secret.tfe_license.id
}

resource "aws_secretsmanager_secret" "tls_certificate" {
  description             = "TLS certificate"
  name                    = "${local.friendly_name_prefix}-tfe_certificate"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "tls_certificate" {
  secret_binary = filebase64(var.ssl_fullchain_cert_path)
  secret_id     = aws_secretsmanager_secret.tls_certificate.id
}

resource "aws_secretsmanager_secret" "tls_key" {
  description             = "TLS key"
  name                    = "${local.friendly_name_prefix}-tfe_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "tls_key" {
  secret_binary = filebase64(var.ssl_key_path)
  secret_id     = aws_secretsmanager_secret.tls_key.id
}

resource "aws_secretsmanager_secret" "agent_token" {
  description             = "TFC agent token"
  name                    = "${local.friendly_name_prefix}-agent_token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "agent_token" {
  secret_string = var.agent_token
  secret_id     = aws_secretsmanager_secret.agent_token.id
}

resource "aws_iam_role_policy" "tfe_asg_discovery" {
  name   = "${local.friendly_name_prefix}-tfe-discovery"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.tfe_asg_discovery.json
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.friendly_name_prefix}-vpc"
  }
}

resource "aws_subnet" "subnet_private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_private_1
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "subnet_private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_private_2
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "subnet_public1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_public_1
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "subnet_public2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet_public_2
  availability_zone = "eu-central-1c"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.friendly_name_prefix}-vpc"
  }
}

resource "aws_eip" "aws_nat" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.aws_nat.id
  subnet_id     = aws_subnet.subnet_public1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${local.friendly_name_prefix}-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${local.friendly_name_prefix}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.friendly_name_prefix}-public"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.subnet_private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.subnet_private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.subnet_public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.friendly_name_prefix}-lb-sg"
  tags = {
    Name = "${local.friendly_name_prefix}-lb-sg"
  }

  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow replicated admin port incoming connection"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow https port incoming connection"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ssh port incoming connection"
  }

  ingress {
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow netdata port incoming connection"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow outgoing connections"
  }
}

resource "aws_security_group" "internal_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.friendly_name_prefix}-internal-sg"
  tags = {
    Name = "${local.friendly_name_prefix}-internal-sg"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all the icmp types"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh port 22"
  }

  ingress {
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow netdata port"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow https port incoming connection"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    description     = "allow https port incoming connection from Load balancer"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
    description = "allow postgres port incoming connections"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
    description = "allow https port incoming connection"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    description     = "Allow ssh port 22 from public security group"
  }

  ingress {
    from_port       = 19999
    to_port         = 19999
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    description     = "Allow netdata port from public security group"
  }

  ingress {
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    self        = true
    description = "allow Vault HA request forwarding"
  }

  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow replicated admin port incoming connection"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing connections"
  }
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.friendly_name_prefix}-public-sg"
  tags = {
    Name = "${local.friendly_name_prefix}-public-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http port incoming connection"
  }

  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow replicated admin port incoming connection"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow https port incoming connection"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh port 22"
  }

  ingress {
    from_port   = 19999
    to_port     = 19999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow netdata port 19999"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing connections"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3_endpoint" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_s3_bucket" "tfe_data" {
  bucket        = "${local.friendly_name_prefix}-tfe-data"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "tfe_data" {
  bucket = aws_s3_bucket.tfe_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfe_data" {
  bucket = aws_s3_bucket.tfe_data.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = false
}

data "aws_iam_policy_document" "tfe_data" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    effect = "Allow"
    principals {
      identifiers = [aws_iam_role.instance_role.arn]
      type        = "AWS"
    }
    resources = [aws_s3_bucket.tfe_data.arn]
    sid       = "AllowS3ListBucketData"
  }

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    effect = "Allow"
    principals {
      identifiers = [aws_iam_role.instance_role.arn]
      type        = "AWS"
    }
    resources = ["${aws_s3_bucket.tfe_data.arn}/*"]
    sid       = "AllowS3ManagementData"
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
  role   = aws_iam_role.instance_role.id
  name   = "${local.friendly_name_prefix}-tfe-cloudwatch"
}

resource "aws_s3_bucket_policy" "tfe_data" {
  bucket = aws_s3_bucket_public_access_block.tfe_data.bucket
  policy = data.aws_iam_policy_document.tfe_data.json
}

resource "random_id" "redis_password" {
  byte_length = 16
}

resource "random_string" "pgsql_password" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "tfe" {
  name       = "${local.friendly_name_prefix}-db-subnet"
  subnet_ids = [aws_subnet.subnet_private1.id, aws_subnet.subnet_private2.id]
  tags = {
    Name = "${local.friendly_name_prefix}-db-subnet"
  }
}

resource "aws_db_instance" "tfe" {
  allocated_storage           = 20
  max_allocated_storage       = 100
  engine                      = "postgres"
  engine_version              = var.postgres_engine_version
  db_name                     = var.postgres_db_name
  username                    = var.postgres_username
  password                    = random_string.pgsql_password.result
  instance_class              = var.db_instance_type
  db_subnet_group_name        = aws_db_subnet_group.tfe.name
  vpc_security_group_ids      = [aws_security_group.internal_sg.id]
  skip_final_snapshot         = true
  allow_major_version_upgrade = true
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  deletion_protection         = false
  publicly_accessible         = false
  storage_type                = "gp2"
  port                        = 5432
  tags = {
    Name = "${local.friendly_name_prefix}-tfe-db"
  }
}

resource "aws_instance" "tfe" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  #  security_groups      = [aws_security_group.internal_sg.id]
  vpc_security_group_ids      = [aws_security_group.internal_sg.id]
  subnet_id                   = aws_subnet.subnet_private1.id
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.tfe_user_data)
  iam_instance_profile        = aws_iam_instance_profile.tfe.id
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "optional"
  }

  root_block_device {
    volume_type           = "io1"
    iops                  = 1000
    volume_size           = 60
    delete_on_termination = true
  }
  tags = {
    Name = "${local.friendly_name_prefix}-tfe"
  }
}

resource "aws_launch_configuration" "tfc_agent" {
  name_prefix   = "${local.friendly_name_prefix}-tfc_agent-launch-configuration"
  image_id      = var.agent_ami
  instance_type = var.instance_type_agent

  user_data_base64 = base64encode(local.tfc_agent_user_data)

  iam_instance_profile = aws_iam_instance_profile.tfe.name
  key_name             = var.key_name
  security_groups      = [aws_security_group.internal_sg.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "optional"
  }

  root_block_device {
    volume_type           = "io1"
    iops                  = 1000
    volume_size           = 40
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tfc_agent" {
  name                      = "${local.friendly_name_prefix}-tfc_agent"
  min_size                  = var.asg_min_agents
  max_size                  = var.asg_max_agents
  desired_capacity          = var.asg_desired_agents
  vpc_zone_identifier       = [aws_subnet.subnet_private1.id, aws_subnet.subnet_private2.id]
  health_check_grace_period = 900
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.tfc_agent.name
  tag {
    key                 = "Name"
    value               = "${local.friendly_name_prefix}-tfc_agent"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "tfe_lb" {
  name                       = "${local.friendly_name_prefix}-tfe-app-lb"
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.subnet_public1.id, aws_subnet.subnet_public2.id]
  security_groups            = [aws_security_group.lb_sg.id]
  enable_deletion_protection = false
  enable_http2               = false
}

resource "aws_lb_target_group" "tfe_443" {
  name        = "${local.friendly_name_prefix}-tfe-tg-443"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.vpc.id
  slow_start  = 900
  target_type = "instance"
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    path                = "/_health_check"
    protocol            = "HTTPS"
    matcher             = "200-399"
  }
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
  depends_on = [
    aws_instance.tfe
  ]
}

resource "aws_lb_target_group" "tfe_8800" {
  name        = "${local.friendly_name_prefix}-tfe-tg-8800"
  port        = 8800
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.vpc.id
  slow_start  = 900
  target_type = "instance"
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200-399"
  }
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
  depends_on = [
    aws_instance.tfe
  ]
}

resource "aws_acm_certificate" "tfe" {
  private_key       = data.local_sensitive_file.sslkey.content
  certificate_body  = data.local_sensitive_file.sslcert.content
  certificate_chain = data.local_sensitive_file.sslchain.content
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "lb_443" {
  load_balancer_arn = aws_lb.tfe_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.lb_ssl_policy
  certificate_arn   = aws_acm_certificate.tfe.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_443.arn
  }
}

resource "aws_lb_listener" "lb_8800" {
  load_balancer_arn = aws_lb.tfe_lb.arn
  port              = 8800
  protocol          = "HTTPS"
  ssl_policy        = var.lb_ssl_policy
  certificate_arn   = aws_acm_certificate.tfe.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_8800.arn
  }
}

resource "aws_lb_listener_rule" "tfe_8800" {
  listener_arn = aws_lb_listener.lb_8800.arn
  condition {
    host_header {
      values = [local.tfe_hostname]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_8800.arn
  }
}

resource "aws_lb_listener_rule" "tfe_443" {
  listener_arn = aws_lb_listener.lb_443.arn
  condition {
    host_header {
      values = [local.tfe_hostname]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_443.arn
  }
}

resource "aws_lb_target_group_attachment" "tfe_443" {
  target_group_arn = aws_lb_target_group.tfe_443.arn
  target_id        = aws_instance.tfe.id
  port             = 443
  depends_on = [
    aws_instance.tfe
  ]
}

resource "aws_lb_target_group_attachment" "tfe_8800" {
  target_group_arn = aws_lb_target_group.tfe_8800.arn
  target_id        = aws_instance.tfe.id
  port             = 8800
  depends_on = [
    aws_instance.tfe
  ]
}

resource "cloudflare_record" "tfe" {
  zone_id = var.cloudflare_zone_id
  name    = local.tfe_hostname
  type    = "CNAME"
  ttl     = 1
  value   = aws_lb.tfe_lb.dns_name
}
