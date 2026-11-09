locals {
  full_domain = "${var.prefix}.${var.domain_name}"
}

#ALB 

resource "aws_lb" "alb" {
  name               = "gatus-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
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

#listeners

resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.alb.arn
  certificate_arn   = aws_acm_certificate_validation.validate.certificate_arn
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

#ACM

resource "aws_acm_certificate" "cert" {
  domain_name       = local.full_domain
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = "gatus"
  }
}


#Route53

resource "aws_route53_record" "status" {
  zone_id = var.hosted_zone_id
  name    = local.full_domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cname" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = var.hosted_zone_id
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = 60

}

resource "aws_acm_certificate_validation" "validate" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cname : record.fqdn]
}
