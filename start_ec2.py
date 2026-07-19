import os
import boto3


def lambda_handler(event=None, context=None):
    instance_id = (event or {}).get("instance_id") or os.environ.get("EC2_INSTANCE_ID")
    if not instance_id:
        raise ValueError("EC2_INSTANCE_ID environment variable is not set")

    ec2 = boto3.client("ec2")
    response = ec2.start_instances(InstanceIds=[instance_id])

    print(f"Starting EC2 instance {instance_id}")
    return {
        "statusCode": 200,
        "body": f"Started EC2 instance {instance_id}",
        "response": response,
    }


if __name__ == "__main__":
    lambda_handler()