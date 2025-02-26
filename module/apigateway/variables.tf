variable "aws_region" {
  type = string
  default = "ap-northeast-1"
}

variable "stage_name" {
  description = "The deployment stage name (dev or prd)"
  type = string
  default = "dev"

  validation {
    condition = var.stage_name == "dev" || var.stage_name == "prd"
    error_message = "The stage name must be either 'dev' or 'prd'."
  }
}

variable "lambda_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}
