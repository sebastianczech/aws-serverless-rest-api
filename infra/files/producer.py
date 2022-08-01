import json
import urllib.parse
import boto3


# Function based on documentation:
# https://boto3.amazonaws.com/v1/documentation/api/latest/guide/sqs-example-sending-receiving-msgs.html


print('Loading function')
sqs = boto3.client('sqs')
# queue_url = 'https://sqs.us-east-1.amazonaws.com/884522662008/cloud_sqs_serverless_rest_api'
queue_url = "${queue_url}"


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    response = sqs.send_message(
        QueueUrl=queue_url,
        DelaySeconds=10,
        MessageAttributes={
            'Deployment': {
                'DataType': 'String',
                'StringValue': 'Terraform'
            },
            'Language': {
                'DataType': 'String',
                'StringValue': 'Python'
            },
            'Version': {
                'DataType': 'Number',
                'StringValue': '1'
            },
            'ARN': {
                'DataType': 'String',
                'StringValue': context.invoked_function_arn
            },
            'RequestID': {
                'DataType': 'String',
                'StringValue': context.aws_request_id
            },
            'Message': {
                'DataType': 'String',
                'StringValue': event['body']['message'] if 'body' in event and 'message' in event['body'] else 'Empty message'
            },
        },
        MessageBody=(
            'Information created by Lambda producer implemented in Python and deployed by Terraform.'
        )
    )

    print("Received SQS response: " + response['MessageId'])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "RequestID ": context.aws_request_id,
            "ReceivedMessage": event['body']['message'] if 'body' in event and 'message' in event['body'] else 'Empty message'
        })
    }
