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

data "aws_caller_identity" "current" {}

locals {
  workload       = "awsomeapp"
  aws_account_id = data.aws_caller_identity.current.account_id
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

module "iam" {
  source         = "./modules/iam"
  workload       = local.workload
  aws_account_id = local.aws_account_id
  aws_region     = var.region
}

module "ecs" {
  source                      = "./modules/ecs"
  aws_region                  = var.region
  workload                    = local.workload
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  vpc_id                      = module.network.vpc_id
  target_group_arn            = module.lb.target_group_arn
  subnets                     = module.network.public_subnets
  repository_url              = aws_ecr_repository.main.repository_url
}

