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
    image     = "TBC"
    name      = "gatus"
    essential = true
    portMappings = [
      {
        containerPort = 8080
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

}

#ECS Service
