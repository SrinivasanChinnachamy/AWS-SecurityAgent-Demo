import boto3
import json
import os
import logging
from decimal import Decimal

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ISSUE: No retry configuration - this will cause throttling errors
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def lambda_handler(event, context):
    # Log the incoming request
    logger.info(f"Processing list users request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        table_name = os.environ['TABLE_NAME']
        table = dynamodb.Table(table_name)
        
        # ISSUE: No pagination parameters validation
        # ISSUE: No result size limits - could return entire table
        query_params = event.get('queryStringParameters') or {}
        
        # ISSUE: No input validation on query parameters
        limit = query_params.get('limit', 1000)  # ISSUE: Default limit too high
        
        # ISSUE: Performs full table scan - extremely inefficient and expensive
        # ISSUE: No exponential backoff for DynamoDB throttling
        # ISSUE: No filtering options to reduce data transfer
        scan_kwargs = {
            'Limit': int(limit) if isinstance(limit, str) and limit.isdigit() else 1000
        }
        
        # Handle pagination token if provided
        if 'lastKey' in query_params:
            # ISSUE: No validation of lastKey format
            # ISSUE: Potential injection if lastKey is manipulated
            try:
                last_key = json.loads(query_params['lastKey'])
                scan_kwargs['ExclusiveStartKey'] = last_key
            except json.JSONDecodeError:
                logger.warning("Invalid lastKey format, ignoring pagination")
        
        logger.info(f"Scanning table with limit: {scan_kwargs['Limit']}")
        
        # ISSUE: Full table scan will consume massive read capacity
        # ISSUE: No circuit breaker for expensive operations
        response = table.scan(**scan_kwargs)
        
        users = response.get('Items', [])
        last_evaluated_key = response.get('LastEvaluatedKey')
        
        logger.info(f"Retrieved {len(users)} users")
        
        # ISSUE: Returns all user data including potentially sensitive information
        # ISSUE: No field filtering to reduce response size
        result = {
            'users': users,
            'count': len(users),
            'scannedCount': response.get('ScannedCount', 0),  # ISSUE: Exposes internal metrics
        }
        
        if last_evaluated_key:
            # ISSUE: Exposes internal DynamoDB key structure
            result['lastKey'] = last_evaluated_key
            result['hasMore'] = True
        else:
            result['hasMore'] = False
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps(result, default=decimal_default)
        }
        
    except ValueError as e:
        # ISSUE: Exposes internal error details
        logger.error(f"Invalid parameter value: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Invalid parameter value',
                'details': str(e)  # ISSUE: Leaks internal error information
            })
        }
        
    except Exception as e:
        # ISSUE: Generic exception handling - doesn't distinguish throttling
        logger.error(f"Error listing users: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during user listing - scan operation too expensive")
        
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

def decimal_default(obj):
    """JSON serializer for DynamoDB Decimal types"""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

# ISSUE: No connection pooling
# ISSUE: No caching mechanism for frequently accessed user lists
# ISSUE: No search/filter capabilities
# ISSUE: No sorting options
# ISSUE: No field selection to reduce response size
# ISSUE: No rate limiting for expensive scan operations
# ISSUE: No admin-only permissions for listing all users
# ISSUE: No data masking for sensitive fields in list view