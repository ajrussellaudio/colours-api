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
