import subprocess
import boto3
import base64
import json
import os

AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
APP_NAME   = os.environ.get("APP_NAME", "flask-app")
IMAGE_TAG  = os.environ.get("IMAGE_TAG", "latest")

def get_ecr_url():
    tf = subprocess.run(
        ["terraform", "output", "-json"],
        capture_output=True, text=True, check=True,
        cwd=os.path.dirname(os.path.abspath(__file__))
    )
    outputs = json.loads(tf.stdout)
    return outputs["ecr_repository_url"]["value"]

def ecr_login(ecr_url):
    ecr = boto3.client("ecr", region_name=AWS_REGION)
    token = ecr.get_authorization_token()
    auth = token["authorizationData"][0]
    username, password = base64.b64decode(auth["authorizationToken"]).decode().split(":")
    registry = auth["proxyEndpoint"]
    subprocess.run(
        ["docker", "login", "--username", username, "--password-stdin", registry],
        input=password, text=True, check=True
    )
    print("ECR login successful")

def build_and_push(ecr_url):
    image = f"{ecr_url}:{IMAGE_TAG}"
    subprocess.run(["docker", "build", "-t", image, "."], check=True)
    subprocess.run(["docker", "push", image], check=True)
    print(f"Pushed {image}")
    return image

def update_kubeconfig(cluster_name):
    subprocess.run(
        ["aws", "eks", "update-kubeconfig", "--region", AWS_REGION, "--name", cluster_name],
        check=True
    )
    print("kubeconfig updated")

def deploy_to_k8s(image):
    # Patch deployment.yaml with actual ECR image
    with open("deployment.yaml") as f:
        manifest = f.read().replace("PLACEHOLDER_ECR_URL:latest", image)
    with open("deployment.yaml", "w") as f:
        f.write(manifest)

    subprocess.run(["kubectl", "apply", "-f", "deployment.yaml"], check=True)
    subprocess.run(["kubectl", "apply", "-f", "service.yaml"], check=True)
    print("Kubernetes manifests applied")

def get_cluster_name():
    tf = subprocess.run(
        ["terraform", "output", "-json"],
        capture_output=True, text=True, check=True,
        cwd=os.path.dirname(os.path.abspath(__file__))
    )
    outputs = json.loads(tf.stdout)
    return outputs["eks_cluster_name"]["value"]

if __name__ == "__main__":
    ecr_url      = get_ecr_url()
    cluster_name = get_cluster_name()

    ecr_login(ecr_url)
    image = build_and_push(ecr_url)
    update_kubeconfig(cluster_name)
    deploy_to_k8s(image)

    print("\nDeployment complete!")
    print("Run: kubectl get svc flask-app-service  (to get the LoadBalancer URL)")
