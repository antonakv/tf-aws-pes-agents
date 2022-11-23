locals {
  aws_eks_credentials_cmd = "aws eks --region ${data.terraform_remote_state.k8s-agents.outputs.region} update-kubeconfig --name ${data.terraform_remote_state.k8s-agents.outputs.friendly_name_prefix}-eks"
}

data "terraform_remote_state" "k8s-agents" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.1"

  cluster_name    = "${data.terraform_remote_state.k8s-agents.outputs.friendly_name_prefix}-eks"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = data.terraform_remote_state.k8s-agents.outputs.vpc_id
  subnet_ids = [data.terraform_remote_state.k8s-agents.outputs.subnet_private1_id, data.terraform_remote_state.k8s-agents.outputs.subnet_private2_id]

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  eks_managed_node_groups = {
    first = {
      name = "${data.terraform_remote_state.k8s-agents.outputs.friendly_name_prefix}-ng-1"

      instance_types = ["t3.large"]
      disk_size      = 50

      min_size     = 1
      max_size     = 3
      desired_size = 3

      vpc_security_group_ids = [
        data.terraform_remote_state.k8s-agents.outputs.internal_sg_id
      ]
    }
  }
}

data "aws_eks_cluster" "k8s" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.k8s.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8s.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.k8s.name
    ]
  }
}

resource "kubernetes_deployment" "tfc-agent" {
  metadata {
    name = "tfc-agent"
    labels = {
      app = "tfc-agent"

    }
  }
  spec {
    selector {
      match_labels = {
        app = "tfc-agent"
      }
    }
    replicas = var.k8s_desired_agents
    template {
      metadata {
        labels = {
          app = "tfc-agent"
        }
      }
      spec {
        container {
          image = var.tfc_agent_image
          name  = "tfc-agent"
          env {
            name  = "TFC_AGENT_TOKEN"
            value = var.agent_token
          }
          env {
            name  = "TFC_ADDRESS"
            value = "https://${data.terraform_remote_state.k8s-agents.outputs.tfe_hostname}"
          }
          env {
            name  = "TFC_AGENT_LOG_LEVEL"
            value = "trace"
          }
          resources {
            limits = {
              cpu    = "1"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
