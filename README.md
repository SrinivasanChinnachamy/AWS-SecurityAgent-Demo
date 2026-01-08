# AWS-SecurityAgent-Demo

This repository holds infrastructure and application code for a demo application that has intentional issues at code level to be reviewed by AWS Security Frontier Agent.

## Enterprise E-Commerce Platform

This demo simulates a comprehensive enterprise e-commerce platform with multiple business domains, intentionally designed with **100+ security vulnerabilities and operational issues** across infrastructure, application code, and CI/CD pipeline.

### Architecture Overview
- **API Gateway**: REST API with 11 endpoints across 4 business domains
- **Lambda Functions**: 11 separate functions handling different business operations
- **DynamoDB**: 4 tables with mixed billing modes and capacity issues
- **CloudWatch**: Logging with wildly inconsistent retention policies (1 day to 7 years)
- **IAM**: Single overly permissive role accessing all business data

### Business Domains & Endpoints

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

### AWS MCP Integration & Security Analysis

This demo is designed to work with AWS Model Context Protocol (MCP) servers for comprehensive security analysis:

#### � AWS Documentation MCP Server
The AWS Security Agent can leverage the [AWS Documentation MCP Server](https://github.com/awslabs/aws-documentation-mcp-server) to:
- **Search AWS Security Best Practices**: Query official AWS security documentation for each service
- **Reference Compliance Guidelines**: Access AWS compliance documentation for PCI DSS, SOX, and GDPR requirements
- **Validate Configuration Standards**: Compare current configurations against AWS Well-Architected Framework security pillar

**Example MCP Usage:**
```bash
# The agent can search for security best practices
search_documentation("DynamoDB encryption at rest best practices")
search_documentation("API Gateway authentication methods")
search_documentation("Lambda function security configuration")
```

#### 📊 AWS Pricing MCP Server
The [AWS Pricing MCP Server](https://github.com/awslabs/aws-pricing-mcp-server) enables cost-security analysis:
- **Identify Over-Provisioning**: Detect expensive misconfigurations (like our 100 RCU transactions table)
- **Cost-Benefit Security Analysis**: Evaluate security improvements against cost implications
- **Resource Right-Sizing**: Optimize security configurations for cost efficiency

**Example MCP Usage:**
```bash
# Analyze DynamoDB pricing for different capacity configurations
get_pricing("AmazonDynamoDB", region="us-east-1", filters=[
    {"Field": "capacityType", "Value": "Provisioned"}
])
```

#### 🏗️ AWS Diagram MCP Server
The [AWS Diagram MCP Server](https://github.com/awslabs/aws-diagram-mcp-server) can visualize security issues:
- **Architecture Security Diagrams**: Generate visual representations of security vulnerabilities
- **Data Flow Analysis**: Show how sensitive data flows through insecure components
- **Compliance Gap Visualization**: Illustrate missing security controls across the architecture

### Intentional Security Issues by Category

#### 🔐 Authentication & Authorization (15+ issues)
**Violates AWS API Gateway Security Best Practices:**
- **No authentication on any endpoint** - AWS recommends implementing least privilege access using IAM policies, Lambda authorizers, or Amazon Cognito user pools
- **No user authorization checks** - Missing resource-based access controls as recommended in AWS security best practices
- **Anyone can access any user's data** - Violates AWS principle of least privilege access
- **Financial data publicly accessible** - Critical compliance violation against AWS security guidelines
- **No admin role validation** - Missing role-based access controls

*Reference: [AWS API Gateway Security Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/security-best-practices.html) - AWS recommends implementing least privilege access, controlling API access through IAM policies, Lambda authorizers, IAM tags, VPC endpoint policies, and Amazon Cognito user pools.*

#### 🛡️ Data Security (20+ issues)
**Violates AWS DynamoDB Security Best Practices:**
- **No encryption at rest or in transit** - AWS DynamoDB security best practices emphasize both preventative and detective security measures including encryption
- **Payment card data in plain text logs** - Severe PCI DSS compliance violation and AWS logging security failure
- **No PCI DSS compliance measures** - Missing required financial data protection controls
- **Financial data mixed with user data** - Violates AWS data classification and separation principles
- **No data masking or field filtering** - Exposes sensitive information unnecessarily

*Reference: [AWS DynamoDB Security Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices-security.html) - AWS provides comprehensive security features and recommends implementing both preventative and detective security measures for DynamoDB workloads.*

#### ⚡ Infrastructure Misconfigurations (25+ issues)
**Violates AWS DynamoDB Best Practices:**
- **DynamoDB throttling (5 RCU/WCU on users table)** - Insufficient capacity planning against AWS best practices for workload distribution
- **Over-provisioned transactions table (100 RCU/50 WCU)** - Cost inefficient resource allocation violating AWS cost optimization principles
- **Mixed billing modes across tables** - Inconsistent capacity management strategy across business domains
- **No auto-scaling policies** - Missing dynamic capacity adjustment recommended by AWS
- **Inconsistent log retention (1 day to 7 years)** - Poor operational governance and compliance management

*Reference: [AWS DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html) - AWS recommends optimizing DynamoDB workloads with proper partition key design, capacity planning, and consistent configuration across tables.*

#### 🔧 Application Security (20+ issues)
**Violates AWS Lambda Best Practices:**
- **No input validation anywhere** - Missing request validation mechanisms recommended by AWS
- **Generic error handling exposing internals** - Security information disclosure violating AWS security guidelines
- **No retry logic or circuit breakers** - Poor resilience patterns against AWS Lambda best practices
- **Cross-table access without validation** - Overly broad data access violating principle of least privilege
- **No fraud detection on payments** - Missing financial security controls for payment processing

*Reference: [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html) - AWS recommends initializing SDK clients outside handlers, using environment variables for configuration, implementing proper error handling, avoiding recursive invocations, and following security best practices including restrictive IAM permissions.*

#### 📊 Monitoring & Observability (15+ issues)
**Violates AWS CloudWatch and Security Best Practices:**
- **No CloudWatch alarms** - Missing proactive monitoring recommended by AWS security best practices
- **No X-Ray tracing** - Lack of distributed tracing for debugging and performance monitoring
- **No custom metrics** - Missing business-specific monitoring and operational insights
- **No audit logging for financial access** - Compliance and security gap violating AWS audit requirements
- **No performance monitoring** - Missing operational insights and performance optimization

*Reference: [AWS API Gateway Security Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/security-best-practices.html) - AWS recommends implementing CloudWatch alarms for monitoring metrics over time, enabling AWS CloudTrail for audit logging, and using AWS Config for compliance validation and resource monitoring.*

#### 🚀 CI/CD Security (10+ issues)
**Violates AWS Security and Deployment Best Practices:**
- **Auto-approve deployments** - Missing human review for critical changes violating AWS security practices
- **No security scanning** - Missing vulnerability assessment in deployment pipeline
- **No dependency checks** - Potential supply chain vulnerabilities in Lambda functions
- **All functions in single package** - Poor separation of concerns violating AWS Lambda best practices
- **No rollback mechanisms** - Missing deployment safety measures and error recovery

*Reference: [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html) - AWS recommends proper function packaging, security scanning, dependency management, and implementing deployment safety measures including rollback capabilities for production workloads.*

### Enterprise Complexity Factors
- **Cross-Domain Data Access**: User functions can access financial data - violates AWS principle of least privilege
- **Inconsistent Resource Allocation**: Memory ranges from 128MB to 3GB - poor resource optimization against AWS cost guidelines
- **Mixed Security Postures**: Some tables provisioned, others on-demand - inconsistent governance violating AWS operational excellence
- **Financial Compliance Gaps**: No SOX, PCI, or GDPR controls - regulatory violations against AWS compliance frameworks
- **Operational Inconsistencies**: Timeout ranges from 15s to 180s - poor standardization violating AWS operational best practices

### AWS Well-Architected Framework Violations

This demo violates multiple pillars of the AWS Well-Architected Framework based on official AWS documentation:

#### Security Pillar
- **Identity and Access Management**: No authentication or authorization mechanisms
- **Detective Controls**: Missing logging, monitoring, and audit capabilities
- **Data Protection**: No encryption, data classification, or protection measures
- **Incident Response**: No security event handling or response procedures

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

### AWS MCP Server Configuration

To analyze this demo with AWS MCP servers, configure your MCP client with:

```json
{
  "mcpServers": {
    "aws-docs": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    },
    "aws-pricing": {
      "command": "uvx", 
      "args": ["awslabs.aws-pricing-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    },
    "aws-diagrams": {
      "command": "uvx",
      "args": ["awslabs.aws-diagram-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    }
  }
}
```

### Purpose
Designed to demonstrate AWS Security Frontier Agent's capabilities in:
1. **Detecting** complex, enterprise-scale security vulnerabilities using AWS MCP documentation
2. **Analyzing** cross-domain security issues and data flows with architectural diagrams
3. **Prioritizing** fixes based on business impact and compliance requirements from AWS best practices
4. **Recommending** comprehensive security architecture improvements backed by official AWS documentation
5. **Identifying** financial and regulatory compliance gaps using AWS compliance guidelines
6. **Cost-optimizing** security improvements using AWS pricing analysis

### Getting Started

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

### Security Analysis Workflow

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

This represents a realistic enterprise scenario where rapid feature development has created a security and operational nightmare requiring systematic remediation using AWS security best practices and official documentation.
