resource "aws_api_gateway_rest_api" "api" {
  name = "colours-api"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # This is a workaround to ensure the deployment is triggered when the API changes.
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.colours.id,
      aws_api_gateway_method.create_colour_method.id,
      aws_api_gateway_integration.create_colour_integration.id,
      aws_api_gateway_resource.colour.id,
      aws_api_gateway_method.get_colour_method.id,
      aws_api_gateway_integration.get_colour_integration.id,
      aws_api_gateway_method.update_colour_method.id,
      aws_api_gateway_integration.update_colour_integration.id,
      aws_api_gateway_method.delete_colour_method.id,
      aws_api_gateway_integration.delete_colour_integration.id,
      aws_api_gateway_method.list_colours_method.id,
      aws_api_gateway_integration.list_colours_integration.id,
      aws_api_gateway_resource.palettes.id,
      aws_api_gateway_method.create_palette_method.id,
      aws_api_gateway_integration.create_palette_integration.id,
      aws_api_gateway_resource.palette.id,
      aws_api_gateway_method.get_palette_method.id,
      aws_api_gateway_integration.get_palette_integration.id,
      aws_api_gateway_method.update_palette_method.id,
      aws_api_gateway_integration.update_palette_integration.id,
      aws_api_gateway_method.delete_palette_method.id,
      aws_api_gateway_integration.delete_palette_integration.id,
      aws_api_gateway_method.list_palettes_method.id,
      aws_api_gateway_integration.list_palettes_integration.id,
      aws_api_gateway_resource.upload.id,
      aws_api_gateway_method.upload_method.id,
      aws_api_gateway_integration.upload_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "colours-api-key"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "colours-api-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
