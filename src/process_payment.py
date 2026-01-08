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
    logger.info(f"Processing payment request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table names from environment
        orders_table_name = os.environ['ORDERS_TABLE']
        transactions_table_name = os.environ['TRANSACTIONS_TABLE']
        
        orders_table = dynamodb.Table(orders_table_name)
        transactions_table = dynamodb.Table(transactions_table_name)
        
        # Extract orderId from path parameters
        order_id = event['pathParameters']['orderId']
        
        # ISSUE: No input validation on request body
        # ISSUE: No JSON schema validation for payment data
        body = json.loads(event.get('body', '{}'))
        
        # ISSUE: Payment data handled in plain text
        # ISSUE: No PCI compliance measures
        payment_method = body.get('paymentMethod')  # ISSUE: No validation
        card_number = body.get('cardNumber')        # ISSUE: Stored in logs!
        cvv = body.get('cvv')                      # ISSUE: Extremely sensitive data
        expiry_date = body.get('expiryDate')       # ISSUE: No format validation
        
        logger.info(f"Processing payment for order: {order_id}")
        # ISSUE: Logs potentially contain sensitive payment data
        logger.info(f"Payment method: {payment_method}")
        
        # Get order details
        # ISSUE: No order ownership validation
        # ISSUE: Anyone can process payment for any order
        order_response = orders_table.get_item(
            Key={'orderId': order_id, 'userId': body.get('userId', 'unknown')}
        )
        
        order = order_response.get('Item', {})
        if not order:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Order not found'})
            }
        
        # ISSUE: No order status validation (could pay for cancelled orders)
        # ISSUE: No duplicate payment prevention
        # ISSUE: No amount validation against order total
        
        order_amount = order.get('totalAmount', Decimal('0'))
        payment_amount = Decimal(str(body.get('amount', '0')))
        
        # ISSUE: No fraud detection
        # ISSUE: No payment gateway integration
        # ISSUE: Simulated payment processing without security
        
        # Create transaction record
        transaction_id = str(uuid.uuid4())
        transaction_data = {
            'transactionId': transaction_id,
            'orderId': order_id,
            'userId': order.get('userId'),
            'amount': payment_amount,
            'paymentMethod': payment_method,
            'cardLast4': card_number[-4:] if card_number else '',  # ISSUE: Still processing card data
            'status': 'completed',  # ISSUE: Always successful - no real validation
            'timestamp': datetime.utcnow().isoformat(),
            'processingFee': payment_amount * Decimal('0.029'),  # ISSUE: Exposes business logic
            'merchantId': 'DEMO_MERCHANT_123',  # ISSUE: Hardcoded sensitive data
            'gatewayResponse': 'APPROVED_SIMULATION'  # ISSUE: Fake processing
        }
        
        # ISSUE: No transaction atomicity - could fail partially
        # ISSUE: No exponential backoff for DynamoDB throttling
        transactions_table.put_item(Item=transaction_data)
        
        # Update order status
        orders_table.update_item(
            Key={'orderId': order_id, 'userId': order.get('userId')},
            UpdateExpression='SET orderStatus = :status, updatedAt = :updated, paymentId = :payment',
            ExpressionAttributeValues={
                ':status': 'paid',
                ':updated': datetime.utcnow().isoformat(),
                ':payment': transaction_id
            }
        )
        
        logger.info(f"Payment processed successfully: {transaction_id}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps({
                'message': 'Payment processed successfully',
                'transactionId': transaction_id,
                'orderId': order_id,
                'amount': payment_amount,
                'status': 'completed',
                'transaction': transaction_data  # ISSUE: Returns sensitive transaction data
            }, default=decimal_default)
        }
        
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in request body: {str(e)}")
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'Invalid JSON format',
                'details': str(e)  # ISSUE: Leaks internal error information
            })
        }
        
    except Exception as e:
        # ISSUE: Generic exception handling for financial operations
        logger.error(f"Error processing payment: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during payment processing")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Payment processing failed',
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
# ISSUE: No PCI DSS compliance
# ISSUE: No encryption of sensitive payment data
# ISSUE: No secure payment gateway integration
# ISSUE: No fraud detection algorithms
# ISSUE: No payment retry mechanisms
# ISSUE: No refund capabilities
# ISSUE: No audit trail for financial transactions
# ISSUE: No regulatory compliance (SOX, PCI, etc.)
# ISSUE: Logs contain sensitive payment information