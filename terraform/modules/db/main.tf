provider "aws" {
  region = "eu-central-1"
}

variable "stage_name" {
  type = string
}

resource "aws_dynamodb_table" "realworld-user-table" {
  name           = "realworld-${var.stage_name}-user"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Username"

  attribute {
    name = "Username"
    type = "S"
  }

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-email-user-table" {
  name           = "realworld-${var.stage_name}-email-user"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Email"

  attribute {
    name = "Email"
    type = "S"
  }

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-follow-table" {
  name           = "realworld-${var.stage_name}-follow"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Follower"
  range_key       = "Publisher"

  attribute {
    name = "Follower"
    type = "S"
  }

  attribute {
    name = "Publisher"
    type = "S"
  }

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-article-table" {
  name           = "realworld-${var.stage_name}-article"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ArticleId"

  attribute {
    name = "ArticleId"
    type = "N"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  attribute {
    name = "Dummy"
    type = "N"
  }

  attribute {
    name = "Author"
    type = "S"
  }

  global_secondary_index {
    name               = "CreatedAt"
    hash_key           = "Dummy"
    range_key          = "CreatedAt"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }  

  global_secondary_index {
    name               = "Author"
    hash_key           = "Author"
    range_key          = "CreatedAt"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }    

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-article-tag-table" {
  name           = "realworld-${var.stage_name}-article-tag"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Tag"
  range_key       = "ArticleId"

  attribute {
    name = "Tag"
    type = "S"
  }

  attribute {
    name = "ArticleId"
    type = "N"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  local_secondary_index {
    name               = "CreatedAt"
    #hash_key           = "Tag"
    range_key          = "CreatedAt"
    projection_type    = "ALL"
  }  

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-tag-table" {
  name           = "realworld-${var.stage_name}-tag"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Tag"

  attribute {
    name = "Tag"
    type = "S"
  }

  attribute {
    name = "ArticleCount"
    type = "N"
  }

  attribute {
    name = "Dummy"
    type = "N"
  }

  global_secondary_index {
    name               = "ArticleCount"
    hash_key           = "Dummy"
    range_key          = "ArticleCount"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }  

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-favorite-article-table" {
  name           = "realworld-${var.stage_name}-favorite-article"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Username"
  range_key       = "ArticleId"

  attribute {
    name = "Username"
    type = "S"
  }

  attribute {
    name = "ArticleId"
    type = "N"
  }

  attribute {
    name = "FavoritedAt"
    type = "N"
  }

  local_secondary_index {
    name               = "FavoritedAt"
    #hash_key           = "Username"
    range_key          = "FavoritedAt"
    projection_type    = "ALL"
  }  

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-comment-table" {
  name           = "realworld-${var.stage_name}-comment"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ArticleId"
  range_key       = "CommentId"

  attribute {
    name = "ArticleId"
    type = "N"
  }

  attribute {
    name = "CommentId"
    type = "N"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  local_secondary_index {
    name               = "CreatedAt"
    #hash_key           = "ArticleId"
    range_key          = "CreatedAt"
    projection_type    = "ALL"
  }  

  tags = {
    Environment = "${var.stage_name}"
  }
}