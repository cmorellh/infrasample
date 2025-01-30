terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

module "infrasample" {
  source = "./modules/vpc"

  vpc_cidr             = local.vpc_cidr
  vpc_tags             = var.vpc_tags
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
}

module "db" {
  source = "./modules/db"

  infrasample_vpc_id                = module.infrasample.vpc_id
  infrasample_private_subnets       = module.infrasample.private_subnets
  infrasample_private_subnets_cidrs = local.private_subnet_cidrs

  db_az            = local.availability_zones[0]
  db_name          = "infrasampleDataDump"
  db_user_name     = var.db_user_name
  db_user_password = var.db_user_password
}

module "webserver" {
  source = "./modules/webserver"

  infrasample_vpc_id         = module.infrasample.vpc_id
  infrasample_public_subnets = module.infrasample.public_subnets
}

# Terraform Modules 