#!/bin/bash

# AWS SecurityAgent Demo - MVP Deployment Script
# This script deploys the intentionally vulnerable e-commerce platform

set -e

echo "🚀 Deploying AWS SecurityAgent Demo - Enterprise E-Commerce Platform"
echo "⚠️  WARNING: This deployment contains intentional security vulnerabilities for demonstration purposes"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Set environment
ENVIRONMENT=${1:-demo}
AWS_REGION=${2:-us-east-1}

echo "🔧 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   AWS Region: $AWS_REGION"
echo ""

# Package Lambda functions
echo "📦 Packaging Lambda functions..."
cd "$(dirname "$0")/.."

zip -j lambda_deployment.zip \
    src/get_user.py \
    src/create_user.py \
    src/update_user.py \
    src/delete_user.py \
    src/list_users.py \
    src/list_products.py \
    src/get_product.py \
    src/create_order.py \
    src/get_user_orders.py \
    src/process_payment.py \
    src/get_transactions.py

mv lambda_deployment.zip infrastructure/

echo "✅ Lambda functions packaged"
echo ""

# Deploy infrastructure
echo "🏗️  Deploying infrastructure with Terraform..."
cd infrastructure

terraform init
terraform plan -var="environment=$ENVIRONMENT" -var="aws_region=$AWS_REGION"
terraform apply -auto-approve -var="environment=$ENVIRONMENT" -var="aws_region=$AWS_REGION"

echo "✅ Infrastructure deployed"
echo ""

# Update Lambda function codes
echo "🔄 Updating Lambda function codes..."

# Get function names from Terraform outputs
GET_USER_FUNCTION=$(terraform output -raw get_user_function_name)
CREATE_USER_FUNCTION=$(terraform output -raw create_user_function_name)
UPDATE_USER_FUNCTION=$(terraform output -raw update_user_function_name)
DELETE_USER_FUNCTION=$(terraform output -raw delete_user_function_name)
LIST_USERS_FUNCTION=$(terraform output -raw list_users_function_name)
LIST_PRODUCTS_FUNCTION=$(terraform output -raw list_products_function_name)
GET_PRODUCT_FUNCTION=$(terraform output -raw get_product_function_name)
CREATE_ORDER_FUNCTION=$(terraform output -raw create_order_function_name)
GET_USER_ORDERS_FUNCTION=$(terraform output -raw get_user_orders_function_name)
PROCESS_PAYMENT_FUNCTION=$(terraform output -raw process_payment_function_name)
GET_TRANSACTIONS_FUNCTION=$(terraform output -raw get_transactions_function_name)

# Update all function codes
aws lambda update-function-code --function-name $GET_USER_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $CREATE_USER_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $UPDATE_USER_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $DELETE_USER_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $LIST_USERS_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $LIST_PRODUCTS_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $GET_PRODUCT_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $CREATE_ORDER_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $GET_USER_ORDERS_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $PROCESS_PAYMENT_FUNCTION --zip-file fileb://lambda_deployment.zip
aws lambda update-function-code --function-name $GET_TRANSACTIONS_FUNCTION --zip-file fileb://lambda_deployment.zip

echo "✅ Lambda functions updated"
echo ""

# Add sample data
echo "📊 Adding sample data..."

# Get table names
USERS_TABLE="$ENVIRONMENT-users-table"
PRODUCTS_TABLE="$ENVIRONMENT-products-table"
ORDERS_TABLE="$ENVIRONMENT-orders-table"
TRANSACTIONS_TABLE="$ENVIRONMENT-transactions-table"

# Add sample users
aws dynamodb put-item --table-name $USERS_TABLE --item '{"userId":{"S":"user123"},"name":{"S":"John Doe"},"email":{"S":"john@example.com"},"status":{"S":"active"},"createdAt":{"S":"2024-01-01T00:00:00Z"}}'
aws dynamodb put-item --table-name $USERS_TABLE --item '{"userId":{"S":"user456"},"name":{"S":"Jane Smith"},"email":{"S":"jane@example.com"},"status":{"S":"active"},"createdAt":{"S":"2024-01-01T00:00:00Z"}}'
aws dynamodb put-item --table-name $USERS_TABLE --item '{"userId":{"S":"user789"},"name":{"S":"Bob Wilson"},"email":{"S":"bob@example.com"},"status":{"S":"inactive"},"createdAt":{"S":"2024-01-01T00:00:00Z"}}'

# Add sample products
aws dynamodb put-item --table-name $PRODUCTS_TABLE --item '{"productId":{"S":"prod001"},"name":{"S":"Laptop Pro"},"category":{"S":"electronics"},"price":{"N":"1299.99"},"stock":{"N":"50"},"description":{"S":"High-performance laptop"}}'
aws dynamodb put-item --table-name $PRODUCTS_TABLE --item '{"productId":{"S":"prod002"},"name":{"S":"Wireless Mouse"},"category":{"S":"electronics"},"price":{"N":"29.99"},"stock":{"N":"200"},"description":{"S":"Ergonomic wireless mouse"}}'
aws dynamodb put-item --table-name $PRODUCTS_TABLE --item '{"productId":{"S":"prod003"},"name":{"S":"Office Chair"},"category":{"S":"furniture"},"price":{"N":"299.99"},"stock":{"N":"25"},"description":{"S":"Comfortable office chair"}}'

# Add sample orders
aws dynamodb put-item --table-name $ORDERS_TABLE --item '{"orderId":{"S":"order001"},"userId":{"S":"user123"},"totalAmount":{"N":"1329.98"},"orderStatus":{"S":"completed"},"createdAt":{"S":"2024-01-01T10:00:00Z"}}'
aws dynamodb put-item --table-name $ORDERS_TABLE --item '{"orderId":{"S":"order002"},"userId":{"S":"user456"},"totalAmount":{"N":"299.99"},"orderStatus":{"S":"pending"},"createdAt":{"S":"2024-01-02T14:30:00Z"}}'

# Add sample transactions
aws dynamodb put-item --table-name $TRANSACTIONS_TABLE --item '{"transactionId":{"S":"txn001"},"orderId":{"S":"order001"},"userId":{"S":"user123"},"amount":{"N":"1329.98"},"status":{"S":"completed"},"timestamp":{"S":"2024-01-01T10:05:00Z"}}'

echo "✅ Sample data added"
echo ""

# Get API endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

echo "🎉 Deployment completed successfully!"
echo ""
echo "🌐 Enterprise E-Commerce API Endpoints:"
echo ""
echo "👥 USER MANAGEMENT:"
echo "📋 List Users: curl $API_ENDPOINT/users"
echo "👤 Get User: curl $API_ENDPOINT/users/user123"
echo "➕ Create User: curl -X POST $API_ENDPOINT/users -H 'Content-Type: application/json' -d '{\"name\":\"Test User\",\"email\":\"test@example.com\"}'"
echo "✏️ Update User: curl -X PUT $API_ENDPOINT/users/user123 -H 'Content-Type: application/json' -d '{\"name\":\"Updated Name\"}'"
echo "🗑️ Delete User: curl -X DELETE $API_ENDPOINT/users/user123"
echo ""
echo "🛍️ PRODUCT CATALOG:"
echo "📦 List Products: curl $API_ENDPOINT/products"
echo "🔍 Get Product: curl $API_ENDPOINT/products/prod001"
echo "🏷️ Filter by Category: curl '$API_ENDPOINT/products?category=electronics'"
echo ""
echo "📋 ORDER MANAGEMENT:"
echo "🛒 Create Order: curl -X POST $API_ENDPOINT/orders -H 'Content-Type: application/json' -d '{\"userId\":\"user123\",\"items\":[{\"productId\":\"prod001\",\"quantity\":1}]}'"
echo "📄 Get User Orders: curl $API_ENDPOINT/users/user123/orders"
echo ""
echo "💳 PAYMENT PROCESSING:"
echo "💰 Process Payment: curl -X POST $API_ENDPOINT/orders/order002/payment -H 'Content-Type: application/json' -d '{\"userId\":\"user456\",\"amount\":299.99,\"paymentMethod\":\"credit_card\",\"cardNumber\":\"4111111111111111\"}'"
echo "📊 Get Transactions: curl $API_ENDPOINT/transactions"
echo "🔍 Filter Transactions: curl '$API_ENDPOINT/transactions?userId=user123'"
echo ""
echo "⚠️  SECURITY NOTICE:"
echo "This deployment contains 100+ intentional security vulnerabilities for demonstration purposes."
echo "DO NOT use this in production environments."
echo ""
echo "🔍 Ready for AWS Security Agent analysis!"