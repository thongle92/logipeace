resource "aws_dynamodb_table" "backend_table" {
  name         = "${var.app_name}backend-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.ecs_kms.arn
  }
}