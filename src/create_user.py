import boto3
import json
import os
import logging
import uuid
from datetime import datetime

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ISSUE: No retry configuration - this will cause throttling errors
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def lambda_handler(event, context):
    # Log the incoming request
    logger.info(f"Processing create user request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        table_name = os.environ['TABLE_NAME']
        table = dynamodb.Table(table_name)
        
        # ISSUE: No input validation on request body
        # ISSUE: No JSON schema validation
        body = json.loads(event.get('body', '{}'))
        
        # ISSUE: No required field validation
        # ISSUE: No email format validation
        # ISSUE: No duplicate user check before creation
        user_data = {
            'userId': str(uuid.uuid4()),  # ISSUE: Predictable UUID generation
            'name': body.get('name', ''),
            'email': body.get('email', ''),
            'createdAt': datetime.utcnow().isoformat(),
            'status': 'active'
        }
        
        logger.info(f"Creating user: {user_data['userId']}")
        
        # ISSUE: No exponential backoff for DynamoDB throttling
        # ISSUE: No conditional put to prevent overwrites
        # ISSUE: No transaction support for data consistency
        response = table.put_item(Item=user_data)
        
        logger.info(f"User created successfully: {user_data['userId']}")
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps({
                'message': 'User created successfully',
                'userId': user_data['userId'],
                'user': user_data
            }, default=str)
        }
        
    except json.JSONDecodeError as e:
        # ISSUE: Exposes internal error details
        logger.error(f"Invalid JSON in request body: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Invalid JSON format',
                'details': str(e)  # ISSUE: Leaks internal error information
            })
        }
        
    except Exception as e:
        # ISSUE: Generic exception handling - doesn't distinguish throttling
        logger.error(f"Error creating user: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during user creation")
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'requestId': context.aws_request_id,
                'details': str(e)  # ISSUE: Exposes internal error details
            })
        }

# ISSUE: No connection pooling
# ISSUE: No caching mechanism
# ISSUE: No rate limiting per user
# ISSUE: No audit logging for user creation
# ISSUE: No data encryption before storage