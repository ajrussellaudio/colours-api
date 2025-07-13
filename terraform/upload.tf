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

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "upload_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.upload_function.invoke_arn
}

resource "aws_lambda_permission" "upload_permission" {
  statement_id  = "AllowAPIGatewayInvokeUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
