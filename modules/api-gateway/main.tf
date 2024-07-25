resource "aws_api_gateway_rest_api" "newsletter_api" {
  name        = var.api_gateway_name
  description = "Newsletter API"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.newsletter_api.id
  parent_id   = aws_api_gateway_rest_api.newsletter_api.root_resource_id
  path_part   = "subscribers"
}
