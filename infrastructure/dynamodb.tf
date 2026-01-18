# DynamoDB Tables for AWS SecurityAgent Demo
# Intentionally vulnerable configurations for demonstration purposes

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