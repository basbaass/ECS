module "network" {
  source             = "./modules/network"
  availability_zones = var.availability_zones
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}


module "alb" {
  source             = "./modules/alb"
  public_subnets_ids = module.network.public_subnets_ids
  alb_sg_ids         = module.security.alb_security_group
  vpc_id             = module.network.vpc_id
  domain_name        = var.domain_name
}
