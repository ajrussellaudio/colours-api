# Colours Lambdas

resource "aws_lambda_function" "create_colour_function" {
  function_name    = "create-colour"
  handler          = "dist/colours/create.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "get_colour_function" {
  function_name    = "get-colour"
  handler          = "dist/colours/get.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "list_colours_function" {
  function_name    = "list-colours"
  handler          = "dist/colours/list.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "update_colour_function" {
  function_name    = "update-colour"
  handler          = "dist/colours/update.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_lambda_function" "delete_colour_function" {
  function_name    = "delete-colour"
  handler          = "dist/colours/delete.handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "nodejs16.x"
  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_api_gateway_resource" "colours" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "colours"
}

resource "aws_api_gateway_resource" "colour" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.colours.id
  path_part   = "{id}"
}

# Create
resource "aws_api_gateway_method" "create_colour_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.colours.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "create_colour_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.colours.id
  http_method             = aws_api_gateway_method.create_colour_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_colour_function.invoke_arn
}

resource "aws_lambda_permission" "create_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeCreateColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Get
resource "aws_api_gateway_method" "get_colour_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.colour.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get_colour_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.colour.id
  http_method             = aws_api_gateway_method.get_colour_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_colour_function.invoke_arn
}

resource "aws_lambda_permission" "get_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# List
resource "aws_api_gateway_method" "list_colours_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.colours.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "list_colours_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.colours.id
  http_method             = aws_api_gateway_method.list_colours_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_colours_function.invoke_arn
}

resource "aws_lambda_permission" "list_colours_permission" {
  statement_id  = "AllowAPIGatewayInvokeListColours"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_colours_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Update
resource "aws_api_gateway_method" "update_colour_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.colour.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "update_colour_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.colour.id
  http_method             = aws_api_gateway_method.update_colour_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_colour_function.invoke_arn
}

resource "aws_lambda_permission" "update_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeUpdateColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Delete
resource "aws_api_gateway_method" "delete_colour_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.colour.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "delete_colour_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.colour.id
  http_method             = aws_api_gateway_method.delete_colour_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_colour_function.invoke_arn
}

resource "aws_lambda_permission" "delete_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeleteColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}