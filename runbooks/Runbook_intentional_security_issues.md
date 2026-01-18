# AWS SecurityAgent Demo - Architecture Runbook

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Classification**: Demo/Educational  
**Target Audience**: Solution Architects, DevOps Engineers, Security Teams

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Solution Overview](#solution-overview)
3. [Architecture Diagrams](#architecture-diagrams)
4. [Component Details](#component-details)
5. [Data Flow Analysis](#data-flow-analysis)
6. [Security Architecture](#security-architecture)
7. [Deployment Architecture](#deployment-architecture)
8. [Operational Procedures](#operational-procedures)
9. [Troubleshooting Guide](#troubleshooting-guide)
10. [Appendices](#appendices)

---

## Executive Summary

The AWS SecurityAgent Demo is an intentionally vulnerable enterprise e-commerce platform designed to demonstrate comprehensive security assessment capabilities. The solution implements a serverless architecture across 4 business domains with 100+ deliberate security vulnerabilities for educational and demonstration purposes.

### Key Metrics
- **11 API Endpoints** across 4 business domains
- **11 Lambda Functions** with single deployment package
- **4 DynamoDB Tables** with mixed billing configurations
- **100+ Security Vulnerabilities** spanning all architectural layers
- **4 Business Domains**: User Management, Product Catalog, Order Processing, Payment Processing

### Architecture Principles (Intentionally Violated)
- ❌ **Security by Design**: No authentication or authorization
- ❌ **Least Privilege Access**: Single overly-permissive IAM role
- ❌ **Defense in Depth**: No network security or encryption
- ❌ **Compliance by Design**: Violates PCI DSS, SOX, and GDPR requirements

---

## Solution Overview

### Business Context
The solution simulates a comprehensive enterprise e-commerce platform handling:
- Customer user management and profiles
- Product catalog with category-based organization
- Order processing and fulfillment
- Payment processing and financial transactions

### Technical Architecture
- **Compute**: AWS Lambda (Serverless)
- **API Management**: Amazon API Gateway
- **Data Storage**: Amazon DynamoDB
- **Monitoring**: Amazon CloudWatch
- **Identity & Access**: AWS IAM
- **Deployment**: Terraform Infrastructure as Code

---

## Architecture Diagrams

### High-Level Solution Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS SecurityAgent Demo                       │
│                 Enterprise E-Commerce Platform                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│   Internet  │───▶│ API Gateway  │───▶│   Lambda    │───▶│  DynamoDB    │
│   Clients   │    │ (11 endpoints)│    │(11 functions)│    │ (4 tables)   │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────────┘
                           │                    │                   │
                           ▼                    ▼                   ▼
                   ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
                   │ CloudWatch   │    │    IAM      │    │ CloudWatch   │
                   │   Logs       │    │   Roles     │    │    Logs      │
                   └──────────────┘    └─────────────┘    └──────────────┘
```

### Business Domain Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Business Domains                                  │
├─────────────────┬─────────────────┬─────────────────┬─────────────────────┤
│ User Management │ Product Catalog │ Order Management│ Payment Processing  │
├─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│ GET /users      │ GET /products   │ POST /orders    │ POST /orders/{id}/  │
│ GET /users/{id} │ GET /products/  │ GET /users/{id}/│      payment        │
│ POST /users     │     {id}        │     orders      │ GET /transactions   │
│ PUT /users/{id} │                 │                 │                     │
│ DELETE /users/  │                 │                 │                     │
│        {id}     │                 │                 │                     │
├─────────────────┼─────────────────┼─────────────────┼─────────────────────┤
│ users-table     │ products-table  │ orders-table    │ transactions-table  │
│ (5 RCU/WCU)     │ (10/2 RCU/WCU)  │ (Pay-per-req)   │ (100/50 RCU/WCU)    │
└─────────────────┴─────────────────┴─────────────────┴─────────────────────┘
```

### Data Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DynamoDB Tables                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   users-table   │  │ products-table  │  │  orders-table   │  │transactions-tbl │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ PK: userId      │  │ PK: productId   │  │ PK: orderId     │  │ PK: transactionId│
│                 │  │ GSI: category   │  │ SK: userId      │  │ SK: timestamp   │
│ Provisioned:    │  │                 │  │ GSI: userId+    │  │ GSI: userId+    │
│ 5 RCU/5 WCU     │  │ Provisioned:    │  │      status     │  │      timestamp  │
│                 │  │ 10 RCU/2 WCU    │  │                 │  │                 │
│ ⚠️ Under-prov    │  │ ⚠️ Under-prov    │  │ Pay-per-request │  │ Provisioned:    │
│                 │  │                 │  │ ⚠️ Mixed billing │  │ 100 RCU/50 WCU  │
│                 │  │                 │  │                 │  │ ⚠️ Over-prov     │
└─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Security Architecture (Current State - Vulnerable)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Security Posture (CRITICAL)                          │
└─────────────────────────────────────────────────────────────────────────────┘

Internet ──────────────────────────────────────────────────────────────────────┐
    │                                                                          │
    │ ❌ No WAF Protection                                                      │
    │ ❌ No Rate Limiting                                                       │
    ▼                                                                          │
┌─────────────────┐                                                           │
│  API Gateway    │ ❌ No Authentication (authorization = "NONE")              │
│  (11 endpoints) │ ❌ No API Keys                                             │
│                 │ ❌ No Request Validation                                   │
└─────────────────┘                                                           │
    │                                                                          │
    ▼                                                                          │
┌─────────────────┐                                                           │
│ Lambda Functions│ ❌ Single IAM Role (overly broad permissions)              │
│ (11 functions)  │ ❌ No VPC Configuration                                    │
│                 │ ❌ No Input Validation                                     │
│                 │ ❌ Generic Error Handling                                  │
└─────────────────┘                                                           │
    │                                                                          │
    ▼                                                                          │
┌─────────────────┐                                                           │
│   DynamoDB      │ ❌ No Encryption at Rest                                   │
│   (4 tables)    │ ❌ No Backup Configuration                                 │
│                 │ ❌ No Point-in-Time Recovery                               │
│                 │ ❌ Cross-table Access Allowed                              │
└─────────────────┘                                                           │
                                                                               │
┌─────────────────────────────────────────────────────────────────────────────┤
│                    CRITICAL SECURITY GAPS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Payment card data in plain text logs                                      │
│ • Financial transactions publicly accessible                                │
│ • Cross-user data access (user123 can access user456's data)               │
│ • No PCI DSS compliance measures                                            │
│ • No audit logging for financial operations                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### API Gateway Configuration

**Resource Structure:**
```
/
├── /users
│   ├── GET    (List Users)
│   ├── POST   (Create User)
│   └── /{userId}
│       ├── GET    (Get User)
│       ├── PUT    (Update User)
│       ├── DELETE (Delete User)
│       └── /orders
│           └── GET (Get User Orders)
├── /products
│   ├── GET (List Products)
│   └── /{productId}
│       └── GET (Get Product)
├── /orders
│   ├── POST (Create Order)
│   └── /{orderId}
│       └── /payment
│           └── POST (Process Payment)
└── /transactions
    └── GET (Get Transactions)
```

**Security Issues:**
- All methods use `authorization = "NONE"`
- No request validation configured
- No throttling or rate limiting
- CORS configured with wildcard origins
- No WAF association

### Lambda Functions

**Function Specifications:**

| Function | Handler | Timeout | Memory | Issues |
|----------|---------|---------|--------|--------|
| get-user | get_user.lambda_handler | 30s | 128MB | Basic config |
| create-user | create_user.lambda_handler | 45s | 256MB | Higher timeout |
| update-user | update_user.lambda_handler | 60s | 512MB | Over-provisioned |
| delete-user | delete_user.lambda_handler | 30s | 128MB | No audit trail |
| list-users | list_users.lambda_handler | 90s | 1024MB | Massive over-prov |
| list-products | list_products.lambda_handler | 120s | 2048MB | Extreme over-prov |
| get-product | get_product.lambda_handler | 15s | 256MB | Reasonable |
| create-order | create_order.lambda_handler | 60s | 512MB | Cross-table access |
| get-user-orders | get_user_orders.lambda_handler | 45s | 512MB | No auth check |
| process-payment | process_payment.lambda_handler | 30s | 256MB | PCI violations |
| get-transactions | get_transactions.lambda_handler | 180s | 3008MB | Maximum resources |

**Common Issues Across All Functions:**
- Single IAM role with excessive permissions
- No X-Ray tracing enabled
- No reserved concurrency limits
- No dead letter queue configuration
- No VPC configuration for sensitive operations

### DynamoDB Tables

**Table Configurations:**

| Table | Billing Mode | Capacity | GSI | Issues |
|-------|--------------|----------|-----|--------|
| users-table | Provisioned | 5 RCU/5 WCU | None | Under-provisioned |
| products-table | Provisioned | 10 RCU/2 WCU | CategoryIndex (3/1) | Under-provisioned |
| orders-table | Pay-per-request | N/A | UserOrdersIndex | Mixed billing |
| transactions-table | Provisioned | 100 RCU/50 WCU | UserTransactionsIndex (50/25) | Over-provisioned |

**Security Issues:**
- No encryption at rest configured
- No backup or point-in-time recovery
- No auto-scaling policies
- Financial data mixed with operational data
- No access logging or monitoring

### IAM Configuration

**Single Role Policy (Overly Permissive):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem", 
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/demo-users-table",
        "arn:aws:dynamodb:*:*:table/demo-products-table",
        "arn:aws:dynamodb:*:*:table/demo-orders-table",
        "arn:aws:dynamodb:*:*:table/demo-transactions-table",
        "arn:aws:dynamodb:*:*:table/*/index/*"
      ]
    }
  ]
}
```

**Violations:**
- All functions can access all tables
- Financial functions can access user data
- User functions can access financial data
- No principle of least privilege

---

## Data Flow Analysis

### User Management Flow

```
Client Request ──▶ API Gateway ──▶ Lambda Function ──▶ DynamoDB
     │                 │               │                  │
     │                 │               │                  │
  ❌ No Auth        ❌ No Valid     ❌ No Input        ❌ No Encrypt
                                     Validation
     │                 │               │                  │
     ▼                 ▼               ▼                  ▼
CloudWatch Logs ◀──── Response ◀──── Function ◀──── Table Access
     │                                 │
     │                                 │
  ❌ Sensitive                      ❌ Cross-table
     Data Logged                      Access Allowed
```

### Payment Processing Flow (Critical Security Issues)

```
Payment Request ──▶ API Gateway ──▶ process-payment ──▶ Multiple Tables
      │                 │               │                    │
   Card Data         ❌ No Auth      ❌ No PCI           ❌ Plain Text
   (Plain Text)                        Compliance           Storage
      │                 │               │                    │
      ▼                 ▼               ▼                    ▼
  CloudWatch ◀──── JSON Response ◀── Transaction ◀──── orders-table
   Logs                  │              Record           transactions-table
      │                  │                │                    │
   ❌ Card              ❌ Exposes      ❌ No Fraud        ❌ No Encryption
      Numbers             Sensitive        Detection
      Logged              Data
```

### Transaction Reporting Flow (Data Exposure)

```
GET /transactions ──▶ API Gateway ──▶ get-transactions ──▶ DynamoDB Scan
        │                 │               │                     │
     ❌ Public          ❌ No Auth     ❌ Full Table         ❌ All Financial
        Access                           Scan                   Data Exposed
        │                 │               │                     │
        ▼                 ▼               ▼                     ▼
   All Financial ◀──── JSON Response ◀── Business ◀──── transactions-table
   Transactions          │              Metrics
   Exposed               │                │
                      ❌ Internal      ❌ Processing
                         Metrics         Costs Exposed
                         Leaked
```

---

## Security Architecture

### Current Security Posture (Vulnerable by Design)

**Authentication & Authorization: CRITICAL FAILURE**
- ❌ No authentication on any of 11 endpoints
- ❌ No user session management
- ❌ No role-based access control
- ❌ Cross-user data access possible
- ❌ Financial data publicly accessible

**Data Protection: CRITICAL FAILURE**
- ❌ No encryption at rest (DynamoDB)
- ❌ Payment card data in plain text
- ❌ Sensitive data in CloudWatch logs
- ❌ No data masking or tokenization
- ❌ No PCI DSS compliance measures

**Infrastructure Security: HIGH RISK**
- ❌ No VPC configuration
- ❌ No security groups or NACLs
- ❌ Single overly-permissive IAM role
- ❌ No network segmentation
- ❌ No WAF protection

**Monitoring & Logging: INADEQUATE**
- ❌ No CloudWatch alarms
- ❌ No security event monitoring
- ❌ Inconsistent log retention (1 day to 7 years)
- ❌ No audit trail for financial operations
- ❌ No X-Ray tracing

### Compliance Violations

**PCI DSS Compliance: COMPLETE FAILURE**
- Requirement 1: ❌ No firewall/network segmentation
- Requirement 2: ❌ Default configurations used
- Requirement 3: ❌ Cardholder data stored unencrypted
- Requirement 4: ❌ No encryption validation
- Requirement 7: ❌ No access controls
- Requirement 8: ❌ No user authentication
- Requirement 10: ❌ No logging/monitoring
- Requirement 11: ❌ No security testing
- Requirement 12: ❌ No security policies

**SOX Compliance: NON-COMPLIANT**
- ❌ No internal controls documentation
- ❌ No segregation of duties
- ❌ No change management controls
- ❌ No financial reporting controls

**GDPR Compliance: VIOLATIONS**
- ❌ No data protection measures
- ❌ No consent management
- ❌ No data subject rights implementation
- ❌ No privacy by design

---

## Deployment Architecture

### Infrastructure as Code (Terraform)

**File Structure:**
```
infrastructure/
├── main.tf           # Primary resource definitions
├── providers.tf      # AWS provider and backend config
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── terraform.tfvars  # Environment-specific values
```

**Deployment Process:**
1. **Package Lambda Functions**: Zip all Python files into single package
2. **Terraform Init**: Initialize backend and providers
3. **Terraform Plan**: Review infrastructure changes
4. **Terraform Apply**: Deploy with auto-approve (❌ Security Issue)
5. **Update Function Code**: Deploy code to all 11 functions
6. **Populate Sample Data**: Add test users, products, orders

**CI/CD Pipeline Issues:**
- ❌ Auto-approve deployments (no manual review)
- ❌ No security scanning (SAST/DAST)
- ❌ No dependency vulnerability checks
- ❌ No infrastructure security scanning
- ❌ No rollback mechanisms

### Environment Configuration

**Terraform Variables:**
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
```

**Resource Naming Convention:**
- DynamoDB Tables: `${environment}-${domain}-table`
- Lambda Functions: `${environment}-${action}-${domain}-function`
- Log Groups: `/aws/lambda/${function-name}`

---

## Operational Procedures

### Deployment Procedures

**Quick Deployment:**
```bash
# Clone repository
git clone <repository-url>
cd AWS-SecurityAgent-Demo

# Deploy infrastructure
./scripts/deploy.sh demo us-east-1

# Verify deployment
./scripts/test-api.sh <API_ENDPOINT>
```

**Manual Deployment:**
```bash
# Package functions
zip -j lambda_deployment.zip src/*.py
mv lambda_deployment.zip infrastructure/

# Deploy with Terraform
cd infrastructure
terraform init
terraform plan -var="environment=demo" -var="aws_region=us-east-1"
terraform apply -auto-approve -var="environment=demo" -var="aws_region=us-east-1"

# Update function codes (repeat for all 11 functions)
aws lambda update-function-code --function-name demo-get-user-function --zip-file fileb://lambda_deployment.zip
```

### Monitoring Procedures

**Health Checks:**
```bash
# Test all endpoints
curl $API_ENDPOINT/users
curl $API_ENDPOINT/products
curl $API_ENDPOINT/transactions

# Check Lambda function status
aws lambda get-function --function-name demo-get-user-function

# Monitor DynamoDB metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=demo-users-table \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-01T01:00:00Z \
  --period 300 \
  --statistics Sum
```

**Log Analysis:**
```bash
# View Lambda logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/demo-"
aws logs get-log-events --log-group-name "/aws/lambda/demo-get-user-function" --log-stream-name <stream-name>

# Search for errors
aws logs filter-log-events --log-group-name "/aws/lambda/demo-process-payment-function" --filter-pattern "ERROR"
```

### Cleanup Procedures

**Complete Cleanup:**
```bash
# Destroy infrastructure
cd infrastructure
terraform destroy -var="environment=demo" -var="aws_region=us-east-1"

# Verify cleanup
aws dynamodb list-tables --query 'TableNames[?contains(@, `demo-`)]'
aws lambda list-functions --query 'Functions[?contains(FunctionName, `demo-`)]'
aws apigateway get-rest-apis --query 'items[?contains(name, `demo-`)]'
```

---

## Troubleshooting Guide

### Common Issues

**DynamoDB Throttling (Expected Issue):**
```
Error: ProvisionedThroughputExceededException
Cause: Users table configured with only 5 RCU/WCU
Solution: Increase capacity or enable auto-scaling
```

**Lambda Timeout Issues:**
```
Error: Task timed out after X seconds
Cause: Various timeout settings (15s-180s) across functions
Solution: Check CloudWatch logs for specific timeout errors
```

**API Gateway CORS Issues:**
```
Error: CORS policy violation
Cause: Wildcard CORS configuration
Solution: Configure specific origins (security improvement)
```

**Payment Processing Errors:**
```
Error: Payment card data validation failed
Cause: No input validation implemented
Solution: This is intentional - demonstrates security gap
```

### Performance Issues

**High Memory Usage:**
- list-products function: 2048MB (over-provisioned)
- get-transactions function: 3008MB (maximum allocation)
- Solution: Right-size based on actual usage

**Long Response Times:**
- Full table scans on users and products
- No caching implemented
- Solution: Implement pagination and caching

### Security Incident Response

**If Deployed to Production by Mistake:**
1. **Immediate Action**: Run `terraform destroy`
2. **Verification**: Check for remaining resources
3. **Audit**: Review CloudTrail logs for access attempts
4. **Notification**: Alert security team of potential exposure

---

## Appendices

### Appendix A: API Endpoint Reference

**User Management Endpoints:**
- `GET /users` - List all users (pagination supported)
- `GET /users/{userId}` - Get specific user details
- `POST /users` - Create new user account
- `PUT /users/{userId}` - Update existing user
- `DELETE /users/{userId}` - Delete user account

**Product Catalog Endpoints:**
- `GET /products` - List products (category filtering)
- `GET /products/{productId}` - Get product details

**Order Management Endpoints:**
- `POST /orders` - Create new order
- `GET /users/{userId}/orders` - Get user's order history

**Payment Processing Endpoints:**
- `POST /orders/{orderId}/payment` - Process payment
- `GET /transactions` - Access financial transactions

### Appendix B: Security Vulnerability Matrix

| Category | Count | Severity | Examples |
|----------|-------|----------|----------|
| Authentication | 15+ | Critical | No auth on any endpoint |
| Data Protection | 20+ | Critical | Card data in logs, no encryption |
| Infrastructure | 25+ | High | No VPC, over-provisioning |
| Application | 20+ | High | No input validation, poor error handling |
| Monitoring | 15+ | High | No alarms, inconsistent logging |
| DevOps | 10+ | Medium | Auto-approve, no scanning |

### Appendix C: Compliance Gap Analysis

**PCI DSS Requirements:**
- All 12 requirements: ❌ FAILED
- Estimated remediation: 6-12 months
- Priority: CRITICAL (financial data exposure)

**SOX Controls:**
- Internal controls: ❌ MISSING
- Change management: ❌ INADEQUATE
- Financial reporting: ❌ NON-COMPLIANT

**GDPR Requirements:**
- Data protection: ❌ VIOLATED
- Privacy by design: ❌ NOT IMPLEMENTED
- Data subject rights: ❌ MISSING

### Appendix D: Cost Analysis

**Current Resource Costs (Estimated Monthly):**
- DynamoDB: $50-200 (depending on usage)
- Lambda: $10-50 (11 functions)
- API Gateway: $5-25 (request-based)
- CloudWatch: $10-30 (logs and monitoring)

**Cost Optimization Opportunities:**
- Right-size Lambda memory allocations: 60% savings
- Optimize DynamoDB capacity: 40% savings
- Implement caching: 30% request reduction

---

**Document Control**  
*This architectural runbook serves as comprehensive documentation for the AWS SecurityAgent Demo solution. All security vulnerabilities are intentional for demonstration purposes and should never be replicated in production environments.*

**⚠️ CRITICAL WARNING**  
*This solution contains 100+ intentional security vulnerabilities. DO NOT deploy to production environments. Use only for security assessment demonstrations and educational purposes.*