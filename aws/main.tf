terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  workload = "awsomeapp"
}

module "network" {
  source   = "./modules/network"
  workload = local.workload
  region   = var.region
}

resource "aws_ecr_repository" "main" {
  name                 = local.workload
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

module "lb" {
  source   = "./modules/lb"
  workload = local.workload
  vpc_id   = module.network.vpc_id
  subnets  = module.network.public_subnets
}
