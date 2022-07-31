from diagrams import Cluster, Diagram
from diagrams.generic.device import Tablet
from diagrams.aws.compute import Lambda
from diagrams.aws.integration import SQS, SNS
from diagrams.aws.storage import S3
from diagrams.aws.database import Dynamodb

with Diagram("Architecture diagram", show=False, direction="LR"):
    user = Tablet("end user's web browser")

    with Cluster("AWS"):
        lambda_producer = Lambda("producer API")
        lambda_consumer = Lambda("consumer API")
        sqq_queue = SQS("message queue")
        s3_storage = S3("object storage")
        dynamo_database = Dynamodb("database")
        sns_notifications = SNS("notification topic")
    
    user >> lambda_producer >> sqq_queue >> lambda_consumer
    lambda_consumer >> dynamo_database
    lambda_consumer >> sns_notifications
    lambda_consumer >> s3_storage
