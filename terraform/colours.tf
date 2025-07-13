# Colours Lambdas

data "archive_file" "create_colour_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/colours/create.js"
  output_path = "${path.module}/../dist/create_colour.zip"
}

resource "aws_lambda_function" "create_colour_function" {
  function_name = "create-colour"
  handler       = "create.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.create_colour_lambda.output_path
  source_code_hash = data.archive_file.create_colour_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "create_colour_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.create_colour_function.invoke_arn
}

resource "aws_apigatewayv2_route" "create_colour_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /colours"
  target    = "integrations/${aws_apigatewayv2_integration.create_colour_integration.id}"
}


resource "aws_lambda_permission" "create_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeCreateColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "get_colour_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/colours/get.js"
  output_path = "${path.module}/../dist/get_colour.zip"
}

resource "aws_lambda_function" "get_colour_function" {
  function_name = "get-colour"
  handler       = "get.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.get_colour_lambda.output_path
  source_code_hash = data.archive_file.get_colour_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "get_colour_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_colour_function.invoke_arn
}

resource "aws_apigatewayv2_route" "get_colour_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /colours/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_colour_integration.id}"
}

resource "aws_lambda_permission" "get_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "list_colours_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/colours/list.js"
  output_path = "${path.module}/../dist/list_colours.zip"
}

resource "aws_lambda_function" "list_colours_function" {
  function_name = "list-colours"
  handler       = "list.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.list_colours_lambda.output_path
  source_code_hash = data.archive_file.list_colours_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "list_colours_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.list_colours_function.invoke_arn
}

resource "aws_apigatewayv2_route" "list_colours_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /colours"
  target    = "integrations/${aws_apigatewayv2_integration.list_colours_integration.id}"
}

resource "aws_lambda_permission" "list_colours_permission" {
  statement_id  = "AllowAPIGatewayInvokeListColours"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_colours_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "update_colour_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/colours/update.js"
  output_path = "${path.module}/../dist/update_colour.zip"
}

resource "aws_lambda_function" "update_colour_function" {
  function_name = "update-colour"
  handler       = "update.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.update_colour_lambda.output_path
  source_code_hash = data.archive_file.update_colour_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "update_colour_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.update_colour_function.invoke_arn
}

resource "aws_apigatewayv2_route" "update_colour_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /colours/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_colour_integration.id}"
}

resource "aws_lambda_permission" "update_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeUpdateColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "delete_colour_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/colours/delete.js"
  output_path = "${path.module}/../dist/delete_colour.zip"
}

resource "aws_lambda_function" "delete_colour_function" {
  function_name = "delete-colour"
  handler       = "delete.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.delete_colour_lambda.output_path
  source_code_hash = data.archive_file.delete_colour_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "delete_colour_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.delete_colour_function.invoke_arn
}

resource "aws_apigatewayv2_route" "delete_colour_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /colours/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_colour_integration.id}"
}

resource "aws_lambda_permission" "delete_colour_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeleteColour"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_colour_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
