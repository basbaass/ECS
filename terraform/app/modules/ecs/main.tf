locals {
  container_name = "gatus"
  container_port = 8080
}

#IAM

data "aws_iam_policy_document" "trust_policy" {

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "gatus_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Cloudwatch

resource "aws_cloudwatch_log_group" "gatus" {
  name = "/ecs/gatus"

  retention_in_days = 7

  tags = {
    Project = "gatus"
  }
}

#Cluster

resource "aws_ecs_cluster" "gatus" {
  name = "gatus-prod"

  tags = {
    Project = "gatus"
  }
}

#Task Definition

resource "aws_ecs_task_definition" "gatus" {

  family                   = "gatus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([{
    image     = var.gatus_image
    name      = local.container_name
    essential = true
    portMappings = [
      {
        containerPort = local.container_port
      }
    ]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.gatus.name,
        awslogs-region        = aws_cloudwatch_log_group.gatus.region,
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  tags = {
    Project = "gatus"
  }

}

#ECS Service

resource "aws_ecs_service" "gatus" {
  name            = "gatus"
  cluster         = aws_ecs_cluster.gatus.arn
  task_definition = aws_ecs_task_definition.gatus.arn
  desired_count   = 2
  depends_on      = [aws_iam_role_policy_attachment.ecs_execution_policy]
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = local.container_port
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_subnet_ids
  }

  tags = {
    Project = "gatus"
  }
}
