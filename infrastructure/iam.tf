# IAM Resources for AWS SecurityAgent Demo
# Intentionally overly-permissive configurations for demonstration purposes

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.environment}-user-api-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "retrieve-user-api"
  }
}

# IAM Policy for Lambda - OVERLY BROAD CROSS-TABLE ACCESS
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "dynamodb-access"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"  # ISSUE: Too broad permissions
        ]
        Resource = [
          aws_dynamodb_table.users_table.arn,
          aws_dynamodb_table.products_table.arn,
          aws_dynamodb_table.orders_table.arn,
          aws_dynamodb_table.transactions_table.arn,
          "${aws_dynamodb_table.products_table.arn}/index/*",
          "${aws_dynamodb_table.orders_table.arn}/index/*",
          "${aws_dynamodb_table.transactions_table.arn}/index/*"
        ]
        # ISSUE: All functions can access all tables
        # ISSUE: Financial data accessible by user management functions
        # ISSUE: No principle of least privilege
      }
    ]
  })
}

# CloudWatch Logs IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_logging_policy" {
  name = "lambda-logging"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      }
    ]
  })
}

# Attach basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}