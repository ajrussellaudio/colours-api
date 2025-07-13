# Palettes Lambdas

resource "aws_lambda_function" "create_palette_function" {
  function_name    = "create-palette"
  handler          = "dist/palettes/create.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
      COLOURS_TABLE  = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "get_palette_function" {
  function_name    = "get-palette"
  handler          = "dist/palettes/get.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
      COLOURS_TABLE  = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "list_palettes_function" {
  function_name    = "list-palettes"
  handler          = "dist/palettes/list.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
      COLOURS_TABLE  = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "update_palette_function" {
  function_name    = "update-palette"
  handler          = "dist/palettes/update.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_lambda_function" "delete_palette_function" {
  function_name    = "delete-palette"
  handler          = "dist/palettes/delete.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_api_gateway_resource" "palettes" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "palettes"
}

resource "aws_api_gateway_resource" "palette" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.palettes.id
  path_part   = "{id}"
}

# Create
resource "aws_api_gateway_method" "create_palette_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.palettes.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "create_palette_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.palettes.id
  http_method             = aws_api_gateway_method.create_palette_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_palette_function.invoke_arn
}

resource "aws_lambda_permission" "create_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeCreatePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Get
resource "aws_api_gateway_method" "get_palette_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.palette.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get_palette_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.palette.id
  http_method             = aws_api_gateway_method.get_palette_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_palette_function.invoke_arn
}

resource "aws_lambda_permission" "get_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetPalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# List
resource "aws_api_gateway_method" "list_palettes_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.palettes.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "list_palettes_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.palettes.id
  http_method             = aws_api_gateway_method.list_palettes_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_palettes_function.invoke_arn
}

resource "aws_lambda_permission" "list_palettes_permission" {
  statement_id  = "AllowAPIGatewayInvokeListPalettes"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_palettes_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Update
resource "aws_api_gateway_method" "update_palette_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.palette.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "update_palette_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.palette.id
  http_method             = aws_api_gateway_method.update_palette_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_palette_function.invoke_arn
}

resource "aws_lambda_permission" "update_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeUpdatePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Delete
resource "aws_api_gateway_method" "delete_palette_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.palette.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "delete_palette_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.palette.id
  http_method             = aws_api_gateway_method.delete_palette_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_palette_function.invoke_arn
}

resource "aws_lambda_permission" "delete_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeletePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}