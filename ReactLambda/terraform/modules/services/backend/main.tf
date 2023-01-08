provider "aws" {
  region = "eu-central-1"
}
locals {
  lambda_function_zip_name = "function.zip"
}

variable "stage_name" {
  type = string
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "reactlambda-terraform"
    key    = "${var.stage_name}/db/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "archive_file" "lambda_package" {
  type = "zip"
  source_dir  = "${path.module}/../../../../backend"
  output_path = "${local.lambda_function_zip_name}"
}

locals {
  build_directory_path = "${path.module}/build"
  lambda_common_libs_layer_path = "${path.module}/../../../../backend/"
  lambda_common_libs_layer_zip_name = "${local.build_directory_path}/commonLibs.zip"
}

resource "null_resource" "backend_lambda_nodejs_layer" {
  provisioner "local-exec" {
    working_dir = "${local.lambda_common_libs_layer_path}/nodejs"
    command = "npm install"
  }

  triggers = {
    rerun_every_time = "${uuid()}"
  }
}

data "archive_file" "lambda_common_libs_layer_package" {
  type = "zip"
  source_dir = "${local.lambda_common_libs_layer_path}"
  output_path = "${local.lambda_common_libs_layer_zip_name}"

  depends_on = [null_resource.backend_lambda_nodejs_layer]
}

resource "aws_lambda_layer_version" "backend_lambda_nodejs_layer" {
  layer_name = "commonLibs"
  filename = "${local.lambda_common_libs_layer_zip_name}"
  source_code_hash = "${data.archive_file.lambda_common_libs_layer_package.output_base64sha256}"
  compatible_runtimes = ["nodejs12.x"]
}

locals {
  lambda_function_name_createUser = "createUser-lambda-${var.stage_name}"
  lambda_function_name_loginUser = "loginUser-lambda-${var.stage_name}"
  lambda_function_name_getUser = "getUser-lambda-${var.stage_name}"
  lambda_function_name_updateUser = "updateUser-lambda-${var.stage_name}"
}

resource "aws_cloudwatch_log_group" "loginUser_logging" {
  name = "/aws/lambda/${local.lambda_function_name_loginUser}"
}

resource "aws_lambda_function" "loginUser_lambda" {
  function_name = "${local.lambda_function_name_loginUser}"
  filename = "${local.lambda_function_zip_name}"
  source_code_hash = "${data.archive_file.lambda_package.output_base64sha256}"
  handler = "src/User.login"
  runtime = "nodejs12.x"
  publish = "true"
  timeout = 60
  role = "${aws_iam_role.lambda_role.arn}"
  depends_on = [aws_cloudwatch_log_group.loginUser_logging]
  layers = ["${aws_lambda_layer_version.backend_lambda_nodejs_layer.arn}"]

  environment {
    variables = {
      DYNAMODB_NAMESPACE = "${var.stage_name}"
    }
  }  
}

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

