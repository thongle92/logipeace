### ECS cluster
resource "aws_ecs_cluster" "default" {
  name = "${var.app_name}-cluster"
}

### Service FE
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.app_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-frontend"
      image     = var.fe_image
      essential = true
      portMappings = [
        {
          containerPort = var.fe_port
          hostPort      = var.fe_port
        }
      ]
      environment = [
        {
          name  = "BACKEND_SERVICE_URL"
          value = "http://backend.${var.app_name}.local:8080"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name                               = "${var.app_name}-frontend-service"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.frontend.arn
  desired_count                      = 2
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.frontend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${var.app_name}frontend"
    container_port   = var.fe_port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https
  ]
}

resource "aws_security_group" "frontend" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.fe_port
    to_port     = var.fe_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block, ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Service BE
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.app_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-backend"
      image     = var.be_image
      essential = true
      portMappings = [
        {
          containerPort = var.be_port
          hostPort      = var.be_port
        }
      ]
      environment = [
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.backend_bucket.bucket
        },
        {
          name  = "DYNAMODB_TABLE_NAME"
          value = aws_dynamodb_table.backend_table.name
        },
        {
          name  = "RDS_HOSTNAME"
          value = aws_db_instance.backend_db.address
        },
        {
          name  = "RDS_USERNAME"
          value = var.db_master_user
        },
        {
          name  = "RDS_PASSWORD"
          value = random_password.db.result
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "backend" {
  name                               = "${var.app_name}-backend-service"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = 2
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }
}


resource "aws_security_group" "backend" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.be_port
    to_port     = var.be_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block, ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_service_discovery_service" "backend" {
  name = "${var.app_name}-backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.app_name}.local"
  vpc         = aws_vpc.vpc.id
  description = "Private DNS namespace for service discovery"
}
