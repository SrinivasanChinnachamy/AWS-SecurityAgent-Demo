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
    logger.info(f"Processing list products request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        products_table_name = os.environ['PRODUCTS_TABLE']
        products_table = dynamodb.Table(products_table_name)
        
        # ISSUE: No input validation on query parameters
        query_params = event.get('queryStringParameters') or {}
        
        # ISSUE: No category validation - potential injection
        category = query_params.get('category')
        limit = query_params.get('limit', 500)  # ISSUE: Very high default limit
        
        if category:
            # ISSUE: Uses GSI without proper capacity planning
            # ISSUE: No exponential backoff for GSI throttling
            logger.info(f"Querying products by category: {category}")
            response = products_table.query(
                IndexName='CategoryIndex',
                KeyConditionExpression='category = :cat',
                ExpressionAttributeValues={':cat': category},
                Limit=int(limit) if isinstance(limit, str) and limit.isdigit() else 500
            )
        else:
            # ISSUE: Full table scan on product catalog - extremely expensive
            logger.info(f"Scanning entire product catalog")
            response = products_table.scan(
                Limit=int(limit) if isinstance(limit, str) and limit.isdigit() else 500
            )
        
        products = response.get('Items', [])
        last_evaluated_key = response.get('LastEvaluatedKey')
        
        logger.info(f"Retrieved {len(products)} products")
        
        # ISSUE: Returns all product data including cost/pricing information
        # ISSUE: No field filtering for public API
        result = {
            'products': products,
            'count': len(products),
            'scannedCount': response.get('ScannedCount', 0),  # ISSUE: Exposes internal metrics
            'consumedCapacity': response.get('ConsumedCapacity', {})  # ISSUE: Leaks capacity information
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
        
    except Exception as e:
        # ISSUE: Generic exception handling - doesn't distinguish throttling
        logger.error(f"Error listing products: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected - product catalog scan too expensive")
        
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
# ISSUE: No caching mechanism for product catalog
# ISSUE: No search capabilities
# ISSUE: No inventory status filtering
# ISSUE: No price range filtering
# ISSUE: No admin vs public view differentiation
# ISSUE: Exposes internal product costs and margins