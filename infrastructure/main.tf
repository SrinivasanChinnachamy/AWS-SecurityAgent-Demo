# DynamoDB Table - Users - INTENTIONALLY LOW CAPACITY
resource "aws_dynamodb_table" "users_table" {
  name           = "${var.environment}-users-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5  # ISSUE: Too low - will cause throttling
  write_capacity = 5  # ISSUE: Too low for production

  hash_key = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  # ISSUE: No auto-scaling configuration
  # ISSUE: No backup configuration
  # ISSUE: No point-in-time recovery
  # ISSUE: No encryption at rest specified

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "retrieve-user-api"
  }
}

# DynamoDB Table - Products - DIFFERENT CAPACITY ISSUES
resource "aws_dynamodb_table" "products_table" {
  name           = "${var.environment}-products-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10  # ISSUE: Still too low for product catalog
  write_capacity = 2   # ISSUE: Extremely low write capacity

  hash_key = "productId"

  attribute {
    name = "productId"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  # ISSUE: GSI without proper capacity planning
  global_secondary_index {
    name            = "CategoryIndex"
    hash_key        = "category"
    read_capacity   = 3  # ISSUE: Dangerously low for GSI
    write_capacity  = 1  # ISSUE: Will cause immediate throttling
    projection_type = "ALL"
  }

  # ISSUE: Same security gaps as users table
  tags = {
    Environment = var.environment
    Application = "product-api"
    Component   = "product-catalog"
  }
}

# DynamoDB Table - Orders - MIXED BILLING MODES
resource "aws_dynamodb_table" "orders_table" {
  name           = "${var.environment}-orders-table"
  billing_mode   = "PAY_PER_REQUEST"  # ISSUE: Inconsistent billing mode

  hash_key  = "orderId"
  range_key = "userId"

  attribute {
    name = "orderId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "orderStatus"
    type = "S"
  }

  # ISSUE: GSI on sensitive order status without access controls
  global_secondary_index {
    name            = "UserOrdersIndex"
    hash_key        = "userId"
    range_key       = "orderStatus"
    projection_type = "ALL"
  }

  # ISSUE: No stream configuration for order processing
  # ISSUE: No TTL for old orders
  tags = {
    Environment = var.environment
    Application = "order-api"
    Component   = "order-management"
  }
}

# DynamoDB Table - Transactions - OVER-PROVISIONED
resource "aws_dynamodb_table" "transactions_table" {
  name           = "${var.environment}-transactions-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 100  # ISSUE: Massively over-provisioned - cost issue
  write_capacity = 50   # ISSUE: Expensive over-provisioning

  hash_key  = "transactionId"
  range_key = "timestamp"

  attribute {
    name = "transactionId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  # ISSUE: Financial data without encryption
  # ISSUE: No compliance controls for PCI/SOX
  global_secondary_index {
    name            = "UserTransactionsIndex"
    hash_key        = "userId"
    range_key       = "timestamp"
    read_capacity   = 50   # ISSUE: More over-provisioning
    write_capacity  = 25
    projection_type = "ALL"  # ISSUE: Exposes all transaction data
  }

  tags = {
    Environment = var.environment
    Application = "transaction-api"
    Component   = "payment-processing"
  }
}

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

# CloudWatch Log Group for Lambda Function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.environment}-get-user-function"
  retention_in_days = 60  # ISSUE: Short retention for production

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "retrieve-user-api"
  }
}

# Lambda Function
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

# API Gateway REST API
resource "aws_api_gateway_rest_api" "user_api" {
  name        = "${var.environment}-user-api"
  description = "User API for DevOps Agent Demo"

  # ISSUE: No API key requirement
  # ISSUE: No throttling configuration

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "retrieve-user-api"
  }
}

# API Gateway Resource - /users
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "users"
}

# API Gateway Resource - /users/{userId}
resource "aws_api_gateway_resource" "user_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_resource.users_resource.id
  path_part   = "{userId}"
}

# API Gateway Resource - /products
resource "aws_api_gateway_resource" "products_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "products"
}

# API Gateway Resource - /products/{productId}
resource "aws_api_gateway_resource" "product_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_resource.products_resource.id
  path_part   = "{productId}"
}

# API Gateway Resource - /orders
resource "aws_api_gateway_resource" "orders_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "orders"
}

# API Gateway Resource - /orders/{orderId}
resource "aws_api_gateway_resource" "order_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_resource.orders_resource.id
  path_part   = "{orderId}"
}

# API Gateway Resource - /transactions
resource "aws_api_gateway_resource" "transactions_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "transactions"
}

# API Gateway Resource - /transactions/{transactionId}
resource "aws_api_gateway_resource" "transaction_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_resource.transactions_resource.id
  path_part   = "{transactionId}"
}

# API Gateway Resource - /orders/{orderId}/payment
resource "aws_api_gateway_resource" "order_payment_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_resource.order_id_resource.id
  path_part   = "payment"
}

# API Gateway Resource - /users/{userId}/orders
resource "aws_api_gateway_resource" "user_orders_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_resource.user_id_resource.id
  path_part   = "orders"
}

# ===== PRODUCT API METHODS =====

# API Gateway Method - GET /products (List Products)
resource "aws_api_gateway_method" "list_products_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.products_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: No authentication for product catalog

  # ISSUE: No request validation for query parameters
  # ISSUE: No rate limiting for expensive catalog operations
}

# API Gateway Integration - GET /products
resource "aws_api_gateway_integration" "list_products_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.products_resource.id
  http_method = aws_api_gateway_method.list_products_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.list_products_function.invoke_arn
}

# API Gateway Method - GET /products/{productId}
resource "aws_api_gateway_method" "get_product_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.product_id_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: No authentication

  # ISSUE: No request validation for productId format
}

# API Gateway Integration - GET /products/{productId}
resource "aws_api_gateway_integration" "get_product_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.product_id_resource.id
  http_method = aws_api_gateway_method.get_product_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_product_function.invoke_arn
}

# ===== ORDER API METHODS =====

# API Gateway Method - POST /orders (Create Order)
resource "aws_api_gateway_method" "create_order_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.orders_resource.id
  http_method   = "POST"
  authorization = "NONE"  # ISSUE: No authentication for order creation

  # ISSUE: No request validation for order data
  # ISSUE: No content-type validation
}

# API Gateway Integration - POST /orders
resource "aws_api_gateway_integration" "create_order_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.orders_resource.id
  http_method = aws_api_gateway_method.create_order_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.create_order_function.invoke_arn
}

# API Gateway Method - GET /users/{userId}/orders
resource "aws_api_gateway_method" "get_user_orders_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user_orders_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: No authentication for sensitive order data

  # ISSUE: No user authorization check
  # ISSUE: No request validation
}

# API Gateway Integration - GET /users/{userId}/orders
resource "aws_api_gateway_integration" "get_user_orders_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_orders_resource.id
  http_method = aws_api_gateway_method.get_user_orders_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_user_orders_function.invoke_arn
}

# ===== PAYMENT & TRANSACTION API METHODS =====

# API Gateway Method - POST /orders/{orderId}/payment
resource "aws_api_gateway_method" "process_payment_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.order_payment_resource.id
  http_method   = "POST"
  authorization = "NONE"  # ISSUE: No authentication for financial operations

  # ISSUE: No request validation for payment data
  # ISSUE: No PCI compliance measures
  # ISSUE: No fraud detection integration
}

# API Gateway Integration - POST /orders/{orderId}/payment
resource "aws_api_gateway_integration" "process_payment_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.order_payment_resource.id
  http_method = aws_api_gateway_method.process_payment_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.process_payment_function.invoke_arn
}

# API Gateway Method - GET /transactions
resource "aws_api_gateway_method" "get_transactions_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.transactions_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: No authentication for sensitive financial data

  # ISSUE: No admin role validation
  # ISSUE: No audit logging for financial data access
  # ISSUE: No request validation
}

# API Gateway Integration - GET /transactions
resource "aws_api_gateway_integration" "get_transactions_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.transactions_resource.id
  http_method = aws_api_gateway_method.get_transactions_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_transactions_function.invoke_arn
}

# ===== USER API METHODS =====
resource "aws_api_gateway_method" "create_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "POST"
  authorization = "NONE"  # ISSUE: No authentication for create operations

  # ISSUE: No request validation for POST body
  # ISSUE: No content-type validation
}

# API Gateway Integration - POST /users
resource "aws_api_gateway_integration" "create_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.create_user_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.create_user_function.invoke_arn
}

# API Gateway Method - GET /users (List Users)
resource "aws_api_gateway_method" "list_users_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: Public access to list all users

  # ISSUE: No pagination parameters validation
  # ISSUE: No result size limits
}

# API Gateway Integration - GET /users
resource "aws_api_gateway_integration" "list_users_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.users_resource.id
  http_method = aws_api_gateway_method.list_users_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.list_users_function.invoke_arn
}

# API Gateway Method - PUT /users/{userId} (Update User)
resource "aws_api_gateway_method" "update_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user_id_resource.id
  http_method   = "PUT"
  authorization = "NONE"  # ISSUE: No authentication for updates

  # ISSUE: No request validation
  # ISSUE: No conditional update headers
}

# API Gateway Integration - PUT /users/{userId}
resource "aws_api_gateway_integration" "update_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_id_resource.id
  http_method = aws_api_gateway_method.update_user_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.update_user_function.invoke_arn
}

# API Gateway Method - DELETE /users/{userId} (Delete User)
resource "aws_api_gateway_method" "delete_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user_id_resource.id
  http_method   = "DELETE"
  authorization = "NONE"  # ISSUE: No authentication for deletions

  # ISSUE: No confirmation required for destructive operations
}

# API Gateway Integration - DELETE /users/{userId}
resource "aws_api_gateway_integration" "delete_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_id_resource.id
  http_method = aws_api_gateway_method.delete_user_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.delete_user_function.invoke_arn
}

# Lambda Permissions for API Gateway - Additional Functions
resource "aws_lambda_permission" "api_gateway_invoke_create" {
  statement_id  = "AllowExecutionFromAPIGatewayCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_update" {
  statement_id  = "AllowExecutionFromAPIGatewayUpdate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_delete" {
  statement_id  = "AllowExecutionFromAPIGatewayDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_list" {
  statement_id  = "AllowExecutionFromAPIGatewayList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_users_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# ===== PRODUCT API PERMISSIONS =====

resource "aws_lambda_permission" "api_gateway_invoke_list_products" {
  statement_id  = "AllowExecutionFromAPIGatewayListProducts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_get_product" {
  statement_id  = "AllowExecutionFromAPIGatewayGetProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# ===== ORDER API PERMISSIONS =====

resource "aws_lambda_permission" "api_gateway_invoke_create_order" {
  statement_id  = "AllowExecutionFromAPIGatewayCreateOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_get_user_orders" {
  statement_id  = "AllowExecutionFromAPIGatewayGetUserOrders"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_orders_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# ===== PAYMENT & TRANSACTION API PERMISSIONS =====

resource "aws_lambda_permission" "api_gateway_invoke_process_payment" {
  statement_id  = "AllowExecutionFromAPIGatewayProcessPayment"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_payment_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_get_transactions" {
  statement_id  = "AllowExecutionFromAPIGatewayGetTransactions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_transactions_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# API Gateway Method - GET /users/{userId}
resource "aws_api_gateway_method" "get_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user_id_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: No authentication

  # ISSUE: No request validation
# API Gateway Integration - GET /users/{userId}
resource "aws_api_gateway_integration" "get_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_id_resource.id
  http_method = aws_api_gateway_method.get_user_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_user_function.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    # User API methods
    aws_api_gateway_method.get_user_method,
    aws_api_gateway_integration.get_user_integration,
    aws_api_gateway_method.create_user_method,
    aws_api_gateway_integration.create_user_integration,
    aws_api_gateway_method.update_user_method,
    aws_api_gateway_integration.update_user_integration,
    aws_api_gateway_method.delete_user_method,
    aws_api_gateway_integration.delete_user_integration,
    aws_api_gateway_method.list_users_method,
    aws_api_gateway_integration.list_users_integration,
    
    # Product API methods
    aws_api_gateway_method.list_products_method,
    aws_api_gateway_integration.list_products_integration,
    aws_api_gateway_method.get_product_method,
    aws_api_gateway_integration.get_product_integration,
    
    # Order API methods
    aws_api_gateway_method.create_order_method,
    aws_api_gateway_integration.create_order_integration,
    aws_api_gateway_method.get_user_orders_method,
    aws_api_gateway_integration.get_user_orders_integration,
    
    # Payment & Transaction API methods
    aws_api_gateway_method.process_payment_method,
    aws_api_gateway_integration.process_payment_integration,
    aws_api_gateway_method.get_transactions_method,
    aws_api_gateway_integration.get_transactions_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.user_api.id
  stage_name  = var.environment

  # ISSUE: No stage configuration for throttling across all endpoints
  # ISSUE: No logging configuration for financial transactions
  # ISSUE: No caching configuration for product catalog
  # ISSUE: No WAF association for enterprise API protection
  # ISSUE: No API key requirement across all business-critical methods
  # ISSUE: No different throttling limits for different endpoint types
}

# MISSING ENTERPRISE RESOURCES:
# - CloudWatch Alarms for each business domain (Users, Products, Orders, Payments)
# - DynamoDB Auto Scaling policies for all tables
# - Lambda Dead Letter Queues for all functions
# - X-Ray Tracing configuration across all services
# - VPC Configuration for Lambda functions handling sensitive data
# - WAF for API Gateway protection against common attacks
# - API Gateway Usage Plans and API Keys for different access tiers
# - Lambda Reserved Concurrency settings per business domain
# - Custom CloudWatch Metrics for business KPIs
# - SNS Topics for alerting on financial transaction failures
# - Parameter Store for configuration management
# - Secrets Manager for sensitive data (API keys, database credentials)
# - KMS keys for encryption of sensitive business data
# - S3 buckets for audit logs and compliance data
# - EventBridge for decoupled event-driven architecture

# ISSUE: No CloudWatch alarms configured for any business domain
# ISSUE: No error rate monitoring across the enterprise API
# ISSUE: No duration monitoring for performance across services
# ISSUE: No throttling monitoring for DynamoDB across all tables
# ISSUE: No cost monitoring for over-provisioned resources
# ISSUE: No security monitoring for unauthorized access attempts
# ISSUE: No business metrics monitoring (order conversion, payment success rates)
# ISSUE: No compliance monitoring for financial data access
# ISSUE: No fraud detection monitoring for payment processing

# Lambda Function - Create User (POST)
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

# Lambda Function - Update User (PUT)
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

# Lambda Function - Delete User (DELETE)
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

# Additional CloudWatch Log Groups for new functions
resource "aws_cloudwatch_log_group" "create_user_log_group" {
  name              = "/aws/lambda/${var.environment}-create-user-function"
  retention_in_days = 30  # ISSUE: Even shorter retention

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "create-user-api"
  }
}

resource "aws_cloudwatch_log_group" "update_user_log_group" {
  name              = "/aws/lambda/${var.environment}-update-user-function"
  retention_in_days = 14  # ISSUE: Extremely short retention

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "update-user-api"
  }
}

resource "aws_cloudwatch_log_group" "delete_user_log_group" {
  name              = "/aws/lambda/${var.environment}-delete-user-function"
  retention_in_days = 7   # ISSUE: Critically short retention for audit

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "delete-user-api"
  }
}

resource "aws_cloudwatch_log_group" "list_users_log_group" {
  name              = "/aws/lambda/${var.environment}-list-users-function"
  retention_in_days = 90  # ISSUE: Inconsistent retention policies

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "list-users-api"
  }
}

# ===== PRODUCT API LOG GROUPS =====

resource "aws_cloudwatch_log_group" "list_products_log_group" {
  name              = "/aws/lambda/${var.environment}-list-products-function"
  retention_in_days = 30  # ISSUE: Different retention than users

  tags = {
    Environment = var.environment
    Application = "product-api"
    Component   = "product-catalog"
  }
}

resource "aws_cloudwatch_log_group" "get_product_log_group" {
  name              = "/aws/lambda/${var.environment}-get-product-function"
  retention_in_days = 14  # ISSUE: Very short retention for product queries

  tags = {
    Environment = var.environment
    Application = "product-api"
    Component   = "product-details"
  }
}

# ===== ORDER API LOG GROUPS =====

resource "aws_cloudwatch_log_group" "create_order_log_group" {
  name              = "/aws/lambda/${var.environment}-create-order-function"
  retention_in_days = 365  # ISSUE: Inconsistent - very long retention

  tags = {
    Environment = var.environment
    Application = "order-api"
    Component   = "order-creation"
  }
}

resource "aws_cloudwatch_log_group" "get_user_orders_log_group" {
  name              = "/aws/lambda/${var.environment}-get-user-orders-function"
  retention_in_days = 60

  tags = {
    Environment = var.environment
    Application = "order-api"
    Component   = "user-orders"
  }
}

# ===== PAYMENT & TRANSACTION LOG GROUPS =====

resource "aws_cloudwatch_log_group" "process_payment_log_group" {
  name              = "/aws/lambda/${var.environment}-process-payment-function"
  retention_in_days = 2555  # ISSUE: 7 years - compliance overkill without proper controls

  tags = {
    Environment = var.environment
    Application = "payment-api"
    Component   = "payment-processing"
  }
}

resource "aws_cloudwatch_log_group" "get_transactions_log_group" {
  name              = "/aws/lambda/${var.environment}-get-transactions-function"
  retention_in_days = 1  # ISSUE: Critically short for financial data

  tags = {
    Environment = var.environment
    Application = "transaction-api"
    Component   = "transaction-reporting"
  }
}
