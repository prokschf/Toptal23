
variable "function_configs" {
    type = any
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

variable "gateway_execution_arn" {
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
  for_each = var.function_configs
  name = "/aws/lambda/realworld-${var.stage_name}-${each.key}"
}

resource "aws_lambda_permission" "gw_permission" {
  for_each = var.function_configs
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "realworld-${var.stage_name}-${each.key}"
  principal     = "apigateway.amazonaws.com"
  depends_on = [aws_lambda_function.lambdas]
  source_arn    = "${var.gateway_execution_arn}/*/*/*"
}

resource "aws_lambda_function" "lambdas" {
  for_each = var.function_configs
  function_name = "realworld-${var.stage_name}-${each.key}"
  filename = "${var.zip_name}"
  source_code_hash = "${var.source_code_hash}"
  handler = each.value.handler
#  runtime = "nodejs12.x"
  runtime = "go1.x"
  publish = "true"
  timeout = 60
  role = "${var.iam_role_arm}"
 # depends_on = [aws_cloudwatch_log_group.log_groups]
#  layers = ["${var.backend_lambda_nodejs_layer_arn}"]

  environment {
    variables = {
      DYNAMODB_NAMESPACE = "${var.stage_name}"
    }
  }  
}

resource "aws_api_gateway_method" "gw_methods" {
  for_each = var.function_configs  
  authorization = "NONE"
  http_method   = each.value.verb
  resource_id   = each.value.resource
  rest_api_id   = "${var.gateway_id}"
}

resource "aws_api_gateway_integration" "integration" {
  for_each = var.function_configs
  rest_api_id = "${var.gateway_id}"
  resource_id = "${each.value.resource}"
  http_method = "${each.value.verb}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambdas[each.key].invoke_arn}"
 

  depends_on = [aws_lambda_function.lambdas]
}