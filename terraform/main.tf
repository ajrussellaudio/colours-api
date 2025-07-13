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
        "dynamodb:Query"
      ]
      Effect   = "Allow"
      Resource = [
        aws_dynamodb_table.colours_table.arn,
        aws_dynamodb_table.palettes_table.arn
      ]
    }]
  })
}

data "archive_file" "colours_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../dist"
  output_path = "${path.module}/../dist/colours.zip"
}

resource "aws_lambda_function" "colours_function" {
  function_name = "colours-api"
  handler       = "colours.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs16.x"

  filename         = data.archive_file.colours_lambda.output_path
  source_code_hash = data.archive_file.colours_lambda.output_base64sha256

  environment {
    variables = {
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
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

resource "aws_apigatewayv2_integration" "colours_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.colours_function.invoke_arn
}

resource "aws_apigatewayv2_route" "colours_route_post" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /colours"
  target    = "integrations/${aws_apigatewayv2_integration.colours_integration.id}"
}

resource "aws_apigatewayv2_route" "colours_route_get_all" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /colours"
  target    = "integrations/${aws_apigatewayv2_integration.colours_integration.id}"
}

resource "aws_apigatewayv2_route" "colours_route_get_one" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /colours/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.colours_integration.id}"
}

resource "aws_apigatewayv2_route" "colours_route_put" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /colours/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.colours_integration.id}"
}

resource "aws_apigatewayv2_route" "colours_route_delete" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /colours/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.colours_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.colours_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
