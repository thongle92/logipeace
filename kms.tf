resource "aws_kms_key" "ecs_kms" {
  description             = "KMS key for encrypting ECS services"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "ecs_kms_alias" {
  name          = "alias/ecsKmsKey"
  target_key_id = aws_kms_key.ecs_kms.id
}
