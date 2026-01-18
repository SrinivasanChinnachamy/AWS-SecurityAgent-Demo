import boto3
import json
import os
import logging

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ISSUE: No retry configuration - this will cause throttling errors
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def lambda_handler(event, context):
    # Log the incoming request
    logger.info(f"Processing get product request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        products_table_name = os.environ['PRODUCTS_TABLE']
        products_table = dynamodb.Table(products_table_name)
        
        # Extract productId from path parameters
        product_id = event['pathParameters']['productId']
        logger.info(f"Looking up product: {product_id}")
        
        # ISSUE: No input validation on productId
        # ISSUE: No exponential backoff for DynamoDB throttling
        response = products_table.get_item(
            Key={'productId': product_id}
        )
        
        product_data = response.get('Item', {})
        
        if product_data:
            logger.info(f"Product found: {product_id}")
            
            # ISSUE: Returns all product data including internal fields
            # ISSUE: Exposes cost, margin, supplier information
            # ISSUE: No field filtering for public vs admin views
            
        else:
            logger.info(f"Product not found: {product_id}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps({
                'product': product_data,
                'productId': product_id
            }, default=str)
        }
        
    except KeyError as e:
        # ISSUE: Doesn't handle missing productId gracefully
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
        logger.error(f"Error retrieving product: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during product lookup")
        
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
# ISSUE: No caching mechanism for frequently accessed products
# ISSUE: No inventory status check
# ISSUE: No price calculation based on user type
# ISSUE: No view tracking for analytics
# ISSUE: Exposes sensitive business data (costs, margins, supplier info)