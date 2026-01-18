# Lambda Functions for AWS SecurityAgent Demo
# Intentionally misconfigured with varying resource allocations for demonstration purposes

# ===== USER MANAGEMENT FUNCTIONS =====

# Lambda Function - Get User (GET /users/{userId})
resource "aws_lambda_function" "get_user_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-get-user-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "get_user.lambda_handler"
  runtime         = "python3.11"
  timeout         = 30  # ISSUE: Too high for DynamoDB operation
  memory_size     = 128 # ISSUE: Might be too low for Python cold starts

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }

  # ISSUE: No X-Ray tracing enabled
  # ISSUE: No reserved concurrency
  # ISSUE: No dead letter queue

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.lambda_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "retrieve-user-api"
  }
}

# Lambda Function - Create User (POST /users)
resource "aws_lambda_function" "create_user_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-create-user-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "create_user.lambda_handler"
  runtime         = "python3.11"
  timeout         = 45  # ISSUE: Even higher timeout for write operations
  memory_size     = 256 # ISSUE: Inconsistent memory allocation

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }

  # ISSUE: Same security gaps as get_user_function
  # ISSUE: No input validation for POST data
  # ISSUE: No duplicate prevention

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.create_user_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "create-user-api"
  }
}

# Lambda Function - Update User (PUT /users/{userId})
resource "aws_lambda_function" "update_user_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-update-user-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "update_user.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60  # ISSUE: Extremely high timeout
  memory_size     = 512 # ISSUE: Over-provisioned memory

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }

  # ISSUE: Same IAM role with excessive permissions
  # ISSUE: No conditional update logic
  # ISSUE: No optimistic locking

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.update_user_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "update-user-api"
  }
}

# Lambda Function - Delete User (DELETE /users/{userId})
resource "aws_lambda_function" "delete_user_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-delete-user-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "delete_user.lambda_handler"
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }

  # ISSUE: Hard delete without soft delete option
  # ISSUE: No audit trail for deletions
  # ISSUE: Same overly broad IAM permissions

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.delete_user_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "delete-user-api"
  }
}

# Lambda Function - List Users (GET /users)
resource "aws_lambda_function" "list_users_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-list-users-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "list_users.lambda_handler"
  runtime         = "python3.11"
  timeout         = 90  # ISSUE: Dangerously high timeout for scan operations
  memory_size     = 1024 # ISSUE: Massively over-provisioned

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }

  # ISSUE: Will perform full table scans
  # ISSUE: No pagination implemented
  # ISSUE: No result size limits
  # ISSUE: Memory waste for simple operations

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.list_users_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "list-users-api"
  }
}

# ===== PRODUCT MANAGEMENT FUNCTIONS =====

# Lambda Function - List Products (GET /products)
resource "aws_lambda_function" "list_products_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-list-products-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "list_products.lambda_handler"
  runtime         = "python3.11"
  timeout         = 120  # ISSUE: Even higher timeout for product catalog
  memory_size     = 2048 # ISSUE: Extremely over-provisioned for product listing

  environment {
    variables = {
      PRODUCTS_TABLE = aws_dynamodb_table.products_table.name
    }
  }

  # ISSUE: Same overly broad IAM permissions
  # ISSUE: No caching for product catalog
  # ISSUE: Will scan entire product table

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.list_products_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "product-api"
    Component   = "product-catalog"
  }
}

# Lambda Function - Get Product (GET /products/{productId})
resource "aws_lambda_function" "get_product_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-get-product-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "get_product.lambda_handler"
  runtime         = "python3.11"
  timeout         = 15
  memory_size     = 256

  environment {
    variables = {
      PRODUCTS_TABLE = aws_dynamodb_table.products_table.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.get_product_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "product-api"
    Component   = "product-details"
  }
}

# ===== ORDER MANAGEMENT FUNCTIONS =====

# Lambda Function - Create Order (POST /orders)
resource "aws_lambda_function" "create_order_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-create-order-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "create_order.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60  # ISSUE: High timeout for order creation
  memory_size     = 512

  environment {
    variables = {
      ORDERS_TABLE    = aws_dynamodb_table.orders_table.name
      PRODUCTS_TABLE  = aws_dynamodb_table.products_table.name
      USERS_TABLE     = aws_dynamodb_table.users_table.name
    }
  }

  # ISSUE: Cross-table access without proper validation
  # ISSUE: No inventory management
  # ISSUE: No order validation logic

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.create_order_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "order-api"
    Component   = "order-creation"
  }
}

# Lambda Function - Get User Orders (GET /users/{userId}/orders)
resource "aws_lambda_function" "get_user_orders_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-get-user-orders-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "get_user_orders.lambda_handler"
  runtime         = "python3.11"
  timeout         = 45
  memory_size     = 512

  environment {
    variables = {
      ORDERS_TABLE = aws_dynamodb_table.orders_table.name
    }
  }

  # ISSUE: No user authorization check
  # ISSUE: Exposes all user order data

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.get_user_orders_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "order-api"
    Component   = "user-orders"
  }
}

# ===== PAYMENT & TRANSACTION FUNCTIONS =====

# Lambda Function - Process Payment (POST /orders/{orderId}/payment)
resource "aws_lambda_function" "process_payment_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-process-payment-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "process_payment.lambda_handler"
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      ORDERS_TABLE       = aws_dynamodb_table.orders_table.name
      TRANSACTIONS_TABLE = aws_dynamodb_table.transactions_table.name
    }
  }

  # ISSUE: Handles financial data without encryption
  # ISSUE: No PCI compliance measures
  # ISSUE: No fraud detection
  # ISSUE: No payment gateway integration security

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.process_payment_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "payment-api"
    Component   = "payment-processing"
  }
}

# Lambda Function - Get Transactions (GET /transactions)
resource "aws_lambda_function" "get_transactions_function" {
  filename         = "lambda_deployment.zip"
  function_name    = "${var.environment}-get-transactions-function"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "get_transactions.lambda_handler"
  runtime         = "python3.11"
  timeout         = 180  # ISSUE: Extremely high timeout for financial data
  memory_size     = 3008 # ISSUE: Maximum memory allocation - massive waste

  environment {
    variables = {
      TRANSACTIONS_TABLE = aws_dynamodb_table.transactions_table.name
    }
  }

  # ISSUE: Exposes all financial transaction data
  # ISSUE: No access controls for sensitive financial information
  # ISSUE: Over-provisioned resources for simple queries

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_dynamodb_policy,
    aws_iam_role_policy.lambda_logging_policy,
    aws_cloudwatch_log_group.get_transactions_log_group,
  ]

  tags = {
    Environment = var.environment
    Application = "transaction-api"
    Component   = "transaction-reporting"
  }
}