resource "aws_apigatewayv2_api" "api" {
  name          = "colours-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "colours-api-key"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "colours-api-usage-plan"
  api_stages {
    api_id = aws_apigatewayv2_api.api.id
    stage  = aws_apigatewayv2_stage.api_stage.name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
