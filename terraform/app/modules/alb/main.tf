#ALB

resource "aws_lb" "alb" {
  name               = "gatus-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in var.public_subnets : subnet.id]

  depends_on = [aws_security_group.alb]
  tags = {
    Project = "gatus"
  }
}

#security groups

resource "aws_security_group" "alb" {

  name   = "alb_security_group"
  vpc_id = var.vpc_id
}

resource "aws_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

resource "aws_security_group_egress_rule" "allow_80" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  // to_port = ECS SG
}




#target groups
#listeners
#ACM
#Route53
