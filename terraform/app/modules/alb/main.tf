#ALB

resource "aws_lb" "alb" {
  name               = "gatus-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_ids]
  subnets            = var.public_subnets_ids


  tags = {
    Project = "gatus"
  }
}

#target group

resource "aws_lb_target_group" "gatus_tg" {
  name        = "gatus-tg"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled  = true
    path     = "/health"
    port     = "traffic-port"
    protocol = "HTTP"
  }

  tags = {
    Project = "gatus"
  }
}

#ACM

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = "gatus"
  }
}


#listeners

resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.alb.arn
  certificate_arn   = aws_acm_certificate.cert.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gatus_tg.arn
  }
  tags = {
    Project = "gatus"
  }
}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Project = "gatus"
  }

}


#Route53
