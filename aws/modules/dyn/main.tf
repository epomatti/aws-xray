resource "aws_dynamodb_table" "tasks" {
  name           = "Tasks"
  billing_mode   = "PAY_PER_REQUEST"
  stream_enabled = false
  hash_key       = "id"

  deletion_protection_enabled = false

  attribute {
    name = "id"
    type = "S"
  }
}
