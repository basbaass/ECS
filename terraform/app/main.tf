module "network" {
  source             = "/modules/network"
  availability_zones = var.availability_zones
}

module "security" {
  source = "/modules/security"
  vpc_id = module.network.vpc_id
}


module "alb" {
  source         = "/modules/alb"
  public_subnets = module.network.public_subnets_ids
}
