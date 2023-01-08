provider "aws" {
  region = "eu-central-1"
}
locals {
  lambda_function_zip_name = "function.zip"
}

variable "test_lambda_function_stage" {
  type = string
  default = "testStage"
}

data "aws_iam_policy_document" "test_lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "test_lambda_role" {
  name = "test-lambda-${var.test_lambda_function_stage}-eu-west-1-lambdaRole"
  assume_role_policy = "${data.aws_iam_policy_document.test_lambda_assume_role_policy.json}"

}

locals {
  lambda_function_name_createUser = "createUser-lambda-${var.test_lambda_function_stage}"
  lambda_function_name_loginUser = "loginUser-lambda-${var.test_lambda_function_stage}"
  lambda_function_name_getUser = "getUser-lambda-${var.test_lambda_function_stage}"
  lambda_function_name_updateUser = "updateUser-lambda-${var.test_lambda_function_stage}"
}

data "aws_iam_policy_document" "cloudwatch_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]

    resources = ["${aws_cloudwatch_log_group.test_lambda_logging.arn}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.test_lambda_logging.arn}:*"]
  }
}

resource "aws_iam_role_policy" "test_lambda_cloudwatch_policy" {
  name = "test-lambda-${var.test_lambda_function_stage}-cloudwatch-policy"
  policy = "${data.aws_iam_policy_document.cloudwatch_role_policy_document.json}"
  role = "${aws_iam_role.test_lambda_role.id}"
}

data "archive_file" "test_lambda_package" {
  type = "zip"
  source_dir  = "${path.module}/../backend"
  output_path = "${local.lambda_function_zip_name}"
}


resource "aws_cloudwatch_log_group" "test_lambda_logging" {
  name = "/aws/lambda/${local.lambda_function_name_createUser}"
}

locals {
  build_directory_path = "${path.module}/build"
  lambda_common_libs_layer_path = "${path.module}/../backend/"
  lambda_common_libs_layer_zip_name = "${local.build_directory_path}/commonLibs.zip"
}

resource "null_resource" "test_lambda_nodejs_layer" {
  provisioner "local-exec" {
    working_dir = "${local.lambda_common_libs_layer_path}/nodejs"
    command = "npm install"
  }

  triggers = {
    rerun_every_time = "${uuid()}"
  }
}

data "archive_file" "test_lambda_common_libs_layer_package" {
  type = "zip"
  source_dir = "${local.lambda_common_libs_layer_path}"
  output_path = "${local.lambda_common_libs_layer_zip_name}"

  depends_on = ["null_resource.test_lambda_nodejs_layer"]
}

resource "aws_lambda_layer_version" "test_lambda_nodejs_layer" {
  layer_name = "commonLibs"
  filename = "${local.lambda_common_libs_layer_zip_name}"
  source_code_hash = "${data.archive_file.test_lambda_common_libs_layer_package.output_base64sha256}"
  compatible_runtimes = ["nodejs12.x"]
}




resource "aws_lambda_function" "loginUser_lambda" {
  function_name = "${local.lambda_function_name_loginUser}"
  filename = "${local.lambda_function_zip_name}"
  source_code_hash = "${data.archive_file.test_lambda_package.output_base64sha256}"
  handler = "src/User.login"
  runtime = "nodejs12.x"
  publish = "true"
  role = "${aws_iam_role.test_lambda_role.arn}"
  depends_on = [aws_cloudwatch_log_group.test_lambda_logging]
  layers = ["${aws_lambda_layer_version.test_lambda_nodejs_layer.arn}"]
}
