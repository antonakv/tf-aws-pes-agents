terraform {
  required_version = ">= 1.4.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}
