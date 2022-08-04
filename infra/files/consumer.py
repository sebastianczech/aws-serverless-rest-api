import json
import boto3


print('Loading function')
sns = boto3.client('sns')
topic_url = "${topic_url}"


def lambda_handler(event, context):
    for record in event['Records']:
        payload = record["body"]
        print("Received SQS message: " + str(payload))

        subject = "Message from SQS"

        response = sns.publish(
            TopicArn=topic_url,
            Message=str(payload),
            Subject=subject,
        )

        print("Send SNS event: " + response['MessageId'])
