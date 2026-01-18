# Quick Start Guide

Get the AWS SecurityAgent Demo up and running in under 15 minutes.

## Prerequisites

Before you begin, ensure you have:

- ✅ AWS Account (use a test/demo account, not production)
- ✅ AWS CLI installed and configured
- ✅ Terraform >= 1.0 installed
- ✅ Python 3.11 (for local testing)
- ✅ `zip` utility (for Lambda packaging)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/AWS-SecurityAgent-Demo.git
cd AWS-SecurityAgent-Demo
```

### 2. Configure AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Verify your AWS identity
aws sts get-caller-identity
```

### 3. Package Lambda Functions

```bash
# Create deployment package with all 11 Lambda functions
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

# Move to infrastructure directory
mv lambda_deployment.zip infrastructure/
```

### 4. Deploy Infrastructure

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

### 5. Update Lambda Function Code

```bash
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

# Update all Lambda functions with the deployment package
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

echo "✅ All Lambda functions updated successfully!"
```

### 6. Get API Endpoint

```bash
# Display the API endpoint
terraform output api_endpoint

# Save to environment variable for testing
export API_ENDPOINT=$(terraform output -raw api_endpoint)
echo "API Endpoint: $API_ENDPOINT"
```

## Testing the API

### Quick Health Check

```bash
# Set your API endpoint
export API_ENDPOINT="https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/demo"

# Test user endpoints
curl $API_ENDPOINT/users
curl $API_ENDPOINT/users/user123

# Test product endpoints
curl $API_ENDPOINT/products
curl $API_ENDPOINT/products/prod001

# Test transaction endpoint (demonstrates security issues)
curl $API_ENDPOINT/transactions
```

### Create Test Data

```bash
# Create a user
curl -X POST $API_ENDPOINT/users \
  -H 'Content-Type: application/json' \
  -d '{
    "userId": "user001",
    "name": "John Doe",
    "email": "john@example.com",
    "status": "active"
  }'

# Create an order
curl -X POST $API_ENDPOINT/orders \
  -H 'Content-Type: application/json' \
  -d '{
    "userId": "user001",
    "items": [
      {"productId": "prod001", "quantity": 2}
    ]
  }'

# Process payment (demonstrates PCI compliance issues)
curl -X POST $API_ENDPOINT/orders/order001/payment \
  -H 'Content-Type: application/json' \
  -d '{
    "userId": "user001",
    "amount": 299.99,
    "paymentMethod": "credit_card",
    "cardNumber": "4111111111111111",
    "cvv": "123",
    "expiryDate": "12/25"
  }'
```

## Monitoring

### View Lambda Logs

```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/demo

# Tail logs for a specific function
aws logs tail /aws/lambda/demo-get-user-function --follow

# Search for errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/demo-process-payment-function \
  --filter-pattern "ERROR"
```

### Check DynamoDB Tables

```bash
# List tables
aws dynamodb list-tables

# Describe a table
aws dynamodb describe-table --table-name demo-users-table

# Scan a table (small datasets only)
aws dynamodb scan --table-name demo-users-table --max-items 10
```

### Monitor API Gateway

```bash
# Get API details
aws apigateway get-rest-apis

# View deployment stages
aws apigateway get-stages --rest-api-id YOUR_API_ID
```

## Cleanup

When you're done testing:

```bash
cd infrastructure

# Destroy all resources
terraform destroy

# Type 'yes' when prompted to confirm
```

## Troubleshooting

### Issue: Terraform Init Fails

**Solution**: Ensure you have internet connectivity and AWS credentials configured.

```bash
aws sts get-caller-identity
terraform version
```

### Issue: Lambda Deployment Package Not Found

**Solution**: Create the deployment package manually.

```bash
cd AWS-SecurityAgent-Demo
zip -j lambda_deployment.zip src/*.py
mv lambda_deployment.zip infrastructure/
```

### Issue: API Returns 403 Forbidden

**Solution**: Check Lambda permissions and API Gateway deployment.

```bash
# Verify Lambda functions exist
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `demo-`)].FunctionName'

# Check API Gateway deployment
cd infrastructure
terraform output api_endpoint
```

### Issue: DynamoDB Throttling Errors

**Solution**: This is intentional! The demo includes under-provisioned tables to demonstrate capacity issues.

### Issue: High AWS Costs

**Solution**: The demo includes over-provisioned resources intentionally. Clean up promptly:

```bash
cd infrastructure
terraform destroy
```

## Next Steps

1. **Explore the API**: Test all 11 endpoints
2. **Review Security Issues**: Check `SECURITY_REQUIREMENTS.md`
3. **Analyze Architecture**: Review `ARCHITECTURE_RUNBOOK.md`
4. **Run Security Assessment**: Use AWS Security Agent
5. **Read the Blog**: Follow the 3-part security analysis series

## Getting Help

- 📖 Read the [full README](README.md)
- 🐛 Report issues on [GitHub Issues](https://github.com/YOUR_USERNAME/AWS-SecurityAgent-Demo/issues)
- 💬 Ask questions with the `question` label
- 📧 Contact the maintainer

## Important Reminders

⚠️ **This infrastructure is intentionally vulnerable**
- Never use in production
- Deploy only in isolated test accounts
- Clean up resources after testing
- Monitor AWS costs
- Review security implications

---

**Ready to explore?** Start with the automated deployment script and then dive into the security analysis!
