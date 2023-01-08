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

module "api_endpoint" {
  source = ".//api_endpoint"

  parent_resource_id = aws_api_gateway_resource.api_resource.id
  gateway_id = aws_api_gateway_rest_api.backend_gw.id
  backend_lambda_nodejs_layer_arn = aws_lambda_layer_version.backend_lambda_nodejs_layer.arn
  iam_role_arm = aws_iam_role.lambda_role.arn
  source_code_hash = "${data.archive_file.lambda_package.output_base64sha256}"
  stage_name = var.stage_name
  zip_name = "${local.lambda_function_zip_name}"  
  function_names_handlers_verbs = [
    ["createUser", "src/User.create", "POST", aws_api_gateway_resource.users_resource.id],
    ["loginUser", "src/User.login", "POST", aws_api_gateway_resource.login_resource.id],
    ["getUser", "src/User.get", "GET", aws_api_gateway_resource.user_resource.id],
    ["updateUser", "src/User.update", "PUT", aws_api_gateway_resource.user_resource.id],
    ["getProfile", "src/User.getProfile", "PUT", aws_api_gateway_resource.username_resource.id],
    ["followUser", "src/User.follow", "POST", aws_api_gateway_resource.follow_resource.id],
    ["unfollowUser", "src/User.follow", "DELETE", aws_api_gateway_resource.follow_resource.id],    
    ["createArticle", "src/Article.create", "POST", aws_api_gateway_resource.articles_resource.id],    
    ["getArticle", "src/Article.get", "GET", aws_api_gateway_resource.slug_resource.id],    
    ["udpateArticle", "src/Article.update", "PUT", aws_api_gateway_resource.slug_resource.id],    
    ["deleteArticle", "src/Article.delete", "DELETE", aws_api_gateway_resource.slug_resource.id],    
    ["favoriteArticle", "src/Article.favorite", "POST", aws_api_gateway_resource.favorite_resource.id],    
    ["unfavoriteArticle", "src/Article.favorite", "DELETE", aws_api_gateway_resource.favorite_resource.id],    
    ["listArticles", "src/Article.list", "GET", aws_api_gateway_resource.articles_resource.id],    
    ["getArticlesFeed", "src/Article.getFeed", "GET", aws_api_gateway_resource.feed_resource.id],    
    ["getTags", "src/Article.getTags", "GET", aws_api_gateway_resource.tags_resource.id],    
    ["createComment", "src/Comment.create", "POST", aws_api_gateway_resource.comments_resource.id],    
    ["getComments", "src/Comment.get", "GET", aws_api_gateway_resource.comments_resource.id],    
    ["deleteComment", "src/Comment.delete", "DELETE", aws_api_gateway_resource.id_resource.id],    
    ["ping", "src/Util.ping", "GET", aws_api_gateway_resource.ping_resource.id],    
  ]
}