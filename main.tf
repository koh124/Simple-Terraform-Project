provider "aws" {
  region = "ap-northeast-1"
}

module "lambda" {
  source = "./module/lambda"
  aws_region = var.aws_region
  stage_name = var.stage_name
}

module "apigateway" {
  source = "./module/apigateway"
  aws_region = var.aws_region
  stage_name = var.stage_name
  lambda_function_name = module.lambda.lambda_function_name
  lambda_arn = module.lambda.lambda_arn
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}

output "api_gateway_invoke_url" {
  value = module.apigateway.api_gateway_invoke_url
}

output "api_gateway_api_key" {
  value = module.apigateway.api_gateway_api_key
  sensitive = true
}
