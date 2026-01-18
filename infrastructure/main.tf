# AWS SecurityAgent Demo - Main Infrastructure Configuration
# This file orchestrates the deployment of an intentionally vulnerable e-commerce platform
# for security assessment demonstration purposes

# ===== TERRAFORM CONFIGURATION =====
# All resources are organized into logical modules for better maintainability

# Note: This main.tf file now serves as the orchestration layer
# Individual resource definitions have been moved to dedicated files:
# - dynamodb.tf: DynamoDB tables and configurations
# - iam.tf: IAM roles, policies, and permissions
# - lambda.tf: Lambda functions and configurations
# - api_gateway.tf: API Gateway resources and methods
# - lambda_permissions.tf: Lambda-API Gateway integration permissions
# - cloudwatch.tf: CloudWatch log groups and monitoring
# - providers.tf: Terraform and AWS provider configuration
# - variables.tf: Input variables
# - outputs.tf: Output values

# ===== INTENTIONAL SECURITY VULNERABILITIES =====
# This infrastructure contains 100+ intentional security vulnerabilities including:
# - No authentication on any API endpoint
# - Unencrypted DynamoDB tables storing sensitive data
# - Overly permissive IAM roles with cross-domain access
# - Payment card data in plain text logs
# - No network security controls (VPC, security groups)
# - Inconsistent resource provisioning and monitoring
# - Missing compliance controls (PCI DSS, SOX, GDPR)

# ===== BUSINESS DOMAINS =====
# The platform simulates 4 business domains:
# 1. User Management (5 endpoints)
# 2. Product Catalog (2 endpoints)  
# 3. Order Processing (2 endpoints)
# 4. Payment Processing (2 endpoints)

# ===== DEPLOYMENT NOTES =====
# This configuration is designed for AWS Security Agent demonstration
# DO NOT use in production environments
# All vulnerabilities are intentional for educational purposes