# Palettes Lambdas

data "archive_file" "create_palette_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/palettes/create.js"
  output_path = "${path.module}/../dist/create_palette.zip"
}

resource "aws_lambda_function" "create_palette_function" {
  function_name = "create-palette"
  handler       = "create.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.create_palette_lambda.output_path
  source_code_hash = data.archive_file.create_palette_lambda.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "create_palette_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.create_palette_function.invoke_arn
}

resource "aws_apigatewayv2_route" "create_palette_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /palettes"
  target    = "integrations/${aws_apigatewayv2_integration.create_palette_integration.id}"
  api_key_required = true
}

resource "aws_lambda_permission" "create_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeCreatePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "get_palette_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/palettes/get.js"
  output_path = "${path.module}/../dist/get_palette.zip"
}

resource "aws_lambda_function" "get_palette_function" {
  function_name = "get-palette"
  handler       = "get.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.get_palette_lambda.output_path
  source_code_hash = data.archive_file.get_palette_lambda.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "get_palette_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_palette_function.invoke_arn
}

resource "aws_apigatewayv2_route" "get_palette_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /palettes/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_palette_integration.id}"
  api_key_required = true
}

resource "aws_lambda_permission" "get_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetPalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "list_palettes_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/palettes/list.js"
  output_path = "${path.module}/../dist/list_palettes.zip"
}

resource "aws_lambda_function" "list_palettes_function" {
  function_name = "list-palettes"
  handler       = "list.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.list_palettes_lambda.output_path
  source_code_hash = data.archive_file.list_palettes_lambda.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "list_palettes_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.list_palettes_function.invoke_arn
}

resource "aws_apigatewayv2_route" "list_palettes_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /palettes"
  target    = "integrations/${aws_apigatewayv2_integration.list_palettes_integration.id}"
  api_key_required = true
}

resource "aws_lambda_permission" "list_palettes_permission" {
  statement_id  = "AllowAPIGatewayInvokeListPalettes"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_palettes_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "update_palette_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/palettes/update.js"
  output_path = "${path.module}/../dist/update_palette.zip"
}

resource "aws_lambda_function" "update_palette_function" {
  function_name = "update-palette"
  handler       = "update.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.update_palette_lambda.output_path
  source_code_hash = data.archive_file.update_palette_lambda.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "update_palette_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.update_palette_function.invoke_arn
}

resource "aws_apigatewayv2_route" "update_palette_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /palettes/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_palette_integration.id}"
  api_key_required = true
}

resource "aws_lambda_permission" "update_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeUpdatePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "delete_palette_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/palettes/delete.js"
  output_path = "${path.module}/../dist/delete_palette.zip"
}

resource "aws_lambda_function" "delete_palette_function" {
  function_name = "delete-palette"
  handler       = "delete.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"
  filename      = data.archive_file.delete_palette_lambda.output_path
  source_code_hash = data.archive_file.delete_palette_lambda.output_base64sha256

  environment {
    variables = {
      PALETTES_TABLE = aws_dynamodb_table.palettes_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "delete_palette_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.delete_palette_function.invoke_arn
}

resource "aws_apigatewayv2_route" "delete_palette_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /palettes/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_palette_integration.id}"
  api_key_required = true
}

resource "aws_lambda_permission" "delete_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeletePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
