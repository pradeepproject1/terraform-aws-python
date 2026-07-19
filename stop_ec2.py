import os
import boto3


def lambda_handler(event=None, context=None):
    instance_id = os.environ.get("EC2_INSTANCE_ID")
    if not instance_id:
        raise ValueError("EC2_INSTANCE_ID environment variable is not set")

    ec2 = boto3.client("ec2")

    state = ec2.describe_instances(InstanceIds=[instance_id])["Reservations"][0]["Instances"][0]["State"]["Name"]
    if state != "running":
        print(f"Instance {instance_id} is already in '{state}' state, skipping stop.")
        return {"statusCode": 200, "body": f"Instance {instance_id} already {state}"}

    response = ec2.stop_instances(InstanceIds=[instance_id])
    print(f"Stopping EC2 instance {instance_id}")
    return {
        "statusCode": 200,
        "body": f"Stopped EC2 instance {instance_id}",
        "response": response,
    }


if __name__ == "__main__":
    lambda_handler()