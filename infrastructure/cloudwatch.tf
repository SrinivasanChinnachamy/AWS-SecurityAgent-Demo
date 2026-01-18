# CloudWatch Resources for AWS SecurityAgent Demo
# Intentionally inconsistent log retention policies for demonstration purposes

# ===== USER MANAGEMENT LOG GROUPS =====

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.environment}-get-user-function"
  retention_in_days = 60  # ISSUE: Short retention for production

  tags = {
    Environment = var.environment
    Application = "user-api"
    Component   = "retrieve-user-api"
  }
}

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

# MISSING ENTERPRISE RESOURCES:
# - CloudWatch Alarms for each business domain (Users, Products, Orders, Payments)
# - Custom CloudWatch Metrics for business KPIs
# - SNS Topics for alerting on financial transaction failures

# ISSUE: No CloudWatch alarms configured for any business domain
# ISSUE: No error rate monitoring across the enterprise API
# ISSUE: No duration monitoring for performance across services
# ISSUE: No throttling monitoring for DynamoDB across all tables
# ISSUE: No cost monitoring for over-provisioned resources
# ISSUE: No security monitoring for unauthorized access attempts
# ISSUE: No business metrics monitoring (order conversion, payment success rates)
# ISSUE: No compliance monitoring for financial data access
# ISSUE: No fraud detection monitoring for payment processing