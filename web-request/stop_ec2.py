import os
import json
import boto3


def lambda_handler(event=None, context=None):
    instance_id = os.environ.get("EC2_INSTANCE_ID")
    if not instance_id:
        return {"statusCode": 400, "body": json.dumps({"error": "EC2_INSTANCE_ID not set"})}

    ec2 = boto3.client("ec2")
    ec2.stop_instances(InstanceIds=[instance_id])

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": f"Stopped EC2 instance {instance_id}"}),
    }
