module "subscribe_to_tenant" {
  source = "./functions/subscribe-to-tenant"

  api_gateway_arn           = var.api_gateway_arn
  api_gateway_id            = var.api_gateway_id
  api_gateway_resource_id   = var.api_gateway_resource_id
  api_gateway_execution_arn = var.api_gateway_execution_arn
}