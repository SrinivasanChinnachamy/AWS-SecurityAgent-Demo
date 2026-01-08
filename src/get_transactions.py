import boto3
import json
import os
import logging
from decimal import Decimal
from datetime import datetime, timedelta

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ISSUE: No retry configuration - this will cause throttling errors
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def lambda_handler(event, context):
    # Log the incoming request
    logger.info(f"Processing get transactions request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        transactions_table_name = os.environ['TRANSACTIONS_TABLE']
        transactions_table = dynamodb.Table(transactions_table_name)
        
        # ISSUE: No authentication - anyone can access all financial transactions
        # ISSUE: No authorization - no admin role validation
        # ISSUE: No audit logging for sensitive financial data access
        
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        
        # ISSUE: No input validation on query parameters
        user_id = query_params.get('userId')  # ISSUE: No user validation
        start_date = query_params.get('startDate')  # ISSUE: No date format validation
        end_date = query_params.get('endDate')    # ISSUE: No date range validation
        limit = query_params.get('limit', 1000)   # ISSUE: Very high default limit
        
        logger.info(f"Querying transactions with filters: userId={user_id}, startDate={start_date}, endDate={end_date}")
        
        if user_id:
            # ISSUE: Uses GSI on financial data without proper access controls
            # ISSUE: No exponential backoff for GSI throttling on financial data
            query_kwargs = {
                'IndexName': 'UserTransactionsIndex',
                'KeyConditionExpression': 'userId = :uid',
                'ExpressionAttributeValues': {':uid': user_id},
                'Limit': int(limit) if isinstance(limit, str) and limit.isdigit() else 1000,
                'ScanIndexForward': False  # Most recent first
            }
            
            # Add date range filter if provided
            if start_date and end_date:
                # ISSUE: No date format validation - potential injection
                query_kwargs['KeyConditionExpression'] += ' AND #ts BETWEEN :start AND :end'
                query_kwargs['ExpressionAttributeValues'][':start'] = start_date
                query_kwargs['ExpressionAttributeValues'][':end'] = end_date
                query_kwargs['ExpressionAttributeNames'] = {'#ts': 'timestamp'}
            
            response = transactions_table.query(**query_kwargs)
        else:
            # ISSUE: Full table scan on financial transactions - extremely dangerous
            # ISSUE: Exposes all financial data in the system
            logger.warning("Performing full scan of transactions table - security risk!")
            
            scan_kwargs = {
                'Limit': int(limit) if isinstance(limit, str) and limit.isdigit() else 1000
            }
            
            # ISSUE: Date filtering on scan is inefficient and expensive
            if start_date and end_date:
                scan_kwargs['FilterExpression'] = '#ts BETWEEN :start AND :end'
                scan_kwargs['ExpressionAttributeValues'] = {
                    ':start': start_date,
                    ':end': end_date
                }
                scan_kwargs['ExpressionAttributeNames'] = {'#ts': 'timestamp'}
            
            response = transactions_table.scan(**scan_kwargs)
        
        transactions = response.get('Items', [])
        last_evaluated_key = response.get('LastEvaluatedKey')
        
        logger.info(f"Retrieved {len(transactions)} transactions")
        
        # Calculate summary statistics - ISSUE: Exposes business intelligence
        total_amount = sum(Decimal(str(t.get('amount', 0))) for t in transactions)
        total_fees = sum(Decimal(str(t.get('processingFee', 0))) for t in transactions)
        
        # ISSUE: Returns all transaction data including sensitive financial information
        # ISSUE: No field filtering to hide sensitive data (card info, merchant details)
        # ISSUE: Exposes internal business metrics (fees, processing details)
        result = {
            'transactions': transactions,
            'count': len(transactions),
            'scannedCount': response.get('ScannedCount', 0),  # ISSUE: Exposes internal metrics
            'summary': {
                'totalAmount': total_amount,
                'totalFees': total_fees,
                'averageTransaction': total_amount / len(transactions) if transactions else 0,
                'processingCosts': total_fees  # ISSUE: Exposes business costs
            },
            'queryInfo': {
                'userId': user_id,
                'dateRange': f"{start_date} to {end_date}" if start_date and end_date else "All time",
                'consumedCapacity': response.get('ConsumedCapacity', {})  # ISSUE: Leaks capacity info
            }
        }
        
        if last_evaluated_key:
            result['lastKey'] = last_evaluated_key
            result['hasMore'] = True
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS for financial data
            },
            'body': json.dumps(result, default=decimal_default)
        }
        
    except Exception as e:
        # ISSUE: Generic exception handling for financial data access
        logger.error(f"Error retrieving transactions: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during financial data access")
        
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
# ISSUE: No data masking for sensitive financial information
# ISSUE: No compliance controls (SOX, PCI DSS, GDPR)
# ISSUE: No audit logging for financial data access
# ISSUE: No rate limiting for expensive financial queries
# ISSUE: No admin-only access controls
# ISSUE: Exposes all business financial metrics
# ISSUE: No data retention policies for financial records
# ISSUE: No encryption of financial data in transit/rest
# ISSUE: Violates financial data privacy regulations