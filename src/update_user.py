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
    logger.info(f"Processing update user request")
    logger.info(f"Request ID: {context.aws_request_id}")
    
    try:
        # Get table name from environment
        table_name = os.environ['TABLE_NAME']
        table = dynamodb.Table(table_name)
        
        # Extract userId from path parameters
        user_id = event['pathParameters']['userId']
        logger.info(f"Updating user: {user_id}")
        
        # ISSUE: No input validation on request body
        # ISSUE: No JSON schema validation
        body = json.loads(event.get('body', '{}'))
        
        # ISSUE: No field validation for update data
        # ISSUE: No protection against updating system fields
        update_expression = "SET updatedAt = :updated"
        expression_values = {':updated': datetime.utcnow().isoformat()}
        
        # ISSUE: Allows updating any field without validation
        if 'name' in body:
            update_expression += ", #name = :name"
            expression_values[':name'] = body['name']
        
        if 'email' in body:
            update_expression += ", email = :email"
            expression_values[':email'] = body['email']  # ISSUE: No email format validation
        
        if 'status' in body:
            update_expression += ", #status = :status"
            expression_values[':status'] = body['status']  # ISSUE: No status validation
        
        # ISSUE: No optimistic locking with version numbers
        # ISSUE: No conditional update to check if user exists
        # ISSUE: No exponential backoff for DynamoDB throttling
        response = table.update_item(
            Key={'userId': user_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_values,
            ExpressionAttributeNames={
                '#name': 'name',
                '#status': 'status'
            },
            ReturnValues='ALL_NEW'
        )
        
        updated_user = response.get('Attributes', {})
        logger.info(f"User updated successfully: {user_id}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # ISSUE: Overly permissive CORS
            },
            'body': json.dumps({
                'message': 'User updated successfully',
                'user': updated_user
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
        logger.error(f"Error updating user: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Request ID: {context.aws_request_id}")
        
        # Log additional context for analysis
        if "ProvisionedThroughputExceededException" in str(e):
            logger.error("DynamoDB throttling detected during user update")
        elif "ConditionalCheckFailedException" in str(e):
            logger.error("User not found or condition failed")
        
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
# ISSUE: No caching mechanism for frequently updated users
# ISSUE: No audit trail for user modifications
# ISSUE: No rollback capability for failed updates
# ISSUE: No field-level permissions (anyone can update any field)