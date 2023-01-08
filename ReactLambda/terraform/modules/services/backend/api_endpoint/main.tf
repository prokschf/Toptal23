variable "function_names_handlers_verbs" {
    type = list(tuple([string, string, string, string]))
    description = "A list of endpoint names, their handler pathes and http verbs"
}

variable "parent_resource_id" {
    type = string
}

variable "gateway_id" {
    type = string
}

variable "stage_name" {
    type = string
}

variable "source_code_hash" {
    type = string
}

variable "iam_role_arm" {
    type = string
}

variable "zip_name" {
    type = string
}

variable "backend_lambda_nodejs_layer_arn" {
    type = string
}

resource "aws_cloudwatch_log_group" "log_groups" {
  count = length(var.function_names_handlers_verbs)
  name = "/aws/lambda/${element(var.function_names_handlers_verbs, count.index)[0]}"
}

resource "aws_lambda_function" "lambdas" {
  count = length(var.function_names_handlers_verbs)
  function_name = "realworld-${var.stage_name}-${var.function_names_handlers_verbs[count.index][0]}"
  filename = "${var.zip_name}"
  source_code_hash = "${var.source_code_hash}"
  handler = var.function_names_handlers_verbs[count.index][1]
  runtime = "nodejs12.x"
  publish = "true"
  timeout = 60
  role = "${var.iam_role_arm}"
  depends_on = [aws_cloudwatch_log_group.log_groups]
  layers = ["${var.backend_lambda_nodejs_layer_arn}"]

  environment {
    variables = {
      DYNAMODB_NAMESPACE = "${var.stage_name}"
    }
  }  
}

resource "aws_api_gateway_method" "gw_methods" {
  count = length(var.function_names_handlers_verbs)
  authorization = "NONE"
  http_method   = var.function_names_handlers_verbs[count.index][2]
  resource_id   = var.function_names_handlers_verbs[count.index][3]
  rest_api_id   = "${var.gateway_id}"
}

resource "aws_api_gateway_integration" "integration" {
  count = length(var.function_names_handlers_verbs)  
  rest_api_id = "${var.gateway_id}"
  resource_id = "${element(aws_api_gateway_method.gw_methods, count.index).resource_id}"
  http_method = "${element(aws_api_gateway_method.gw_methods, count.index).http_method}"

  integration_http_method = "${element(var.function_names_handlers_verbs, count.index)[2]}"
  type                    = "AWS_PROXY"
  uri                     = "${element(aws_lambda_function.lambdas, count.index).invoke_arn}"

  depends_on = [aws_lambda_function.lambdas]
}