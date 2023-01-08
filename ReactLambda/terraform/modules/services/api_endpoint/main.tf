resource "aws_cloudwatch_log_group" "createUser_logging" {
  name = "/aws/lambda/${local.lambda_function_name_createUser}"
}

resource "aws_lambda_function" "createUser_lambda" {
  function_name = "${local.lambda_function_name_createUser}"
  filename = "${local.lambda_function_zip_name}"
  source_code_hash = "${data.archive_file.lambda_package.output_base64sha256}"
  handler = "src/User.create"
  runtime = "nodejs12.x"
  publish = "true"
  timeout = 60
  role = "${aws_iam_role.lambda_role.arn}"
  depends_on = [aws_cloudwatch_log_group.createUser_logging]
  layers = ["${aws_lambda_layer_version.backend_lambda_nodejs_layer.arn}"]

  environment {
    variables = {
      DYNAMODB_NAMESPACE = "${var.stage_name}"
    }
  }  
}

resource "aws_api_gateway_resource" "users_resource" {
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "users"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

resource "aws_api_gateway_method" "post_users" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.users_resource.id
  rest_api_id   = aws_api_gateway_rest_api.backend_gw.id
}