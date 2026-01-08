import boto3
import json
import os
import logging
import uuid
from datetime import datetime
from decimal import Decimal

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ISSUE: No retry configuration - this will cause throttling errors
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def lambda_handler(event, context):
    # Log the incoming request
    logger.info(f"Processing create order request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table names from environment
        orders_table_name = os.environ['ORDERS_TABLE']
        products_table_name = os.environ['PRODUCTS_TABLE']
        users_table_name = os.environ['USERS_TABLE']
        
        orders_table = dynamodb.Table(orders_table_name)
        products_table = dynamodb.Table(products_table_name)
        users_table = dynamodb.Table(users_table_name)
        
        # ISSUE: No input validation on request body
        body = json.loads(event.get('body', '{}'))
        
        # ISSUE: No required field validation
        user_id = body.get('userId')
        items = body.get('items', [])  # ISSUE: No validation of items structure
        
        if not user_id or not items:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing required fields: userId and items'})
            }
        
        # ISSUE: No user existence validation
        # ISSUE: No authentication - anyone can create orders for any user
        logger.info(f"Creating order for user: {user_id}")
        
        # Calculate order total - ISSUE: No inventory check
        total_amount = Decimal('0')
        order_items = []
        
        for item in items:
            product_id = item.get('productId')
            quantity = item.get('quantity', 1)
            
            # ISSUE: No product existence validation
            # ISSUE: No stock availability check
            # ISSUE: Potential race condition on inventory
            try:
                product_response = products_table.get_item(Key={'productId': product_id})
                product = product_response.get('Item', {})
                
                if not product:
                    logger.warning(f"Product not found: {product_id}")
                    continue  # ISSUE: Silently skips invalid products
                
                price = product.get('price', Decimal('0'))
                item_total = price * Decimal(str(quantity))
                total_amount += item_total
                
                order_items.append({
                    'productId': product_id,
                    'productName': product.get('name', ''),
                    'quantity': quantity,
                    'unitPrice': price,
                    'totalPrice': item_total
                })
                
            except Exception as e:
                logger.error(f"Error processing item {product_id}: {str(e)}")
                # ISSUE: Continues processing despite errors
        
        # Create order record
        order_id = str(uuid.uuid4())
        order_data = {
            'orderId': order_id,
            'userId': user_id,
            'items': order_items,
            'totalAmount': total_amount,
            'orderStatus': 'pending',
            'createdAt': datetime.utcnow().isoformat(),
            'updatedAt': datetime.utcnow().isoformat()
        }
        
        # ISSUE: No transaction support - order could be partially created
        # ISSUE: No exponential backoff for DynamoDB throttling
        orders_table.put_item(Item=order_data)
        
        logger.info(f"Order created successfully: {order_id}")
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps({
                'message': 'Order created successfully',
                'orderId': order_id,
                'order': order_data
            }, default=decimal_default)
        }
        
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in request body: {str(e)}")
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Invalid JSON format',
                'details': str(e)  # ISSUE: Leaks internal error information
            })
        }
        
    except Exception as e:
        # ISSUE: Generic exception handling
        logger.error(f"Error creating order: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during order creation")
        
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
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
# ISSUE: No inventory management system integration
# ISSUE: No fraud detection
# ISSUE: No order limits per user
# ISSUE: No duplicate order prevention
# ISSUE: No payment validation before order creation
# ISSUE: No order workflow management