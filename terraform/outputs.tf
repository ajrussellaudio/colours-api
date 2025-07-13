output "dynamodb_table_name" {
  value = aws_dynamodb_table.colours_table.name
}

output "palettes_table_name" {
  value = aws_dynamodb_table.palettes_table.name
}

output "api_gateway_url" {
  description = "The invoke URL for the API Gateway stage"
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

output "api_key" {
  description = "The API key for the API Gateway"
  value       = aws_api_gateway_api_key.api_key.value
  sensitive   = true
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}
