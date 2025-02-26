resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_${var.stage_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "lambda" {
  function_name = "Function-${var.stage_name}"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "nodejs18.x"
  filename      = "./lambda/function.zip"
  source_code_hash = filebase64sha256("./lambda/function.zip")
  timeout = abs(15)
  environment {
    variables = {
      EXAMPLE = "VALUE"
    }
  }
}
