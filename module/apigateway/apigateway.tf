# REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "api_${var.stage_name}"
  description = "description"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# resource "aws_api_gateway_rest_api_policy" "api_policy" {
#   rest_api_id = aws_api_gateway_rest_api.api.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action = "execute-api:Invoke",
#         Resource = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST",
#         # Condition = {
#         #   "IpAddress": {
#         #     "aws:SourceIp": [
#         #       "133.106.35.56"
#         #     ]
#         #   }
#         # }
#       }
#     ]
#   })
# }

# リソース
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "dispatch"
}

# リクエストバリデータ
resource "aws_api_gateway_request_validator" "api_request_validator" {
  name = "api_request_validator_${var.stage_name}"
  rest_api_id = aws_api_gateway_rest_api.api.id
  validate_request_body = true
  validate_request_parameters = true
}

# メソッド
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
  request_validator_id = aws_api_gateway_request_validator.api_request_validator.id

  # request_models = {
  #   "application/json" = "Empty"
  # }

  request_parameters = {
    "method.request.header.x-api-key" = true
  }
}

# Lambdaプロキシ統合
resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
}

# LambdaのリソースベースポリシーでAPIGatewayからのアクセスのみに限定
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecuteLambdaFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# デプロイメント
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_method.post_method,
    aws_api_gateway_integration.integration
  ]
}

# デプロイメントのステージ
resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name = var.stage_name

  # xray_tracing_enabled = true

  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_log_group.arn
  #   format          = "{\"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\"}"
  # }
}

# cloudwatch ロググループの作成
# resource "aws_cloudwatch_log_group" "api_log_group" {
#   name = "/aws/apigateway/dispatch"
#   retention_in_days = 30
# }

# APIキー
resource "aws_api_gateway_api_key" "api_key" {
  name = "api_key_${var.stage_name}"
}

# 使用量プラン
resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name = "api_usage_plan_${var.stage_name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage = aws_api_gateway_stage.api_stage.stage_name
  }

  # quota_settings {
  #   limit = 500
  #   period = "WEEK"
  # }

  # throttle_settings {
  #   burst_limit = 100
  #   rate_limit = 100
  # }
}

# APIキーと使用量プランを関連付ける
resource "aws_api_gateway_usage_plan_key" "api_usage_plan_key" {
  key_id = aws_api_gateway_api_key.api_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}
