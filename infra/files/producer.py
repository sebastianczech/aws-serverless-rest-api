import json
import urllib.parse
import boto3


# Function based on documentation:
# https://boto3.amazonaws.com/v1/documentation/api/latest/guide/sqs-example-sending-receiving-msgs.html


print('Loading function')
sqs = boto3.client('sqs')
queue_url = 'https://sqs.us-east-1.amazonaws.com/884522662008/cloud_sqs_serverless_rest_api'


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))

    response = sqs.send_message(
        QueueUrl=queue_url,
        DelaySeconds=10,
        MessageAttributes={
            'Title': {
                'DataType': 'String',
                'StringValue': 'The Whistler'
            },
            'Author': {
                'DataType': 'String',
                'StringValue': 'John Grisham'
            },
            'WeeksOn': {
                'DataType': 'Number',
                'StringValue': '6'
            }
        },
        MessageBody=(
            'Information about current NY Times fiction bestseller for '
            'week of 12/11/2016.'
        )
    )

    print(response['MessageId'])
