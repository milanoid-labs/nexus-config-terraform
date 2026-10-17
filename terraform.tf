terraform {

  required_version = "~> 1.12"

  backend "s3" {
    bucket       = "milanoid-labs-terraform-tofu-state"
    key          = "nexus-config-terraform/terraform.tfstate"
    use_lockfile = true
    region       = "eu-central-1"
    # Locally: source ~/.config/nexus-config-terraform.env (sets AWS_PROFILE=milanoid).
    encrypt = true # to make it explicit, S3 default encryption is enabled in AWS
  }

  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

variable "nexus_url" {
  type        = string
  description = "Nexus base URL. Plain HTTP on the LAN; only homelab-runners (in-cluster) and local machines can reach it."
  default     = "http://192.168.1.204:8081"
}

variable "nexus_username" {
  type        = string
  description = "Nexus user OpenTofu authenticates as (the hand-made 'tofu' user with nx-admin). Supplied via TF_VAR_nexus_username."
  sensitive   = true
}

variable "nexus_password" {
  type        = string
  description = "Password of the 'tofu' Nexus user. Supplied via TF_VAR_nexus_password (CI: repo secret TF_VAR_NEXUS_PASSWORD)."
  sensitive   = true
}

provider "nexus" {
  url      = var.nexus_url
  username = var.nexus_username
  password = var.nexus_password
}
