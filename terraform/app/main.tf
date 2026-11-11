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
  alb_sg_id          = module.security.alb_security_group_id
  vpc_id             = module.network.vpc_id
  domain_name        = var.domain_name
  hosted_zone_id     = data.aws_route53_zone.primary.zone_id
}

module "ecs" {
  source                = "./modules/ecs"
  target_group_arn      = module.alb.target_group_arn
  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = module.security.ecs_security_group_id
  gatus_image           = data.aws_ecr_image.gatus.image_uri

}

data "aws_ecr_image" "gatus" {
  repository_name = "ecr-gatus-v1"
  image_tag       = var.image_tag
}

data "aws_route53_zone" "primary" {
  name = var.domain_name
}
