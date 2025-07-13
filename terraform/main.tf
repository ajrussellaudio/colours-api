provider "aws" {
  region = "eu-west-1"
}

resource "aws_dynamodb_table" "colours_table" {
  name           = "colours"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "palettes_table" {
  name           = "palettes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "dynamodb_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:GetObject",
        "dynamodb:PutObject",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:BatchWriteItem"
      ]
      Effect   = "Allow"
      Resource = [
        aws_dynamodb_table.colours_table.arn,
        aws_dynamodb_table.palettes_table.arn
      ]
    }]
  })
}

resource "aws_apigatewayv2_api" "api" {
  name          = "colours-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

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

# ... and so on for get, list, update, delete

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
}

resource "aws_lambda_permission" "delete_palette_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeletePalette"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_palette_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

data "archive_file" "upload_lambda" {
  type        = "zip"
  source_file = "${path.module}/../dist/upload.js"
  output_path = "${path.module}/../dist/upload.zip"
}

resource "aws_lambda_function" "upload_function" {
  function_name = "upload-api"
  handler       = "upload.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"

  filename         = data.archive_file.upload_lambda.output_path
  source_code_hash = data.archive_file.upload_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
}

resource "aws_apigatewayv2_integration" "upload_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.upload_function.invoke_arn
}

resource "aws_apigatewayv2_route" "upload_route_post" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_permission_upload" {
  statement_id  = "AllowAPIGatewayInvokeUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
