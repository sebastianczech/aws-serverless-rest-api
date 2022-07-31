from diagrams import Cluster, Diagram
from diagrams.generic.device import Tablet
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import SQS, SNS
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb
from diagrams.programming.language import Python

with Diagram("Architecture diagram", show=False, direction="LR"):
    user = Tablet("end user's web browser")

    with Cluster("AWS"):
        lambda_producer = Lambda("producer API")
        lambda_consumer = Lambda("consumer API")
        sqs_queue = SQS("message queue")
        s3_storage = S3("object storage")
        dynamo_database = Dynamodb("database")
        sns_notifications = SNS("notification topic")

    with Cluster("Localstack"):
        python_producer = Python("producer API")
        python_consumer = Python("consumer API")
        local_sqs_queue = SQS("message queue")
        local_s3_storage = S3("object storage")
        local_dynamo_database = Dynamodb("database")
        local_sns_notifications = SNS("notification topic")        
    
    user >> lambda_producer >> sqs_queue >> lambda_consumer
    lambda_consumer >> dynamo_database
    lambda_consumer >> sns_notifications
    lambda_consumer >> s3_storage

    user >> python_producer >> local_sqs_queue >> python_consumer
    python_consumer >> local_dynamo_database
    python_consumer >> local_sns_notifications
    python_consumer >> local_s3_storage
