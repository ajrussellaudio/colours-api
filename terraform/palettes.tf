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
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
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
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
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
      COLOURS_TABLE = aws_dynamodb_table.colours_table.name
    }
  }
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
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.palettes.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "create_palette_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.palettes.id
  http_method = aws_api_gateway_method.create_palette_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_palette_function.invoke_arn
}

# Get
resource "aws_api_gateway_method" "get_palette_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.palette.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "get_palette_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.palette.id
  http_method = aws_api_gateway_method.get_palette_method.http_method
  integration_http_method = "GET"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.get_palette_function.invoke_arn
}

# List
resource "aws_api_gateway_method" "list_palettes_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.palettes.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "list_palettes_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.palettes.id
  http_method = aws_api_gateway_method.list_palettes_method.http_method
  integration_http_method = "GET"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.list_palettes_function.invoke_arn
}

# Update
resource "aws_api_gateway_method" "update_palette_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.palette.id
  http_method   = "PUT"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "update_palette_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.palette.id
  http_method = aws_api_gateway_method.update_palette_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.update_palette_function.invoke_arn
}

# Delete
resource "aws_api_gateway_method" "delete_palette_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.palette.id
  http_method   = "DELETE"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "delete_palette_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.palette.id
  http_method = aws_api_gateway_method.delete_palette_method.http_method
  integration_http_method = "DELETE"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.delete_palette_function.invoke_arn
}
