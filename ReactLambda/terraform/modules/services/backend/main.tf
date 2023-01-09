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
/*
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
*/


data "archive_file" "lambda_package" {
  type = "zip"
  source_file  = "${path.module}/../../../../backend-go/bin/articles-get"
  output_path = "${local.lambda_function_zip_name}"
}


module "api_endpoint" {
  source = ".//api_endpoint"

  parent_resource_id = aws_api_gateway_resource.api_resource.id
  gateway_id = aws_api_gateway_rest_api.backend_gw.id
  backend_lambda_nodejs_layer_arn = ""#aws_lambda_layer_version.backend_lambda_nodejs_layer.arn
  iam_role_arm = aws_iam_role.lambda_role.arn
  source_code_hash = "${data.archive_file.lambda_package.output_base64sha256}"
  stage_name = var.stage_name
  gateway_execution_arn = aws_api_gateway_rest_api.backend_gw.execution_arn
  zip_name = "${local.lambda_function_zip_name}"  
  function_configs = {
        "listArticles": {
        "handler": "articles-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.articles_resource.id
    },
    /*"createUser": {
        #"handler": "src/User.create",
        "handler": "users-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.users_resource.id
    },
    "loginUser": {
        "handler": "src/User.login",
        "verb": "POST",
        "resource": aws_api_gateway_resource.login_resource.id
    },
    "getUser": {
        "handler": "src/User.get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.user_resource.id
    },
    "updateUser": {
        "handler": "src/User.update",
        "verb": "PUT",
        "resource": aws_api_gateway_resource.user_resource.id
    },
    "getProfile": {
        "handler": "src/User.getProfile",
        "verb": "PUT",
        "resource": aws_api_gateway_resource.username_resource.id
    },
    "followUser": {
        "handler": "src/User.follow",
        "verb": "POST",
        "resource": aws_api_gateway_resource.follow_resource.id
    },
    "unfollowUser": {
        "handler": "src/User.follow",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.follow_resource.id
    },
    "createArticle": {
        "handler": "src/Article.create",
        "verb": "POST",
        "resource": aws_api_gateway_resource.articles_resource.id
    },
    "getArticle": {
        "handler": "src/Article.get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.slug_resource.id
    },
    "udpateArticle": {
        "handler": "src/Article.update",
        "verb": "PUT",
        "resource": aws_api_gateway_resource.slug_resource.id
    },
    "deleteArticle": {
        "handler": "src/Article.delete",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.slug_resource.id
    },
    "favoriteArticle": {
        "handler": "src/Article.favorite",
        "verb": "POST",
        "resource": aws_api_gateway_resource.favorite_resource.id
    },
    "unfavoriteArticle": {
        "handler": "src/Article.favorite",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.favorite_resource.id
    },
    "getArticlesFeed": {
        "handler": "src/Article.getFeed",
        "verb": "GET",
        "resource": aws_api_gateway_resource.feed_resource.id
    },
    "getTags": {
        "handler": "src/Article.getTags",
        "verb": "GET",
        "resource": aws_api_gateway_resource.tags_resource.id
    },
    "listArticles": {
        "handler": "src/Article.list",
        "verb": "GET",
        "resource": aws_api_gateway_resource.articles_resource.id
    },
    "createComment": {
        "handler": "src/Comment.create",
        "verb": "POST",
        "resource": aws_api_gateway_resource.comments_resource.id
    },
    "getComments": {
        "handler": "src/Comment.get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.comments_resource.id
    },
    "deleteComment": {
        "handler": "src/Comment.delete",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.id_resource.id
    },
    "ping": {
        "handler": "src/Util.ping",
        "verb": "GET",
        "resource": aws_api_gateway_resource.ping_resource.id
    }*/
  }
}

