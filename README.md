# AWS SecurityAgent Demo 🔐

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Serverless-orange.svg)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org/)

> **⚠️ WARNING**: This repository contains **100+ intentional security vulnerabilities** for educational purposes. Never deploy this code in production environments.

An enterprise-scale e-commerce platform intentionally designed with security vulnerabilities to demonstrate AWS Security Agent's capabilities in detecting, analyzing, and prioritizing security issues across infrastructure, application code, and CI/CD pipelines.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Business Domains](#business-domains--endpoints)
- [Security Vulnerabilities](#intentional-security-issues-by-category)
- [Infrastructure Organization](#infrastructure-organization-terraform-best-practices)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This demo simulates a comprehensive enterprise e-commerce platform with multiple business domains, intentionally designed with **100+ security vulnerabilities and operational issues** across infrastructure, application code, and CI/CD pipeline.

### Why This Project?

This repository serves as a comprehensive demonstration for:
- **Security Professionals**: Understanding enterprise-scale vulnerability detection
- **DevOps Engineers**: Learning AWS security best practices through anti-patterns
- **Solution Architects**: Analyzing cross-domain security issues
- **AWS Security Agent**: Showcasing automated security assessment capabilities

### Key Statistics

- 🔴 **100+ Security Vulnerabilities** across 6 categories
- 🏗️ **11 Lambda Functions** handling business logic
- 🌐 **11 API Endpoints** with no authentication
- 💾 **4 DynamoDB Tables** with mixed configurations
- 📊 **Inconsistent Monitoring** (1 day to 7 years log retention)
- 💰 **Cost Optimization Issues** (over/under-provisioned resources)

## 🏛️ Architecture

### Technology Stack

| Component | Technology | Configuration |
|-----------|-----------|---------------|
| **API Layer** | Amazon API Gateway | REST API, 11 endpoints, no authentication ⚠️ |
| **Compute** | AWS Lambda | 11 functions, Python 3.11, varying resources |
| **Database** | Amazon DynamoDB | 4 tables, mixed billing modes |
| **Monitoring** | Amazon CloudWatch | Inconsistent retention (1 day - 7 years) ⚠️ |
| **IAM** | AWS IAM | Single overly-permissive role ⚠️ |
| **IaC** | Terraform | Modular structure, 7 organized files |

### Architecture Diagram

![AWS Security Demo Architecture](aws_security_demo_architecture.png)

*Complete architecture showing all 11 endpoints, Lambda functions, DynamoDB tables, and security gaps*

## 📁 Infrastructure Organization (Terraform Best Practices)
The infrastructure code follows Terraform best practices with modular organization:

```
infrastructure/
├── main.tf                 # Main orchestration and documentation
├── providers.tf           # Terraform and AWS provider configuration
├── variables.tf           # Input variables and defaults
├── outputs.tf             # Output values and API endpoints
├── terraform.tfvars       # Environment-specific values
├── dynamodb.tf            # DynamoDB tables and GSI configurations
├── iam.tf                 # IAM roles, policies, and attachments
├── lambda.tf              # Lambda functions and environment variables
├── api_gateway.tf         # API Gateway resources, methods, and integrations
├── lambda_permissions.tf  # Lambda-API Gateway integration permissions
└── cloudwatch.tf          # CloudWatch log groups and retention policies
```

**Benefits of Modular Structure:**
- **Maintainability**: Easier to locate and modify specific resource types
- **Readability**: Clear separation of concerns across AWS services
- **Collaboration**: Multiple team members can work on different modules
- **Security Review**: Simplified security assessment by service category
- **Debugging**: Faster troubleshooting with focused resource groupings

## 🛒 Business Domains & Endpoints

#### 👥 User Management
- `GET /users` - List all users (with pagination)
- `GET /users/{userId}` - Get specific user
- `POST /users` - Create new user
- `PUT /users/{userId}` - Update existing user  
- `DELETE /users/{userId}` - Delete user

#### 🛍️ Product Catalog
- `GET /products` - List products (with category filtering)
- `GET /products/{productId}` - Get product details

#### 📋 Order Management
- `POST /orders` - Create new order
- `GET /users/{userId}/orders` - Get user's order history

#### 💳 Payment & Financial
- `POST /orders/{orderId}/payment` - Process payment (PCI nightmare)
- `GET /transactions` - Access all financial transactions

## 🚨 Intentional Security Issues by Category

All vulnerabilities are mapped to official AWS security best practices documentation.

#### 🔐 Authentication & Authorization (15+ issues)
**Violates AWS API Gateway Security Best Practices:**
- **No authentication on any endpoint** - AWS recommends implementing least privilege access using IAM policies, Lambda authorizers, or Amazon Cognito user pools
- **No user authorization checks** - Missing resource-based access controls as recommended in AWS security best practices
- **Anyone can access any user's data** - Violates AWS principle of least privilege access
- **Financial data publicly accessible** - Critical compliance violation against AWS security guidelines
- **No admin role validation** - Missing role-based access controls

*Reference: [AWS API Gateway Security Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/security-best-practices.html) - AWS recommends implementing least privilege access, controlling API access through IAM policies, Lambda authorizers, IAM tags, VPC endpoint policies, and Amazon Cognito user pools. AWS also recommends implementing CloudWatch alarms for monitoring metrics over time, enabling AWS CloudTrail for audit logging, and using AWS Config for compliance validation.*

#### 🛡️ Data Security (20+ issues)
**Violates AWS DynamoDB Security Best Practices:**
- **No encryption at rest or in transit** - AWS DynamoDB security best practices emphasize encryption at rest using AWS KMS keys and encryption in transit
- **Payment card data in plain text logs** - Severe PCI DSS compliance violation and AWS logging security failure
- **No PCI DSS compliance measures** - Missing required financial data protection controls
- **Financial data mixed with user data** - Violates AWS data classification and separation principles
- **No data masking or field filtering** - Exposes sensitive information unnecessarily
- **No client-side encryption** - AWS recommends considering client-side encryption for sensitive data using AWS Database Encryption SDK

*Reference: [AWS DynamoDB Security Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices-security-preventative.html) - AWS provides comprehensive security features including encryption at rest with AWS KMS, IAM roles for authentication, IAM policies for fine-grained access control, VPC endpoints for network security, and client-side encryption for sensitive data protection.*

#### ⚡ Infrastructure Misconfigurations (25+ issues)
**Violates AWS DynamoDB Best Practices:**
- **DynamoDB throttling (5 RCU/WCU on users table)** - Insufficient capacity planning against AWS best practices for workload distribution
- **Over-provisioned transactions table (100 RCU/50 WCU)** - Cost inefficient resource allocation violating AWS cost optimization principles
- **Mixed billing modes across tables** - Inconsistent capacity management strategy across business domains
- **No auto-scaling policies** - Missing dynamic capacity adjustment recommended by AWS
- **Inconsistent log retention (1 day to 7 years)** - Poor operational governance and compliance management
- **No VPC endpoints** - Missing network security controls recommended for DynamoDB access

*Reference: [AWS DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html) - AWS recommends optimizing DynamoDB workloads with proper partition key design, capacity planning, consistent configuration across tables, and using VPC endpoints for secure access.*

#### 🔧 Application Security (20+ issues)
**Violates AWS Lambda Best Practices:**
- **No input validation anywhere** - Missing request validation mechanisms recommended by AWS
- **Generic error handling exposing internals** - Security information disclosure violating AWS security guidelines
- **No retry logic or circuit breakers** - Poor resilience patterns against AWS Lambda best practices
- **Cross-table access without validation** - Overly broad data access violating principle of least privilege
- **No fraud detection on payments** - Missing financial security controls for payment processing
- **Overly permissive IAM roles** - Single role with excessive permissions violating least privilege principle
- **No environment variable encryption** - Missing security for configuration data

*Reference: [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html) - AWS recommends initializing SDK clients outside handlers, using environment variables for configuration, implementing proper error handling, avoiding recursive invocations, using most-restrictive IAM permissions, writing idempotent code, and implementing structured JSON logging for better observability.*

#### 📊 Monitoring & Observability (15+ issues)
**Violates AWS CloudWatch and Security Best Practices:**
- **No CloudWatch alarms** - Missing proactive monitoring recommended by AWS security best practices
- **No X-Ray tracing** - Lack of distributed tracing for debugging and performance monitoring
- **No custom metrics** - Missing business-specific monitoring and operational insights
- **No audit logging for financial access** - Compliance and security gap violating AWS audit requirements
- **No performance monitoring** - Missing operational insights and performance optimization
- **No structured JSON logging** - Missing observability best practices recommended by AWS
- **No Cost Anomaly Detection** - Missing cost monitoring recommended by AWS

*Reference: [AWS API Gateway Security Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/security-best-practices.html) and [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html) - AWS recommends implementing CloudWatch alarms for monitoring metrics over time, enabling AWS CloudTrail for audit logging, using AWS Config for compliance validation, implementing structured JSON logging, and using Cost Anomaly Detection for unusual activity monitoring.*

#### 🚀 CI/CD Security (10+ issues)
**Violates AWS Security and Deployment Best Practices:**
- **Auto-approve deployments** - Missing human review for critical changes violating AWS security practices
- **No security scanning** - Missing vulnerability assessment in deployment pipeline
- **No dependency checks** - Potential supply chain vulnerabilities in Lambda functions
- **All functions in single package** - Poor separation of concerns violating AWS Lambda best practices
- **No rollback mechanisms** - Missing deployment safety measures and error recovery
- **No Infrastructure as Code security scanning** - Missing Terraform security validation
- **No AWS Config compliance monitoring** - Missing resource configuration validation

*Reference: [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html) and [AWS API Gateway Security Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/security-best-practices.html) - AWS recommends proper function packaging, security scanning, dependency management, implementing deployment safety measures including rollback capabilities, using AWS Config for compliance validation, and enabling AWS Security Hub CSPM for security monitoring.*

## ⚙️ Enterprise Complexity Factors
- **Cross-Domain Data Access**: User functions can access financial data - violates AWS principle of least privilege
- **Inconsistent Resource Allocation**: Memory ranges from 128MB to 3GB - poor resource optimization against AWS cost guidelines
- **Mixed Security Postures**: Some tables provisioned, others on-demand - inconsistent governance violating AWS operational excellence
- **Financial Compliance Gaps**: No SOX, PCI, or GDPR controls - regulatory violations against AWS compliance frameworks
- **Operational Inconsistencies**: Timeout ranges from 15s to 180s - poor standardization violating AWS operational best practices

## 🏗️ AWS Well-Architected Framework Violations

This demo violates multiple pillars of the AWS Well-Architected Framework based on official AWS documentation:

#### Security Pillar
- **Identity and Access Management**: No authentication or authorization mechanisms
- **Detective Controls**: Missing logging, monitoring, and audit capabilities  
- **Data Protection**: No encryption, data classification, or protection measures
- **Incident Response**: No security event handling or response procedures
- **Infrastructure Protection**: Missing network security and VPC configurations

*Reference: [AWS Well-Architected Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)*

#### Reliability Pillar
- **Foundations**: Poor capacity planning and inconsistent resource allocation
- **Workload Architecture**: No fault tolerance, retry mechanisms, or resilience patterns
- **Change Management**: Unsafe deployment practices without rollback capabilities

#### Performance Efficiency Pillar
- **Selection**: Poor resource sizing and configuration choices
- **Review**: No performance monitoring, optimization, or capacity planning
- **Monitoring**: Missing performance metrics, alarms, and operational insights

#### Cost Optimization Pillar
- **Expenditure and Usage Awareness**: Over-provisioned resources and poor cost monitoring
- **Cost-Effective Resources**: Inefficient resource allocation and sizing
- **Manage Demand**: No auto-scaling, capacity management, or demand-based scaling

#### Operational Excellence Pillar
- **Prepare**: Missing operational procedures and documentation
- **Operate**: No monitoring, alerting, or incident response capabilities
- **Evolve**: No continuous improvement or lessons learned processes

## 🎓 Educational Purpose

This project demonstrates AWS Security Agent's capabilities in:
1. **Detecting** complex, enterprise-scale security vulnerabilities 
2. **Analyzing** cross-domain security issues and data flows 
3. **Prioritizing** fixes based on business impact and compliance requirements from AWS best practices
4. **Recommending** comprehensive security architecture improvements backed by official AWS documentation
5. **Identifying** financial and regulatory compliance gaps using AWS compliance guidelines
6. **Cost-optimizing** security improvements using AWS pricing analysis
7. **Implementing** AWS Well-Architected Framework principles across all five pillars

*All security violations reference current AWS official documentation including API Gateway Security Best Practices, DynamoDB Security Best Practices, Lambda Best Practices, and the AWS Well-Architected Framework Security Pillar.*

## 🚀 Getting Started

#### Quick Deployment (MVP)

1. **Prerequisites**:
   ```bash
   # Install required tools
   # - Terraform >= 1.0
   # - AWS CLI configured with credentials
   # - jq (for testing script)
   ```

2. **Deploy the Platform**:
   ```bash
   # Clone and deploy
   cd AWS-SecurityAgent-Demo
   ./scripts/deploy.sh [environment] [aws-region]
   
   # Example:
   ./scripts/deploy.sh demo us-east-1
   ```

3. **Test the API**:
   ```bash
   # Get API endpoint from Terraform output
   cd infrastructure
   API_ENDPOINT=$(terraform output -raw api_endpoint)
   
   # Run tests
   ../scripts/test-api.sh $API_ENDPOINT
   ```

4. **Manual Testing Examples**:
   ```bash
   # Replace YOUR_API_ENDPOINT with actual endpoint
   API_ENDPOINT="https://abc123.execute-api.us-east-1.amazonaws.com/demo"
   
   # Test user management
   curl $API_ENDPOINT/users
   curl $API_ENDPOINT/users/user123
   
   # Test product catalog
   curl $API_ENDPOINT/products
   curl $API_ENDPOINT/products/prod001
   
   # Test order management
   curl -X POST $API_ENDPOINT/orders \
     -H 'Content-Type: application/json' \
     -d '{"userId":"user123","items":[{"productId":"prod001","quantity":1}]}'
   
   # Test payment processing (demonstrates security issues)
   curl -X POST $API_ENDPOINT/orders/order002/payment \
     -H 'Content-Type: application/json' \
     -d '{"userId":"user456","amount":299.99,"paymentMethod":"credit_card","cardNumber":"4111111111111111"}'
   ```

#### Alternative Deployment Methods

**Using GitHub Actions**:
- Push to main branch triggers automatic deployment
- Requires AWS credentials configured in GitHub Secrets

**Manual Terraform**:
```bash
cd infrastructure
terraform init
terraform plan -var="environment=demo" -var="aws_region=us-east-1"
terraform apply -var="environment=demo" -var="aws_region=us-east-1"
```

**Infrastructure Files Overview**:
- `main.tf`: Orchestration and documentation (no resources)
- `dynamodb.tf`: All DynamoDB tables with intentional misconfigurations
- `iam.tf`: IAM roles and policies with overly broad permissions
- `lambda.tf`: All 11 Lambda functions with varying resource allocations
- `api_gateway.tf`: API Gateway with no authentication (intentional vulnerability)
- `lambda_permissions.tf`: Integration permissions between API Gateway and Lambda
- `cloudwatch.tf`: Log groups with inconsistent retention policies

## 🔍 Security Analysis Workflow

1. **Deploy the Infrastructure**: Use the deployment script or Terraform to deploy the intentionally vulnerable infrastructure
2. **Review Security Requirements**: Examine `SECURITY_REQUIREMENTS.md` for comprehensive security standards
3. **Configure Security Agent**: Use `security-agent-config.json` as input configuration
4. **Run Security Analysis**: Use AWS Security Agent to identify and prioritize security issues
5. **Compare Implementation**: Review `CURRENT_IMPLEMENTATION.md` for detailed vulnerability mapping
6. **Document Findings**: Generate reports with references to official AWS documentation
7. **Implement Fixes**: Apply security improvements based on AWS best practices (future commits)

#### Security Assessment Files

- **`SECURITY_REQUIREMENTS.md`**: Comprehensive security requirements document (100+ requirements across 7 categories)
- **`CURRENT_IMPLEMENTATION.md`**: Detailed analysis of current security posture and violations
- **`security-agent-config.json`**: Configuration file for AWS Security Agent assessment
- **`GITHUB_SETUP.md`**: Complete GitHub repository setup guide

#### Cleanup
```bash
cd infrastructure
terraform destroy -var="environment=demo" -var="aws_region=us-east-1"
```

## 📚 Documentation

Comprehensive documentation is available:

- **[ARCHITECTURE_RUNBOOK.md](ARCHITECTURE_RUNBOOK.md)** - Detailed architecture with vulnerability explanations
- **[PRODUCTION_ARCHITECTURE_RUNBOOK.md](PRODUCTION_ARCHITECTURE_RUNBOOK.md)** - Production-style runbook for security agent analysis
- **[SECURITY_REQUIREMENTS.md](SECURITY_REQUIREMENTS.md)** - 100+ security requirements across 7 categories
- **[CURRENT_IMPLEMENTATION.md](CURRENT_IMPLEMENTATION.md)** - Current security posture analysis
- **[TERRAFORM_REFACTORING_SUMMARY.md](TERRAFORM_REFACTORING_SUMMARY.md)** - Infrastructure refactoring details
- **[GITHUB_SETUP.md](GITHUB_SETUP.md)** - GitHub repository setup guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Ways to Contribute

- 🐛 Report documentation issues
- 💡 Suggest additional security vulnerabilities to demonstrate
- 📖 Improve documentation and examples
- 🧪 Add testing scenarios
- ✨ Enhance deployment automation

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Disclaimer**: This software contains intentional security vulnerabilities for educational purposes only. The authors are not responsible for any misuse or damage caused by this software.

## 🌟 Acknowledgments

- AWS Security Best Practices Documentation
- AWS Well-Architected Framework
- Terraform Best Practices
- Open Source Security Community

## 📧 Contact

For questions, suggestions, or discussions about this project, please open an issue on GitHub.

---

**⚠️ Remember**: This represents a realistic enterprise scenario where rapid feature development has created a security and operational nightmare requiring systematic remediation using AWS security best practices and official documentation. Never use this code in production!
