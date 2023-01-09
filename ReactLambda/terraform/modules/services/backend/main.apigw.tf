resource "aws_api_gateway_rest_api" "backend_gw" {
  name = "realworld-backend-${var.stage_name}"
}



resource "aws_api_gateway_resource" "api_resource" {
  parent_id   = aws_api_gateway_rest_api.backend_gw.root_resource_id
  path_part   = "api"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors1" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.api_resource.id
  depends_on = [aws_api_gateway_resource.api_resource]
}

resource "aws_api_gateway_resource" "users_resource" {
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "users"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors2" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.users_resource.id
  depends_on = [aws_api_gateway_resource.users_resource]
}

resource "aws_api_gateway_resource" "login_resource" {
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "login"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors3" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.login_resource.id
  depends_on = [aws_api_gateway_resource.login_resource]  
}

resource "aws_api_gateway_resource" "user_resource" {
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "user"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors4" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.user_resource.id
  depends_on = [aws_api_gateway_resource.user_resource]  
}

resource "aws_api_gateway_resource" "profiles_resource" {
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "profiles"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors5" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.profiles_resource.id
  depends_on = [aws_api_gateway_resource.profiles_resource]  
}

resource "aws_api_gateway_resource" "username_resource" {
  parent_id   = aws_api_gateway_resource.profiles_resource.id
  path_part   = "{username}"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors6" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.username_resource.id
  depends_on = [aws_api_gateway_resource.username_resource]  
}

resource "aws_api_gateway_resource" "follow_resource" {
  parent_id   = aws_api_gateway_resource.username_resource.id
  path_part   = "follow"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors7" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.follow_resource.id
  depends_on = [aws_api_gateway_resource.follow_resource]  
}

resource "aws_api_gateway_resource" "articles_resource" {
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "articles"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors8" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.articles_resource.id
  depends_on = [aws_api_gateway_resource.articles_resource]  
}

resource "aws_api_gateway_resource" "slug_resource" {
  parent_id   = aws_api_gateway_resource.articles_resource.id
  path_part   = "{slug}"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors9" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.slug_resource.id
  depends_on = [aws_api_gateway_resource.slug_resource]  
}

resource "aws_api_gateway_resource" "favorite_resource" {
  parent_id   = aws_api_gateway_resource.slug_resource.id
  path_part   = "favorite"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors10" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.favorite_resource.id
  depends_on = [aws_api_gateway_resource.favorite_resource]  
}

resource "aws_api_gateway_resource" "feed_resource" {
  parent_id   = aws_api_gateway_resource.articles_resource.id
  path_part   = "feed"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors11" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.feed_resource.id
  depends_on = [aws_api_gateway_resource.feed_resource]  
}

resource "aws_api_gateway_resource" "tags_resource" {
  parent_id   = aws_api_gateway_rest_api.backend_gw.root_resource_id
  path_part   = "tags"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors12" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.tags_resource.id
  depends_on = [aws_api_gateway_resource.tags_resource]  
}

resource "aws_api_gateway_resource" "comments_resource" {
  parent_id   = aws_api_gateway_resource.slug_resource.id
  path_part   = "comments"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors13" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.comments_resource.id
  depends_on = [aws_api_gateway_resource.comments_resource]  
}

resource "aws_api_gateway_resource" "id_resource" {
  parent_id   = aws_api_gateway_resource.comments_resource.id
  path_part   = "{id}"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors14" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.id_resource.id
  depends_on = [aws_api_gateway_resource.id_resource]  
}


resource "aws_api_gateway_resource" "ping_resource" {
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "ping"
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id
}

module "cors15" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.backend_gw.id
  api_resource_id = aws_api_gateway_resource.ping_resource.id
  depends_on = [aws_api_gateway_resource.ping_resource]  
}

resource "aws_api_gateway_deployment" "deployment_gw" {
  rest_api_id = aws_api_gateway_rest_api.backend_gw.id

  depends_on = [module.api_endpoint]

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      module.api_endpoint
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "gw_stage" {
  deployment_id = aws_api_gateway_deployment.deployment_gw.id
  rest_api_id   = aws_api_gateway_rest_api.backend_gw.id
  stage_name    = "${var.stage_name}"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.deployment_gw.invoke_url}"
}

