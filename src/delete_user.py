import boto3
import json
import os
import logging
from datetime import datetime

# Configure logging for CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ISSUE: No retry configuration - this will cause throttling errors
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def lambda_handler(event, context):
    # Log the incoming request
    logger.info(f"Processing delete user request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        table_name = os.environ['TABLE_NAME']
        table = dynamodb.Table(table_name)
        
        # Extract userId from path parameters
        user_id = event['pathParameters']['userId']
        logger.info(f"Deleting user: {user_id}")
        
        # ISSUE: No soft delete implementation - hard delete only
        # ISSUE: No backup before deletion
        # ISSUE: No confirmation mechanism for destructive operations
        # ISSUE: No check if user exists before deletion
        
        # ISSUE: No exponential backoff for DynamoDB throttling
        # ISSUE: No conditional delete to ensure user exists
        response = table.delete_item(
            Key={'userId': user_id},
            ReturnValues='ALL_OLD'  # Get the deleted item for logging
        )
        
        deleted_user = response.get('Attributes', {})
        
        if deleted_user:
            logger.info(f"User deleted successfully: {user_id}")
            # ISSUE: No audit trail stored in separate audit table
            logger.info(f"Deleted user data: {json.dumps(deleted_user, default=str)}")
        else:
            logger.warning(f"User not found for deletion: {user_id}")
            # ISSUE: Still returns success even if user didn't exist
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps({
                'message': 'User deleted successfully',
                'userId': user_id,
                'deletedUser': deleted_user  # ISSUE: Returns sensitive deleted data
            }, default=str)
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
        logger.error(f"Error deleting user: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during user deletion")
        
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
# ISSUE: No soft delete with status flag
# ISSUE: No data retention policies
# ISSUE: No cascade delete for related data
# ISSUE: No admin-only permissions for delete operations
# ISSUE: No deletion confirmation workflow
# ISSUE: No backup mechanism before deletion
# ISSUE: No GDPR compliance for data deletion requests