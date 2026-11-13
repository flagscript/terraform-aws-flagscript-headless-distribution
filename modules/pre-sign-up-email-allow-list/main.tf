# ---------------------------------------------------------------------------
# Lambda: an ES module bundle built from lambda/src by CI and committed at
# lambda/dist/index.mjs, so consumers of the module need no Node toolchain.
# ---------------------------------------------------------------------------
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/dist/index.mjs"
  output_path = "${path.module}/lambda/dist/lambda.zip"
  # Same zip (and so the same source_code_hash) on every machine, regardless
  # of the file permissions the checkout ended up with.
  output_file_mode = "0644"
}

resource "aws_lambda_function" "pre_sign_up" {
  depends_on       = [aws_iam_role_policy.pre_sign_up_lambda_role_policy]
  for_each         = toset(local.deployment_regions)
  region           = each.key
  function_name    = "${var.user_pool_name}-pre-sign-up"
  description      = "Cognito pre sign-up trigger: only allow-listed emails may sign up."
  role             = aws_iam_role.pre_sign_up_lambda_role.arn
  runtime          = "nodejs24.x"
  architectures    = ["arm64"]
  handler          = "index.handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  memory_size      = 128
  # Cognito waits at most 5 seconds for a trigger to respond.
  timeout = 5
  tags = merge(
    {
      "Name" = "${var.user_pool_name}-pre-sign-up"
    },
    local.common_tags
  )

  environment {
    variables = {
      ALLOW_LIST_TABLE = aws_dynamodb_table.allow_list_dynamo_table[each.key].name
      DENY_MESSAGE     = var.deny_message
    }
  }

  logging_config {
    application_log_level = var.lambda_application_log_level
    log_format            = "JSON"
    log_group             = aws_cloudwatch_log_group.lambda_log_group[each.key].name
    system_log_level      = var.lambda_system_log_level
  }

}

resource "aws_lambda_permission" "cognito_lambda_permission" {
  for_each      = toset(local.deployment_regions)
  region        = each.key
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_sign_up[each.key].function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.user_pool_arn[each.key]
}
