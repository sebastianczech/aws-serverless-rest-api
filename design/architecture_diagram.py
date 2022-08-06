from diagrams import Cluster, Diagram
from diagrams.generic.device import Tablet
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import SQS, SNS
from diagrams.aws.storage import S3
from diagrams.aws.management import Cloudwatch
from diagrams.aws.database import Dynamodb
from diagrams.programming.language import Python

with Diagram("Architecture diagram", show=False, direction="LR"):
    user = Tablet("end user's web browser")

    with Cluster("AWS"):
        lambda_producer = Lambda("producer API")
        lambda_consumer = Lambda("consumer API")
        sqs_queue = SQS("message queue")
        dynamo_database = Dynamodb("database")
        sns_notifications = SNS("notification topic")
        cloud_watch_logs = Cloudwatch("logs")

    with Cluster("Localstack"):
        python_app = Python("boto3 client")
        local_sqs_queue = SQS("message queue")
        local_s3_storage = S3("object storage")
        local_sns_notifications = SNS("notification topic")
        local_dynamo_database = Dynamodb("database")

    user >> lambda_producer >> sqs_queue >> lambda_consumer
    lambda_consumer >> dynamo_database
    lambda_consumer >> sns_notifications
    lambda_producer >> cloud_watch_logs
    lambda_consumer >> cloud_watch_logs

    user >> python_app 
    python_app >> local_sqs_queue
    python_app >> local_dynamo_database
    python_app >> local_sns_notifications
    python_app >> local_s3_storage
