resource "aws_dynamodb_table" "newsletter_table" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Name      = var.dynamodb_table
    IaC       = true
    CreatedBy = "Terraform"
  }
}