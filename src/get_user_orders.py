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
    logger.info(f"Processing get user orders request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        orders_table_name = os.environ['ORDERS_TABLE']
        orders_table = dynamodb.Table(orders_table_name)
        
        # Extract userId from path parameters
        user_id = event['pathParameters']['userId']
        logger.info(f"Retrieving orders for user: {user_id}")
        
        # ISSUE: No user authentication - anyone can view any user's orders
        # ISSUE: No authorization check - user A can see user B's orders
        
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        status_filter = query_params.get('status')  # ISSUE: No status validation
        limit = query_params.get('limit', 100)
        
        # ISSUE: Uses GSI without proper capacity planning
        # ISSUE: No exponential backoff for GSI throttling
        query_kwargs = {
            'IndexName': 'UserOrdersIndex',
            'KeyConditionExpression': 'userId = :uid',
            'ExpressionAttributeValues': {':uid': user_id},
            'Limit': int(limit) if isinstance(limit, str) and limit.isdigit() else 100,
            'ScanIndexForward': False  # Most recent first
        }
        
        # Add status filter if provided
        if status_filter:
            # ISSUE: No input validation on status filter
            query_kwargs['KeyConditionExpression'] += ' AND orderStatus = :status'
            query_kwargs['ExpressionAttributeValues'][':status'] = status_filter
        
        response = orders_table.query(**query_kwargs)
        
        orders = response.get('Items', [])
        last_evaluated_key = response.get('LastEvaluatedKey')
        
        logger.info(f"Retrieved {len(orders)} orders for user {user_id}")
        
        # ISSUE: Returns all order data including sensitive financial information
        # ISSUE: No field filtering to hide internal order details
        # ISSUE: Exposes payment information, addresses, etc.
        result = {
            'userId': user_id,
            'orders': orders,
            'count': len(orders),
            'scannedCount': response.get('ScannedCount', 0),  # ISSUE: Exposes internal metrics
        }
        
        if last_evaluated_key:
            result['lastKey'] = last_evaluated_key
            result['hasMore'] = True
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps(result, default=decimal_default)
        }
        
    except KeyError as e:
        # ISSUE: Doesn't handle missing userId gracefully
        logger.error(f"Missing required parameter: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Missing required parameter',
                'parameter': str(e)
            })
        }
        
    except Exception as e:
        # ISSUE: Generic exception handling - doesn't distinguish throttling
        logger.error(f"Error retrieving user orders: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during user orders query")
        
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
# ISSUE: No caching mechanism for frequently accessed user orders
# ISSUE: No data masking for sensitive order information
# ISSUE: No user consent tracking for data access
# ISSUE: No audit logging for order data access
# ISSUE: No rate limiting per user
# ISSUE: Violates principle of least privilege - exposes all order details