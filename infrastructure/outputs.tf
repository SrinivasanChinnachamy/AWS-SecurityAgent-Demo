output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "https://${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}"
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.users_table.name
}

output "get_user_function_name" {
  description = "Get User Lambda function name"
  value       = aws_lambda_function.get_user_function.function_name
}

output "create_user_function_name" {
  description = "Create User Lambda function name"
  value       = aws_lambda_function.create_user_function.function_name
}

output "update_user_function_name" {
  description = "Update User Lambda function name"
  value       = aws_lambda_function.update_user_function.function_name
}

output "delete_user_function_name" {
  description = "Delete User Lambda function name"
  value       = aws_lambda_function.delete_user_function.function_name
}

output "list_users_function_name" {
  description = "List Users Lambda function name"
  value       = aws_lambda_function.list_users_function.function_name
}

output "list_products_function_name" {
  description = "List Products Lambda function name"
  value       = aws_lambda_function.list_products_function.function_name
}

output "get_product_function_name" {
  description = "Get Product Lambda function name"
  value       = aws_lambda_function.get_product_function.function_name
}

output "create_order_function_name" {
  description = "Create Order Lambda function name"
  value       = aws_lambda_function.create_order_function.function_name
}

output "get_user_orders_function_name" {
  description = "Get User Orders Lambda function name"
  value       = aws_lambda_function.get_user_orders_function.function_name
}

output "process_payment_function_name" {
  description = "Process Payment Lambda function name"
  value       = aws_lambda_function.process_payment_function.function_name
}

output "get_transactions_function_name" {
  description = "Get Transactions Lambda function name"
  value       = aws_lambda_function.get_transactions_function.function_name
}

output "log_group_names" {
  description = "CloudWatch Log Group names"
  value = {
    get_user         = aws_cloudwatch_log_group.lambda_log_group.name
    create_user      = aws_cloudwatch_log_group.create_user_log_group.name
    update_user      = aws_cloudwatch_log_group.update_user_log_group.name
    delete_user      = aws_cloudwatch_log_group.delete_user_log_group.name
    list_users       = aws_cloudwatch_log_group.list_users_log_group.name
    list_products    = aws_cloudwatch_log_group.list_products_log_group.name
    get_product      = aws_cloudwatch_log_group.get_product_log_group.name
    create_order     = aws_cloudwatch_log_group.create_order_log_group.name
    get_user_orders  = aws_cloudwatch_log_group.get_user_orders_log_group.name
    process_payment  = aws_cloudwatch_log_group.process_payment_log_group.name
    get_transactions = aws_cloudwatch_log_group.get_transactions_log_group.name
  }
}

output "api_endpoints" {
  description = "Available API endpoints for enterprise e-commerce platform"
  value = {
    # User Management
    get_user    = "GET ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/users/{userId}"
    create_user = "POST ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/users"
    update_user = "PUT ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/users/{userId}"
    delete_user = "DELETE ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/users/{userId}"
    list_users  = "GET ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/users"
    
    # Product Catalog
    list_products = "GET ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/products"
    get_product   = "GET ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/products/{productId}"
    
    # Order Management
    create_order     = "POST ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/orders"
    get_user_orders  = "GET ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/users/{userId}/orders"
    
    # Payment Processing
    process_payment   = "POST ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/orders/{orderId}/payment"
    get_transactions  = "GET ${aws_api_gateway_rest_api.user_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/transactions"
  }
}

output "table_names" {
  description = "DynamoDB table names for all business domains"
  value = {
    users        = aws_dynamodb_table.users_table.name
    products     = aws_dynamodb_table.products_table.name
    orders       = aws_dynamodb_table.orders_table.name
    transactions = aws_dynamodb_table.transactions_table.name
  }
}