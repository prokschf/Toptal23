resource "aws_api_gateway_rest_api" "backend_gw" {
  name = "realworld-backend-${var.stage_name}"
}

resource "aws_api_gateway_resource" "api_resource" {
  parent_id   = aws_api_gateway_rest_api.backend_gw.root_resource_id
  path_part   = "api"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}



resource "aws_api_gateway_integration" "createUser_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.backend_gw.id}"
  resource_id = "${aws_api_gateway_method.post_users.resource_id}"
  http_method = "${aws_api_gateway_method.post_users.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.createUser_lambda.invoke_arn}"

  depends_on = [aws_lambda_function.createUser_lambda]
}

resource "aws_api_gateway_deployment" "deployment_gw" {
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_method.post_users]
}

resource "aws_api_gateway_stage" "gw_stage" {
  deployment_id = aws_api_gateway_deployment.deployment_gw.id
  rest_api_id   = aws_api_gateway_rest_api.backend_gw.id
  stage_name    = "${var.stage_name}"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.deployment_gw.invoke_url}"
}