module "lambda" {
  source = "./modules/lambda"

  api_gateway_arn           = module.api_gateway.api_gateway_arn
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_resource_id   = module.api_gateway.api_gateway_resource_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_arn


}

module "dynamodb" {
  source = "./modules/dynamodb"

  dynamodb_table = var.dynamodb_table_name
}

module "api_gateway" {
  source = "./modules/api-gateway"

  api_gateway_name = var.api_gateway_name
}