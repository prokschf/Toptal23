provider "aws" {
  region = "eu-central-1"
}

variable "stage_name" {
  type = string
}

resource "aws_dynamodb_table" "realworld-users-table" {
  name           = "realworld-${var.stage_name}-users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "username"

  attribute {
    name = "username"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name               = "email"
    hash_key           = "email"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-articles-table" {
  name           = "realworld-${var.stage_name}-articles"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "slug"

  attribute {
    name = "slug"
    type = "S"
  }

  attribute {
    name = "dummy"
    type = "S"
  }

  attribute {
    name = "updatedAt"
    type = "N"
  }

  global_secondary_index {
    name               = "updatedAt"
    hash_key           = "dummy"
    range_key          = "updatedAt"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = {
    Environment = "${var.stage_name}"
  }
}

resource "aws_dynamodb_table" "realworld-comments-table" {
  name           = "realworld-${var.stage_name}-comments"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "slug"
    type = "S"
  }

  global_secondary_index {
    name               = "article"
    hash_key           = "slug"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = {
    Environment = "${var.stage_name}"
  }
}