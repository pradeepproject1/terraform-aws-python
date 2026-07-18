import os
import subprocess
import boto3


def get_instance_id():
    terraform_dir = os.path.dirname(os.path.abspath(__file__))
    result = subprocess.run(
        ["terraform", "output", "-raw", "instance_id"],
        cwd=terraform_dir,
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


instance_id = get_instance_id()
ec2 = boto3.client("ec2")

response = ec2.stop_instances(InstanceIds=[instance_id])

print("Stopping EC2...")
print(response)