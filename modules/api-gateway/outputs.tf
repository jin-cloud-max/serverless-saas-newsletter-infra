output "api_gateway_id" {
  value       = aws_api_gateway_rest_api.newsletter_api.id
  description = "The ID of the API Gateway"
}

output "api_gateway_arn" {
  value       = aws_api_gateway_rest_api.newsletter_api.execution_arn
  description = "The ARN of the API Gateway"
}

output "api_gateway_resource_id" {
  value       = aws_api_gateway_resource.proxy.id
  description = "The ID of the API Gateway resource"
}
