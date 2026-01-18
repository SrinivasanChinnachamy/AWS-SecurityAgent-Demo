# Quick Start Guide

Get the AWS SecurityAgent Demo up and running in under 10 minutes.

## Prerequisites

Before you begin, ensure you have:

- ✅ AWS Account (use a test/demo account, not production)
- ✅ AWS CLI installed and configured
- ✅ Terraform >= 1.0 installed
- ✅ Python 3.11 (for local testing)
- ✅ `jq` command-line tool (for test scripts)
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

### 3. Set Up Terraform Variables

```bash
cd infrastructure

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your preferred settings
# Default values work fine for most cases
```

### 4. Deploy Using the Automated Script

```bash
# Return to project root
cd ..

# Run the deployment script
./scripts/deploy.sh demo us-east-1
```

The script will:
- Package Lambda functions
- Initialize Terraform
- Deploy all infrastructure
- Output the API endpoint URL

### 5. Test the Deployment

```bash
# Get the API endpoint
cd infrastructure
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Run automated tests
cd ..
./scripts/test-api.sh $API_ENDPOINT
```

## Manual Deployment (Alternative)

If you prefer manual control:

### Step 1: Package Lambda Functions

```bash
# Create deployment package
zip -j lambda_deployment.zip src/*.py

# Move to infrastructure directory
mv lambda_deployment.zip infrastructure/
```

### Step 2: Initialize Terraform

```bash
cd infrastructure
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan -var="environment=demo" -var="aws_region=us-east-1"
```

### Step 4: Deploy Infrastructure

```bash
terraform apply -var="environment=demo" -var="aws_region=us-east-1"
```

Type `yes` when prompted to confirm deployment.

### Step 5: Get API Endpoint

```bash
# Display all outputs
terraform output

# Get just the API endpoint
terraform output -raw api_endpoint
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
terraform destroy -var="environment=demo" -var="aws_region=us-east-1"
```

Type `yes` when prompted to confirm destruction.

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
