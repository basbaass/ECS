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





#target groups
#listeners
#ACM
#Route53
