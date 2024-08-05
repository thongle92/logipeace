resource "aws_db_instance" "backend_db" {
  allocated_storage       = var.db_storage_size
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_class
  username                = var.db_master_user
  password                = random_password.db.result
  parameter_group_name    = var.parameter_group_name
  skip_final_snapshot     = true
  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  availability_zone       = element(local.az, 0)
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.ecs_kms.arn

  tags = {
    Name = "${var.app_name}-backenddb"
  }
}

resource "random_password" "db" {
  length           = 10
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "secret" {
  name        = "/database/password/master"
  description = "The parameter description"
  type        = "SecureString"
  value       = random_password.db.result
}
