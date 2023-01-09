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

module "api_endpoint" {
  source = ".//api_endpoint"

  parent_resource_id = aws_api_gateway_resource.api_resource.id
  gateway_id = aws_api_gateway_rest_api.backend_gw.id
  iam_role_arm = aws_iam_role.lambda_role.arn
  stage_name = var.stage_name
  gateway_execution_arn = aws_api_gateway_rest_api.backend_gw.execution_arn
  function_configs = {
    "createUser": {
        "handler": "users-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.users_resource.id
    },
    "loginUser": {
        "handler": "users-login-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.login_resource.id
    },
    "getUser": {
        "handler": "user-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.user_resource.id
    },
    "updateUser": {
        "handler": "user-put",
        "verb": "PUT",
        "resource": aws_api_gateway_resource.user_resource.id
    },
    "getProfile": {
        "handler": "profiles-get",
        "verb": "PUT",
        "resource": aws_api_gateway_resource.username_resource.id
    },
    "followUser": {
        "handler": "profiles-follow-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.follow_resource.id
    },
    "unfollowUser": {
        "handler": "profiles-follow-delete",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.follow_resource.id
    },
    "createArticle": {
        "handler": "articles-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.articles_resource.id
    },
    "getArticle": {
        "handler": "articles-slug-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.slug_resource.id
    },
    "udpateArticle": {
        "handler": "articles-slug-put",
        "verb": "PUT",
        "resource": aws_api_gateway_resource.slug_resource.id
    },
    "deleteArticle": {
        "handler": "articles-slug-delete",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.slug_resource.id
    },
    "favoriteArticle": {
        "handler": "favorite-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.favorite_resource.id
    },
    "unfavoriteArticle": {
        "handler": "favorite-delete",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.favorite_resource.id
    },
    "getArticlesFeed": {
        "handler": "articles-feed-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.feed_resource.id
    },
    "getTags": {
        "handler": "tags-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.tags_resource.id
    },
    "listArticles": {
        "handler": "articles-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.articles_resource.id
    },
    "createComment": {
        "handler": "comments-post",
        "verb": "POST",
        "resource": aws_api_gateway_resource.comments_resource.id
    },
    "getComments": {
        "handler": "comments-get",
        "verb": "GET",
        "resource": aws_api_gateway_resource.comments_resource.id
    },
    "deleteComment": {
        "handler": "comments-delete",
        "verb": "DELETE",
        "resource": aws_api_gateway_resource.id_resource.id
    }
  }
}



