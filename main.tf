provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "nice-dcv-sample-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}c"]
  public_subnets  = var.public_subnets_cidr
  private_subnets = var.private_subnets_cidr

  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
}

module "ad" {
  source         = "./modules/ad"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnets
  domain_name    = var.domain_name
  admin_password = var.admin_password
}

module "fsx" {
  source              = "./modules/fsx"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  active_directory_id = module.ad.active_directory_id
  storage_capacity    = var.fsx_storage_capacity
  throughput_capacity = var.fsx_throughput_capacity
}

module "windows" {
  source                   = "./modules/windows"
  vpc                      = module.vpc
  instance_type            = var.windows_instance_type
  ami_id                   = var.windows_ami_id
  allowed_cidr             = var.allowed_cidr
  security_group_ids       = [module.fsx.security_group_id]
  domain_join_ssm_document = module.ad.domain_join_ssm_document
}
