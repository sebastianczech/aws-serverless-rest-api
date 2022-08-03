def lambda_handler(event, context):
    for record in event['Records']:
        payload = record["body"]
        print("Received SQS message: " + str(payload))