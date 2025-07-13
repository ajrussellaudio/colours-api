output "dynamodb_table_name" {
  value = aws_dynamodb_table.colours_table.name
}

output "palettes_table_name" {
  value = aws_dynamodb_table.palettes_table.name
}

output "api_gateway_url" {
  description = "The invoke URL for the API Gateway stage"
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}