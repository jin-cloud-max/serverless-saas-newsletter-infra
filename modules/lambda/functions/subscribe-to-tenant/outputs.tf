output "lambda_function_arn" {
  value       = aws_lambda_function.stt_lambda_template.arn
  sensitive   = false
  description = "The ARN of the Lambda function"
}
