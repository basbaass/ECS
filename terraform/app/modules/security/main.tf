#security groups
resource "aws_security_group" "alb" {

  name        = "alb_security_group"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP ingress to the ALB"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS ingress to the ALB"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs.id

  description = "Allow ALB traffic to ECS on port 8080"


  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}


resource "aws_security_group" "ecs" {
  name        = "ecs_security_group"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow ECS ingress from ALB on port 8080"

  ip_protocol = "tcp"
  from_port   = 8080
  to_port     = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_https" {
  security_group_id = aws_security_group.ecs.id

  description = "Allow ECS outbound HTTPS traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_http" {
  security_group_id = aws_security_group.ecs.id

  description = "Allow ECS outbound HTTP traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_icmp" {
  security_group_id = aws_security_group.ecs.id

  description = "Allow ICMP Echo requests"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "icmp"
  from_port   = 8
  to_port     = 0

}

