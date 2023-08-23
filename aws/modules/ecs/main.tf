resource "aws_ecs_cluster" "main" {
  name = "cluster-${var.workload}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]
}

# https://docs.aws.amazon.com/xray/latest/devguide/xray-daemon-ecs.html

resource "aws_ecs_task_definition" "main" {
  family             = "${var.workload}-task"
  network_mode       = "awsvpc"
  cpu                = 512
  memory             = 1024
  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      "name" : "xray-daemon",
      "image" : "public.ecr.aws/xray/aws-xray-daemon:latest",
      "environment" : [
        { "name" : "AWS_REGION", "value" : "${var.aws_region}" },
      ],
      "cpu" : 32,
      "memoryReservation" : 256,
      "portMappings" : [
        {
          "containerPort" : 2000,
          "protocol" : "udp"
        }
      ]
    },
    {
      "name" : "${var.workload}",
      "image" : "${var.repository_url}:latest",
      "environment" : [
        { "name" : "PORT", "value" : "80" },
        { "name" : "AWS_REGION", "value" : "${var.aws_region}" },
      ],
      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost:80/health || exit 1",
        ],
      },
      "essential" : true,
      "portMappings" : [
        {
          "protocol" : "tcp",
          "containerPort" : 80,
          "hostPort" : 80
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : "${var.aws_region}",
          "awslogs-group" : "${aws_cloudwatch_log_group.main.name}",
          "awslogs-stream-prefix" : var.workload,
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "main" {
  name              = var.workload
  retention_in_days = 7
}

resource "aws_ecs_service" "main" {
  name                               = "${var.workload}-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  scheduling_strategy                = "REPLICA"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.all.id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.workload
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "all" {
  name        = "fargate-${var.workload}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-fargate-${var.workload}"
  }
}

resource "aws_security_group_rule" "egress_http" {
  description       = "Allows HTTP egress, required to get credentials"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.all.id
}

resource "aws_security_group_rule" "egress_https" {
  description       = "Allows HTTPS egress"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.all.id
}

resource "aws_security_group_rule" "ingress_http" {
  description       = "Allows HTTP ingress from ELB"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.all.id
}
