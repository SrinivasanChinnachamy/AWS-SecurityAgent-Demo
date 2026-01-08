# GitHub Setup Guide for AWS SecurityAgent Demo

This guide helps you prepare your GitHub repository for smooth deployment of the AWS SecurityAgent Demo.

## 🔧 Required GitHub Secrets

You need to configure the following secrets in your GitHub repository:

### 1. Navigate to Repository Settings
- Go to your GitHub repository
- Click on **Settings** tab
- In the left sidebar, click **Secrets and variables** → **Actions**

### 2. Add Required Secrets

Click **New repository secret** and add each of the following:

#### `AWS_ACCESS_KEY_ID`
- **Value**: Your AWS Access Key ID
- **Description**: AWS credentials for deployment
- **How to get**: 
  ```bash
  # From AWS CLI
  aws configure list
  # Or create new IAM user with programmatic access
  ```

#### `AWS_SECRET_ACCESS_KEY`
- **Value**: Your AWS Secret Access Key
- **Description**: AWS credentials for deployment
- **Security**: Keep this secret secure, never commit to code

### 3. Required AWS IAM Permissions

Your AWS credentials need the following permissions for deployment:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*",
                "lambda:*",
                "apigateway:*",
                "iam:*",
                "logs:*",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "*"
        }
    ]
}
```

**Recommended**: Create a dedicated IAM user for GitHub Actions with these permissions.

## 📁 Repository Structure Check

Ensure your repository has this structure:

```
AWS-SecurityAgent-Demo/
├── .github/
│   └── workflows/
│       └── deploy.yml ✅
├── infrastructure/
│   ├── main.tf ✅
│   ├── variables.tf ✅
│   ├── outputs.tf ✅
│   ├── providers.tf ✅
│   └── terraform.tfvars ✅
├── src/
│   ├── get_user.py ✅
│   ├── create_user.py ✅
│   ├── update_user.py ✅
│   ├── delete_user.py ✅
│   ├── list_users.py ✅
│   ├── list_products.py ✅
│   ├── get_product.py ✅
│   ├── create_order.py ✅
│   ├── get_user_orders.py ✅
│   ├── process_payment.py ✅
│   └── get_transactions.py ✅
├── scripts/
│   ├── deploy.sh ✅
│   └── test-api.sh ✅
└── README.md ✅
```

## 🚀 Deployment Triggers

The GitHub Actions workflow will trigger on:

### Automatic Triggers
- **Push to main branch**: Full deployment
- **Pull Request**: Terraform plan only (validation)

### Manual Trigger (Optional)
You can add manual workflow dispatch by adding this to the workflow:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:  # Add this for manual triggers
```

## 🔍 Pre-Deployment Checklist

Before pushing to main branch:

### ✅ AWS Prerequisites
- [ ] AWS account with appropriate permissions
- [ ] S3 bucket for Terraform state exists: `terraform-statefile-bucket-0503`
- [ ] AWS credentials configured in GitHub Secrets
- [ ] IAM permissions verified

### ✅ Repository Prerequisites  
- [ ] All source files committed and pushed
- [ ] GitHub Secrets configured
- [ ] Repository structure matches requirements
- [ ] No sensitive data in code (all intentional for demo)

### ✅ Terraform State Backend
Ensure the S3 bucket specified in `providers.tf` exists:

```bash
# Create the bucket if it doesn't exist
aws s3 mb s3://terraform-statefile-bucket-0503 --region us-east-1
```

## 🎯 Deployment Process

### 1. Pull Request (Testing)
```bash
git checkout -b feature/test-deployment
git push origin feature/test-deployment
# Create PR → Triggers terraform plan
```

### 2. Main Branch (Deployment)
```bash
git checkout main
git merge feature/test-deployment
git push origin main
# Triggers full deployment
```

## 📊 Monitoring Deployment

### GitHub Actions Logs
- Go to **Actions** tab in your repository
- Click on the running workflow
- Monitor each step's progress
- Check for any errors in real-time

### Expected Deployment Time
- **Terraform Plan**: ~2-3 minutes
- **Full Deployment**: ~8-12 minutes
- **Lambda Updates**: ~2-3 minutes
- **Sample Data**: ~1 minute

## 🔧 Troubleshooting

### Common Issues

#### 1. AWS Credentials Error
```
Error: NoCredentialsError
```
**Solution**: Verify GitHub Secrets are correctly set

#### 2. S3 Backend Error
```
Error: Failed to get existing workspaces
```
**Solution**: Create the S3 bucket or update bucket name in `providers.tf`

#### 3. IAM Permissions Error
```
Error: AccessDenied
```
**Solution**: Verify IAM user has required permissions

#### 4. Terraform State Lock
```
Error: Error locking state
```
**Solution**: Wait for previous deployment to complete or manually unlock

### Debug Steps
1. Check GitHub Actions logs
2. Verify AWS credentials and permissions
3. Ensure S3 bucket exists and is accessible
4. Check Terraform syntax locally before pushing

## 🎉 Success Indicators

Deployment is successful when you see:

1. ✅ All GitHub Actions steps complete
2. ✅ API endpoints displayed in workflow output
3. ✅ Sample data added successfully
4. ✅ All 11 Lambda functions deployed
5. ✅ All 4 DynamoDB tables created

## 🧪 Post-Deployment Testing

After successful deployment:

```bash
# Get API endpoint from GitHub Actions output or:
# Go to AWS Console → API Gateway → Your API → Stages → demo

# Test the API
curl https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/demo/users
curl https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/demo/products
```

## 🔒 Security Notes

- This deployment contains **intentional security vulnerabilities**
- Only deploy in development/demo environments
- Never use in production
- AWS costs will be minimal but monitor usage
- Clean up resources when done testing

## 🧹 Cleanup

To destroy the infrastructure:

```bash
# Local cleanup
cd infrastructure
terraform destroy -var="environment=demo" -var="aws_region=us-east-1"

# Or modify workflow to add destroy job
```

---

**Ready to deploy?** Push to main branch and watch the magic happen! 🚀