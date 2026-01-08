#!/bin/bash

# AWS SecurityAgent Demo - API Testing Script
# Tests all endpoints to verify the MVP deployment works

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <API_ENDPOINT>"
    echo "Example: $0 https://abc123.execute-api.us-east-1.amazonaws.com/demo"
    exit 1
fi

API_ENDPOINT=$1

echo "🧪 Testing AWS SecurityAgent Demo API"
echo "🌐 API Endpoint: $API_ENDPOINT"
echo ""

# Test User Management
echo "👥 Testing User Management..."
echo "📋 List Users:"
curl -s "$API_ENDPOINT/users" | jq '.' || echo "Response received"
echo ""

echo "👤 Get User:"
curl -s "$API_ENDPOINT/users/user123" | jq '.' || echo "Response received"
echo ""

echo "➕ Create User:"
curl -s -X POST "$API_ENDPOINT/users" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test User","email":"test@example.com"}' | jq '.' || echo "Response received"
echo ""

# Test Product Catalog
echo "🛍️ Testing Product Catalog..."
echo "📦 List Products:"
curl -s "$API_ENDPOINT/products" | jq '.' || echo "Response received"
echo ""

echo "🔍 Get Product:"
curl -s "$API_ENDPOINT/products/prod001" | jq '.' || echo "Response received"
echo ""

echo "🏷️ Filter by Category:"
curl -s "$API_ENDPOINT/products?category=electronics" | jq '.' || echo "Response received"
echo ""

# Test Order Management
echo "📋 Testing Order Management..."
echo "🛒 Create Order:"
curl -s -X POST "$API_ENDPOINT/orders" \
  -H 'Content-Type: application/json' \
  -d '{"userId":"user123","items":[{"productId":"prod001","quantity":1}]}' | jq '.' || echo "Response received"
echo ""

echo "📄 Get User Orders:"
curl -s "$API_ENDPOINT/users/user123/orders" | jq '.' || echo "Response received"
echo ""

# Test Payment Processing
echo "💳 Testing Payment Processing..."
echo "💰 Process Payment:"
curl -s -X POST "$API_ENDPOINT/orders/order002/payment" \
  -H 'Content-Type: application/json' \
  -d '{"userId":"user456","amount":299.99,"paymentMethod":"credit_card","cardNumber":"4111111111111111"}' | jq '.' || echo "Response received"
echo ""

echo "📊 Get Transactions:"
curl -s "$API_ENDPOINT/transactions" | jq '.' || echo "Response received"
echo ""

echo "🔍 Filter Transactions:"
curl -s "$API_ENDPOINT/transactions?userId=user123" | jq '.' || echo "Response received"
echo ""

echo "✅ API testing completed!"
echo ""
echo "⚠️  Security Issues Detected (Intentional):"
echo "   - No authentication on any endpoint"
echo "   - Financial data publicly accessible"
echo "   - Payment card data in plain text"
echo "   - Cross-user data access possible"
echo ""
echo "🔍 Ready for AWS Security Agent analysis!"