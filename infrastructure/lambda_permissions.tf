# Lambda Permissions for API Gateway Integration
# Allows API Gateway to invoke Lambda functions

# ===== USER MANAGEMENT PERMISSIONS =====

# Lambda Permission for API Gateway - Get User
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Create User
resource "aws_lambda_permission" "api_gateway_invoke_create" {
  statement_id  = "AllowExecutionFromAPIGatewayCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Update User
resource "aws_lambda_permission" "api_gateway_invoke_update" {
  statement_id  = "AllowExecutionFromAPIGatewayUpdate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Delete User
resource "aws_lambda_permission" "api_gateway_invoke_delete" {
  statement_id  = "AllowExecutionFromAPIGatewayDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - List Users
resource "aws_lambda_permission" "api_gateway_invoke_list" {
  statement_id  = "AllowExecutionFromAPIGatewayList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_users_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# ===== PRODUCT API PERMISSIONS =====

# Lambda Permission for API Gateway - List Products
resource "aws_lambda_permission" "api_gateway_invoke_list_products" {
  statement_id  = "AllowExecutionFromAPIGatewayListProducts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Get Product
resource "aws_lambda_permission" "api_gateway_invoke_get_product" {
  statement_id  = "AllowExecutionFromAPIGatewayGetProduct"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# ===== ORDER API PERMISSIONS =====

# Lambda Permission for API Gateway - Create Order
resource "aws_lambda_permission" "api_gateway_invoke_create_order" {
  statement_id  = "AllowExecutionFromAPIGatewayCreateOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Get User Orders
resource "aws_lambda_permission" "api_gateway_invoke_get_user_orders" {
  statement_id  = "AllowExecutionFromAPIGatewayGetUserOrders"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_orders_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# ===== PAYMENT & TRANSACTION API PERMISSIONS =====

# Lambda Permission for API Gateway - Process Payment
resource "aws_lambda_permission" "api_gateway_invoke_process_payment" {
  statement_id  = "AllowExecutionFromAPIGatewayProcessPayment"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_payment_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}

# Lambda Permission for API Gateway - Get Transactions
resource "aws_lambda_permission" "api_gateway_invoke_get_transactions" {
  statement_id  = "AllowExecutionFromAPIGatewayGetTransactions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_transactions_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}