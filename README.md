# Flask App on EKS

A simple Python Flask app containerized with Docker and deployed to AWS EKS using Kubernetes.

## Project Structure
```
docker-kube-eks/
├── app.py              # Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Docker image definition
├── deployment.yaml     # Kubernetes deployment manifest
├── service.yaml        # Kubernetes service manifest
└── README.md
```

## Prerequisites
- Docker
- kubectl
- eksctl
- AWS CLI (configured)

## Run Locally
```bash
docker build -t flask-app .
docker run -p 5000:5000 flask-app
# Visit http://localhost:5000
```

## Deploy to EKS
```bash
# Push image to ECR
aws ecr create-repository --repository-name flask-app --region us-east-1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com
docker tag flask-app:latest <account_id>.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
docker push <account_id>.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest

# Create EKS cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.medium --nodes 2

# Deploy
aws eks update-kubeconfig --name my-cluster --region us-east-1
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

## Cleanup
```bash
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
eksctl delete cluster --name my-cluster --region us-east-1
aws ecr delete-repository --repository-name flask-app --region us-east-1 --force
```

## Endpoints
| Endpoint | Response |
|---|---|
| `/` | `{"message": "Hello from EKS!", "status": "running"}` |
| `/health` | `{"status": "healthy"}` |
