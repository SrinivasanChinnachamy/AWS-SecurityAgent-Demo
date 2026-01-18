# API Gateway Resources for AWS SecurityAgent Demo
# Intentionally vulnerable configurations with no authentication for demonstration purposes

# ===== API GATEWAY REST API =====

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

# ===== API GATEWAY RESOURCES =====

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

# ===== USER MANAGEMENT API METHODS =====

# API Gateway Method - GET /users/{userId}
resource "aws_api_gateway_method" "get_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user_id_resource.id
  http_method   = "GET"
  authorization = "NONE"  # ISSUE: No authentication

  # ISSUE: No request validation
}

# API Gateway Integration - GET /users/{userId}
resource "aws_api_gateway_integration" "get_user_integration" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_id_resource.id
  http_method = aws_api_gateway_method.get_user_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_user_function.invoke_arn
}

# API Gateway Method - POST /users (Create User)
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

# ===== API GATEWAY DEPLOYMENT =====

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