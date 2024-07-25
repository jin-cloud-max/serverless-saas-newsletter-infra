variable "lambda_function_name" {
  default = "subscribe-to-tenant"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "stt_lambda_role" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "stt_lambda_permissions" {
  name = "stt-lambda-permissions"

  role = aws_iam_role.stt_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
    ],
  })


}

data "archive_file" "sst_booststrap" {
  type        = "zip"
  source_file = "${path.module}/../../templates/golang/hello.sh"
  output_path = "${path.module}/templates/golang/bootstrap.zip"
}

resource "aws_lambda_function" "stt_lambda_template" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.stt_lambda_role.arn
  handler       = "handler"

  runtime = "provided.al2023"

  filename = data.archive_file.sst_booststrap.output_path

  source_code_hash = data.archive_file.sst_booststrap.output_base64sha256

  logging_config {
    log_format = "Text"
  }

  lifecycle {
    ignore_changes = [filename]
  }

  # architures = ["x86_64"]

  tags = {
    Name      = "subscribe-to-tenant"
    IaC       = "True"
    CreatedBy = "Terraform"
  }

}

resource "aws_cloudwatch_log_group" "stt_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stt_lambda_template.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*/subscribers"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = var.api_gateway_id
  resource_id   = var.api_gateway_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_method.proxy_method.rest_api_id
  resource_id = aws_api_gateway_method.proxy_method.resource_id
  http_method = aws_api_gateway_method.proxy_method.http_method


  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.stt_lambda_template.invoke_arn
}


resource "aws_api_gateway_method_response" "proxy_response" {
  rest_api_id = var.api_gateway_id
  resource_id = var.api_gateway_resource_id
  http_method = "POST"

  status_code = 201

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

}

resource "aws_api_gateway_deployment" "stt_lambda_deployment" {
  rest_api_id = var.api_gateway_id

  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]

  stage_name = "prod"
}
