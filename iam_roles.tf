resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}_ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "${var.app_name}_ecs_task_execution_policy_attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}_ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ecs_s3_policy" {
  name        = "${var.app_name}-ecs_s3_policy"
  description = "Policy for ECS tasks to interact with S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.backend_bucket.arn,
          "${aws_s3_bucket.backend_bucket.arn}/*"
        ]
      }
    ]
  })
}
# DynamoDB
resource "aws_iam_policy" "ecs_dynamodb_policy" {
  name        = "${var.app_name}_ecs_dynamodb_policy"
  description = "Policy for ECS tasks to interact with DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.backend_table.arn
      }
    ]
  })
}

# RDS
resource "aws_iam_policy" "ecs_rds_policy" {
  name        = "${var.app_name}_ecs_rds_policy"
  description = "Policy for ECS tasks to interact with RDS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = aws_db_instance.backend_db.arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_s3_policy_attachment" {
  name       = "${var.app_name}_ecs_s3_policy_attachment"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = aws_iam_policy.ecs_s3_policy.arn
}

resource "aws_iam_policy_attachment" "ecs_dynamodb_policy_attachment" {
  name       = "${var.app_name}_ecs_dynamodb_policy_attachment"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = aws_iam_policy.ecs_dynamodb_policy.arn
}

resource "aws_iam_policy_attachment" "ecs_rds_policy_attachment" {
  name       = "${var.app_name}_ecs_rds_policy_attachment"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = aws_iam_policy.ecs_rds_policy.arn
}