
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


variable "iam_role_arm" {
    type = string
}

data "archive_file" "lambda_package" {
  for_each = var.function_configs
  type = "zip"
  source_file  = "${path.module}/../../../../../backend-go/bin/${each.value.handler}"
  output_path = "zip_${each.value.handler}"
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
  filename = "zip_${each.value.handler}"
  source_code_hash = data.archive_file.lambda_package[each.key].output_base64sha256
  handler = each.value.handler
  runtime = "go1.x"
  publish = "true"
  timeout = 60
  role = "${var.iam_role_arm}"

  environment {
    variables = {
      STAGE = "${var.stage_name}"
    }
  }  
}

resource "aws_api_gateway_method" "gw_methods" {
  for_each = var.function_configs  
  authorization = "NONE"
  http_method   = each.value.verb
  resource_id   = each.value.resource.id
  rest_api_id   = "${var.gateway_id}"
}

resource "aws_api_gateway_integration" "integration" {
  for_each = var.function_configs
  rest_api_id = "${var.gateway_id}"
  resource_id = "${each.value.resource.id}"
  http_method = "${each.value.verb}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambdas[each.key].invoke_arn}"
 
  depends_on = [aws_api_gateway_method.gw_methods, aws_lambda_function.lambdas]
}

resource "aws_cloudwatch_metric_alarm" "time_alarm" {
  for_each = var.function_configs
  depends_on = [aws_lambda_function.lambdas]
  alarm_name          = "realworld-${var.stage_name}-${each.key}-lambda-execution-time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "${aws_lambda_function.lambdas[each.key].timeout * 1000 * 0.75}"
  alarm_description   = "${each.key} Lambda Execution Time"
  treat_missing_data  = "ignore"

  insufficient_data_actions = [
    "${aws_sns_topic.lambda_alarm_topic.arn}",
  ]

  alarm_actions = [
    "${aws_sns_topic.lambda_alarm_topic.arn}",
  ]

  ok_actions = [
    "${aws_sns_topic.lambda_alarm_topic.arn}",
  ]

  dimensions {
    FunctionName = "${aws_lambda_function.lambdas[each.key].function_name}"
    Resource     = "${aws_lambda_function.lambdas[each.key].function_name}"
  }
}

resource "aws_sns_topic" "lambda_alarm_topic" {
  name = "user-updates-topic"
}