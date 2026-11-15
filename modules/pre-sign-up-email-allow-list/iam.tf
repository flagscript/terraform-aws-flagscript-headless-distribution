data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pre_sign_up_lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
  description        = "IAM role for the ${var.user_pool_name} cognito user pool pre-sign-up Lambda function."
  name               = "${local.title_user_pool_name}PreSignUpLambdaRole"
  tags = merge(
    {
      "Name" = "${local.title_user_pool_name}PreSignUpLambdaRole"
    },
    local.common_tags
  )
}

data "aws_iam_policy_document" "pre_sign_up_lambda_role_policy_document" {
  statement {
    actions = [
      "dynamodb:GetItem"
    ]
    effect    = "Allow"
    resources = concat([aws_dynamodb_table.allow_list_dynamo_table.arn], aws_dynamodb_table.allow_list_dynamo_table.replica[*].arn)
    sid       = "ReadAllowList"
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = [for loggroup in aws_cloudwatch_log_group.lambda_log_group : "${loggroup.arn}:*"]
    sid       = "WriteLogs"
  }
}

resource "aws_iam_role_policy" "pre_sign_up_lambda_role_policy" {
  name   = "pre-sign-up-lambda-role-policy"
  role   = aws_iam_role.pre_sign_up_lambda_role.id
  policy = data.aws_iam_policy_document.pre_sign_up_lambda_role_policy_document.json
}
