resource "aws_iam_role_policy" "backend_lambda_policy" {
  name = "backend-lambda-${var.stage_name}-cloudwatch-policy"
  policy = "${data.aws_iam_policy_document.cloudwatch_role_policy_document.json}"
  role = "${aws_iam_role.lambda_role.id}"
}

resource "aws_iam_role" "lambda_role" {
  name = "reactlambda-backend-lambda-${var.stage_name}-lambdaRole"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role_policy.json}"
}

data "aws_iam_policy_document" "cloudwatch_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:DescribeTable",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem"]
    resources = [
      "${data.terraform_remote_state.db.outputs.users-table.arn}/*",
      "${data.terraform_remote_state.db.outputs.articles-table.arn}/*",
      "${data.terraform_remote_state.db.outputs.comments-table.arn}/*",
    ]
  }  
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}