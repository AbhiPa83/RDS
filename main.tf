provider "aws" {
  region = "us-east-1"
}

module "network" {
  source   = "./modules/network"
  vpc_cidr = "192.168.1.0/24"
}

module "compute" {
  source        = "./modules/compute"
  vpc_id        = module.network.vpc_id
  public_subnet = module.network.public_subnet_id
}

module "database" {
  source        = "./modules/database"
  vpc_id        = module.network.vpc_id
  db_subnet_ids = module.network.db_subnet_ids
  ec2_sg_id     = module.compute.ec2_sg_id
}
