import os
import boto3


def lambda_handler(event=None, context=None):
    instance_id = os.environ.get("EC2_INSTANCE_ID")
    if not instance_id:
        raise ValueError("EC2_INSTANCE_ID environment variable is not set")

    ec2 = boto3.client("ec2")

    state = ec2.describe_instances(InstanceIds=[instance_id])["Reservations"][0]["Instances"][0]["State"]["Name"]
    if state != "stopped":
        print(f"Instance {instance_id} is already in '{state}' state, skipping start.")
        return {"statusCode": 200, "body": f"Instance {instance_id} already {state}"}

    response = ec2.start_instances(InstanceIds=[instance_id])
    print(f"Starting EC2 instance {instance_id}")
    return {
        "statusCode": 200,
        "body": f"Started EC2 instance {instance_id}",
        "response": response,
    }


if __name__ == "__main__":
    lambda_handler()