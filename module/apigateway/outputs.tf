output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}/dispatch"
}

output "api_gateway_api_key" {
  value = aws_api_gateway_api_key.api_key.value
  sensitive = true
}
